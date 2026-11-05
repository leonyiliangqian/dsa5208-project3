# Group review before final submission

Due 13 November 2026, 23:59 SGT. Nothing here has been submitted.

## Decisions and details only the group can settle

- [ ] **Student details:** confirm the three names and student IDs in `report/main.tex`, and that the membership is final.
- [ ] **AI disclosure:** confirm what each member actually reviewed. The draft says the group reviewed the code, tests and text.
- [ ] **AI provenance:** did AI help with the earlier serial code and design? This is not established. Did OpenAI Codex have a
      role in November? Some session messages mention a "Codex Claude-check schedule". Update the statement and `notes/ai_usage.md`.
- [ ] **Source hand-in:** Lecture 12 asks for source, while Canvas lists PDF only. Check Canvas for how to hand it in.
- [ ] **Report text:** read the new or changed parts: Terms Used, input generation, Table 1 (test purposes), Planned Studies, the
      lines marked "expected", Parallelization Decisions and What the Results Support.
- [ ] **GPU paragraph:** review it against job 1519638.
- [ ] **256 cores:** Leon decides on charge approval, after reading the balance with `amgr login`. Without it, the report must
      say that scaling stops short of 256 cores.

## Results still missing

No CPU scaling result exists. These stay as red `[PENDING]` markers until Vanda runs fill them:

- Serial runtime against N.
- MPI and MPI+OpenMP strong and weak scaling to at least 256 cores, with speedup and efficiency.
- Communication share of runtime and phase times.
- Ranks x threads, schedule, leaf size, and accuracy against cost.
- Measured findings, Discussion, Limitations from measurements, Conclusion.
- Memory per node, interconnect, and the nodes used for measurement.

## Final checks

- [ ] `grep -n 'pending{' report/main.tex` prints nothing.
- [ ] Every figure is regenerated from Vanda runs. Axes for time, N and core count are logarithmic.
- [ ] No local simulation appears as a result.
- [ ] `bash tests/jobs/package_test.sh` passes at the final commit, then build the package from `code/` with
      `bash scripts/package_submission.sh`.
- [ ] The Overleaf source matches `report/` (see `report/README.md`), and the PDF has the final names and results.
