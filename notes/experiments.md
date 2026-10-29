# Validation and measurement plan

No benchmark results are claimed by this plan.

## Validation gates

1. Serial tree: theta=0 vs direct summation with max relative error <= 1e-10 on
   ordinary nonzero-force inputs. Also report absolute error for zero/near-zero forces.
2. Edge cases: empty/singleton, coincident/near-coincident particles, unequal masses,
   domain boundaries; retain all particles and total mass. Current checks do not cover these.
3. Hybrid: gather results by stable particle ID and compare accelerations, positions
   and velocities to serial on identical seed, timestep, softening and theta. Quantify
   ordering-related differences and choose tolerances before formal runs.
4. Repeat at one/multiple ranks and threads, including N not divisible by ranks and
   ranks with no particles. Verify mass, particle counts and IDs after exchanges.
5. Distinguish approximation error (theta vs direct) from implementation error
   (hybrid vs serial at the same theta). Energy drift alone proves neither.

## Experiments on Atlas or Vanda

Use pilot runs to select feasible sizes, core counts and durations. Do not promise
millions of particles before checking memory, runtime and scheduler limits.

| Study | Keep fixed | Vary |
|---|---|---|
| Strong scaling | N, steps, theta, seed, algorithm | Allocated cores, ranks × threads |
| Weak scaling | N per allocated core, steps, theta | Cores and N proportionally |
| Hybrid split | N and total allocated cores | Ranks × OpenMP threads |
| Scheduling | N, ranks, threads and algorithm | Static vs dynamic, chunk size |
| Optional LET | Same physics and accuracy settings | Replicated vs distributed tree |

If using particles per rank for weak scaling, keep threads per rank fixed and
state that convention. At each point use at least three independent runs, save
all observations and report median and min/max. Warm up separately and record it.

Strong speedup S(P)=T_serial/T_parallel(P); efficiency E(P)=S(P)/P, where
P is total allocated physical CPU cores and the serial baseline uses the same
Barnes–Hut settings and comparable compiler optimization. Also show the one-core
hybrid time to expose MPI/OpenMP overhead. Weak efficiency is T(P0,N0)/T(P,N)
with N/P=N0/P0; identify P0 explicitly.

Use MPI_Wtime for hybrid wall time. Time the same timestep region in serial and
hybrid; exclude input generation, diagnostics and output. Record initialization
separately. Synchronize the start, reduce elapsed time with MPI_MAX, and record
build, traversal, communication, integration and repartition phases. Overlapped
phase times need not sum to wall time; state how they were measured.

## Per-run provenance

Record UTC timestamp plus timezone, git revision or source hash, seed, N, steps,
dt, theta, softening, solver/decomposition/schedule/chunk, nodes, ranks, threads,
allocated physical cores, binding, scheduler job ID, cluster/node model, compiler
and MPI versions, module list, flags, repetitions, validation errors and raw times.
Capture command lines and stdout/stderr alongside structured JSON/CSV.

Keep local development output under code/artifacts/local and formal cluster
outputs under code/artifacts/cluster. Never present local timing as Atlas/Vanda
results. Generate final tables and plots from retained observations.

## Fixed tolerances (28 October, before any cluster run)

Set in `code/tests/validate_hybrid.py` and not to be loosened to pass a run:
1-step accelerations `|d| <= 1e-12 |ref| + 1e-14 max|ref|`; 10-step positions,
velocities and accelerations `|d| <= 1e-10 |ref| + 1e-13 max|ref|`. Locally all
differences are exactly zero, because both programs evaluate each particle with
the same code on the same tree; a mutant without the position exchange fails 11
checks, so the zeros are not a blind harness.

## Local pilot observations (Docker, not reportable as results)

`artifacts/local/runs/pilot-*`: N=50000, 3 steps, theta 0.5, leaf 8, dynamic/64,
8 physical cores with SMT on a laptop. Efficiency fell from 0.95 (1x4) to 0.71
(1x8) and 0.46 (8x1). Tree build was under 1% of step time and traverse imbalance
about 1.01, so in this pilot the 8x1 loss appears in the traversal phase rather
than the build or imbalance; the laptop's run-to-run spread (serial 4.46-5.30 s in
a repeat pilot) limits what this shows. Unconfirmed hypotheses to test on the cluster: per-rank tree copies competing for
cache/memory bandwidth, and poor locality because particle IDs are spatially
random. A candidate design comparison is ownership by Morton order (compact
owned regions, better reuse, possibly worse balance) versus ID order.

Supplementary energy study (`artifacts/local/energy_study_linux.json`, N=2000,
T=0.2): at theta 0, relative drift falls 4x per dt halving (7.3e-8 to 2.8e-10).
For theta > 0 it is nearly independent of dt and differs by theta (about 1.9e-7,
1.1e-6, 3.7e-6, 3.6e-6 for theta 0.2, 0.3, 0.5, 0.7; not monotone at 0.7).
Consistent with a tree-force contribution; cause not isolated.

Serial leaf-size sweep (`artifacts/local/runs/leafsweep-*`, N=50000, Docker):
L=8 and L=16 had the lowest medians with overlapping ranges; L=1 was about 18%
slower. The default stays 8 until re-tuned on the cluster.

Binding (`artifacts/local/runs/binding-*`): 1 rank x 4 threads, Open MPI default
binding 1.57 s median vs 0.40 s with `--bind-to none`; `--report-bindings`
showed the default bound the rank to one hardware thread.

## Vanda runs (actual cluster execution)

| When (SGT) | Job | Commit | Request | Queue | Purpose | Outcome |
|---|---|---|---|---|---|---|
| 28 Oct 20:24 | 1503779.stdct-mgmt-02 | d959217 | 1 x 8 CPUs, 16 GB, 30 min | auto_free -> cpu_parallel, no -P | First correctness job | Ran 20:31–20:32 on IN-003, Exit_status 0; all 9 gates PASS |

Charging basis: site `hpc cpu` instructions present `-q auto_free` without
`-P` as the alternative to a project; `auto_free`, `cpu_parallel` and
`cpu_serial` have `queue_charge_rate = 0`; personal-leonyil.qian balance
10000.0 CPU-hours before submission (evidence:
`code/artifacts/cluster/discovery/vanda_allocation_queues_20261028T202042.txt`).
Submission explicitly authorised by the user for exactly this one job.

Job 1503779 findings (`code/artifacts/cluster/runs/correctness-20261028T123124Z-1503779/`):
compute node IN-003 is 2 x 32-core Intel Xeon Gold 6438N, no SMT, 2 NUMA
domains, RHEL 9.4 (the login node is a Xeon Platinum 8452Y, so build on compute
nodes). The PBS cpuset gave CPUs 0,2,...,14 and Open MPI saw only those 8 cores.
Placement 2x4, 4x2 and 8x1 bound one thread per core, with no memory-binding
warning. Hybrid gate: all 15 cases bitwise identical to serial. System Python
3.9.18 sufficed. git is absent on compute nodes, so the records show
git_rev=no-git; their source hashes match commit d959217. submit.sh now passes
SOURCE_GIT_REV. Credit balance after the job: not yet re-checked (connection
dropped).
