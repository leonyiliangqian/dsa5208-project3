# Group checklist before hand-in

Due 17 November 2026 (per Leon, 10 Nov; cutoff time unconfirmed). **Not ready: required measurements and reviews are missing.** Nothing has been submitted.
Unticked means not done or not confirmed. Tick only what actually happened.

## Names and IDs

- [ ] Membership is final. Listed so far, unconfirmed: Yan Yixin, Zhang Yue, Leon Yiliang Qian.
- [ ] Each member's student ID is correct in the title block of `report/main.tex`. Not confirmed.

## Who actually reviewed what

The report's declaration must not claim more than this table. Each member fills in their own row. Nothing is recorded yet.

| Member | Code reviewed | Tests rerun | Report sections read | Figures and numbers checked |
|---|---|---|---|---|
| Yan Yixin | | | | |
| Zhang Yue | | | | |
| Leon Yiliang Qian | | | | |

## AI disclosure

- [ ] The declaration in `report/main.tex` matches [ai_usage.md](ai_usage.md) and the table above.
- [ ] Did AI help with the earlier serial code and design? Not established.
- [ ] Confirm the group review of the Project 3 statement in `report/main.tex`, which names OpenAI Codex, GPT and Claude.

## Results still missing

Keep the red `[PENDING]` markers for missing measurements until formal Vanda results are verified. Pilot timings are for sizing.

- [x] Serial runtime against N: measured in job `1528774`, a whole 64-core node (earlier `1523703`, 16 shared cores). Group review of the text still open.
- [ ] MPI strong and weak scaling to at least 256 CPU cores, with speedup and efficiency.
- [ ] MPI+OpenMP strong and weak scaling: to 64 cores of one node, from job `1528774`. Missing beyond one node, to 256 cores.
- [ ] Communication share of runtime and phase times: within one node only. Missing between nodes.
- [x] Ranks x threads, schedule, leaf size, and accuracy against cost: at 64 cores, job `1528774`.
- [ ] Measured findings, Discussion, Limitations from measurements, Conclusion.
- [ ] Memory per node, interconnect, and the nodes used for measurement.
- [ ] **256 cores:** Pilot4 was submitted under Leon's approval. See the [handoff](../HANDOFF.md) for job status. After it finishes, verify its
      gates and sizing data, then recheck the Vanda balance. If it passes, freeze the Bench4 manifest and obtain separate approval for the formal run.

## Report review

- [ ] Read the Results text, now from job `1528774` (7 Nov), especially the tree-build, schedule (8 x 8) and efficiency-above-1 paragraphs.
- [ ] Read: Terms Used, input generation, Table 1 (test purposes), Planned Studies, the lines marked "expected", Parallelization
      Decisions, What the Results Support, and the pilot paragraph in Results.
- [ ] GPU paragraph, against job `1519638`.

## Final PDF

- [ ] `grep -n 'pending{' report/main.tex` prints nothing.
- [ ] Every figure is regenerated from Vanda runs, with logarithmic time, N and core-count axes.
- [ ] No local simulation or pilot number appears as a result.
- [ ] Overleaf source matches `report/`, as `report/README.md` describes.
- [ ] Every page read in the final PDF, with final names, results and AI declaration.

## Final source

- [ ] **How source reaches Canvas:** the brief lists PDF upload and also requires source. Check Canvas; do not assume a repository
      link is enough. Not confirmed.
- [ ] `bash tests/jobs/package_test.sh` passes at the final commit, then build with `bash scripts/package_submission.sh`, both from `code/`.
- [ ] One member unzips the package elsewhere and follows its README from the start.
