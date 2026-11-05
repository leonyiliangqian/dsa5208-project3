#!/bin/bash
# The source package must hold what is needed to build and run, and no logs, terminal output,
# evidence, binaries or credentials. Builds it from the committed tree, inspects it, and shows
# the script refuses a log and a private key added to a scratch copy of the repository.
#   bash tests/jobs/package_test.sh     (run from code/)
set -uo pipefail
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0
result() { # NAME OK(0|1) [detail]
    if [ "$2" = 0 ]; then echo "package $1 PASS ${3:-}"; else echo "package $1 FAIL ${3:-}"; failures=$((failures + 1)); fi
}
bash scripts/package_submission.sh "$work/p.zip" > "$work/build.out" 2>&1; result builds $? "$(cat "$work/build.out")"
python3 -c 'import sys, zipfile; print("\n".join(zipfile.ZipFile(sys.argv[1]).namelist()))' "$work/p.zip" > "$work/list"
[ "$(wc -l < "$work/list")" -gt 50 ]; result not_empty $? "entries=$(wc -l < "$work/list" | tr -d ' ')"
mkdir "$work/x" && python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$work/p.zip" "$work/x"
for f in code/README.md code/Makefile code/common/nbody.hpp code/serial/barnes_hut.cpp code/hybrid/bh_hybrid.cpp \
         code/gpu/bh_gpu.cpp code/scripts/run_manifest.py code/manifests/studies_four_node.json code/jobs/vanda/submit.sh; do
    grep -qx "dsa5208-project3/$f" "$work/list"; rc=$?
    result "has_$(basename "$f")" "$rc"
done
! grep -E '\.(log|OU|ER|out|txt|stdout|stderr|o|a|so|exe|bundle|zip|pdf|pem|key|pyc|jsonl)$' "$work/list" | grep -q .; result no_log_or_binary_names $?
! grep -E '/(artifacts|bin|__pycache__|notes|report)/' "$work/list" | grep -q .; result no_evidence_or_notes_dirs $?
# Split so this file does not match its own patterns.
private='leon''yil|/Users/''leon|A0[0-9]{6}[A-Z]|gmail''[.]com'
! grep -rlE "BEGIN [A-Z ]*PRIVATE KEY|PBS_JOBCOOKIE=[0-9A-F]|$private" "$work/x" | grep -q .; result no_credentials_or_personal_details $?
! grep -E '(package_submission|package_test|repo_links_test|HANDOFF)' "$work/list" | grep -q .; result no_internal_tools $?
# The README must stand alone: every dependency and build path, and no pointer out of the package.
readme="$work/x/dsa5208-project3/code/README.md"
for word in '## Dependencies' 'make hybrid' 'make gpu' 'mpicxx' 'nvc++' 'make check-hybrid' 'make check-gpu' 'Python 3'; do
    grep -qF "$word" "$readme"; result "readme_has_${word// /_}" $?
done
! grep -nE '\.\./|HANDOFF|notes/|report/' "$readme" | grep -q .; result readme_points_nowhere_else $?
binaries=$(cd "$work/x" && find . -type f -exec sh -c 'head -c 4 "$1" | grep -q "^.ELF\|^.\{0,1\}PK" && echo "$1"' _ {} \; | wc -l | tr -d ' ')
[ "$binaries" = 0 ]; result no_binary_content $? "found=$binaries"

# Negative controls, in a scratch copy of the committed tree.
top=$(git rev-parse --show-toplevel)
control() { # NAME PATH TEXT
    local c="$work/$1"
    git clone -q "$top" "$c" && echo "$3" > "$c/$2" && git -C "$c" add -f "$2" \
        && git -C "$c" -c user.name=t -c user.email=t@t.invalid commit -qm control
    (cd "$c/code" && bash scripts/package_submission.sh "$work/$1.zip") > "$work/$1.out" 2>&1; local rc=$?
    [ "$rc" != 0 ] && grep -q refusing "$work/$1.out"; result "control_$1" $? "rc=$rc"
}
control log_file code/tests/run.log "terminal output"
control terminal_text code/jobs/vanda/output.txt "terminal output"
control private_key code/scripts/notes.py "# -----BEGIN RSA PRIV""ATE KEY-----"

echo "$([ "$failures" = 0 ] && echo PASS || echo FAIL): source package, $failures failed"
[ "$failures" = 0 ]
