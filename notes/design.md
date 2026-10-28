# Project 3 design: Barnes–Hut n-body, MPI + OpenMP

Working topic recorded 2026-10-20. Implementation plan revised 2026-10-28; see staged scope below. The brief requires a serial implementation, a parallel one,
and a comparison of *different* parallelization choices — so the plan below is
deliberately a set of variants to measure against each other, not one design.

## Staged scope (28 October update)

The LET, three decomposition variants and task-based build below are the original
ambitious design, not implemented features. First deliver a replicated global
tree/particle-state MPI+OpenMP baseline, then static/dynamic scheduling and a
rank/thread sweep. Add LET as an extension after correctness and pilot scaling.
See `project3_prep.md` and `experiments.md` for the current delivery gates.

Historical serial measurements below have no retained run provenance and must
not be used as report evidence. The maximum-depth particle drop and the unchecked traversal stack were fixed on
28 October (bucket leaves, bounded stack); see `code/README.md`. Symplectic leapfrog does not by itself guarantee bounded energy with an
approximate, changing tree force; measure drift and timestep sensitivity.

## Why Barnes–Hut

It is not embarrassingly parallel in three distinct ways, each of which gives the
report something to measure:

1. **The tree is global.** A particle near a domain boundary needs multipole
   information about cells owned by other ranks, so every step involves a
   non-trivial exchange, not just a reduction at the end.
2. **The work is data-dependent.** Traversal cost per particle varies with local
   density, so an equal split of particles is *not* an equal split of work. Load
   balancing is a real design decision with a measurable cost.
3. **Particles move.** The decomposition goes stale, so repartitioning frequency
   is a tunable parameter with a visible scaling consequence.

Validation is clean: at `theta = 0`, Barnes–Hut degenerates to direct summation
and must agree with it to machine precision; the measured value is 1.2e-14 max
relative error at N=2000. At production `theta` the tree result is compared
against direct summation as an accuracy/cost tradeoff, and the symplectic
integrator's energy drift gives a second, independent check.

## Serial reference (done)

`code/serial/barnes_hut.cpp` — octree build, centre-of-mass moments, `s/d < theta`
acceptance, Plummer initial conditions, kick-drift-kick leapfrog, direct-summation
reference, validation mode and per-step force timing.

Measured on this Mac (Apple clang, `-O3 -march=native`, N=20000, 2 steps):

| Evaluator | s / step |
|---|---|
| direct O(N²) | 1.966 |
| Barnes–Hut, theta=0.5 | 0.526 |

Accuracy vs direct summation at N=2000: max relative error 1.1e-1 and mean 3.5e-3
at theta=0.5; 1.6e-2 and 8.6e-4 at theta=0.3; 1.2e-14 and 1.5e-15 at theta=0.

Leaves were single particles; they are now buckets (`--leaf-size`, default 8), with
the acceptance test applied to leaves that do not contain the target. Worth a
paragraph in the report: a slow serial baseline silently inflates every speedup
number, so the leaf size is tuned on the serial code before any speedup is reported.

## MPI layer — the variants to compare

| Variant | Decomposition | Expected weakness to measure |
|---|---|---|
| A | Particle-count split by Morton (Z-order) key | Cheap to compute, ignores work imbalance |
| B | Orthogonal recursive bisection on particle count | Better locality, still work-blind |
| C | ORB weighted by measured per-particle traversal cost from the previous step | Best balance, adds a repartition cost to amortise |

All three build a **locally essential tree**: each rank builds its local tree,
then exchanges the subset of its cells that any remote rank could need under the
MAC, so force evaluation is local afterwards. The exchange volume differs between
the variants, which is the point.

Second axis to measure: repartition every step vs every k steps.

## OpenMP layer — the variants to compare

1. `parallel for` over local particles, static schedule — the naive version.
2. Same, `schedule(dynamic, chunk)` — handles traversal-cost variance.
3. Tasking for the tree *build* as well, not just the traversal.

The traversal is read-only once the tree is built, so the interesting
parallelization problems are in the build and in the imbalance, not in races.

## Measurement protocol

- Strong scaling: fixed N (target ~2–10 M particles), ranks 1 → as many nodes as
  the queue allows; report speedup and parallel efficiency against the *serial*
  time, stated explicitly.
- Weak scaling: fixed particles per rank.
- Hybrid sweep: at fixed total cores, vary ranks × threads (e.g. 16×1, 8×2, 4×4,
  2×8, 1×16) — this is the clearest MPI+X result in the report.
- Timed region excludes initial condition generation and I/O; force evaluation,
  tree build, communication and repartitioning are timed separately so the
  efficiency loss can be attributed.
- Repetitions: 3 runs per configuration, report the median and the spread.
- Every run writes one JSON line (config + timings) to an artifacts directory;
  no number is copied into the report by hand. This worked well in Project 2.

## Platform

Runtime figures must come from **Atlas or Vanda** (brief requirement). `atlas8`
answers on port 22 from this machine without VPN; `vanda` does not. Toolchain
there is unknown until the account is approved — compilers, MPI flavour, module
names, scheduler and the per-queue core limits all need checking before the
scaling plan above is final.

## Risks

- HPC account approval is the long pole. Everything else can be developed locally.
- Canvas accepts a PDF only, but the brief also asks for source code and a README.
  Needs a question to the lecturer.
- Deep recursion on coincident particles — capped at depth 64 in the serial code;
  the parallel version must keep the same cap or the trees will differ.
