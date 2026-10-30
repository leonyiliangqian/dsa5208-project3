#!/bin/bash
# After a gate, on one node: find this user's processes the gate may have left
# behind (MPI launchers/daemons, or anything whose command line contains
# PATTERN, the job's binary directory), terminate them (TERM, then KILL), and
# report whether any remain. Exit 0 only if none remain.
#   leftover_check.sh vanda-1507215/
# With LEFTOVER_JOBID set, processes carrying a different PBS_JOBID are left
# alone (another job of this user). The checker's own ancestry is excluded.
pattern=${1:?pattern}
host=$(hostname -s)

ancestry=" "
p=$$
while [ "${p:-0}" -gt 1 ] && [ -r /proc/$p/stat ]; do
    ancestry="$ancestry$p "
    p=$(sed 's/.*) //' /proc/$p/stat | cut -d' ' -f2)
done

candidates() {
    local d pid comm cmd job
    for d in /proc/[0-9]*; do
        [ -O "$d" ] || continue
        pid=${d#/proc/}
        case "$ancestry" in *" $pid "*) continue ;; esac
        comm=$(cat "$d/comm" 2>/dev/null) || continue
        cmd=$(tr '\0' ' ' < "$d/cmdline" 2>/dev/null) || continue
        case "$cmd" in *leftover_check.sh*) continue ;; esac
        case "$comm" in
            mpirun|mpiexec|orterun|orted|prterun|prted) ;;
            *) case "$cmd" in *"$pattern"*) ;; *) continue ;; esac ;;
        esac
        if [ -n "${LEFTOVER_JOBID:-}" ]; then
            job=$(tr '\0' '\n' < "$d/environ" 2>/dev/null | sed -n 's/^PBS_JOBID=//p')
            [ -n "$job" ] && [ "$job" != "$LEFTOVER_JOBID" ] && continue
        fi
        echo "$pid $comm ${cmd:0:160}"
    done
}

found=$(candidates)
n_found=$(printf '%s' "$found" | grep -c .)
if [ "$n_found" -gt 0 ]; then
    printf '%s\n' "$found" | sed "s/^/leftover host=$host found: /"
    kill -TERM $(printf '%s\n' "$found" | cut -d' ' -f1) 2>/dev/null
    sleep 3
    rest=$(candidates)
    [ -n "$rest" ] && kill -KILL $(printf '%s\n' "$rest" | cut -d' ' -f1) 2>/dev/null && sleep 2
fi
remaining=$(candidates)
n_rem=$(printf '%s' "$remaining" | grep -c .)
[ "$n_rem" -gt 0 ] && printf '%s\n' "$remaining" | sed "s/^/leftover host=$host remaining: /"
echo "leftover_check host=$host found=$n_found remaining=$n_rem $([ "$n_rem" -eq 0 ] && echo CLEAN || echo DIRTY)"
[ "$n_rem" -eq 0 ]
