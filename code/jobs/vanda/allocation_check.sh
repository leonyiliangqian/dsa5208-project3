#!/bin/bash
# Multi-node allocation check, run before anything is compiled.
#   allocation_check.sh OUT NODES LAUNCH      (MPI: the mpirun command line)
# One unbound process per node reports host, allowed CPUs, architecture,
# model, ISA flags and process ancestry. Required: two distinct hosts, exactly
# the chunk's 8 CPUs on each, x86_64 on each (the portable build target), and,
# under tm, mpirun's log selecting the tm launcher with the remote process
# started by orted and not through sshd. Models and ISA flags are recorded
# only; mixed models are allowed here and make a job unusable for timing.
# Writes OUT/env/nodes.txt and OUT/env/launch_verbose.txt.
set -o pipefail
OUT=${1:?OUT} NODES=${2:?NODES} LAUNCH=${3:?LAUNCH}
: "${MPI:?MPI must hold the mpirun command line}"
$MPI --mca plm_base_verbose 10 --mca ras_base_verbose 10 -np "$NODES" --map-by ppr:1:node \
    --bind-to none bash tests/toolchain/node_report.sh \
    2> "$OUT/env/launch_verbose.txt" | sort | tee "$OUT/env/nodes.txt"
python3 - "$OUT/env/nodes.txt" "$NODES" "$OUT/env/launch_verbose.txt" "$LAUNCH" "$(hostname -s)" <<'EOF'
import re, sys
nodes, want, verbose, launch, head = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]
lines = [l for l in open(nodes) if l.startswith("node ")]
def field(l, k):
    m = re.search(rf"\b{k}=(\S*)", l)
    return m.group(1) if m else ""
def count(spec):
    n = 0
    for part in filter(None, spec.split(",")):
        a, _, b = part.partition("-")
        n += int(b) - int(a) + 1 if b else 1
    return n
hosts = {l.split()[1] for l in lines}
cpus = [count(field(l, "allowed")) for l in lines]
archs = {field(l, "arch") for l in lines}
models = sorted({field(l, "model") for l in lines})
isas = {field(l, "isa") for l in lines}
log = open(verbose, errors="replace").read()
selected = {k: re.findall(rf"\(\s*{k}\) Selected component \[(\w+)\]", log) for k in ("plm", "ras")}
remote = [field(l, "ancestry") for l in lines if l.split()[1] != head]
checks = {
    "two_hosts": len(hosts) == want == 2 and len(lines) == want,
    "cpus_8_each": len(cpus) == want and all(c == 8 for c in cpus),
    "arch_x86_64": archs == {"x86_64"},
}
if launch == "tm":
    checks["plm_tm_selected"] = selected["plm"] == ["tm"]
    checks["remote_orted_not_sshd"] = len(remote) == want - 1 and all(
        "orted" in a.split("<") and "sshd" not in a.split("<") for a in remote)
ok = all(checks.values())
# Supporting evidence only: ras may log no selection line, and /proc may hide
# root's pbs_mom from users (hidepid), which would end the ancestry early.
pbs_mom = [("pbs_mom" in a.split("<")) for a in remote]
print(f"allocation hosts={sorted(hosts)} head={head} allowed_cpus={cpus} archs={sorted(archs)}")
print(f"launcher={launch} plm_selected={selected['plm']} ras_selected={selected['ras']} "
      f"remote_ancestry={remote} remote_pbs_mom_visible={pbs_mom}")
print(f"recorded_only models={models} mixed_models={len(models) > 1} isa_lists_equal={len(isas) == 1}")
print(" ".join(f"{k}={'ok' if v else 'FAIL'}" for k, v in checks.items()))
print("allocation", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
EOF
