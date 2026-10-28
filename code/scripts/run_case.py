#!/usr/bin/env python3
"""Run one measured configuration and keep everything needed to trust it later.

Each call writes <out>/raw/<case>_rep<k>.json (never overwriting) plus the raw
stdout/stderr, recording the exact command, scheduler job ID, host, CPU model,
source revision and dirty-tree hash, binary hash, compiler/MPI versions, OpenMP
environment and the program's own result line. A failed run is recorded with
its exit code rather than skipped, so failures stay visible in the evidence.

Scheduler-agnostic: a Slurm or PBS job script calls this once per repetition.

  run_case.py --out artifacts/cluster/runs/<RUN_ID> --case strong_8x2 --rep 1 \\
      --launcher "mpirun -np 8 --map-by ppr:4:socket:PE=2 --bind-to core" \\
      -- bin/linux/bh_hybrid --n 1000000 --steps 5 --schedule dynamic --chunk 64
"""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import platform
import shlex
import socket
import subprocess
import sys

root = Path(__file__).resolve().parents[1]


def sh(cmd):
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=30)
        return (r.stdout or r.stderr).strip()
    except Exception as e:  # provenance is best-effort; never fail the run on it
        return f"unavailable: {e}"


def source_state():
    rev = sh(f"git -C {shlex.quote(str(root))} rev-parse HEAD 2>/dev/null") or "no-git"
    # Hash the source files themselves so an uncommitted edit is still traceable.
    files = sorted(list(root.glob("common/*.hpp")) + list(root.glob("serial/*.cpp")) +
                   list(root.glob("hybrid/*.cpp")) + [root / "Makefile"])
    h = hashlib.sha256()
    for f in files:
        h.update(str(f.relative_to(root)).encode())
        h.update(f.read_bytes())
    # Tracked files only: run outputs are untracked by design and must not mark
    # an unmodified source tree as dirty.
    dirty = sh(f"git -C {shlex.quote(str(root))} status --porcelain --untracked-files=no -- . 2>/dev/null")
    return {"git_rev": rev, "source_tree_sha256": h.hexdigest(), "git_dirty": bool(dirty)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="run directory, e.g. artifacts/cluster/runs/<RUN_ID>")
    ap.add_argument("--case", required=True)
    ap.add_argument("--rep", type=int, required=True)
    ap.add_argument("--launcher", default="", help="MPI launcher prefix; empty for serial")
    ap.add_argument("--allocated-cores", type=int, required=True,
                    help="physical cores allocated to this run; the P in efficiency S/P")
    ap.add_argument("--timeout", type=int, default=7200)
    ap.add_argument("cmd", nargs=argparse.REMAINDER)
    a = ap.parse_args()
    cmd = a.cmd[1:] if a.cmd and a.cmd[0] == "--" else a.cmd
    if not cmd:
        sys.exit("no program given after --")

    raw = Path(a.out) / "raw"
    raw.mkdir(parents=True, exist_ok=True)
    stem = f"{a.case}_rep{a.rep}"
    record_path = raw / f"{stem}.json"
    if record_path.exists():
        sys.exit(f"refusing to overwrite {record_path}")

    full = shlex.split(a.launcher) + cmd
    started = datetime.datetime.now(datetime.timezone.utc)
    try:
        r = subprocess.run(full, capture_output=True, text=True, timeout=a.timeout)
        code, out, err = r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired as e:
        code, out, err = 124, e.stdout or "", (e.stderr or "") + f"\nTIMEOUT after {a.timeout}s"
    (raw / f"{stem}.stdout").write_text(out if isinstance(out, str) else out.decode())
    (raw / f"{stem}.stderr").write_text(err if isinstance(err, str) else err.decode())

    result = None
    for line in (out if isinstance(out, str) else "").splitlines():
        if line.startswith("result "):
            result = json.loads(line[len("result "):])
    binary = Path(cmd[0])
    # A run is usable only if it exited cleanly, reported a result, kept its
    # replicated state consistent and actually ran the requested thread count.
    problems = []
    if code != 0:
        problems.append(f"exit {code}")
    if result is None:
        problems.append("no result line")
    else:
        if result.get("replicated", True) is not True:
            problems.append("replication check failed")
        if result.get("threads_effective") != result.get("threads"):
            problems.append("effective threads differ from requested")
        if result["ranks"] * result["threads"] > a.allocated_cores:
            problems.append("ranks x threads exceeds allocated cores (oversubscribed)")
    record = {
        "case": a.case, "rep": a.rep, "returncode": code,
        "ok": not problems, "problems": problems,
        "started_utc": started.isoformat(),
        "local_time": datetime.datetime.now().astimezone().isoformat(),
        "command": full, "allocated_cores": a.allocated_cores,
        "scheduler_job_id": os.environ.get("SLURM_JOB_ID") or os.environ.get("PBS_JOBID"),
        "scheduler_nodelist": os.environ.get("SLURM_JOB_NODELIST") or sh("cat $PBS_NODEFILE 2>/dev/null | sort -u | paste -sd,"),
        "launch_host": socket.gethostname(), "platform": platform.platform(),
        "cpu_model": sh("lscpu 2>/dev/null | grep -m1 'Model name' | cut -d: -f2 || sysctl -n machdep.cpu.brand_string"),
        "binary": str(binary), "binary_sha256": hashlib.sha256(binary.read_bytes()).hexdigest() if binary.exists() else None,
        "compiler": sh("${CXX:-c++} --version | head -1"),
        "mpicxx": sh("mpicxx --version 2>/dev/null | head -1"),
        "mpi": sh("mpirun --version 2>&1 | head -1"),
        "modules": os.environ.get("LOADEDMODULES", ""),
        "env": {k: os.environ.get(k) for k in ("OMP_NUM_THREADS", "OMP_PROC_BIND", "OMP_PLACES",
                                               "OMP_SCHEDULE", "SLURM_CPUS_PER_TASK", "SLURM_NTASKS",
                                               "PBS_NCPUS", "CXXFLAGS")},
        **source_state(),
        "result": result,
    }
    record_path.write_text(json.dumps(record, indent=2) + "\n")
    print(f"{stem}: exit={code} ok={record['ok']} wall_s={result.get('wall_s') if result else None}"
          + (f" problems={problems}" if problems else ""))
    sys.exit(0 if record["ok"] else 1)


if __name__ == "__main__":
    main()
