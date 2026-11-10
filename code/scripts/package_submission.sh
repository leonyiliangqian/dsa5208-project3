#!/bin/bash
# Build the source package for the final submission from the committed tree:
# code and code/README.md only; the root README is internal project status. Raw evidence (artifacts/, job logs, terminal output)
# stays in the repository for internal verification and is left out, as the
# Lecture 12 requirements ask. Tools and tests that only make sense inside the repository stay out too
# (report_figures_prefix_test.py compares against the report's generated files and cluster summaries).
#   scripts/package_submission.sh [OUTPUT.zip]    (run from code/)
set -euo pipefail
out=${1:-dsa5208-project3-source.zip}
out=$(cd "$(dirname "$out")" && pwd)/$(basename "$out")
cd "$(git rev-parse --show-toplevel)"
paths=(code/README.md code/Makefile code/common code/serial code/hybrid code/gpu code/tests
       code/scripts code/manifests code/jobs code/docker
       ':(exclude)code/scripts/package_submission.sh' ':(exclude)code/tests/jobs/package_test.sh'
       ':(exclude)code/tests/repo_links_test.py' ':(exclude)code/scripts/redact_evidence.py'
       ':(exclude)code/tests/report_figures_prefix_test.py')
bad=$(git ls-files -- "${paths[@]}" | grep -E '\.(log|OU|ER|out|txt|stdout|stderr|o|a|so|exe|bundle|zip|pdf|pem|key|pyc)$|(^|/)(artifacts|bin|__pycache__)/|(^|/)(\.env|id_rsa|credentials)' || true)
if [ -n "$bad" ]; then
    echo "refusing: log, evidence, binary or credential files in the package paths:" >&2
    echo "$bad" >&2
    exit 1
fi
secret=$(git grep -lE 'BEGIN [A-Z ]*PRIVATE KEY|PBS_JOBCOOKIE=[0-9A-F]' HEAD -- "${paths[@]}" || true)
if [ -n "$secret" ]; then
    echo "refusing: credential or job-cookie text in:" >&2
    echo "$secret" >&2
    exit 1
fi
git archive --format=zip -o "$out" --prefix=dsa5208-project3/ HEAD -- "${paths[@]}"
echo "wrote $out from $(git rev-parse --short HEAD)"
