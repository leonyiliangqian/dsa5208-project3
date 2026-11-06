# Project 3 handoff: current status

**This is the only place for changing job status.** Report due **13 Nov 2026 23:59 SGT**. Not ready to hand in: see
[notes/group_review.md](notes/group_review.md). Everything under "History" is dated and may be out of date.

Where things are: [README.md](README.md) (entry point), [notes/README.md](notes/README.md) (notes index),
[notes/evidence_index.md](notes/evidence_index.md) (every job), [notes/submission_audit.md](notes/submission_audit.md) (requirements and package).

## Current status, 6 November 2026

| Job | State | Means |
|---|---|---|
| `1523703` `bench16` | **Finished, passed:** exit 0, 9 of 9 gates, 121 of 121 runs verified | **Formal 16-core results**, now in the report. One shared node; ranges are wide |
| `1522998` 64-core pilot | **Finished, passed:** exit 0, 5 of 5 gates, 20 of 20 runs verified, whole node | Sizing only. Answered the 64-core rules |
| `1523275` 16-core pilot | Finished, passed | Sizing only |
| `pilot2`, `bench1` | **Ready to request**, free, dry runs done on Vanda | Exact text in [notes/approval_requests.md](notes/approval_requests.md) |
| `pilot4`, `bench4` | Not ready: charged, need `pilot2` to pass and Leon's balance check | Up to 192 and 725 core-hours |

- **In the report:** serial runtime against N, strong and weak scaling to 16 cores, ranks x threads, schedule, leaf size, theta, communication share, all from `1523703`.
- **Still missing:** MPI strong and weak scaling to at least 256 cores, and communication between nodes. 10 points. Needs a charged queue.
- **Variability:** repetitions of one case differ by up to 61% on the shared node, so speedups are given as ranges. Efficiency above 1 appears and is reported, with
  the baseline effect shown; its cause is not established.
- **No job is queued or running.** Approvals: none open. Lecturer contact is closed. No job is retried without a new approval.
- **Redaction:** job cookies removed from committed evidence; see `code/artifacts/cluster/REDACTIONS.md`. Originals are owner-only in
  `/Users/leon.qian/Desktop/DSA5208/p3-evidence-originals-private`, outside the repository, and on Vanda.

**Next, in order:**

1. Leon decides on `pilot2` and `bench1`. Both are free; they cannot run at the same time.
2. Leon reads the balance with `amgr login` and decides on `pilot4`, then `bench4`, for 256 cores.
3. Group items in [notes/group_review.md](notes/group_review.md), including reading the new Results text.

## Status on 5 November 2026, superseded


| Job | State | Means |
|---|---|---|
| `1523275` 16-core pilot | **Finished, 14:51 SGT:** exit 0, 15 min 12 s, 5 of 5 gates, 20 of 20 runs, IN-002 | Provisional sizing only. Not a scaling result, and proves nothing at 64 or 256 cores |
| `1522998` 64-core pilot | **Queued at 17:20 SGT**, never started; waits for a whole node | Do not resubmit or cancel. Nothing is watching it. Check once with `qstat -xf 1522998` when asked |
| `1523703` `bench16` | **Running at 17:20:47 SGT**, IN-002, started 17:20:44, rate 0, 16 cores, 4 h limit; about 95 min expected | Formal free 16-core studies. Submitted once; do not resubmit or cancel. Nothing is watching it, and nothing is measured until its evidence is retrieved and verified |
| `pilot2`, `pilot4`, `bench4`, `bench1` | **Not approved**, sizes provisional | Order and rules in [notes/plan_256core.md](notes/plan_256core.md) |

- **Formal CPU results: none.** Serial against N, and MPI and MPI+OpenMP scaling, are all still `[PENDING]` in the report.
- **GPU test:** measured in job `1519638`, in the report, review open.
- **Biggest open item:** 256 cores, 10 points. It needs a charged queue, so Leon reads the balance with `amgr login` and decides.
- **Sizing from the pilot, provisional:** keep N_s = 10^6, 50,000 particles per core, theta 0.5, leaf size 8, dynamic chunk 64. All rules are in `plan_256core.md`.
- **New finding to test:** on the same 16 cores, 16 x 1 took about 1.9 times as long as 1 x 16, and exchange was only 1.3% of its time. One repetition; cause untested.
- **Approvals:** none open. Lecturer contact is closed. No job is retried without a new approval.

**Next, in order:**

1. When asked, retrieve and verify `1523703`. If a gate failed, diagnose and do not retry.
2. When asked, check `1522998` once. If it passes, apply the rules for its 64-core checks; if it fails, diagnose and do not retry.
3. Leon reads the balance and decides on 256 cores.
4. Group items in [notes/group_review.md](notes/group_review.md).

