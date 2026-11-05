#!/usr/bin/env python3
"""Every file the project documents point to must exist, and the report's inputs must resolve.

Checks relative Markdown links and backticked repository paths in tracked Markdown files, and
each \\input in report/main.tex. Paths with a placeholder or wildcard must match at least one
file when they have a wildcard, and are skipped when they have a placeholder.

  python3 tests/repo_links_test.py     (run from code/; repository only, not in the source package)
"""
import glob
from pathlib import Path
import re
import subprocess
import sys

root = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
LINK = re.compile(r"\]\(([^)#\s]+)(?:#[^)]*)?\)")
CODE = re.compile(r"`((?:code|notes|report|artifacts|manifests|jobs|scripts|tests)/[^`\s]+|[\w./-]+\.(?:md|json|pbs|py|sh|tex))`")


# Named in the documents, and produced only at the end.
NOT_YET = {"report/DSA5208_Project3_Report.pdf", "tab_failed_runs.tex"}


def exists(ref, base):
    if "<" in ref or "NUSNETID" in ref or ref in NOT_YET:
        return True
    for start in (base, root, root / "code", root / "code/artifacts/cluster", root / "code/artifacts/cluster/discovery",
                  root / "notes", root / "report", root / "code/manifests", root / "code/scripts", root / "code/jobs/vanda",
                  root / "code/tests", root / "code/docker", *map(Path, glob.glob(str(root / "code/artifacts/cluster/runs/*")))):
        if glob.glob(str(start / ref)) or (start / ref).exists():
            return True
    return False


def main():
    files = subprocess.check_output(["git", "-C", str(root), "ls-files", "*.md"], text=True).split()
    bad, count = [], 0
    for name in files:
        path = root / name
        # Run records quote paths from the machine they ran on.
        if "/artifacts/" in name:
            continue
        for line_no, line in enumerate(path.read_text().splitlines(), 1):
            refs = [r for r in LINK.findall(line) if not re.match(r"[a-z]+:", r)] + CODE.findall(line)
            for ref in refs:
                count += 1
                if not exists(ref.rstrip("/.,:"), path.parent):
                    bad.append(f"{name}:{line_no}: {ref}")
    report = (root / "report/main.tex").read_text()
    for ref in re.findall(r"\\input\{([^}#]+)\}", report):
        count += 1
        target = root / "report" / (ref if ref.endswith(".tex") else ref + ".tex")
        if not target.exists():
            bad.append(f"report/main.tex: \\input {ref}")
    for x in bad:
        print("MISSING", x)
    print(f"{'FAIL' if bad else 'PASS'}: {count} references, {len(bad)} missing")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
