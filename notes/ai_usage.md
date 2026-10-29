# AI-use record

Update this record throughout the project; review the final statement as a group.

| Date | Tool | Work performed | Review status |
|---|---|---|---|
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

We used OpenAI Codex (ChatGPT) to review the project starter, organize requirements
and milestones, refine the proposed parallelization and validation plans, and
create setup and validation scripts. [Add all further AI uses, including assistance
with earlier code/design if applicable.] We reviewed [specify the work reviewed]
and validated [specify the checks actually completed]. We are responsible for the
content and quality of the submitted work.

Use the policy links in the assignment; do not claim this log itself establishes
compliance. Cite external algorithms, code and text actually used.
