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
| 29 Oct 13:30 | 1506687.stdct-mgmt-02 | 3c76d5e | 2 x 8 CPUs, 16 GB each, place=scatter, 30 min | auto_free -> cpu_parallel, no -P | Two-node correctness | Ran 13:30-13:31 on CN-161 + IN-002; Exit_status 5: allocation check stopped the job before compiling (CPU models differ) |
| 29 Oct 15:15 | 1507215.stdct-mgmt-02 | 494af8b | 2 x 8 CPUs, 16 GB each, place=scatter, 30 min | auto_free -> cpu_parallel, no -P | Two-node correctness, portable build, forced tm launch | Ran 15:15-15:47 on IN-011 + IN-013; Exit_status -29 (killed at the 30 min walltime). Gates allocation, build, flags, toolchain, internode_2, internode_16 PASS; place_1x8 hung with no output; later gates not run |

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

Job 1506687 findings (`code/artifacts/cluster/runs/twonode-20261029T053005Z-1506687/`):
two distinct hosts (CN-161, IN-002), each restricted to exactly its 8
allocated CPUs, including the rank launched remotely; CPU models differ
(Platinum 8452Y vs Gold 6438N), which the original identical-model rule
rejected, so nothing was compiled or run. The launcher actually used was
pbs_tmrsh with a hostfile, not tm: the tm components failed to load because
libpbs.so.0 (in /opt/pbs/lib) was not on the library path, although ompi_info
lists them either way. The cpu_free pool holds 20 IN (64-core 6438N), 3 CN
(72-core 8452Y) and 1 RN node, with no PBS attribute for CPU model, so
select=2 can mix families.

Correction: an earlier note here said the two models' matching ISA flag lists
(a filtered subset) made a -march=native binary compatible across them. That
does not follow and is withdrawn. Revised twonode.pbs: builds with the
portable target -march=x86-64 -mtune=generic for serial and hybrid, records
the resolved target and embedded flags (flags gate); requires two hosts,
exactly 8 allowed CPUs each and x86_64 before compiling; forces the tm
launcher (`--mca plm tm --mca ras tm`, no fallback) and requires mpirun's own
selection log to show plm tm and the remote process to start from orted, not
sshd. Models and ISA lists are recorded only. Vanda's Open MPI library is
itself built for x86-64-v3 (AVX2), so this job shows portability of this
project's code only. Mixed-model results are correctness evidence, never
scaling measurements; benchmarks must use one family.
Balance 10000.0 at 13:29 (after job 1503779), before this job.

Job 1507215 findings (`code/artifacts/cluster/runs/twonode-20261029T071525Z-1507215/`,
retrieved 30 Oct 15:52): two distinct hosts IN-011 and IN-013, both Gold
6438N, each restricted to CPUs 0,2,...,14 (8). mpirun's log selected plm tm
and ras tm; the remote process ancestry was bash<orted<pbs_shepherd<pbs_mom,
so PBS-integrated launching was used. The portable flags were resolved to
-march=x86-64 with no AVX/SSE4.2 macros and are embedded in both binaries.
internode_2 and internode_16 exchanged data across the two hosts correctly.
The place_1x8 gate (2 ranks, `--map-by ppr:1:node:PE=8 --bind-to core
--report-bindings`, under tm) printed nothing, not even the binding report,
and the job used 19 CPU-seconds in 31 minutes before PBS killed it. Cause not
established; the placement mapping/binding under tm with PE=8 equal to the
whole per-node cpuset is one possibility to test, not a finding. No gate had
its own time limit, so one hang consumed the walltime and the serial, hybrid
and recorder gates never ran: the two-node correctness of the solver is still
unverified. Scheduling was off (maintenance) when the evidence was retrieved.

**Status: two-node solver correctness is UNVERIFIED** (no hybrid gate has run
on two nodes on Vanda). Single-node correctness: job 1503779, all gates PASS.

### Local diagnosis of the 1507215 stall (30 Oct, Docker; not Vanda evidence)

