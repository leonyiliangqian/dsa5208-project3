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
- [x] MPI strong and weak scaling to 256 CPU cores, with speedup and efficiency: job `1535991` (4 nodes, Platinum 8452Y), verified 11 Nov, in the report. Group review of the text still open.
- [x] MPI+OpenMP strong and weak scaling: to 64 cores of one node (`1528774`, Gold 6438N) and to 256 cores on four nodes (`1535991`, Platinum 8452Y), kept separate with their own baselines.
- [x] Communication share of runtime and phase times: within one node (`1528774`) and across four nodes (`1535991`).
- [x] Ranks x threads, schedule, leaf size, and accuracy against cost: at 64 cores, job `1528774`.
- [ ] Measured findings, Discussion, Limitations from measurements, Conclusion.
- [x] Memory per node and the nodes used for measurement; the interconnect was not characterised (stated in the report).
- [x] **256 cores:** `pilot4` `1535640` (sizing) and `bench4` `1535991` (formal) passed and were verified; balance after `bench4` to be read by Leon (expected 9,040).

## Report review

- [ ] Read the Results text: `1528774` (one node) and the new four-node subsection from `1535991` (11 Nov), especially the tree-build, exchange and weak-scaling paragraphs.
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
