# Submission audit

Checked 11 November 2026 against [assignment_brief.txt](assignment_brief.txt) and Lecture 12 in [project_memory.md](project_memory.md).
Due 17 November 2026 (per Leon; cutoff time unconfirmed). **Not ready to hand in:** the required measurements now exist, but group review,
names and IDs, and the Canvas source route are open. Nothing has been submitted.

## What is handed in

| Item | Source | How it is made | Status |
|---|---|---|---|
| PDF report | `report/` | Compiled as [../report/README.md](../report/README.md) describes | **Draft with all results**, 13 pages; one red `[PENDING]` marker left, for the Canvas source route |
| Source with a run README | `code/` | `bash scripts/package_submission.sh`, from `code/`, at the final commit | Package tested; rebuild at the final commit |

**How source reaches Canvas is unconfirmed.** The brief lists "file upload, PDF only" and also requires source code. The group must
check the Canvas page. A repository link should not be assumed to meet the requirement. See [group_review.md](group_review.md).

## Brief and Lecture 12 against the current state

| Requirement | Points | Where | Status |
|---|---|---|---|
| Explain the algorithm | 5 | Report: Problem and Method | Drafted; group review open |
| Serial runtime against N | 5 | Report: Results; job `1528774` | **Measured** on a whole 64-core node, 10^4 to 3 x 10^6, three repetitions (earlier: `1523703`, shared node) |
| MPI strong and weak to at least 256 CPU cores, with speedup, efficiency, communication | 10 | Report: Scaling to 256 Cores on Four Nodes; job `1535991` | **Measured**, 1 to 256 cores on four nodes, three repetitions, own baselines; group review open |
| MPI+OpenMP analysis | 10 (shared with GPU) | Report: Results; `1528774` and `1535991` | **Measured** to 64 cores of one node and to 256 cores on four nodes (8 threads per rank), kept separate |
| At least one GPU test | | Job `1519638` | Measured; review open |
| Discussion of decisions, techniques, communication | 5 | Report: Parallelization Decisions, Discussion | Drafted with measured results; group review open |
| Scaling and efficiency discussion | | Report: Results, Discussion | Drafted from `1528774` and `1535991`; group review open |
| Parallel algorithm validated, with why each test matters | | Report: Correctness, Table 1 | Drafted |
| Runtime figures from Atlas or Vanda; logarithmic time, N and CPU axes | | `report_figures.py` | Generated from Vanda jobs `1528774` and `1535991` (the latter with the `b4_` prefix) |
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
| `code/scripts`, `manifests`, `jobs`, `docker` | Tools and tests that need the repository: `package_submission.sh`, `package_test.sh`, `repo_links_test.py`, `redact_evidence.py`, `report_figures_prefix_test.py` |

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
