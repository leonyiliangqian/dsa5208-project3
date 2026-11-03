#!/bin/bash
# Multi-node allocation check, run before anything is compiled.
#   allocation_check.sh OUT NODES LAUNCH      (MPI: the mpirun command line)
# One unbound process per node reports host, allowed CPUs, architecture,
# model, ISA flags and process ancestry. Required: two distinct hosts, exactly
# the chunk's 8 CPUs on each, x86_64 on each (the portable build target), and,
# under tm, mpirun's log selecting the tm launcher with the remote process
# started by orted and not through sshd. Under pbs_tmrsh: the rsh launcher with
# a remote process under orted and pbs_mom, not sshd, carrying PBS_JOBID, and no
# log line naming another agent or --daemonize. Models and ISA flags are
# recorded only; mixed models are allowed here and make a job unusable for timing.
# Environment: ALLOC_EXPECT_NODES (required) is the number of distinct hosts
# the job must have; ALLOC_CPUS_PER_NODE (default 8) is the exact cpuset size
# expected on every node; ALLOC_SAME_MODEL=1 (timing jobs) also requires one
# CPU model on all nodes. With one node the host and launcher checks reduce
# to "one host" and are not about remote processes.
# Writes OUT/env/nodes.txt and OUT/env/launch_verbose.txt.
set -o pipefail
OUT=${1:?OUT} NODES=${2:?NODES} LAUNCH=${3:?LAUNCH}
: "${MPI:?MPI must hold the mpirun command line}"
$MPI --mca plm_base_verbose 10 --mca ras_base_verbose 10 -np "$NODES" --map-by ppr:1:node \
    --bind-to none bash tests/toolchain/node_report.sh \
    2> "$OUT/env/launch_verbose.txt" | sort | tee "$OUT/env/nodes.txt"
python3 - "$OUT/env/nodes.txt" "$NODES" "$OUT/env/launch_verbose.txt" "$LAUNCH" "$(hostname -s)" \
    "${ALLOC_CPUS_PER_NODE:-8}" "${ALLOC_SAME_MODEL:-0}" "${ALLOC_EXPECT_NODES:?set ALLOC_EXPECT_NODES}" <<'EOF'
import re, sys
nodes, want, verbose, launch, head = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4], sys.argv[5]
per_node, same_model, expect = int(sys.argv[6]), sys.argv[7] == "1", int(sys.argv[8])
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
    f"{expect}_hosts": len(hosts) == expect == want and len(lines) == expect,
    f"cpus_{per_node}_each": len(cpus) == want and all(c == per_node for c in cpus),
    "arch_x86_64": archs == {"x86_64"},
}
if same_model:
    checks["one_cpu_model"] = len(models) == 1 and models[0] != ""
if launch == "tm" and want > 1:
    checks["plm_tm_selected"] = selected["plm"] == ["tm"]
    checks["remote_orted_not_sshd"] = len(remote) == want - 1 and all(
        "orted" in a.split("<") and "sshd" not in a.split("<") for a in remote)
if launch == "pbs_tmrsh" and want > 1:
    chain = [a.split("<") for a in remote]
    # Where the remote process really runs decides this. An ssh daemon descends from sshd, and
    # a daemonized one leaves pbs_mom. The log can only reject: daemons may log through the
    # launcher too, and the template line's wording has not been seen on Vanda.
    argv = re.search(r"final template argv:\s*\n\s*(.+)", log)
    checks["plm_rsh_selected"] = bool(selected["plm"]) and set(selected["plm"]) == {"rsh"}
    checks["agent_not_contradicted"] = not argv or argv.group(1).split()[0].rsplit("/", 1)[-1] == "pbs_tmrsh"
    checks["daemonize_not_seen"] = not argv or "--daemonize" not in argv.group(1)
    checks["remote_orted_not_sshd"] = len(remote) == want - 1 and all(
        "orted" in c and "sshd" not in c for c in chain)
    checks["remote_under_pbs_mom"] = len(remote) == want - 1 and all("pbs_mom" in c for c in chain)
    checks["pbs_jobid_on_every_node"] = len(lines) == want and all(field(l, "pbs_jobid_env") == "yes" for l in lines)
ok = all(checks.values())
# Supporting evidence only: ras may log no selection line, and /proc may hide
# root's pbs_mom from users (hidepid), which would end the ancestry early.
pbs_mom = [("pbs_mom" in a.split("<")) for a in remote]
print(f"allocation hosts={sorted(hosts)} head={head} allowed_cpus={cpus} archs={sorted(archs)}")
print(f"launcher={launch} plm_selected={selected['plm']} ras_selected={selected['ras']} "
      f"remote_ancestry={remote} remote_pbs_mom_visible={pbs_mom}")
if launch == "pbs_tmrsh" and want > 1:
    print(f"recorded_only template_line_seen={bool(argv)}")
print(f"recorded_only models={models} mixed_models={len(models) > 1} isa_lists_equal={len(isas) == 1} "
      f"pbs_jobid_env={[field(l, 'pbs_jobid_env') for l in lines]}")
print(" ".join(f"{k}={'ok' if v else 'FAIL'}" for k, v in checks.items()))
print("allocation", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
EOF
