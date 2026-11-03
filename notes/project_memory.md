# Project 3 persistent requirements and decisions

## Lecture 12 clarification supplied by Leon, 3 November 2026

Source: user-pasted excerpts from *Lecture 12: The Design of Parallel
Algorithms*, Project 3 slides. Retain alongside `assignment_brief.txt`.
These clarify the original brief and must inform the experiment plan,
report and submission packaging. They are requirements, not measured results.

### Submission and figures

- Include source code in the final submission. **Do not include log files or
  terminal output in the final submission.** Preserve raw evidence separately
  for internal verification; distinguish it from the submission package.
- Include informative plots. Axes representing time, problem size or CPU count
  must use logarithmic scales.
- Further Vanda downtime may lead the lecturer to extend the deadline.
  No extension or replacement deadline has been announced in this excerpt;
  retain 13 November 2026, 23:59 SGT until a new date is confirmed.

### Grading (35 points)

| Points | Requirement |
|---|---|
| 5 | Explain the algorithm being parallelized. |
| 5 | Serial runtime scaling with varying problem size. For sparse matrices vary dimension and nonzero count; for graphs vary vertices and edges. For this n-body project vary particle count N. |
| 10 | MPI runtime analysis scaling to **at least 256 CPU cores**; both strong and weak scaling; speedup and parallel efficiency; explain communication's impact on runtime. |
| 10 | MPI+X analysis. **If X is OpenMP, also test on at least one GPU.** |
| 5 | Overall discussion: parallelization decisions, techniques for different parts and communication needs; conclusions about real data when applicable. |

### Report, synthetic inputs, validation and AI

- Define every non-standard term used in the report.
- Explain how synthetic data are generated. Synthetic data are suitable for
  weak scaling. For this project explain the actual Plummer-profile generator
  and velocity initialization without claiming equilibrium unless established.
- Explain validation tests and why they are meaningful. Avoid presenting a
  large test count as a substitute for a rationale (the lecturer asks why
  projects would need 100+ validation tests).
- Declare AI usage accurately; the report and its terminology must make sense.
- Conditional comments for other topics: Poisson solvers should cover both 2D
  and 3D; graph projects should discuss sparsity. These do not add Poisson or
  graph work to this Barnes–Hut project.

### CUDA-aware MPI modules mentioned by lecturer

- Recommended: `module load nvhpc-hpcx-cuda12/26.1`
- Alternative: `module load OpenMPI/4.1.4-NVHPC-22.7-CUDA-11.7.0`

The lecturer states Vanda supports CUDA-aware MPI. Verify module availability,
GPU access and toolchain compatibility before choosing the GPU experiment.
The excerpt requires a GPU test but does not specify its implementation or
minimum GPU count beyond at least one; do not invent additional requirements.

### Consequences for the existing plan

- The proposed manifest previously stopped at 128 cores. Revise it to include
  at least 256, and resolve the previously observed free-queue 160-CPU/user
  limit through read-only site checks and a concrete feasible proposal.
- MPI+OpenMP alone no longer covers the full clarified requirements. Prepare a
  meaningful, validated GPU experiment and explain what is compared.
- Add an explicit serial N-scaling study and check all relevant plot axes.
- Keep the existing implementation and genuine results; no new cluster job,
  charged allocation, queue change or GPU submission is authorized merely by
  recording these requirements. Present concrete job requests for approval.
- Final submission packaging must exclude retained raw logs/terminal output.

