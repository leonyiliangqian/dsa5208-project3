# Submission audit

Checked 5 November 2026 against [assignment_brief.txt](assignment_brief.txt) and Lecture 12 in [project_memory.md](project_memory.md).
**Not ready to hand in:** required measurements and group review are missing. Nothing has been submitted.

## What is handed in

| Item | Source | How it is made | Status |
|---|---|---|---|
| PDF report | `report/` | Compiled as [../report/README.md](../report/README.md) describes | **Working draft only**, with red `[PENDING]` markers |
| Source with a run README | `code/` | `bash scripts/package_submission.sh`, from `code/`, at the final commit | Package tested; rebuild at the final commit |

**How source reaches Canvas is unconfirmed.** The brief lists "file upload, PDF only" and also requires source code. The group must
check the Canvas page. A repository link should not be assumed to meet the requirement. See [group_review.md](group_review.md).

## Brief and Lecture 12 against the current state

| Requirement | Points | Where | Status |
|---|---|---|---|
| Explain the algorithm | 5 | Report: Problem and Method | Drafted; group review open |
| Serial runtime against N | 5 | Report: Results; job `1523703` | **Measured** on 16 cores of a shared node, 10^4 to 2 x 10^6. `bench1` would repeat it on a whole node |
| MPI strong and weak to at least 256 CPU cores, with speedup, efficiency, communication | 10 | Report: Results; `bench4` | **Missing.** Needs a charged queue and Leon's decision |
| MPI+OpenMP analysis | 10 (shared with GPU) | Report: Results; `1523703`, then `bench4` | **Partial:** to 16 cores only |
| At least one GPU test | | Job `1519638` | Measured; review open |
| Discussion of decisions, techniques, communication | 5 | Report: Parallelization Decisions, Discussion | Decisions drafted; Discussion needs results |
| Scaling and efficiency discussion | | Report: Results, Discussion | **Partial:** to 16 cores, with variability |
| Parallel algorithm validated, with why each test matters | | Report: Correctness, Table 1 | Drafted |
| Runtime figures from Atlas or Vanda; logarithmic time, N and CPU axes | | `report_figures.py` | 16-core figures generated from Vanda; 256 cores missing |
| Non-standard terms defined | | Report: Terms Used | Drafted |
| Synthetic generator explained, no equilibrium claim | | Report: input generation | Drafted |
| Conclusions about real data | | Not applicable: synthetic input | None needed |
| AI use explained | | Report: AI usage; [ai_usage.md](ai_usage.md) | **Draft.** Group must confirm |
| Names and student IDs | | Report title block | **Unconfirmed** |
| Source with README; no logs or terminal output | | Package below | Tested |

## Package contents

| Included | Excluded |
|---|---|
| `code/README.md`, `code/Makefile` | `code/artifacts/`: logs, terminal output, run records, job cookies |
| `code/common`, `serial`, `hybrid`, `gpu`: all C++ source | `notes/`, `report/`, `HANDOFF.md`, root `README.md` |
| `code/tests`: gates and probes | `bin/`, caches, object files |
| `code/scripts`, `manifests`, `jobs`, `docker` | Package tools that need the repository: `package_submission.sh`, `package_test.sh`, `repo_links_test.py` |

The script refuses to build if a log, text output, binary, private key or job cookie appears in the included paths, and takes files
only from the committed tree, so private connection files on a machine cannot enter. Some scripts need what stays out:
`report_tables.py` reads `artifacts/local/`, and `report_figures.py` writes to the report by default. Both are included for
transparency, and the run README's `--allow-local --out` form works alone.

## Verified, 6 November, at `0647895`

The package was rebuilt after the figure and report scripts changed. It has 80 files and includes the reviewed `report_figures.py`. It has no logs, terminal output, run records,
job cookies, binaries, personal paths, `redact_evidence.py` or package tools. Extracted alone in Docker, it passed each command below again. `make check` also passes on macOS.

## Verified, 5 November, at `e86bf5d`

- `package_test` passes: 29 checks with three refusal controls; 80 files.
- Extracted alone, outside the repository, in Docker: `make all hybrid gpu`, `make check`, `make check-hybrid`, `make check-gpu`, each
  README command, `plan_budget_test`, `pbs_entry_test`, `pipeline_e2e` (42 of 42). `make check` also passes on macOS. No GPU was used.
- Not tested from the package: a real device build. That path ran on Vanda from the repository, in jobs `1514775` and `1519638`.
