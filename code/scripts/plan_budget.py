#!/usr/bin/env python3
"""Check a manifest against its job script before anyone asks for approval.

Reads the request from the #PBS lines and the runs from the manifest, then prints the
core-hours requested, the credits under an assumed charge, the time every run could use and
the memory each case is expected to need. Exit 1 if the runs cannot all start within the
walltime, a case would pass its node's memory request, or a limit is under twice the
estimate. Nothing here is a measurement: estimates only size the request, and the constants
below must be replaced from pilot results before a manifest is frozen.

  plan_budget.py MANIFEST PBS_SCRIPT [--rate R] [--startup-s S] [--runs]

--rate is the assumed credits per core-hour requested. The site's conversion is unconfirmed.
--startup-s is the time expected for gates before the first run.
"""
import argparse
import json
import math
import re
import sys

from run_manifest import GRACE_S, expand

# Kernel core-microseconds per particle per step at N = 1e6. Job 1519638 gave 22 (nvc++, 36
# threads); job 1514458 gave 22 at N = 5e4 where nvc++ gave about 15 near that size, so GCC
# is about 1.4 times slower; rounded up to 35 for lost parallel efficiency.
KERNEL_US = 35.0
# Tree build on one thread, microseconds per particle per step at N = 1e6 (job 1519638),
# doubled for ranks sharing memory bandwidth.
BUILD_US = 0.123 * 2
# Allgatherv: 24 bytes per particle into every rank of a node over an assumed 10 GB/s per
# node. Close to job 1514458 (9.5 ms per step at N = 5e4), which also includes waiting.
NODE_BYTES_PER_S = 10e9
# Setup, microseconds per particle: rounded up from job 1514458 (0.09 s at N = 5e4).
SETUP_US = 2.0
# Peak RSS per rank in MiB: local Docker, artifacts/local/memory_probe_20261104.txt, with 30%
# for the higher baseline seen on Vanda (26.8 against 20.0 MiB at N = 5e4).
RSS_BASE_MIB, RSS_PER_MILLION_MIB, RSS_MARGIN = 17.0, 136.4, 1.3
# Gate time after the runner's deadline: see jobs/vanda/gates.sh and measure.sh.
END_RESERVE_S, GATE_GRACE_S, SNAPSHOT_NODE_S, CLEANUP_NODE_S, ANALYZE_LIMIT_S = 60, 20, 12, 40, 120


def request(path):
    text = open(path).read()
    m = re.search(r"^#PBS -l select=(\d+):ncpus=(\d+):mpiprocs=\d+:mem=(\d+)gb", text, re.M)
    w = re.search(r"^#PBS -l walltime=(\d+):(\d+):(\d+)", text, re.M)
    if not m or not w:
        sys.exit(f"{path}: no select or walltime line")
    h, mi, s = map(int, w.groups())
    return int(m[1]), int(m[2]), int(m[3]), h * 3600 + mi * 60 + s


def estimate_s(p):
    n = p["n"]
    if p["program"] == "validate":
        return 60.0
    kernel = KERNEL_US * (1 + 0.23 * math.log10(n / 1e6)) * 1e-6 * n
    build = BUILD_US * (n / 1e6) ** 0.3 * 1e-6 * n
    steps = p["steps"] + p["warmup"]
    if p["program"] == "serial":
        return SETUP_US * 1e-6 * n + steps * (kernel + build / 2)
    per_node = p["ranks"] / p.get("nodes", 1)
    exchange = 24 * n * per_node / NODE_BYTES_PER_S if p["ranks"] > 1 else 0.0
    return SETUP_US * 1e-6 * n + steps * (kernel / (p["ranks"] * p["threads"]) + build + exchange)


def node_mem_gb(p):
    per_node = p["ranks"] / p.get("nodes", 1) if p["program"] == "hybrid" else 1
    return per_node * RSS_MARGIN * (RSS_BASE_MIB + RSS_PER_MILLION_MIB * p["n"] / 1e6) / 1024


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("manifest")
    ap.add_argument("pbs")
    ap.add_argument("--rate", type=float, default=0.0)
    ap.add_argument("--startup-s", type=int, default=300)
    ap.add_argument("--runs", action="store_true", help="print every case")
    a = ap.parse_args()
    nodes, cores, mem_gb, walltime = request(a.pbs)
    points = expand(json.load(open(a.manifest)))
    overhead = GATE_GRACE_S + nodes * (SNAPSHOT_NODE_S + 2) + 2 + nodes * (CLEANUP_NODE_S + 5)
    budget = walltime - END_RESERVE_S - 2 * overhead - ANALYZE_LIMIT_S - a.startup_s
    problems, worst, expected, runs = [], 0, 0.0, 0
    for p in points:
        est, mem, reps = estimate_s(p), node_mem_gb(p), p.get("reps", 1)
        worst += reps * (p["timeout_s"] + GRACE_S)
        expected += reps * est
        runs += reps
        if a.runs:
            print(f"  {p['name']}: est {est:.0f} s, limit {p['timeout_s']} s, node memory {mem:.0f} GB, reps {reps}")
        if mem > mem_gb:
            problems.append(f"{p['name']}: {mem:.0f} GB per node over the {mem_gb} GB requested")
        if p["timeout_s"] < 2 * est:
            problems.append(f"{p['name']}: limit {p['timeout_s']} s under twice the {est:.0f} s estimate")
    core_h = nodes * cores * walltime / 3600
    print(f"request: {nodes} x {cores} cores, {mem_gb} GB each, {walltime} s = {core_h:g} core-hours requested")
    print(f"credits at assumed rate {a.rate:g} per core-hour: {a.rate * core_h:g} if charged on the request")
    print(f"runs: {runs}, estimated {expected:.0f} s, worst case {worst} s, budget {budget} s after "
          f"{a.startup_s} s of gates and {walltime - budget - a.startup_s} s reserved at the end")
    print(f"expected job time: {(expected + a.startup_s) / 60:.0f} min = "
          f"{nodes * cores * (expected + a.startup_s) / 3600:.0f} core-hours used")
    print(f"largest node memory: {max(node_mem_gb(p) for p in points):.0f} GB of {mem_gb} GB")
    if worst > budget:
        problems.append(f"worst case {worst} s over the {budget} s budget, so later runs could be skipped")
    for x in problems:
        print("PROBLEM", x)
    print("PLAN " + ("REFUSED" if problems else "OK"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
