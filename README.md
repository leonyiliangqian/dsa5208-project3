# DSA5208 Project 3: MPI+OpenMP Barnes–Hut

Due **13 November 2026, 23:59 Singapore time**. Worth **35 points**.

Existing group listing: Yan Yixin, Zhang Yue, Leon Yiliang Qian. Confirm the
membership and student IDs in `report/main.tex` before submission.

**Teammates writing the report: start with [HANDOFF.md](HANDOFF.md).**

## Current state (30 October 2026)

- Topic: Barnes–Hut n-body, C++17, MPI+OpenMP.
- Serial reference audited and fixed; serial gate passes on macOS, Docker and Vanda.
- Replicated-tree MPI+OpenMP solver matches serial bitwise in 15 configurations,
  locally (Docker) and on a Vanda compute node.
- Vanda (PBS) correctness job 1503779 passed all 9 gates on node IN-003 (8 cores,
  zero-rate `auto_free`).
- Two-node solver correctness on Vanda is **unverified**: job 1506687 stopped at
  the allocation check; job 1507215 verified two hosts, the 8-CPU cpusets and PBS
  tm launching, then stalled in a placement probe until the walltime. Gates now
  have time limits and cleanup checks, and a small diagnostic job
  (`code/jobs/vanda/diag.pbs`) is prepared but not submitted. Benchmarks start
  after the 2 Nov 17:00 reopening. See notes/experiments.md and notes/cluster_access.md.
- Measurement pipeline complete and tested locally (manifests, time-limited runs,
  analysis, report figures/tables); no performance measurement exists yet.
- Report: method, parallel design, correctness (Vanda) and methodology drafted
  in `report/` for Overleaf; results slots fill from Vanda runs only.

## Limitations at this point (read before writing)

- Single-node correctness passed on Vanda (job 1503779).
- **Two-node solver correctness is unverified** (jobs 1506687 and 1507215 did
  not reach the solver comparison; evidence kept).
- **Local Docker simulations are tests, not Vanda performance results.**
- **No formal cluster scaling measurement has been collected.**
- Vanda scheduling was confirmed disabled for maintenance (30 Oct); reopening
  was announced for **2 November 17:00 SGT**. Every cluster job needs Leon's
  approval first.

## Start here

```sh
cd code
make check                                   # serial gate (macOS or Linux)
docker/run.sh make check check-hybrid        # serial + hybrid gates in Linux (Docker)
docker/run.sh bash tests/pipeline_e2e.sh     # measurement pipeline on tiny inputs
docker/twonode/run.sh 'bash tests/jobs/gates_selftest.sh'   # job gate library, two simulated nodes
```

Report figures and tables are generated, never typed: `code/scripts/report_tables.py`
(validation tables, from the Vanda correctness run) and `code/scripts/report_figures.py`
(scaling results, from Vanda runs only). See [HANDOFF.md](HANDOFF.md) for the
commands and [code/README.md](code/README.md) for details.

## Evidence

| Where | What | Status |
|---|---|---|
| [code/artifacts/cluster/](code/artifacts/cluster/) | Genuine Vanda runs (passed and failed jobs), PBS logs, site and charging checks | cluster evidence |
| [code/artifacts/local/](code/artifacts/local/) | macOS/Docker validation, simulations and pipeline tests | local only, never results |

| File | Purpose |
|---|---|
| [HANDOFF.md](HANDOFF.md) | State of the work, evidence, commands after reopening, pending report items |
| [notes/assignment_brief.txt](notes/assignment_brief.txt) | Assignment wording |
| [notes/project_memory.md](notes/project_memory.md) | Lecture 12 requirements and grading |
| [notes/requirements_plan.md](notes/requirements_plan.md) | Rubric, 256-core check, GPU proposal, job proposals |
| [notes/approval_requests.md](notes/approval_requests.md) | Exact job commands awaiting approval |
| [notes/project3_prep.md](notes/project3_prep.md) | Requirements, milestones and blockers |
| [notes/design.md](notes/design.md) | Algorithm design and staged scope |
| [notes/experiments.md](notes/experiments.md) | Validation and scaling protocol; every Vanda job and finding |
| [notes/experiment_manifest.md](notes/experiment_manifest.md) | Study design (machine-readable plans in `code/manifests/`) |
| [notes/ai_usage.md](notes/ai_usage.md) | AI-use record and declaration draft |
| [notes/cluster_access.md](notes/cluster_access.md) | Vanda runbook |
| [notes/progress_report_draft.md](notes/progress_report_draft.md) | Optional progress report draft (not sent) |
| [code/](code/) | C++17 serial and MPI+OpenMP solvers, tests, measurement pipeline, Vanda jobs |
| [report/](report/) | Overleaf-ready report source; method and validation drafted, results pending |

## Submission

Submit a PDF covering the algorithm, design choices, validation, scaling and
efficiency, runtime figures from **Atlas or Vanda**, and AI usage. Include names
and student IDs for group work. Real-data conclusions apply only if real data
is used; the current design uses synthetic inputs.

Lecture 12: include source code; exclude logs and terminal output
(`code/scripts/package_submission.sh` builds the source package from the committed tree).

The brief also requires source code and a run README, although the listed upload
type is PDF. Confirm the source delivery mechanism with the lecturer or Canvas;
do not assume a repository link alone meets the requirement. No email has been sent.
