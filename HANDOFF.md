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
- **Fix:** commit 563d198, merged to `main`. Tested locally only; not yet tried on Vanda.
- **Still no GPU code and no scaling measurement.** 256 cores do not fit the free queue.

## The short version

- The code is complete for the baseline: serial Barnes–Hut, MPI+OpenMP
  replicated-tree solver, validation, and the whole measurement pipeline
  (manifests, runner, analysis, report figure and table generation).
- **Verified on Vanda:** single-node correctness (job 1503779, all 9 gates pass).
- **Not verified on Vanda:** two-node correctness (two attempts, neither reached
  the solver comparison).
- **No performance measurement exists.** Every scaling figure and table in the
  report is still a red `\pending` slot, filled automatically once Vanda jobs
  have run.
- Every cluster job needs Leon's approval before submission (charging and site
  rules). Nothing below may be submitted without it.

## What you can write now, and what must wait

**Write now** (evidence exists): Introduction (minus findings); Problem and
Method; Parallel Implementation; Correctness for one node (Vanda job 1503779)
and the honest status of the two-node attempts; Computing Environment (node
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
| Mixed CPU models in the free pool (Platinum 8452Y and Gold 6438N) | `code/artifacts/cluster/runs/twonode-20261029T053005Z-1506687/` | **Vanda** (job stopped by design) |
| Zero charge (balance 10000.0 after jobs 1503779 and 1506687; 1507215 not yet re-checked) | `code/artifacts/cluster/discovery/` | **Vanda** |
| Energy behaviour vs dt and theta; leaf-size and binding observations; mutation check | `code/artifacts/local/` | local only |
| Gate library fault injection 42/42; simulated twonode/diag/correctness/pilot/bench2 jobs; pipeline end to end 26/26 | `code/artifacts/local/runs/gates-selftest-*`, `simulated-*`, `pipeline-e2e-*` | local Docker simulation, **not** measurements |

The validation tables already in the report (`report/generated/*.tex`) are
generated from the Vanda correctness run by `code/scripts/report_tables.py`.

## What is missing

1. **Two-node correctness.** Job 1507215 stalled in a placement probe (one rank
   per node bound to all 8 cores) and hit its walltime before the hybrid–serial
   comparison. Cause unknown; it does not reproduce locally. A small diagnostic
   job (`code/jobs/vanda/diag.pbs`) is ready, awaiting approval.
2. **Credit balance after job 1507215.** Needs `amgr login` (Leon's password).
3. **Single-node pilot** (`pilot.pbs`, 64 cores, 1 h). Not approved yet.
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

Then, in order, each after approval and after the previous one is understood:

| Step | Command (from `code/`) | Request |
|---|---|---|
| Diagnostic | `submit.sh diag ...` | 2 x 8 cores, 4 GB, 20 min |
| Two-node correctness | `submit.sh twonode ...` | 2 x 8 cores, 16 GB, 30 min |
| Pilot | `submit.sh pilot ...` | 1 x 64 cores, 120 GB, 60 min |
| Freeze manifests | edit sizes in `manifests/studies_*.json` from pilot timings, set `"status": "frozen <date> <commit>"`, commit | — |
| Formal single node | `submit.sh bench1 ...` (set walltime from the pilot first) | 1 x 64 cores |
| Formal two node | `submit.sh bench2 ...` (only after two-node correctness) | 2 x 64 cores, one CPU model |
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
Correctness (single node, from Vanda), Computing Environment, Experimental
Methodology (timing, metrics, planned studies, bounded runs, provenance),
Limitations (design part), AI usage statement (draft).

Red `\pending{...}` markers (19) still to resolve:

| Section | Pending |
|---|---|
| Submission overview | how source is submitted (ask lecturer); "Atlas or Vanda" -> Vanda |
| Introduction | main measured findings (2–3 sentences) |
| Serial Baseline | leaf size re-tuned on the cluster (pilot) |
| Correctness | two-node hybrid–serial comparison and the diagnostic outcome |
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
