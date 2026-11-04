# Project 3 handoff: state of the work and how to finish the report

Status at handoff: 30 October 2026. Vanda is closed for maintenance until
**Mon 2 Nov 17:00 SGT**. Report due **13 Nov 2026 23:59 SGT**.

## Update, 3 November 2026 (read this first)

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
  Program, driver (`nvidia-smi` 100%, process listed) and mandatory offload agree. No GPU timing yet; the force
  traversal only is offloaded; fault-injection checks did not run on the GPU.
- **Pilot 1514774 measured nothing.** Exit 1 after 1 s: a relative `source` ran before the `cd`, since PBS starts in
  $HOME. 0 of 20 planned runs started, so there is **no sizing data**. Fixed locally in pilot, bench1, bench2 and
  bench4 and tested in Docker, not on Vanda. The rerun needs a new approval.
- **G2 GPU timing:** code and local tests ready (`jobs/vanda/gpu_timing.pbs`), refuses device fallback. Never run on
  a GPU. Still no GPU timing.
- **Pilot order risk:** `pilot_single_node.json` can skip every 64-core case if its serial cases run slow; `..._v2.json`
  has the same 20 runs with those first. See `notes/experiments.md`.
- **Still no scaling measurement.** 256 cores do not fit the free queue.
- **Next approvals:** [notes/approval_requests.md](notes/approval_requests.md). None granted.

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

All use `--queue auto_free --no-project` (zero charge rate; verify on the day).
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
| Submission overview | how source is submitted (ask lecturer); "Atlas or Vanda" -> Vanda |
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
| Report: pdfLaTeX `-shell-escape` + biber in `code/docker/tex` | compiles, 5 pages, no errors, undefined references or overfull boxes (the 5.5 pt overflow in `generated/hybrid_table.tex` was fixed on 30 Oct by narrower column spacing in `report_tables.py`; regenerated from Vanda job 1503779, numbers unchanged) |

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