# History

Dated notes, newest first. Each was true when written; job states here are superseded by the table above.

## Update, 5 November 2026, before pilot16 finished

- **Pilot `1519637` failed at its third gate and measured nothing.** It ran 05:11:16 to 05:13:07 on IN-020 with exit 5, rate 0.
  `allocation` and `build` passed; `placement` timed out at 90 s. 0 of 20 runs started, so there is **no sizing data** and rule 1
  of `plan_256core.md` stops here. Only the CPU model is usable: Gold 6438N.
- **Cause, as far as shown:** the job asked for a hostfile launch, but mpirun still selected `tm`, the launcher that hung with
  binding in job 1514029. Same process state too. Why `tm` hangs with binding is still unknown.
- **Fix, commit `3f77e87`:** every job launches through `pbs_tmrsh`. Passed locally only; Docker has no PBS or `tm`.
- **Rerun submitted once: job `1522998`**, 5 Nov 13:46:25 SGT, source `3f77e87`, 1 x 64 cores, 120 GB, 60 min, `cpu_parallel`, rate 0.
  Queued at submission. Nothing is watching it. The approval is used up: do not resubmit or cancel it. The last wait was 10 h 1 min.
- **16-core pilot submitted once: job `1523275`**, 5 Nov 14:36:19 SGT, source `96a37ba`, 1 x 16 cores, 16 GB, 60 min, `cpu_parallel`,
  rate 0. Queued at submission. It sets provisional sizes only, and the 64-core checks remain. The approval is used up; nothing is
  watching either job. Do not resubmit or cancel either.
- **Report:** terms, input generation, test purposes and parallelization decisions are drafted. CPU results remain red `[PENDING]`
  markers, because none exists. It compiles to 8 pages in a scratch copy.
- **Source package:** checked by `code/tests/jobs/package_test.sh`. Group items are in [notes/group_review.md](notes/group_review.md).

## Update, 4 November 2026, 23:21 SGT

- **Done:** GPU timing (job 1519638) is in the report: the GPU was slower than the 36 CPU cores at every size. Please
  review that paragraph.
- **Waiting (superseded on 5 Nov):** pilot `1519637` was still queued at 23:20 SGT. It gives the sizes for everything below. Do not resubmit or cancel it. Nothing is watching it now: the 4-hour watch ended at 23:10, so check with `qstat -xf 1519637`.
- **Biggest open item:** 256 cores, 10 points. [notes/plan_256core.md](notes/plan_256core.md) has the job order, exact
  requests, charge assumptions, dry runs and the rules for using the pilot's results. All sizes are provisional and none of
  those jobs is approved.
- **Lecturer contact is closed:** Leon decided on 4 Nov that it is no longer needed. Do not draft or send lecturer messages.
  The final deadline stays 13 Nov 23:59 SGT.
- **Remaining decisions:**
  1. **Pilot sizing:** apply the rules in `plan_256core.md` once a pilot passes its gates (`1519637` did not; `1522998` is queued).
  2. **256-core access:** Leon reads the current balance with `amgr login`, then decides on charge approval.
  3. **Formal experiments:** each job needs its own approval, after its manifest is frozen.
  4. **Report review:** the group reviews the GPU paragraph, AI declaration, membership and student IDs, and how source is handed in.

## Update, 3 November 2026

- **New requirements:** [notes/project_memory.md](notes/project_memory.md) records Lecture 12.
  [notes/requirements_plan.md](notes/requirements_plan.md) maps the rubric to the plan and lists
  the 256-core check, GPU proposal and job proposals. Where this file differs, those win.
- **Vanda reopened.** Diagnostic job 1513781 ran once on 3 Nov and stopped after its allocation
  gate because `pbs_tmrsh` does not return remote output, so one node's CLEAN report was lost.
  Build and d1-d9 never ran: **the 1507215 stall is still unexplained and two-node solver
  correctness is still unverified.** Do not resubmit 1513781; a rerun is a new approval.
- **Fix:** commit 563d198, on `main`. Confirmed on Vanda by job 1514029 (22 of 22 CLEAN reports).
- **Stall narrowed by job 1514029:** tm launch with a PE mapping and core binding hangs, even for
  `hostname`; tm without them passes. Root cause unknown, and job 1514458 did not use tm.
