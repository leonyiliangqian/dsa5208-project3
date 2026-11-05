# Project 3 readiness

> **Historical, 28 October.** Superseded by `requirements_plan.md` and `submission_audit.md`. Kept as a record; statuses here are out of date.

Updated 28 October 2026 from the supplied assignment and current local files.

## Requirements and evidence

| Requirement | Evidence to produce | Current status |
|---|---|---|
| C/C++/Fortran serial algorithm | Source, reproducible build, reference outputs | Serial C++ exists; limited local validation |
| MPI plus X | MPI+OpenMP source and run commands | `code/hybrid/bh_hybrid.cpp`, builds in Docker |
| Nontrivial parallelization | Explain global tree information, synchronization and imbalance | Barnes–Hut design exists |
| Different design choices | Controlled comparisons with common settings | Planned |
| Correctness | Direct vs serial, then serial vs hybrid; edge cases | Serial and hybrid gates pass locally (Docker); cluster rerun pending |
| Scaling and efficiency | Strong/weak scaling, rank/thread sweep, uncertainty | Pending |
| Atlas or Vanda runtimes | Raw job outputs, environment, figures | Pending |
| Real-data conclusions | Only if real data is used | Not applicable to synthetic Plummer inputs |
| AI explanation | Specific tools, contributions, human review | Log started in ai_usage.md |
| Group names and IDs | Verify report author line | Existing names/IDs retained, confirmation needed |
| Source and README | Clean reproducible source package | Starter only |
| PDF report | Rendered, checked final PDF | Template only |

## Local readiness

Run `python3 code/scripts/preflight.py` to refresh the tool inventory.
Apple clang can build the serial reference. MPI/OpenMP support and the HPC
compiler/module setup must be checked separately; an available compiler is not
proof of OpenMP support. No package installation or account change is assumed.

## Staged scope

1. Establish a trustworthy serial baseline and close tree edge-case issues.
2. Add MPI+OpenMP with replicated global positions/tree as a simple communication
   baseline, distributed target particles and MPI_THREAD_FUNNELED. Exchange updated
   particle states each step; keep MPI calls on the main thread.
3. Compare OpenMP static/dynamic scheduling and rank/thread configurations.
4. If time permits, add a distributed locally essential tree (LET) and compare it
   against the replicated baseline. Weighted ORB and task-based tree build are stretch goals.

This preserves a complete measurable MPI+X path before the more complex LET work.

## Milestones (Singapore dates)

| Target | Deliverable |
|---|---|
| 28–29 Oct | Confirm topic/group, check HPC access and scheduler, audit serial baseline |
| 29 Oct | Prepare optional progress update if useful; send only on explicit request |
| 30 Oct–2 Nov | Working MPI+OpenMP baseline and serial/hybrid validation |
| 3–5 Nov | Scheduling comparison; pilot cluster runs; choose feasible sizes |
| 6–9 Nov | Repeated strong/weak scaling and rank/thread experiments |
| 10–11 Nov | Figures and evidence-backed report draft |
| 12 Nov | Reproduction check, final PDF inspection, source packaging |
| 13 Nov | Submit before 23:59; leave time for upload problems |

## Blockers and next checks

- Vanda access works (28 Oct); allocation (`amgr login`, `hpc project`) and execution-queue limits still unverified. First correctness job prepared; scheduling pauses 29 Oct 18:00 to 2 Nov 17:00.
- Record scheduler, queue limits, CPU topology, modules and compiler/MPI versions
  before writing scheduler-specific scripts. Do not assume Slurm or PBS.
- Confirm how code is submitted alongside the PDF.
- Confirm existing group membership and IDs.
- Resolved 28 Oct: the tree is now built top-down with bucket leaves, so particles
  at maximum depth are retained; the traversal stack has a proven bound
  (7 x depth + 8); arguments are parsed strictly. `make check` covers empty,
  singleton, coincident, below-max-depth, unequal-mass and on-plane inputs,
  including particle retention, total mass and self-interaction exclusion.
- Old local timing numbers in design.md are historical, without saved provenance;
  exclude them from report results until reproduced and recorded.
