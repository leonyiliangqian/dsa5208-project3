# Project 3 requirements and plan after Lecture 12

Written 3 November 2026 from [project_memory.md](project_memory.md) and read-only
checks saved in `code/artifacts/cluster/discovery/vanda_lecture12_checks_20261103.txt`.
Nothing here has been measured. No job, allocation or charge below is approved.
Deadline stays 13 November 2026, 23:59 SGT until a new date is confirmed.

## Rubric against current state

| Pts | Requirement | Plan | State |
|---|---|---|---|
| 5 | Explain the algorithm | Report sections on Problem and Method | Drafted |
| 5 | Serial runtime against N | Study 0, log-log, with fitted slope | Figure code and manifest ready; no measurement |
| 10 | MPI to at least 256 cores: strong, weak, speedup, efficiency, communication | Studies 1 and 4, MPI-only series, one job | **Blocked**: queue and charge decision; two-node correctness passed on the free pool (job 1514458, comparison unbound) |
| 10 | MPI+X, and at least one GPU test because X is OpenMP | T=8 series, ranks x threads, schedule; study 7 for the GPU | CPU side ready, pilot not yet run; GPU correctness validated on an A40 (job 1514775); no GPU timing |
| 5 | Overall discussion | After results | Not started |

Also required: define non-standard terms; explain how the Plummer positions and
velocities are generated without claiming equilibrium; say why each validation
test is meaningful rather than quoting test counts; declare AI use; log axes for
time, problem size and CPU count; source code in the submission, logs and terminal
output excluded (`code/scripts/package_submission.sh`; raw evidence stays in the
repository).

## 256 cores: feasibility

| Queue | Limit found | Charge rate | 256 cores? |
|---|---|---|---|
| `auto_free` -> `cpu_parallel` | 160 CPUs per job and per user, 2 running jobs | 0 | **No.** Two jobs cannot be one MPI run |
| `auto` -> `batch_cpu` | 720 CPUs per job and per user, 10 nodes, 6 running jobs | 1 | Yes by its limits, but charged |

Open before a 256-core job: `amgr login` by Leon to read projects and balance (last
reading 10000.0 on 29 Oct, before job 1507215); how charge rate 1 converts to credits;
CPU model of the `cpu_node` pool; whether the lecturer has a course project or
exception for this requirement.

Run the whole series, 1 to 256 cores, inside one 4-node job
(`manifests/studies_four_node.json`, `jobs/vanda/bench4.pbs`, both proposed). Mixing
free-pool points up to 128 with a charged 256-core point would change the node pool
inside one curve, and analysis only computes speedup against a serial baseline on the
same CPU model. Replicated memory and the per-rank tree build are expected to limit
weak scaling; that is a prediction to test, and N must fit the memory seen in the pilot.

Communication analysis: `exchange_s` times the per-step `MPI_Allgatherv`.
`fig_phases` and `fig_comm_fraction` show it against P for strong and weak series.

## Studies changed

| # | Study | Change |
|---|---|---|
| 0 | Serial against N | New. N = 1e4 to 3e6 plus the strong-scaling N (placeholders) |
| 1 | Strong | MPI-only to 256; T=8 to 256 |
| 2 | Ranks x threads | Adds P = 256 |
| 4 | Weak | Adds MPI-only from P0 = 1; both series to 256 |
| 7 | GPU | New, below |

## Study 7: GPU test

`code/gpu/bh_gpu.cpp` offloads the force traversal with OpenMP `target`. The tree is built on
the host with the existing `Octree`; the serial and hybrid solvers are unchanged and stay the
CPU baselines. **G0 and G1 passed on a real A40 (job 1514775).** G2 timing has not run. Local tests used GCC 12
without offload support, so target regions ran on the host and transfers did nothing.

| Step | What | Why it is meaningful | State |
|---|---|---|---|
| G0 | Kernel on a device with separate memory; `--require-device`; `nvidia-smi` sampling during a run | A silent fallback to CPU would make every GPU number false. GCC 12 ignored `OMP_TARGET_OFFLOAD=MANDATORY` with no device, so that variable alone proves nothing | Logic tested locally; needs a GPU |
| G1 | theta=0 against direct summation; theta>0 against the host tree; closed-form pair; trajectory against `bh_serial`; reused device buffers with a growing tree | Independent references. Limits fixed before any device run: 1e-10, 1e-12, 1e-10 | Pass with host fallback; needs a GPU |
| G2 | Same N sweep (log axes): 1 GPU against the 36 CPU cores of the chunk, same binary, one kernel; flatten, transfer and kernel timed separately | Shows where the GPU wins and what transfers cost | Timers exist; runner support and manifest to add after G1 |
| G3 | Optional: 2 ranks and 2 GPUs on one node, exchanging device buffers | The only step that would exercise CUDA-aware MPI | Not written |

Errors that need separate device memory, such as a missing transfer or a wrong map clause,
cannot be seen with host fallback. G1 on a GPU is the first real test of them.

Site facts: `auto_free` routes to `gpu`, charge rate 0, 1 to 2 GPUs, at most 36 CPUs per
job; node names are `gn-a40-*`, 2 GPUs per node. Most GPUs showed as busy on 3 Nov.

| Module | Open MPI | Built with CUDA | PBS tm | Use |
|---|---|---|---|---|
| `nvhpc-hpcx-cuda12/26.1` (recommended by lecturer) | 4.1.9a1 | yes | **no** | First choice: single-node GPU jobs do not need tm |
| `OpenMPI/4.1.4-NVHPC-22.7-CUDA-11.7.0` | 4.1.4 | yes | yes | Fallback, and needed if a GPU run spans nodes |

These were queried on the login node, whose architecture differs from compute nodes;
confirm on a GPU node in G0.

## Job proposals, in order. None of the remaining jobs approved

Revisions and exact commands are in [approval_requests.md](approval_requests.md).

| # | Job | Request | Queue, rate | Depends on |
|---|---|---|---|---|
| 1 | `diag` rerun | Done as job 1514029 | | |
| 2 | `twonode` correctness | Done: job 1514458 passed | | |
| 3 | `pilot` | 1 x 64 cores, 120 GB, 60 min | `auto_free`, 0 | 1514774 failed at entry; rerun needs new approval |
| 4 | `gpu_validate` (G0 and G1) | Done: job 1514775 passed | | |
| 5 | 4-node pilot, including a 256-rank hybrid-against-serial comparison | 4 x 64 cores, 30 min, about 128 core-hours requested | `auto` -> `batch_cpu`, 1 | Job 2, balance, charge approval |
| 6 | `bench4` formal series | 4 x 64 cores, walltime from job 5 | `auto` -> `batch_cpu`, 1 | Manifests frozen, charge approval |
| 7 | GPU G2 | 1 GPU, 36 cores, walltime from job 4 | `auto_free`, 0 | Job 4 passes, runner support added |

Job 2 on the free pool does not establish correctness on `cpu_node` nodes, so job 5
repeats the comparison there.