What the Vanda evidence shows: in 1507215 the place_1x8 log holds the make
and mpirun command lines and nothing else. In single-node job 1503779 the
`--report-bindings` lines (from mpirun) came before any probe output. Their
absence suggests the stall began at or before binding was reported, but does
not establish it: output can be lost when a process is killed, and how the
remote node's binding report travels under tm has not been observed. Launch,
binding and the probe all remain possible locations.

Local tests (Open MPI 4.1.4, GCC 12, Docker; rsh/ssh launch, no PBS or tm):
- One container restricted to CPUs 0,2,...,14 (the 1507215 cpuset):
  `-np 1 --map-by ppr:1:node:PE=8 --bind-to core` completes; Open MPI reports
  "MCW rank 0 is not bound (or bound to all available processors)", i.e. PE=8
  equal to the whole cpuset makes rank binding a no-op; OpenMP still binds the
  8 threads to distinct CPUs and the probe passes. PE=9 is rejected at once.
- Two containers (docker/twonode/run.sh), same cpusets, ssh launch: place_1x8,
  2x4, 4x2 and 8x1 all PASS in 2-3 s; the whole revised twonode.pbs passes
  all 13 gates (artifacts/local/runs/simulated-twonode-*), and diag.pbs runs
  every step (artifacts/local/runs/simulated-diag-*; d8 skipped, no pbs_tmrsh).
- So the stall does not reproduce locally. Not reproduced, hence untested:
  PBS tm launching, PBS cgroups, Open MPI 4.1.6 and its UCX/libfabric
  transports, and the IN-node topology (2 sockets, 2 NUMA domains).
- Code review: no probe or solver path makes some ranks skip a collective or
  exit early; pass/fail is broadcast from rank 0, and bh_hybrid aborts all
  ranks on an exception. placement_check now agrees on the thread count
  before MPI_Gather (a mismatch was erroneous, not a clean failure).

Unconfirmed Vanda-specific hypotheses for the diagnostic job to separate:
(a) tm launch or wire-up stalls for this mapping; (b) binding a rank to all
8 cores of the chunk's cpuset behaves differently under PBS cgroups/tm; (c)
the probe stalls after start (MPI_Init, OpenMP start or a collective); (d) an
intermittent fault not tied to PE=8.

Changes made for this (30 Oct):
- jobs/vanda/gates.sh: every gate has a time limit (timeout in its own
  process group, TERM then KILL), a snapshot of process state, wait channels
  and stacks (gdb if present) on every node shortly before the limit, and a
  cleanup check on every node after the gate (tests/toolchain/leftover_check.sh).
  Unverifiable cleanup stops the job (exit 6); a failed critical gate stops
  it (exit 5); dependants of a failed gate are skipped.
- Revised 30 Oct after review (see "Gate library review" below): ownership-
  based cleanup, required/optional gate kinds, worst-case time accounting.
- placement_check: PLACEMENT_TRACE=1 writes flushed, rank-labelled stage
  lines (start with OS affinity, MPI_Init, OpenMP team, each collective,
  MPI_Finalize); result lines are line-buffered.
- twonode.pbs and correctness.pbs use the gate library; in twonode.pbs the
  1x8 placement now runs last, hybrid needs serial and recorder needs
  place_2x4. Shared setup moved to jobs/vanda/multinode_setup.sh.
- jobs/vanda/diag.pbs: the diagnostic job (one factor per step, see header).

### Gate library review (30 Oct, local; supersedes the 22/22 self-test above)

1. Cleanup ownership. leftover_check.sh now kills only processes positively
   owned by the job: PBS_JOBID equal to the job's, or P3_RUN_MARKER (unique
   per run, exported by gates.sh) equal to the run's, or a command line
   containing the job-unique binary path (bin/vanda-JOB/). Processes with a
   different PBS_JOBID are foreign and ignored. MPI launchers/daemons with no
   marker, or whose environment cannot be read, are unattributed: never
   killed, re-checked after 3 s, and if still present the node reports
   UNCERTAIN and the job stops (exit 6), since it cannot show the cores are
   free of its own strays. Assumption to verify on Vanda: processes started
   by PBS tm on the second node carry PBS_JOBID (node_report.sh now records
   pbs_jobid_env per node). If they do not, a leftover remote orted would be
   unattributed and the job would stop rather than kill it.
