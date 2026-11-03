# Experiment manifest — PROPOSED, not frozen

Machine-readable versions (what the jobs actually run): `code/manifests/`
`pilot_single_node.json` (the pilot), `studies_single_node.json` and
`studies_two_node.json` (formal studies, status proposed; `bench1.pbs` and
`bench2.pbs` refuse to run them until their status starts with `frozen`).
`local_*.json` are local test manifests only.

Status (29 Oct 2026): proposal only. N_s, N_w and step counts are placeholders
until the single-node pilot (`code/jobs/vanda/pilot.pbs`) measures runtime and
memory on Vanda. No formal benchmark has run. Freeze this file (record the
commit) before the first formal job, and change it afterwards only by adding a
dated amendment.

**Amendment, 3 Nov 2026 (still proposed):** Lecture 12 requires serial runtime against N,
MPI strong and weak scaling to at least 256 cores, and a GPU test. The tables below stop at
128 and are superseded on those points by [requirements_plan.md](requirements_plan.md) and
`code/manifests/studies_four_node.json`. The queue row below does not hold at 256 cores.

## Fixed for every formal run

| Setting | Value |
|---|---|
| Cluster, queue | Vanda, `auto_free` (routes to `cpu_parallel`), no `-P`, zero queue charge rate |
| Toolchain | `OpenMPI/4.1.6-GCC-13.2.0`, `-O3 -std=c++17 -march=native`, built on the compute node in the same job |
| Input | Plummer-profile positions, seed 42, softening 0.025, dt = 1e-3 |
| Numerics | theta 0.5, leaf size L* (from pilot; default 8) unless the study varies it |
| Placement | `--map-by ppr:R:node:PE=T --bind-to core`, `OMP_PROC_BIND=close`, `OMP_PLACES=cores`; probe run in each job |
| Schedule | dynamic, chunk C* (from pilot/study 3) unless the study varies it |
| Timed region | S timed steps after 1 warm-up step; setup recorded separately |
| Repetitions | 3 per configuration, in the same job, interleaved; median and min/max reported; failures kept |
| P | cores bound to the run (ranks x threads); recorded per run |
| Node usage | whole 64-core nodes requested for timing jobs so other jobs cannot share them (pilot checks this is schedulable) |

## Studies

N_s: largest N for which serial Barnes–Hut takes about 60–120 s for S steps.
N_w: particles per core for weak scaling, chosen so the largest P stays in memory.

| # | Study | Fixed | Varied | Runs |
|---|---|---|---|---|
| 1 | Strong scaling | N_s, S, theta, L*, C* | P = 1 (serial), 1 (1x1 hybrid), 2, 4, 8, 16, 32, 64 (1 node), 128 (2 nodes); two series: MPI-only (T=1) and T=8 (P >= 8) | 3 reps each |
| 2 | Ranks x threads | N_s, P = 64 and P = 128 | 64x1, 32x2, 16x4, 8x8, 4x16, 2x32, 1x64 (per node) | 3 reps each |
| 3 | OpenMP schedule | N_s, 1x64 and 8x8 | static; dynamic chunk 1, 16, 64, 256; guided | 3 reps each |
| 4 | Weak scaling | N_w per core, T = 8 | P = 8, 16, 32, 64, 128 (P0 = 8) | 3 reps each |
| 5 | Leaf size | N_s, serial and 8x8 | L = 4, 8, 16, 32 | 3 reps each |
| 6 | Accuracy vs cost | 8x8 | theta = 0.3, 0.5, 0.7, 0.9; error vs direct at N = 2e4 (serial validate) | 3 reps each (timing) |

Study 4 also reports peak memory per rank and summed over ranks, to show the
O(N) replication of the baseline. Weak efficiency is T(P0, N0) / T(P, N) with
P0 = 8; constant particles per core is not constant work per core.

## Dependencies and order

1. Two-node correctness job (`twonode.pbs`) passes.
2. Single-node pilot (`pilot.pbs`) sets N_s, N_w, S, L*, C* and confirms
   whole-node requests are schedulable within `cpu_parallel` limits
   (max 160 CPUs and 2 running jobs per user).
3. A two-node pilot checks the 128-core points before studies 1, 2 and 4 use them.
4. Formal studies, one job per study (or per node count), each self-contained.

## CPU-hour estimate (requested, i.e. cores x walltime)

Queue charge rate is 0 for `auto_free` / `cpu_parallel`, so the expected charge is
zero; requested core-hours are listed for transparency and approval.

| Job | Request | Requested core-hours |
|---|---|---|
| Two-node correctness | 2 x 8 cores, 30 min | 8 |
| Single-node pilot | 1 x 64 cores, 60 min | 64 |
| Formal studies | to be estimated from pilot timings before submission | — |