- **Two-node correctness passed once, job 1514458 (commit 0b1f36b, `pbs_tmrsh`):** 17 of 17 gates; 22 of 22
  hybrid-serial cases matched exactly, 17 across both nodes. That comparison ran **unbound**. Bound evidence is
  separate: placement probes and one smoke run, none compared with serial. One job on one node pair; it does not
  cover 64-core nodes, more than 2 nodes or the charged pool. See `notes/experiments.md`.
- **Stale JSON label:** that run's validation JSON says `kind: local development validation`. It ran on Vanda.
  The files stay unchanged; validators now record `execution_context`. Do not edit the originals.
- **GPU validated on real hardware, job 1514775 (commit fa9da68):** NVIDIA A40, 4 of 4 gates, 23 of 23 checks.
  Program, driver (`nvidia-smi` 100%, process listed) and mandatory offload agree. The force
  traversal only is offloaded; fault-injection checks did not run on the GPU.
- **Pilot 1514774 measured nothing.** Exit 1 after 1 s: a relative `source` ran before the `cd`, since PBS starts in
  $HOME. 0 of 20 planned runs started, so there is **no sizing data**. Fixed locally in pilot, bench1, bench2 and
  bench4 and tested in Docker, not on Vanda. The rerun needs a new approval.
- **G2 GPU timing measured, job 1519638 (commit 8a50c8f):** NVIDIA A40 on GN-A40-004, 5 of 5 gates, 24 of 24 runs valid.
  **The GPU was slower than the 36 CPU cores at every size:** CPU/device 0.46, 0.61, 0.63 and 0.74 for N = 1e5, 3e5, 1e6
  and 3e6. The kernel is at least 97% of the gap; mapping and transfers are under 1% of device wall time. One job, one
  node, three repetitions. Cause not investigated. See `notes/experiments.md`.
- **Pilot v2 1519637 still queued** (22:50 SGT, 4 Nov; PBS: insufficient `node_pool`). No sizing data yet.
- **Pilot order risk:** `pilot_single_node.json` can skip every 64-core case if its serial cases run slow; `pilot_single_node_v2.json`
  has the same 20 runs with those first. See `notes/experiments.md`.
- **Still no scaling measurement.** 256 cores do not fit the free queue.
- **Approvals:** both requests in [notes/approval_requests.md](notes/approval_requests.md) are used. None is open.

## Written 30 October: status at that time, when Vanda was closed for maintenance until 2 Nov

## Open before submission (13 Nov 23:59 SGT)

| Gap | State | Who |
|---|---|---|
| **256-core MPI scaling, 10 points** | Not measured. The free queue stops at 160 CPUs per job and per user. `batch_cpu` fits but is charged at rate 1: up to 896 core-hours requested across `pilot4` and `bench4`, see [plan_256core.md](notes/plan_256core.md). Balance last read 29 Oct. No charged job is approved. | Leon: `amgr login`, charge decision |
| **Source submission** | Lecture 12 asks for code, Canvas lists PDF only; how to hand in source is unconfirmed, and the report has a pending marker. `code/scripts/package_submission.sh` builds the source zip. Check the Canvas submission page. | Group |
| **AI declaration** | Draft in `report/main.tex`, record in `notes/ai_usage.md`. Needs group review; provenance of the earlier serial code is unconfirmed; Codex's role in November needs confirming. | Group |
| Report results | GPU timing is in the report. Pilot is queued and formal runs have not run, so their figures stay pending. | After pilot, then approvals |
| Group details | Membership and student IDs in `report/main.tex`. | Group |

## The short version

- The code is complete for the baseline: serial Barnes–Hut, MPI+OpenMP
  replicated-tree solver, validation, and the whole measurement pipeline
  (manifests, runner, analysis, report figure and table generation).
- **Verified on Vanda:** single-node correctness (job 1503779, all 9 gates pass).
- **Verified once on Vanda:** two-node correctness, unbound comparison (job 1514458).
- **Not verified:** a bound result against serial, or anything beyond two 8-core allocations.
- **No performance measurement exists.** Every scaling figure and table in the
  report is still a red `\pending` slot, filled automatically once Vanda jobs
  have run.
- Every cluster job needs Leon's approval before submission (charging and site
  rules). Nothing below may be submitted without it.

## What you can write now, and what must wait

**Write now** (evidence exists): Introduction (minus findings); Problem and
Method; Parallel Implementation; Correctness for one node (Vanda job 1503779)
and two nodes (job 1514458, unbound); Computing Environment (node
types, build policy, placement); Experimental Methodology (timing, metrics,
planned studies, bounded runs, provenance); design Limitations; AI usage draft.

**Must wait for Vanda measurements**: the findings sentence in the
Introduction; leaf size and frozen manifest values; two-node correctness;
every Results subsection (figures and tables fill automatically from
`report_figures.py`); Discussion, measured Limitations and Conclusion.

