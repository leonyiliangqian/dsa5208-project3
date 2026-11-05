# AI-use record

Update this record throughout the project; review the final statement as a group.

| Date | Tool | Work performed | Review status |
|---|---|---|---|
| 5 Nov 2026 | Claude Code (Claude Opus 5.5) | Retrieved and checked the evidence of failed pilot 1519637; compared it with earlier launcher runs; changed one-node jobs to `pbs_tmrsh`; tightened the allocation check; added tests; drafted the rerun request | Leon: evidence and fix pending review; no job submitted |
| 3-4 Nov 2026 | Claude Code (Claude Opus 5.5) | Lecture 12 plan; OpenMP target GPU solver and validator; `pbs_tmrsh` launcher; G2 timing runner and fallback refusal; job-entry and execution-label fixes; submitted Vanda jobs 1513781, 1514029, 1514458, 1514774 and 1514775 one at a time after Leon's approval, and analysed them; report text and package audit | Leon directed and approved jobs; group review pending |
| 30 Oct 2026 | Claude Code (Claude Opus 5.5) | Gate library review (ownership-based cleanup, gate kinds, time accounting); machine-readable manifests and runner with per-run timeouts and deadlines; process-group timeouts in run_case.py; multi-run analysis; pgfplots figure/table generator with local-evidence refusal; pilot and benchmark jobs on a shared gated body; end-to-end pipeline and fault-injection tests; report result slots; teammate handoff | Local tests and simulations only; no cluster job submitted; no performance measurement |
| 29-30 Oct 2026 | Claude Code (Claude Opus 5.5) | Two-node job revisions (portable build, forced PBS tm launch with verified selection); submitted authorised jobs 1506687 and 1507215 and retrieved their evidence; local diagnosis of the 1507215 stall (two-container simulation, traced placement probe); bounded gates with cleanup checks and fault-injection test; diagnostic job diag.pbs (not submitted); report text on two-node status, node pool and bounded runs | Two-node solver correctness unverified on Vanda; stall cause unknown; simulations are local evidence only |
| 28 Oct 2026 | OpenAI Codex (ChatGPT) | Inspected the existing starter; updated requirements, milestones, staged implementation and experiment plans; added tool inventory and serial validation runner; corrected stale report placeholders | Setup checks run; group review pending |
| 29 Oct 2026 | Claude Code (Claude Opus 5.5) | Peak-memory reporting in both drivers; inter-node MPI probe; multi-host placement checks; multinode hybrid gate suite with host-count check; two-node correctness job and single-node pilot job (both tested in local simulation, not submitted); proposed experiment manifest; updated progress-report draft (not sent) | Local gates pass; Vanda jobs await user approval |
| 28 Oct 2026 | Claude Code (Claude Opus 5.5) | Used the user's SSH control session to read allocation and queue rules, transfer the bundle and run preflight; submitted the correctness job 1503779 the user authorised; retrieved and checked its evidence; fixed git-revision provenance on git-less compute nodes; regenerated report tables from Vanda evidence | All 9 gates passed on Vanda; credit balance re-check pending |
| 28 Oct 2026 | Claude Code (Claude Opus 5.5) | Vanda preparation from Codex's discovery note: placement probe, PBS correctness job, read-only preflight, guarded submit wrapper, Vanda runbook; report placement/environment text | Job tested in local PBS simulation only; not yet run on Vanda |
| 28 Oct 2026 | Claude Code (Claude Opus 5.5) | Third pass: reviewed run recording/analysis (setup timing alignment, embedded build flags, effective threads, placement and build in configuration keys, explicit allocated cores, oversubscription rejection); retained binding and leaf-size evidence; extended energy study over theta; generated report tables from evidence; verified bibliography entries online; drafted report method, design, correctness and methodology sections; cluster transfer guide; revised progress-report draft (not sent); Git checkpoint | Gates re-run locally; report and draft need group review |
| 28 Oct 2026 | Claude Code (Claude Opus 5.5) | Second pass against the execution brief: cells containing the target are always opened; int32 overflow guards; analytic, symmetric and negative-control tests; sanitizer build; Docker GCC/Open MPI environment and toolchain probes; MPI+OpenMP replicated-tree solver; hybrid validation harness and mutation check; energy/timestep study; run recorder, analysis script, local pilot; cluster discovery script; documentation | Serial and hybrid gates pass locally; group review pending |
| 28 Oct 2026 | Claude Code (Claude Opus 5.5) | Moved shared tree/physics code into `code/common/nbody.hpp`; rewrote the octree build with bucket leaves to fix the maximum-depth particle drop; bounded the traversal stack; added strict argument parsing, an edge-case self-test and extended `make check`; added `make help` modelled on Project 1 | `make check` passes locally; group review of code pending |

Earlier serial code and design predate this setup pass. Their AI provenance has
not been established here; confirm it rather than assuming independent authorship.
Record future AI assistance with code, debugging, experiment design, analysis,
figures and report writing, plus the checks performed by the group.

## Declaration draft (update before submission)

The current wording is in `report/main.tex` (AI usage). Before submission, confirm as a group:
- what each member actually reviewed and checked (the draft must not claim more);
- whether AI helped with the earlier serial code and design (provenance unconfirmed);
- what role OpenAI Codex had in November: messages in the Claude session refer to a "Codex Claude-check schedule", so it may
  have supervised this work, and that belongs in the declaration if so.
