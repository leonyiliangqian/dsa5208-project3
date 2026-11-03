# Project 3 code

C++17 Barnes–Hut gravitational n-body simulation, serial and MPI+OpenMP.

| Path | Contents |
|---|---|
| `common/nbody.hpp` | Particles, Plummer initial conditions, direct summation, octree, leapfrog |
| `common/run_support.hpp` | Shared CLI options/validation, state dump, JSON helpers |
| `serial/barnes_hut.cpp` | Serial driver (`bh_serial`): speedup denominator, `--self-test`, `--validate` |
| `hybrid/bh_hybrid.cpp` | MPI+OpenMP driver (`bh_hybrid`); 1 rank = OpenMP only, 1 thread = MPI only |
| `tests/` | Serial gate, hybrid gate, energy/timestep study, toolchain probes, `pipeline_e2e.sh`, `jobs/gates_selftest.sh` |
| `scripts/` | `run_case.py` (one recorded, time-limited run), `run_manifest.py` (all runs of a manifest), `analyze.py`, `report_figures.py`, `report_tables.py`, preflight, discovery |
| `manifests/` | Machine-readable experiment plans (pilot, proposed formal studies, local test manifests) |
| `jobs/vanda/` | PBS jobs, gate library, submission wrapper (see below) |
| `docker/` | Development image and `run.sh`; `twonode/` two-container simulation; `tex/` LaTeX compile test |
| `artifacts/local/` | Local development evidence and simulations (macOS and Docker). Never cluster results |
| `artifacts/cluster/` | Genuine Vanda evidence only: job runs, PBS logs, site checks |

## Build and check

macOS (serial only; Apple clang has no OpenMP or MPI here):

```sh
make help
make check            # serial gate
make sanitize         # ASan + UBSan debug build, never timed
```

Linux / Docker (serial + hybrid). Docker Desktop must be running:

```sh
docker/run.sh make toolchain      # OpenMP team, 2 MPI ranks, FUNNELED + OpenMP
docker/run.sh make check          # serial gate
docker/run.sh make check-hybrid   # serial vs MPI+OpenMP, by particle ID
docker/run.sh sh scripts/local_pilot.sh   # pipeline exercise, local evidence only
```

Binaries go to `bin/<os>/` (`bin/darwin`, `bin/linux`), so the two never mix.

### Gates

- `make check`: edge-case self-test (empty, singleton, all-coincident, coincident
  cluster, separations below the depth-64 cell, unequal masses, lattice points on
  cell planes, two-particle closed-form force at theta 0/0.5/10, symmetric cube,
  plus negative controls that must fail); invalid arguments exit 2; theta=0 vs
  direct summation max relative error <= 1e-10 at leaf sizes 1 and 8.
- `make check-hybrid`: 15 configurations (1–5 ranks, 1–4 threads, static/dynamic/
  guided, uneven N, ranks owning nothing, N=1) compared with serial at the same
  settings. Tolerances are fixed in `tests/validate_hybrid.py`: 1-step
  accelerations `1e-12·|ref| + 1e-14·max|ref|`; 10-step positions, velocities and
  accelerations `1e-10·|ref| + 1e-13·max|ref|`. Also: 3 repeated threaded runs must
  be bitwise identical, invalid arguments must exit 2 on all ranks without hanging,
  and a 1e-9 perturbation must be detected.

Both write JSON evidence with source and binary hashes to `artifacts/local/`.

## Running

Both programs accept `--n`, `--theta`, `--dt`, `--steps`, `--warmup`, `--seed`,
`--leaf-size`, `--energy` and `--dump FILE`. `bh_serial` adds `--method bh|direct`,
`--validate` and `--self-test`; `bh_hybrid` adds `--schedule static|dynamic|guided`
and `--chunk C` (0 = OpenMP default). Threads per rank come from `OMP_NUM_THREADS`.

```sh
./bin/linux/bh_serial --n 50000 --steps 5 --warmup 1
OMP_NUM_THREADS=4 mpirun -np 2 --bind-to none ./bin/linux/bh_hybrid \
    --n 50000 --steps 5 --warmup 1 --schedule dynamic --chunk 64
```

Each prints a human-readable line and a `result {...}` JSON line with the
configuration and timings. Process binding matters: Open MPI's default binds a
rank to one core when there are few ranks, so its OpenMP threads share that core
(measured locally: 1 rank x 4 threads took 0.89 s bound vs 0.24 s with
`--bind-to none`). Cluster jobs must give each rank as many cores as threads.

## Numerical model

Softened gravity (G = 1, softening 0.025), Plummer-profile positions with small
random velocities from a fixed seed (not an equilibrium Plummer model),
kick–drift–kick leapfrog. Leaves hold up to `--leaf-size` particles (default 8);
particles still sharing a cell at depth 64 stay in one leaf, so none are dropped.
A cell is used as a monopole only if it passes s/d < theta and does not contain
the target particle; otherwise it is opened, and opened leaves are summed
pairwise without self-interaction. Default leaf size 8: in a local sweep L=8 and
L=16 were fastest with overlapping ranges; re-tune on the cluster before formal runs.

## Hybrid design (replicated baseline)

