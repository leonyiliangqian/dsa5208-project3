#!/bin/bash
# Build the source package for the final submission from the committed tree:
# code and README only. Raw evidence (artifacts/, job logs, terminal output)
# stays in the repository for internal verification and is left out, as the
# Lecture 12 requirements ask.
#   scripts/package_submission.sh [OUTPUT.zip]    (run from code/)
set -euo pipefail
out=${1:-dsa5208-project3-source.zip}
cd "$(git rev-parse --show-toplevel)"
paths=(README.md code/README.md code/Makefile code/common code/serial code/hybrid code/gpu code/tests
       code/scripts code/manifests code/jobs code/docker)
bad=$(git ls-files -- "${paths[@]}" | grep -E '(\.log|\.OU|\.ER|\.stdout|\.stderr)$|(^|/)artifacts/' || true)
if [ -n "$bad" ]; then
    echo "refusing: log or evidence files in the package paths:" >&2
    echo "$bad" >&2
    exit 1
fi
git archive --format=zip -o "$OLDPWD/$out" --prefix=dsa5208-project3/ HEAD -- "${paths[@]}"
echo "wrote $out from $(git rev-parse --short HEAD)"