2. Gate kinds. critical (stop on anything but PASS), required (continue;
   FAIL, TIMEOUT or SKIP prevents an overall PASS) and optional (listed in
   the verdict, never decides it). In diag.pbs only d8 (pbs_tmrsh comparison)
   is optional; a missing pbs_tmrsh is recorded as `d8 SKIP kind=optional`.
3. Time accounting. Worst case per gate on N nodes: limit + GATE_GRACE_S
   (20) + N*(SNAPSHOT_NODE_S+2)+2 (watcher allowed to finish after a timeout,
   12 s per node) + N*(CLEANUP_NODE_S+5) (sequential cleanup, 40 s per node):
   limit + 140 s for N=2. Before each gate the limit is cut so the worst case
   ends END_RESERVE_S (60 s) before the walltime; with under 20 s left the
   gate is skipped. The snapshot watcher now runs in its own process group
   (setsid) and the group is removed before cleanup. This is bounded best
   effort, not a guarantee: the clock starts when the script starts (PBS
   starts earlier), module loading, the environment record and the final
   summary are not bounded, and a process in uninterruptible sleep survives
   KILL. The earlier statement that limits "never exceed the remaining
   walltime" ignored the grace, snapshot and cleanup time and is withdrawn.
Fault-injection evidence: artifacts/local/runs/gates-selftest-* (results.txt,
provenance.txt with source revision and file hashes, one directory per
scenario).

### Diagnostic preflight, 30 Oct 16:59 SGT (read-only; nothing transferred or submitted)

Existing SSH master; no credentials entered. Notice unchanged (scheduling
stopped 29 Oct 18:00, access stops 31 Oct 06:00, release 2 Nov 17:00).
`scheduling = False`, server Idle: remote work stopped. auto_free and
cpu_parallel enabled/started, queue_charge_rate = 0; no jobs of mine queued.
Balance not read: the allocation-manager session has expired (`amgr login`
needed). Record: code/artifacts/cluster/discovery/vanda_prediag_checks_*.txt.
Local dry run for diag.pbs at e43b561 prints the expected qsub command;
directives select=2:ncpus=8:mpiprocs=8:mem=4gb, place=scatter, 00:20:00.

### Diagnostic job 1513781, 3 Nov 15:35 SGT (one submission, stopped by our own harness)

Submitted once from a clean clone of 18c0d24: auto_free routed to cpu_parallel,
no -P, select=2:ncpus=8:mpiprocs=8:mem=4gb, place=scatter, 00:20:00; charge rate
0 on the job record. Ran on IN-002 and IN-005, both Gold 6438N, 12 s walltime,
Exit_status 6. Evidence: artifacts/cluster/runs/diag-20261103T073541Z-1513781/ and
artifacts/cluster/logs/1513781.stdct-mgmt-02.OU.

Result: `allocation` PASS (2 hosts, 8 CPUs each, plm and ras tm selected, remote
orted under pbs_mom). Then `cleanup` FAIL and exit 6. **`build` and d1-d9 never
ran, so no trace exists and this job says nothing about the 1507215 stall.** That
stall remains unexplained, and it is not evidence of two-node solver correctness.

Cause of the exit, a false negative in jobs/vanda/gates.sh: cleanup_all captures
the remote leftover check through `pbs_tmrsh ... >> cleanup.log`, but pbs_tmrsh
writes remote output to the PBS job's output file, not to its own stdout (man
page: artifacts/cluster/discovery/vanda_pbs_tmrsh_man_20261103.txt). The IN-005
line `... unattributed=0 CLEAN` is in the .OU and absent from cleanup.log and
job.log, so the count of CLEAN reports was 1 of 2 nodes. Both nodes reported CLEAN.
The local simulations use ssh, which does return stdout, so they could not catch
this. The gate library dates from 30 Oct, after the earlier jobs; this was its first
multi-node run on Vanda. snapshot_watch.sh has the same pattern, so remote
snapshots would be lost too. Every multi-node job using gates.sh (twonode, measure)
would stop the same way. Balance not read (no amgr session).

