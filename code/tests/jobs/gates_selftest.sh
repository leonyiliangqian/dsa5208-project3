#!/bin/bash
# Fault-injection test for jobs/vanda/gates.sh in the two-container
# simulation (docker/twonode/run.sh, ssh between node1 and node2):
#   docker/twonode/run.sh 'bash tests/jobs/gates_selftest.sh'
# Each scenario runs in its own shell, because the library exits the job on
# STOP, and checks gates.txt, cleanup.log and the exit status.
set -u
cd "$(dirname "$0")/../.."
root=$(mktemp -d)
pass=0 fail=0
PAT="vanda-selftest/"

scenario() {  # scenario NAME EXPECTED_EXIT BODY
    local name=$1 want=$2 body=$3 out=$root/$1 rc
    mkdir -p "$out"
    OUT=$out JOB_START_S=$(date +%s) WALLTIME_S=${WALLTIME_S:-900} LEFTOVER_PATTERN=$PAT \
        REMOTE_EXEC=${REMOTE_EXEC:-"ssh -o BatchMode=yes"} CLEANUP_RESERVE_S=${CLEANUP_RESERVE_S:-150} \
        GATE_GRACE_S=5 bash -c "source jobs/vanda/gates.sh; $body; finish 0" > "$out/stdout" 2>&1
    rc=$?
    SC_OUT=$out SC_RC=$rc SC_WANT=$want
}

check() {  # check DESCRIPTION CONDITION...
    local what=$1; shift
    if "$@"; then echo "PASS $what"; pass=$((pass + 1)); else echo "FAIL $what"; fail=$((fail + 1)); fi
}
has() { grep -Eq "$1" "$2"; }
none_left() {  # no matching process on either node
    # The [v] keeps pgrep from matching the shell that runs it over ssh.
    ! pgrep -u "$(id -un)" -f "[v]${PAT#v}" >/dev/null \
        && ! ssh -o BatchMode=yes node2 "pgrep -u \$(id -un) -f '[v]${PAT#v}'" >/dev/null
}

# 1. A two-node MPI job that never finishes: TIMEOUT, cleanup clean, next gate runs.
scenario hang 0 "
gate hang 8 independent mpirun --hostfile $PBS_NODEFILE -np 2 --map-by node bash -c 'exec -a ${PAT}hang sleep 600'
gate after 30 independent true"
check "hang: recorded TIMEOUT"          has '^hang TIMEOUT rc=124 ' "$SC_OUT/gates.txt"
check "hang: both nodes CLEAN"          test "$(grep -c ' CLEAN$' "$SC_OUT/cleanup.log")" -ge 2
check "hang: later gate still ran"      has '^after PASS ' "$SC_OUT/gates.txt"
check "hang: job exit 0 as scripted"    test "$SC_RC" -eq 0
check "hang: no process left"           none_left
check "hang: snapshot of both nodes"    test "$(grep -c '^== snapshot host=' "$SC_OUT/gate_hang.snapshot")" -eq 2
check "hang: snapshot saw the rank"     has 'vanda-selftest/hang' "$SC_OUT/gate_hang.snapshot"
check "after: no snapshot (finished)"   test ! -e "$SC_OUT/gate_after.snapshot"

# 2. A gate that "passes" but leaves a TERM-ignoring process on node2:
#    cleanup finds it, escalates to KILL, and reports the node clean.
scenario stray 0 "
gate stray 20 independent ssh -o BatchMode=yes node2 \"setsid bash -c 'trap \\\"\\\" TERM; exec -a ${PAT}stray sleep 600' </dev/null >/dev/null 2>&1 &\""
check "stray: gate PASS"                has '^stray PASS ' "$SC_OUT/gates.txt"
check "stray: found on node2"           has 'leftover_check host=node2 found=1 remaining=0 CLEAN' "$SC_OUT/cleanup.log"
check "stray: no process left"          none_left

# 3. Dependencies: a failed gate makes its dependants SKIP, and the job goes on.
scenario deps 0 "
gate base 20 independent false
need base dependant && gate dependant 20 independent true
gate other 20 independent true"
check "deps: base FAIL"                 has '^base FAIL rc=1 ' "$SC_OUT/gates.txt"
check "deps: dependant SKIP"            has '^dependant SKIP rc=- secs=0 needs base to pass' "$SC_OUT/gates.txt"
check "deps: unrelated gate ran"        has '^other PASS ' "$SC_OUT/gates.txt"

# 4. Walltime budget: limits are cut to the time left; with none left, SKIP.
WALLTIME_S=185 CLEANUP_RESERVE_S=150 scenario budget 0 "
gate cut 600 independent sleep 1
gate late 600 independent sleep 40
gate none 600 independent true"
check "budget: limit cut, still PASS"   has '^cut PASS .*limit cut from 600s' "$SC_OUT/gates.txt"
check "budget: next gate times out"     has '^late TIMEOUT ' "$SC_OUT/gates.txt"
check "budget: no time -> SKIP"         has '^none SKIP .*no time left' "$SC_OUT/gates.txt"

# 5. Cleanup cannot be verified on node2 (remote exec fails): STOP, exit 6.
REMOTE_EXEC="ssh -o BatchMode=yes -o ConnectTimeout=2 -p 1" scenario unverifiable 6 "
gate first 20 independent true
gate second 20 independent true"
check "unverifiable: exit 6"            test "$SC_RC" -eq 6
check "unverifiable: STOP message"      has 'STOP: could not verify' "$SC_OUT/stdout"
check "unverifiable: second not run"    bash -c "! grep -q '^second ' '$SC_OUT/gates.txt'"

# 6. Critical gate fails: STOP, exit 5, nothing after it runs.
scenario critical 5 "
gate crit 20 critical false
gate later 20 independent true"
check "critical: exit 5"                test "$SC_RC" -eq 5
check "critical: later not run"         bash -c "! grep -q '^later ' '$SC_OUT/gates.txt'"

echo "gates_selftest passed=$pass failed=$fail $([ "$fail" -eq 0 ] && echo PASS || echo FAIL)"
[ "$fail" -eq 0 ]