## What is verified, and where the evidence is

Genuine Vanda evidence lives only under `code/artifacts/cluster/`. Everything
under `code/artifacts/local/` is local (macOS or Docker) and must never be
presented as a cluster result.

| Claim | Evidence | Source |
|---|---|---|
| Serial tree = direct summation at theta=0 (max rel. error <= 1e-10), edge-case self-test, sanitizers clean | `code/artifacts/cluster/runs/correctness-20261028T123124Z-1503779/` | **Vanda**, node IN-003 |
| Hybrid = serial, bitwise, 15 configurations (1–5 ranks, 1–4 threads, 3 schedules, uneven N, ranks owning nothing) | same run, `hybrid_validation_vanda-1503779.json` | **Vanda** |
| Placement: one thread per core, bound, inside the PBS cpuset | same run, `gate_place_*.log` | **Vanda** |
| Two hosts, exact 8-CPU cpusets, PBS tm launching, MPI data exchange between nodes (2 and 16 ranks) | `code/artifacts/cluster/runs/twonode-20261029T071525Z-1507215/` | **Vanda** (job then stalled) |
| Two-node hybrid = serial, exact, 22 cases (17 across both hosts), **unbound**; 8 bound placement probes and one bound smoke run, not compared with serial | `code/artifacts/cluster/runs/twonode-20261103T102750Z-1514458/` | **Vanda**, IN-002 + IN-005 |
| Real GPU execution and device correctness; no timing | `code/artifacts/cluster/runs/gpu_validate-20261103T134410Z-1514775/` | **Vanda**, GN-A40-005 |
| GPU timing against 36 CPU cores, N = 1e5 to 3e6, 3 repetitions | `code/artifacts/cluster/runs/gpu_timing-20261104T111747Z-1519638/` | **Vanda**, GN-A40-004 |
| Mixed CPU models in the free pool (Platinum 8452Y and Gold 6438N) | `code/artifacts/cluster/runs/twonode-20261029T053005Z-1506687/` | **Vanda** (job stopped by design) |
| Zero charge (balance 10000.0 after jobs 1503779 and 1506687; later jobs not re-checked, queue rate 0 at submission) | `code/artifacts/cluster/discovery/` | **Vanda** |
| Energy behaviour vs dt and theta; leaf-size and binding observations; mutation check | `code/artifacts/local/` | local only |
| Gate library fault injection 42/42; simulated twonode/diag/correctness/pilot/bench2 jobs; pipeline end to end 26/26 | `code/artifacts/local/runs/gates-selftest-*`, `simulated-*`, `pipeline-e2e-*` | local Docker simulation, **not** measurements |

The validation tables already in the report (`report/generated/*.tex`) are
generated from the Vanda correctness run by `code/scripts/report_tables.py`.

## What is missing

1. **Bound two-node comparison against serial.** Not done; job 1514458's comparison was unbound. The tm stall
   from 1507215 and 1514029 is unexplained and avoided by using `pbs_tmrsh`.
