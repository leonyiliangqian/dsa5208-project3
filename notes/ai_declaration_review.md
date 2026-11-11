# AI declaration: current statement, alternative draft, open discrepancies

Written 11 November 2026 for the group. **Nothing here changes the report.** The statement in `report/main.tex` stays as it is
until the group decides. Sources: [ai_usage.md](ai_usage.md), the brief's sample declaration in
[assignment_brief.txt](assignment_brief.txt), and `git log` commit trailers.

## Current statement (in the report, unchanged)

Added in commit `376890d` (6 Nov, "Use the group-approved AI usage statement in the report"). On 11 Nov Leon confirmed that he
supplied and approved this exact wording. No other member's sign-off is recorded in this repository.

> The group independently developed the experimental design and workflow, including the plans for data processing and results
> analysis. OpenAI Codex, GPT and Anthropic's Claude assisted with code implementation and review, environment configuration, data
> processing and analysis following the group's plans, experiment execution, result verification, and report drafting and revision.

## Where the record and the statement disagree

| # | Statement says | Record says | For the group to resolve |
|---|---|---|---|
| 1 | "The group independently developed the experimental design and workflow, including the plans" | `ai_usage.md` has AI drafting plans: Codex "updated requirements, milestones, staged implementation and experiment plans" (28 Oct); Claude Code "proposed experiment manifest" (29 Oct), "machine-readable manifests and runner" (30 Oct), the "Lecture 12 plan" (3-4 Nov), "proposed the 16-core pilot" and "proposed `bench16` and resized plans" (5 Nov), "applied the 64-core sizing rules; refit budgets; froze bench1" (6 Nov) | Drafting a plan is not the same as making the design decision. The record shows that Leon directed the work and approved every job and charge. It does **not** record who chose the algorithm, the replicated-tree design, the studies or the sizes. If group members made those choices, say so specifically. If AI proposed them and the group accepted them, "independently developed" overstates it |
| 2 | "following the group's plans" | Same entries: many of the plans were AI drafts | Same as 1 |
| 3 | Tools: "OpenAI Codex, GPT and Anthropic's Claude" | Recorded: Claude Code with Claude Opus 5.5 (every Claude row, and 102 commit trailers "Claude Opus 5.5"); OpenAI Codex (ChatGPT), 28 Oct. **No row records GPT used separately from Codex** | Was GPT used outside Codex? If so, record it with what it did. The brief's sample names the tool and model. The Codex model is not recorded; do not guess it |
| 4 | Lists AI tasks in general terms | AI also wrote or rewrote core source: shared octree build (bucket leaves, depth fix), MPI+OpenMP solver, GPU solver and validator, launchers, gates, analysis and figure scripts, `verify_run.py`; submitted Vanda jobs after Leon's approval; drafted Results, Discussion and Conclusion text | Decide whether "code implementation" is specific enough. The brief asks for "specific uses" |
| 5 | Silent on the earlier serial code | `ai_usage.md`: "Earlier serial code and design predate this setup pass. Their AI provenance has not been established" | Whoever wrote it states whether AI was used |
| 6 | Silent on responsibility | The brief's sample ends "I am responsible for the content and quality of the submitted work" | Consider adding "We are responsible for the content and quality of the submitted work" |
| 7 | — | `git log` shows 28 commits from 7 to 11 Nov with a "Claude Opus 5.5" co-author trailer. On 11 Nov, rows for 7, 8 and 10 Nov were added to `ai_usage.md`. They were reconstructed from those commits and the run records and are labelled as such (22 commits; none on 9 Nov). Still not covered: the 6 commits of 11 Nov 01:47-02:01 (`8c0fd3e` to `c1f67d9`), which added bench4's evidence, the 256-core report section and the source package. Commit `04a7458` (10 Nov) has no AI trailer, and who made it is unknown | Check the reconstructed rows. Decide whether to add a row for the early 11 Nov commits and whether the reconstruction is accurate enough to cite |
| 8 | — | `ai_usage.md` mentions a possible "Codex Claude-check schedule" in November | Confirm whether Codex supervised or checked Claude's work. If it did, it belongs in the declaration |
| 9 | — | Commit `376890d` calls the statement "group-approved", but [group_review.md](group_review.md) leaves "Confirm the group review of the Project 3 statement" unticked | Tick it only when each member has agreed |

## Alternative draft, supported by the record

Square brackets mark facts only the group can supply. Do not submit them unresolved.

> We used two AI tools: Anthropic's Claude, through Claude Code with the Claude Opus 5.5 model, and OpenAI Codex (ChatGPT)
> [add GPT if used separately, with what it did]. Codex helped at the start to organise the requirements, milestones and an
> initial experiment plan, and added a serial validation runner. Claude Code wrote or revised much of the source code, including the
> octree build, the MPI+OpenMP and GPU solvers, the validation tests, the cluster job scripts and the measurement, analysis and
> figure scripts. It also drafted the experiment plans, manifests and sizing rules, submitted each Vanda job only after a group
> member approved it, retrieved and checked the results, generated the figures and tables from the run records, and drafted and
> revised most sections of this report. [Group: state the decisions members made themselves, for example the choice of
> algorithm, the replicated-tree design, which studies to run, and approving each job and the charged four-node runs.]
> [Group: state whether AI was used for the earlier serial code.] [Group: state what each member reviewed and checked, matching
> group_review.md.] We are responsible for the content and quality of the submitted work.

The draft names the model only where the record names it, and claims no independent authorship, serial-code provenance or member
review that the record does not show.
