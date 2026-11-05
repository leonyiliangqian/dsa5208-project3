# Optional progress report — DRAFT for group review, not sent

> **Historical. Never sent, and the 30 October date has passed.** Do not revise or send. Kept as a record.

To: Anthony Chen <cygnari@nus.edu.sg>
Optional progress reports are accepted before 30 October 2026, so it must go
out by tomorrow if the group wants to use it. Updated 29 Oct with the Vanda result.
Before sending: confirm names and student IDs (taken from the Project 2 report),
check every claim against the current state, and agree as a group. Claude will
not send this.

---

**Subject:** DSA5208 Project 3 progress report — Barnes–Hut n-body with MPI+OpenMP

Dear Dr Chen,

We are Yan Yixin (A0327039A), Zhang Yue (A0333668U) and Leon Yiliang Qian
(A0355825W). We are sending an optional progress report for Project 3 and would
be grateful for direction on the two questions at the end.

**Algorithm.** We are parallelising the Barnes–Hut gravitational n-body method
(octree with the s/d < θ opening criterion, softened gravity, leapfrog
integration) in C++17 with MPI and OpenMP. Inputs are synthetic, centrally
concentrated Plummer-profile particle clouds. The method is not embarrassingly
parallel: every timestep needs a tree built from all positions, the work per
particle depends on local density, and the decomposition changes as particles move.

**Progress so far.**
- Serial reference with direct summation as a check. With the opening angle set
  to zero, the tree reproduces direct summation to rounding error, and edge-case
  tests (coincident particles, empty and single-particle inputs, unequal masses)
  pass.
- MPI+OpenMP version: each rank owns a contiguous range of particles; positions
  are exchanged with MPI_Allgatherv every step; every rank rebuilds the global
  tree and computes forces for its own particles in an OpenMP loop, using
  MPI_THREAD_FUNNELED. Across 1–5 ranks and 1–4 threads, including uneven
  divisions and ranks with no particles, it gives results identical to the
  serial program.
- On Vanda, a first correctness job on one compute node (8 cores, built there
  with GCC 13.2 and Open MPI 4.1.6) passed all of these checks, and also
  confirmed that each MPI rank and OpenMP thread runs on its own core. No
  performance measurements have been made yet.

**Plan on Vanda.** After a two-node correctness check and a pilot to choose
problem sizes: strong and weak scaling against the serial Barnes–Hut time;
different ranks × threads splits at fixed core counts; static versus dynamic
OpenMP scheduling; and the effect of leaf size and opening angle on cost. We
will present this as a replicated-tree baseline and discuss its limits (every
rank stores all positions and repeats the tree build) rather than claim a
distributed tree.

**Questions.**
1. Is this scope sufficient for the project, or would you expect a distributed
   (locally essential) tree or another more advanced decomposition?
2. Canvas accepts only a PDF upload, but the brief asks for the source code and
   a README. How would you like us to submit the code: a ZIP file elsewhere, a
   repository link in the report, an appendix, or another route?

Kind regards,
Yan Yixin, Zhang Yue and Leon Yiliang Qian
