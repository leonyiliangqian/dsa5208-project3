# Group checklist before hand-in

Due 13 November 2026, 23:59 SGT. **Not ready: required measurements and reviews are missing.** Nothing has been submitted.
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
- [ ] Did OpenAI Codex have a role in November? Some session messages mention a "Codex Claude-check schedule". Not established.

## Results still missing

These stay as red `[PENDING]` markers until Vanda runs fill them. Pilot `1523275` does not fill any of them.

- [ ] Serial runtime against N.
- [ ] MPI strong and weak scaling to at least 256 CPU cores, with speedup and efficiency.
- [ ] MPI+OpenMP strong and weak scaling.
- [ ] Communication share of runtime and phase times.
- [ ] Ranks x threads, schedule, leaf size, and accuracy against cost.
- [ ] Measured findings, Discussion, Limitations from measurements, Conclusion.
- [ ] Memory per node, interconnect, and the nodes used for measurement.
- [ ] **256 cores:** Leon reads the balance with `amgr login` and decides on charge approval. Without it, the report must say that
      scaling stops short of 256 cores.

## Report review

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
