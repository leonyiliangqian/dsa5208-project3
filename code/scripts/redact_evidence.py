#!/usr/bin/env python3
"""Remove authentication values from retained evidence before it is committed.

PBS writes the job's PBS_JOBCOOKIE, which authenticates job processes to the node daemons, into
each run's environment record. This replaces each value with a marker, keeps an unchanged copy of
the original under KEEP_DIR (outside the repository, readable by the owner only), and appends one
row per file to artifacts/cluster/REDACTIONS.md with both hashes. Lines are otherwise unchanged.

  redact_evidence.py KEEP_DIR FILE [FILE ...]     (run from code/; repository only)
"""
import hashlib
import os
from pathlib import Path
import re
import shutil
import sys

FIELD = re.compile(r"^(PBS_JOBCOOKIE=)([0-9A-Fa-f]+)$", re.M)
MARK = "[REDACTED: see artifacts/cluster/REDACTIONS.md]"
CODE = Path(__file__).resolve().parents[1]
LEDGER = CODE / "artifacts/cluster/REDACTIONS.md"
HEAD = """# Redactions in retained cluster evidence

Authentication values are removed from the committed copies. Each row gives the original file's SHA-256, which the
retrieval checksums refer to, and the hash of the committed copy. Nothing else in a file changes. Originals are kept
outside the repository by `scripts/redact_evidence.py`, readable by the owner only, and remain on Vanda in the clone
that wrote them. Copies committed before 6 Nov 2026 also remain unredacted in this repository's earlier commits,
which are not rewritten.

| File | Field | Original SHA-256 | Committed SHA-256 |
|---|---|---|---|
"""


def sha(b):
    return hashlib.sha256(b).hexdigest()


def main():
    keep = Path(sys.argv[1]).resolve()
    if CODE.parent in keep.parents or keep == CODE.parent:
        sys.exit("KEEP_DIR must be outside the repository")
    keep.mkdir(parents=True, exist_ok=True)
    os.chmod(keep, 0o700)
    rows = []
    for name in sys.argv[2:]:
        path = Path(name).resolve()
        rel = path.relative_to(CODE)
        data = path.read_bytes()
        text = data.decode()
        if not FIELD.search(text):
            continue
        dest = keep / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        if not dest.exists():
            shutil.copy2(path, dest)
            os.chmod(dest, 0o600)
        if dest.read_bytes() != data:
            sys.exit(f"{rel}: a different original is already kept at {dest}")
        new = FIELD.sub(lambda m: m.group(1) + MARK, text).encode()
        path.write_bytes(new)
        rows.append(f"| `{rel}` | `PBS_JOBCOOKIE` | `{sha(data)}` | `{sha(new)}` |\n")
    if rows:
        old = LEDGER.read_text() if LEDGER.exists() else HEAD
        LEDGER.write_text(old + "".join(rows))
    print(f"redacted {len(rows)} files; originals in {keep}")


if __name__ == "__main__":
    sys.exit(main())