Rank 0 generates the initial state and broadcasts positions, velocities and
masses. Rank r owns a contiguous ID range (balanced; ranks may own nothing).
Each step: half kick and drift of owned particles, `MPI_Allgatherv` of positions
in ID order, identical global tree build on every rank, OpenMP
`schedule(runtime)` force loop over owned particles, half kick. Masses are sent
once; velocities and accelerations are gathered only for `--dump`/`--energy`.
`MPI_THREAD_FUNNELED` is required and checked; MPI is called only by the main
thread outside parallel regions. After the timed loop, all ranks verify that
their global positions and masses agree bitwise and that owned counts sum to N.

This is not a distributed tree: every rank builds the whole tree and stores all
N positions, so memory per rank is O(N) and the build is redundant.

## Timing

Timed region: `--steps` steps after setup (initial forces, optional energy,
`--warmup` steps). Hybrid: barrier, then per-rank `MPI_Wtime`, reduced with
MPI_MAX; phase times (integrate, exchange, build, traverse) are per-rank sums
reduced with MPI_MAX, plus the traverse mean for the imbalance ratio max/mean.
Serial times the same region and phases with `steady_clock`. Use serial
Barnes–Hut, never direct summation, as the speedup denominator.

## Measurement pipeline

```sh
python3 scripts/run_manifest.py manifests/<m>.json --out <run dir> --bin <bin dir> \
    [--mpirun ...] [--cores-per-node C] [--nodes K] [--first-cpu CPU] [--deadline EPOCH] [--plan-only]
python3 scripts/analyze.py <run dir> [<run dir> ...] [--out <dir>]     # summary.csv/json
python3 scripts/report_figures.py <summary.json> [...]                 # -> ../report/generated/
```

A manifest lists cases; list-valued fields are swept. Repetitions are
interleaved. Every run has its own timeout and runs in its own process group
(TERM, then KILL); a run that cannot finish before the deadline is recorded as
skipped. Each record carries the manifest id and sha256, study tag, command,
allocated cores, CPU model, source and binary hashes, compiler, MPI and flags.
`analyze.py` groups repetitions by every setting that can change a timing and
computes speedup only against a serial baseline with the same problem, CPU
model, source tree and flags. `report_figures.py` writes pgfplots figures and
tables; it refuses inputs outside `artifacts/cluster/` unless `--allow-local`
with an `--out` outside `report/generated/`, and then marks every caption
LOCAL PIPELINE TEST.

Tests: `docker/run.sh bash tests/pipeline_e2e.sh` (manifest -> runs -> analysis
-> figures on tiny inputs, timeout, deadline, interruption and refusal paths);
`docker/twonode/run.sh 'bash tests/jobs/gates_selftest.sh'` (gate library fault
injection on two simulated nodes).

## Vanda (PBS)

Every job is submitted only through `jobs/vanda/submit.sh <job> --queue auto_free
--no-project` (dry run unless `--yes`), which records the login node's commit as
`SOURCE_GIT_REV` (compute nodes have no git). Jobs build on the compute node and
run their steps as gates (`jobs/vanda/gates.sh`): each has a time limit, a
process snapshot before expiry and an ownership-checked cleanup on every node
after it; kinds are critical, required and optional. Step-by-step:
`../notes/cluster_access.md`.

| Job | Request | Purpose | Status |
|---|---|---|---|
| `correctness.pbs` | 1 x 8 cores, 30 min | serial, hybrid, placement, sanitizer gates on one node | PASSED as job 1503779 |
| `twonode.pbs` | 2 x 8 cores, scatter, 30 min | two-host correctness, portable build, `pbs_tmrsh` launch | PASSED as job 1514458 (comparison unbound; 1506687 and 1507215 did not reach it) |
| `diag.pbs` | 2 x 8 cores, 4 GB, 20 min | locate the 1507215 stall (one factor per step) | ran as job 1514029: stall reproduced under tm, cause unknown |
| `pilot.pbs` | 1 x 64 cores, 120 GB, 60 min | `manifests/pilot_single_node.json` | prepared, NOT approved |
| `bench1.pbs` / `bench2.pbs` | 1 or 2 x 64 cores | formal studies from a frozen manifest (refuse a proposed one; one CPU model required) | walltime placeholder; after pilot |

Results so far: correctness job 1503779 (one node) passed; no performance
measurement exists.

## OpenMP target solver (GPU not yet verified)

`gpu/bh_gpu.cpp` offloads the force traversal; the tree is built on the host. `--backend device`
uses `target`, and `--backend cpu` runs the same kernel on host threads. `--require-device` exits 7
unless the kernel ran on a device with separate memory. A compiler without offload support runs
target regions on the host, so `make check-gpu` then tests logic only. It has not been built with
`nvc++` or run on a GPU; `jobs/vanda/gpu_validate.pbs` is the proposed first test.

```sh
docker/run.sh make check-gpu                                   # local, no GPU
make CXX=nvc++ GPU_CXX=nvc++ CXXFLAGS="-O3 -std=c++17" GPU_OMPFLAGS="-mp=gpu -Minfo=mp" \
    GPU_GATE_ARGS=--expect-device check-gpu                    # on a GPU node, not yet run
```