2. **Credit balance after job 1507215.** Needs `amgr login` (Leon's password).
3. **Single-node pilot** (`pilot.pbs`, 64 cores, 1 h). Job 1514774 failed at entry; rerun needs approval.
4. **Formal measurements** (strong, ranks x threads, schedule, weak, leaf,
   accuracy–cost). The manifests `code/manifests/studies_*.json` are *proposed*:
   their sizes are placeholders until the pilot. The bench jobs refuse to run
   until a manifest's status starts with `frozen`.

## Commands after the reopening (each submission needs approval)

On the Mac: start the SSH master (Leon enters the password), then on Vanda:

```sh
amgr login                                   # Leon; for the balance check
cd ~/<new clone of the latest commit>/code
bash jobs/vanda/preflight.sh                 # read-only: queues, modules, balance
bash jobs/vanda/submit.sh diag    --queue auto_free --no-project          # dry run, prints qsub
bash jobs/vanda/submit.sh diag    --queue auto_free --no-project --yes    # ONLY after approval
```

Diagnostic and two-node correctness are done. Then, in order, each after approval and after the previous one is understood:

| Step | Command (from `code/`) | Request |
|---|---|---|
| Pilot | `submit.sh pilot ...` | 1 x 64 cores, 120 GB, 60 min |
| Freeze manifests | edit sizes in `manifests/studies_*.json` from pilot timings, set `"status": "frozen <date> <commit>"`, commit | — |
| Formal single node | `submit.sh bench1 ...` (set walltime from the pilot first) | 1 x 64 cores |
| Formal two node | `submit.sh bench2 ...` | 2 x 64 cores, one CPU model |
| 256-core series | `submit.sh bench4 ...` (replaces bench2 for the graded curves; charged queue, see requirements_plan.md) | 4 x 64 cores, one CPU model |

All but `bench4` use `--queue auto_free --no-project` (zero charge rate; verify on the day). `pilot4` and `bench4` are charged; see [plan_256core.md](notes/plan_256core.md).
Bring results back with `tar czf` of `artifacts/cluster/runs/<run>` and the
matching `artifacts/cluster/logs/<job>.OU`, unpack into `code/` and commit.

Then generate the report's results from the Vanda runs only:

```sh
cd code
python3 scripts/analyze.py artifacts/cluster/runs/bench1-* artifacts/cluster/runs/bench2-* \
    --out artifacts/cluster/analysis/formal
python3 scripts/report_figures.py artifacts/cluster/analysis/formal/summary.json
# writes report/generated/fig_*.tex and tab_*.tex; the Results slots pick them up
```

Pass every summary in one command, including `artifacts/cluster/runs/gpu_timing-20261104T111747Z-1519638/summary.json`.
`tab_failed_runs.tex` lists only its inputs, so it was left out while the GPU job was the only input.

`report_figures.py` refuses anything outside `artifacts/cluster/` for the report.

## Report: what is written and what is pending

Source: `report/main.tex` (compile in Overleaf; see `report/README.md`). Drafted:
Introduction (minus findings), Problem and Method, Parallel Implementation,
Correctness (one and two nodes, from Vanda), Computing Environment, Experimental
Methodology (timing, metrics, planned studies, bounded runs, provenance),
Limitations (design part), AI usage statement (draft).

Red `\pending{...}` markers still to resolve:

| Section | Pending |
|---|---|
| Submission overview | how source is submitted (check Canvas); "Atlas or Vanda" -> Vanda |
| Introduction | main measured findings (2–3 sentences) |
| Serial Baseline | leaf size re-tuned on the cluster (pilot) |
| Computing Environment | memory per node, interconnect, single-node-type enforcement, nodes used |
| Planned Studies | frozen manifest values |
| Results (7 slots) | figures/tables fill automatically from `report_figures.py`; interpretation text per subsection |
| Discussion, Limitations, Conclusion | after results |
| AI usage | group review; provenance of the earlier serial code |

Writing rules we have followed: no number typed by hand into results; local
timings never reported as performance; no cause claimed without evidence (e.g.
the energy plateau and the 1507215 stall are explicitly unexplained).

## Verification done for this handoff (30 Oct, local only)

From a fresh clone of commit `fc338c5` (tracked tree clean):

| Check | Result |
|---|---|
| `make check` on macOS (serial gate) | PASS |
| `make check check-hybrid` in Docker (serial + 15-configuration hybrid gate) | PASS |
| `tests/pipeline_e2e.sh` (manifest -> runs -> analysis -> figures; timeout, deadline, interruption, refusal) | 26/26 PASS |
| `tests/jobs/gates_selftest.sh` on two simulated nodes | 42/42 PASS |
| Simulated `twonode`, `diag`, `correctness`, `bench2` jobs | verdict PASS (diag: optional d8 SKIP, no pbs_tmrsh locally) |
| Simulated `pilot` job (local test manifest) | runs gate FAIL only because the test manifest contains a deliberate 3 s timeout probe |
| Report: pdfLaTeX `-shell-escape` + biber in `code/docker/tex` | compiles, 6 pages with the GPU timing, no errors, undefined references or overfull boxes (the 5.5 pt overflow in `generated/hybrid_table.tex` was fixed on 30 Oct by narrower column spacing in `report_tables.py`; regenerated from Vanda job 1503779, numbers unchanged) |

Evidence: `code/artifacts/local/runs/*-20261030T092*` (each records commit
`fc338c5`). These are simulations and tests, never measurements.

Overleaf needs `-shell-escape` for the `minted` package, which Overleaf
enables by default.

## Checking the code yourself

```sh
cd code
make check                                       # serial gate (macOS or Linux)
docker/run.sh make check check-hybrid            # serial + hybrid gates in Linux
docker/run.sh bash tests/pipeline_e2e.sh         # measurement pipeline, tiny inputs
docker/twonode/run.sh 'bash tests/jobs/gates_selftest.sh'   # gate library on two simulated nodes
```

More detail: `notes/experiments.md` (protocol and every Vanda finding),
`notes/cluster_access.md` (Vanda runbook), `notes/experiment_manifest.md`
(study design), `notes/ai_usage.md` (AI-use record).
