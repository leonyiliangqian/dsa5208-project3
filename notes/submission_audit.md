# Submission audit

Checked 11 November 2026 against [assignment_brief.txt](assignment_brief.txt) and Lecture 12 in [project_memory.md](project_memory.md).
Due 17 November 2026 (confirmed by the lecturer's Canvas announcement, edited 10 Nov; it gives no time, so 23:59 is a planning assumption inherited from the original brief, not a verified Canvas cutoff). **Not ready to hand in:** the required measurements now exist, but group review,
names and IDs, and the Canvas source route are open. Nothing has been submitted.

## What is handed in

| Item | Source | How it is made | Status |
|---|---|---|---|
| PDF report | `report/` | Compiled as [../report/README.md](../report/README.md) describes | **Draft with all results**, 14 pages after the 11 Nov revision; one red `[PENDING]` marker left, for the Canvas source route |
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

## Verified, 11 November, at `ba10fb6` (candidate for hand-in)

Package `dsa5208-project3-source-ba10fb6.zip` (kept next to the repository, outside it): 83 files, SHA-256
`b972a4a1c8ba24fdf24285809389aff33a5ae890f0386a5e23f8939acef2a228`. No logs, terminal output, run records, binaries, caches, job cookies,
private keys, user names, numeric UIDs or personal paths; none of the repository-only tools or `report_figures_prefix_test.py`.
Unzipped outside the repository and run in the existing Docker image (`dsa5208-p3-dev:bookworm`), exactly as its Quick start says:
`make help` (now `awk`, since the image has no `column`), `make all hybrid gpu` (no warnings), `make check check-hybrid check-gpu`
(serial PASS, hybrid PASS, GPU host fallback 29 of 29), `tests/pipeline_e2e.sh` 42 of 42. Also from the package: `verify_run_test` 17 of 17,
`allocation_check_test` 13 of 13 (evidence replays skipped), `plan_budget_test`, `pbs_entry_test`, `launch_policy_test` 21 of 21.
In the repository: `package_test`, `repo_links_test`, `report_figures_prefix_test`, `allocation_check_test` 15 of 15, and `verify_run`
on `1523703`, `1528774`, `1535640`, `1535991` all PASS. Not tested from the package: a real GPU build (done on Vanda from the
repository) and a Vanda job. Later commits that touch only `notes/`, `report/` or the root files leave the package's contents unchanged;
rebuild it at the final commit anyway.

## Verified, 6 November, at `0647895`

The package was rebuilt after the figure and report scripts changed. It has 80 files and includes the reviewed `report_figures.py`. It has no logs, terminal output, run records,
job cookies, binaries, personal paths, `redact_evidence.py` or package tools. Extracted alone in Docker, it passed each command below again. `make check` also passes on macOS.

## Verified, 5 November, at `e86bf5d`

- `package_test` passes: 29 checks with three refusal controls; 80 files.
- Extracted alone, outside the repository, in Docker: `make all hybrid gpu`, `make check`, `make check-hybrid`, `make check-gpu`, each
  README command, `plan_budget_test`, `pbs_entry_test`, `pipeline_e2e` (42 of 42). `make check` also passes on macOS. No GPU was used.
- Not tested from the package: a real device build. That path ran on Vanda from the repository, in jobs `1514775` and `1519638`.
