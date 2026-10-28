# DSA5208 Project 3: MPI+OpenMP Barnes–Hut

Due **13 November 2026, 23:59 Singapore time**. Worth **35 points**.
Optional progress report: **before 30 October**; prepare by 29 October if using it.

Existing group listing: Yan Yixin, Zhang Yue, Leon Yiliang Qian. Confirm the
membership and student IDs in `report/main.tex` before submission.

## Current state (28 October 2026)

- Topic: Barnes–Hut n-body, C++17, MPI+OpenMP.
- Serial reference audited and fixed; serial gate passes on macOS and Docker Linux.
- Replicated-tree MPI+OpenMP solver implemented; matches serial bitwise in 15
  local configurations (Docker, Open MPI 4.1.4, GCC 12). Local evidence only.
- Report: method, parallel design, local correctness and methodology drafted
  in `report/` for Overleaf; cluster results sections pending.
- Vanda (PBS) access works. First correctness job `code/jobs/vanda/correctness.pbs`
  is ready and tested in a local PBS simulation; submission needs the allocation
  (`amgr login`, preflight) before scheduling stops on 29 Oct 18:00. Benchmarks
  resume after the 2 Nov 17:00 reopening. See notes/cluster_access.md.

## Start here

```sh
cd code
make check                        # serial gate (macOS or Linux)
docker/run.sh make check-hybrid   # hybrid gate in the Linux container
```

See [code/README.md](code/README.md) for outputs and limitations.

| File | Purpose |
|---|---|
| [notes/assignment_brief.txt](notes/assignment_brief.txt) | Assignment wording |
| [notes/project3_prep.md](notes/project3_prep.md) | Requirements, milestones and blockers |
| [notes/design.md](notes/design.md) | Existing algorithm design and staged scope |
| [notes/experiments.md](notes/experiments.md) | Validation and scaling protocol |
| [notes/ai_usage.md](notes/ai_usage.md) | AI-use record and declaration draft |
| [notes/cluster_access.md](notes/cluster_access.md) | Login, project transfer and discovery steps |
| [notes/progress_report_draft.md](notes/progress_report_draft.md) | Optional progress report, draft only |
| [code/](code/) | Serial source and validation runner |
| [report/](report/) | Overleaf-ready report source; method/validation drafted, results pending |

## Submission

Submit a PDF covering the algorithm, design choices, validation, scaling and
efficiency, runtime figures from **Atlas or Vanda**, and AI usage. Include names
and student IDs for group work. Real-data conclusions apply only if real data
is used; the current design uses synthetic inputs.

The brief also requires source code and a run README, although the listed upload
type is PDF. Confirm the source delivery mechanism with the lecturer or Canvas;
do not assume a repository link alone meets the requirement. No email has been sent.
