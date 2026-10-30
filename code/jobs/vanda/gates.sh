# Gate runner shared by the Vanda job scripts (source it; not executable).
#
#   gate NAME LIMIT_S KIND CMD...    KIND: critical | independent
#
# Each gate runs under `timeout` in its own process group, so on expiry the
# whole tree (make, python, mpirun) gets TERM, then KILL after a grace period.
# Shortly before a gate's limit a process snapshot of every node is saved to
# gate_NAME.snapshot. After every gate, leftover MPI processes are searched for, terminated and
# re-checked on every node of the job (cleanup_all). Outcomes in gates.txt:
#   NAME PASS|FAIL|TIMEOUT|SKIP rc=.. secs=.. [reason]
# The job stops (finish 5) when a critical gate does not pass, and stops
# (finish 6) when cleanup cannot be verified, because later gates would then
# share the nodes with stray processes. An independent gate's FAIL or TIMEOUT
# is recorded and the job continues; gates that depend on it are skipped
# with `need`. A gate is never given more time than remains before the job
# walltime minus CLEANUP_RESERVE_S, so PBS does not kill the job first.
#
# Expects: OUT, JOB_START_S (epoch), WALLTIME_S, LEFTOVER_PATTERN; optional
# REMOTE_EXEC (pbs_tmrsh by default, ssh in local simulation).

CLEANUP_RESERVE_S=${CLEANUP_RESERVE_S:-150}
GATE_GRACE_S=${GATE_GRACE_S:-20}
if [ -z "${REMOTE_EXEC:-}" ]; then
    if command -v pbs_tmrsh >/dev/null 2>&1; then REMOTE_EXEC=pbs_tmrsh
    else REMOTE_EXEC="ssh -o BatchMode=yes -o ConnectTimeout=10"; fi
fi
: > "$OUT/gates.txt"
: > "$OUT/cleanup.log"

stamp() { date +%H:%M:%S; }

finish() {
    echo; echo "===== summary $(stamp)"; cat "$OUT/gates.txt"
    echo "end=$(date -Is)"
    exit "$1"
}

remaining_s() { echo $(( JOB_START_S + WALLTIME_S - CLEANUP_RESERVE_S - $(date +%s) )); }

# Short host name, lower case, for comparing node file entries with hostname.
short() { echo "${1%%.*}" | tr '[:upper:]' '[:lower:]'; }

cleanup_all() {
    local label=$1 h rc=0 me
    me=$(short "$(hostname)")
    echo "== after $label $(stamp)" >> "$OUT/cleanup.log"
    for h in $(sort -u "${PBS_NODEFILE:-/dev/null}"); do
        if [ "$(short "$h")" = "$me" ]; then
            timeout -k 5 40 bash tests/toolchain/leftover_check.sh "$LEFTOVER_PATTERN" \
                >> "$OUT/cleanup.log" 2>&1 || rc=1
        else
            timeout -k 5 40 $REMOTE_EXEC "$h" env LEFTOVER_JOBID="${LEFTOVER_JOBID:-}" \
                bash "$PWD/tests/toolchain/leftover_check.sh" "$LEFTOVER_PATTERN" \
                >> "$OUT/cleanup.log" 2>&1 || rc=1
        fi
    done
    local nodes
    nodes=$(sort -u "${PBS_NODEFILE:-/dev/null}" | wc -l)
    # Every node must have reported CLEAN; a missing report counts as failure.
    local clean
    clean=$(sed -n "/^== after $label /,\$p" "$OUT/cleanup.log" | grep -c ' CLEAN$')
    [ "$rc" -eq 0 ] && [ "$clean" -eq "$nodes" ]
}

# Process snapshot of every node into gate_NAME.snapshot (tests/toolchain/proc_snapshot.sh).
snapshot_all() {
    local label=$1 h me
    me=$(short "$(hostname)")
    for h in $(sort -u "${PBS_NODEFILE:-/dev/null}"); do
        if [ "$(short "$h")" = "$me" ]; then
            timeout -k 2 25 bash tests/toolchain/proc_snapshot.sh "$LEFTOVER_PATTERN"
        else
            timeout -k 2 25 $REMOTE_EXEC "$h" bash "$PWD/tests/toolchain/proc_snapshot.sh" "$LEFTOVER_PATTERN"
        fi
    done >> "$OUT/gate_$label.snapshot" 2>&1
}

gate() {
    local name=$1 limit=$2 kind=$3; shift 3
    local left rc status t0 note=""
    left=$(remaining_s)
    if [ "$left" -lt "$limit" ]; then
        note="limit cut from ${limit}s to fit the walltime"
        limit=$left
    fi
    if [ "$left" -lt 20 ]; then
        echo "$name SKIP rc=- secs=0 no time left before the walltime" | tee -a "$OUT/gates.txt"
        [ "$kind" = critical ] && { echo "STOP: no time for critical gate $name"; finish 5; }
        return
    fi
    echo; echo "===== gate $name ($kind, limit ${limit}s) $(stamp): $*"
    t0=$(date +%s)
    # Shortly before the limit, record where every process is waiting; the
    # watcher is discarded if the gate finishes first.
    local snap_at=$(( limit > 15 ? limit - 8 : limit / 2 )) watcher
    ( sleep "$snap_at"; snapshot_all "$name" ) &
    watcher=$!
    timeout -k "$GATE_GRACE_S" "$limit" "$@" > "$OUT/gate_$name.log" 2>&1
    rc=$?
    kill "$watcher" 2>/dev/null; wait "$watcher" 2>/dev/null
    case $rc in
        0) status=PASS ;;
        124|137) status=TIMEOUT; note="${note:+$note; }no completion within ${limit}s" ;;
        *) status=FAIL ;;
    esac
    tail -n 30 "$OUT/gate_$name.log"
    echo "$name $status rc=$rc secs=$(( $(date +%s) - t0 )) $note" | tee -a "$OUT/gates.txt"
    if ! cleanup_all "$name"; then
        sed -n "/^== after $name /,\$p" "$OUT/cleanup.log"
        echo "STOP: could not verify that gate $name left no processes on every node"
        echo "cleanup FAIL after $name" >> "$OUT/gates.txt"
        finish 6
    fi
    if [ "$status" != PASS ] && [ "$kind" = critical ]; then
        echo "STOP: critical gate $name $status; later gates would not mean what they claim"
        finish 5
    fi
}

# need GATE NAME: true if GATE passed; otherwise record NAME as skipped.
need() {
    grep -q "^$1 PASS " "$OUT/gates.txt" && return 0
    echo "$2 SKIP rc=- secs=0 needs $1 to pass" | tee -a "$OUT/gates.txt"
    return 1
}

# Exit status for the job: 0 only if every recorded gate passed.
all_passed() { ! grep -qv '^[^ ]* PASS ' "$OUT/gates.txt"; }
