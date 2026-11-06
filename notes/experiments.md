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
| 3 Nov 18:27 | 1514458.stdct-mgmt-02 | 0b1f36b | 2 x 8 CPUs, 16 GB each, place=scatter, 30 min | auto_free -> cpu_parallel, no -P | Two-node correctness, pbs_tmrsh launch | Ran 18:27-18:31 on IN-002 + IN-005; Exit_status 0; all 17 gates PASS. Hybrid comparison unbound |
| 3 Nov 19:41 | 1514774.stdct-mgmt-02 | fa9da68 | 1 x 64 CPUs, 120 GB, 60 min | auto_free -> cpu_parallel, no -P | Single-node pilot | Started 20:50 on IN-009; Exit_status 1 after 1 s. Failed at entry; no gate or case ran |
| 3 Nov 19:41 | 1514775.stdct-mgmt-02 | fa9da68 | 1 GPU, 36 CPUs, 60 GB, 30 min | auto_free -> gpu, no -P | GPU validation | Ran 21:43-21:45 on GN-A40-005; Exit_status 0; 4 of 4 critical and required gates PASS, optional PASS |

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

### Local validation of the remote-report fix, 3 Nov (not Vanda)

Branch fix/tm-remote-report, 563d198. The self-test gained `tm_output`, a transport that
sends remote output away from the caller's stdout, as pbs_tmrsh does. Fixed library: 48/48
(artifacts/local/runs/gates-selftest-20261103T073942Z). Old library with the same test:
43/48, tm_output exit 6, the job 1513781 failure (gates-selftest-mutation-oldharness-20261103).
Not shown yet: read-back over Vanda's NFS under real pbs_tmrsh. A missing report still stops
the job, so a failure there is safe but would stop the job again.

Read-only site checks for Lecture 12, same day: discovery/vanda_lecture12_checks_20261103.txt.
Plan and proposals: requirements_plan.md.

### OpenMP target solver, local tests, 3 Nov (not a GPU)

`gpu/bh_gpu.cpp`, built with GCC 12 and no offload support, so target regions run on the host and
transfers do nothing. `make check-gpu` passes, serial and hybrid gates still pass, and
ASan/UBSan are clean on both backends. Seven broken kernels are all caught by the self-test.
Evidence: artifacts/local/gpu_validation_linux.json, which records real_gpu_executed=false.

Two findings. GCC 12 returns success under OMP_TARGET_OFFLOAD=MANDATORY with no device, so the
job relies on --require-device and on nvidia-smi sampling instead. Removing the `j != i` test
changes no force: a softened self-pair contributes exactly zero, so it is not a usable mutation.

Not shown: that nvc++ accepts the code, that map clauses and transfers are right with separate
memory, that the traversal stack fits on the device, or any GPU timing.

Diagnostic rehearsal from a clean clone of main (56d3de5), two containers, remote output sent away
from stdout as pbs_tmrsh does: verdict PASS, all steps reached, 20 of 20 CLEAN reports (d8 skipped,
no pbs_tmrsh). Evidence: artifacts/local/runs/simulated-diag-tmoutput-20261103-56d3de5. This does
not reproduce the 1507215 stall and is not a Vanda result.

### Diagnostic job 1514029, 3 Nov 16:26 SGT (fixed harness; stall reproduced)

Submitted once from a clean clone of aa763c9: auto_free routed to cpu_parallel, no -P,
select=2:ncpus=8:mpiprocs=8:mem=4gb, place=scatter, 00:20:00; charge rate 0 on the job record. Ran on
IN-006 and IN-007, both Gold 6438N, 5 min 52 s, Exit_status 1 (verdict FAIL, by design when required
steps do not pass). Evidence: artifacts/cluster/runs/diag-20261103T082648Z-1514029/ and
artifacts/cluster/logs/1514029.stdct-mgmt-02.OU. Balance not read (no amgr session).

| Step | Launch | Mapping | Program | Result |
|---|---|---|---|---|
| allocation | tm | ppr:1:node, no binding | report | PASS |
| d1 | tm | ppr:1:node, bind none | hostname | PASS |
| d2 | tm | ppr:2:node:PE=4, bind core | hostname | TIMEOUT 60 s, no output |
| d3 | tm | ppr:1:node:PE=8, bind core | hostname | TIMEOUT 60 s, no output |
| d4 | tm | ppr:2:node:PE=4, bind core | probe | TIMEOUT 60 s, no trace |
| d5 | tm | ppr:1:node:PE=8, bind core | probe | TIMEOUT 60 s, no trace |
| d6 | tm | --host head, PE=8 | probe | FAIL: "already filled" |
| d7 | tm | ppr:1:node, bind none | probe, 8 threads | PASS |
| d8 | pbs_tmrsh | ppr:1:node:PE=8, bind core | probe | PASS (optional step, once) |
| d9 | tm | ppr:1:node:PE=8, bind core | probe | TIMEOUT 60 s, no trace |

Shown:
- The remote-report fix works under real pbs_tmrsh: 22 of 22 reports CLEAN, so the run directory
  is writable and readable across the two nodes. Every step ran past each stall.
- The 1507215 stall reproduces on another node pair: all five tm launches with a PE mapping and core
  binding hang, while all tm launches without them pass.
- It is not specific to the whole cpuset (PE=4 hangs too), and not to MPI or our code (hostname hangs,
  and the probes print no trace, not even stage=start).
- In d5 both daemons started: their rmaps messages are in the .OU, and tm launches one on each node,
  including the head. By the 52 s snapshot no orted appears on either node and mpirun is idle in poll.
- The same PE=8 mapping and binding runs when launched through pbs_tmrsh.

Not shown:
- The root cause, or why the daemons were gone. Whether PE or --bind-to core is the trigger: no step
  separates them.
- That pbs_tmrsh works repeatedly, with PE below the cpuset size, or with several ranks per node. d8 ran
  once, and with PE=8 mpirun reports the rank as "not bound" because the mask is the whole cpuset.
- One node against two: d6 failed on our own command, as --host gives one slot and PE=8 needs eight.
- **Two-node solver correctness: no solver ran.** No timing was measured.

Local simulations could not show any of this: Docker uses ssh and no tm.

### pbs_tmrsh launcher option, local tests, 3 Nov (not Vanda)

`MPI_LAUNCHER=pbs_tmrsh` uses the rsh launcher with pbs_tmrsh as its agent. It differs from d8 in two
ways, chosen deliberately and not yet run on Vanda: no tree spawn, and attached daemons (the rsh launch
line otherwise includes --daemonize, which could take a daemon out of its PBS task). A missing or
non-executable agent stops the job at setup with no ssh fallback. Cleanup and snapshots use the same agent.

The allocation gate decides from where the remote process runs: under orted and pbs_mom, not sshd, with
PBS_JOBID and the exact cpuset. Log lines can only reject another agent or --daemonize, because the template
line's wording has not been seen on Vanda and daemons may log through the launcher.

Local results at 03cae7c, using a stand-in named pbs_tmrsh that calls ssh:
- tests/jobs/launcher_selftest.sh 61/61: 12 repeated mappings over two hosts (PE=4, 2, 1, 8, three times each);
  no plain ssh; agent failing, hanging or broken for cleanup; rank failure; daemon killed mid-run; refusals.
- gates_selftest 48/48. twonode through the stand-in stops at allocation, exit 5, because the daemon descends from
  sshd. twonode on the hostfile route passes all 17 gates.

Not shown: anything about real pbs_tmrsh. The stand-in cannot pass the real ancestry check, so that check has
only been run on canned records. Reliability and the root cause of the tm hang remain unproven; the route has
one passing launch on Vanda (d8, job 1514029), without these two options.

### Two-node correctness job 1514458, 3 Nov 18:27 SGT (one submission, passed)

Commit 0b1f36b, clean clone, rate 0, 3 min 39 s of 30 min, IN-002 + IN-005 (both Gold 6438N), Exit_status 0.
Balance not read (no amgr session). Evidence: artifacts/cluster/runs/twonode-20261103T102750Z-1514458/,
artifacts/cluster/logs/1514458.stdct-mgmt-02.OU, and discovery/vanda_*0b1f36b*. All 30 files were byte-identical
to the Vanda copies before commit. No timing from this job is a measurement.

**Unbound comparison against serial.** `gate_hybrid.log` and `hybrid_validation_vanda-1514458.json`: 22 of 22
cases within tolerance, every difference 0.0; 17 cases on both hosts, up to 16 ranks and N=20011; repeat runs
bitwise identical; negative control detected. Its flags include `--map-by node --bind-to none`.

**Separate bound checks, none compared with serial.** Eight placement probes passed, each with one CPU per thread:
PE=4 and PE=8 three times each, plus 4x2 and 8x1. They run a probe program, not the solver. `recorder` ran the
solver once, bound, 4 ranks x 4 threads, N=50000, 2 steps, and recorded exit 0 and `ok`. Nothing here shows that
a bound run gives the serial answer.

**Launcher.** Remote ancestry `bash<orted<pbs_shepherd<pbs_mom`, agent `/opt/pbs/bin/pbs_tmrsh`, plm rsh, no
`--daemonize`, 8 CPUs per node, PBS_JOBID on both nodes, 34 of 34 leftover checks CLEAN. First run of the ancestry
check on a real launch, and first Vanda run of no-tree-spawn and attached daemons.

**Stale label in the original JSON.** Both validation files in this run say `"kind": "local development validation;
not Atlas/Vanda performance evidence"`. That string was hard-coded in the validators, so it is wrong about where
they ran; `env/environment.txt` (PBS_ENVIRONMENT=PBS_BATCH, this PBS_JOBID) and the run directory show Vanda. The
same string is in older cluster runs. It correctly says these are not performance evidence. The files are
kept unchanged (sha256: hybrid 9a0bf35e, serial 456f3f26). Validators after 0f57fc6 write `execution_context`
from the environment; tests/test_execution_context.py covers this. Those later files will not match these
in schema, and that fix has not run on PBS: a fake PBS environment in Docker is all that has exercised it.

Not shown: reliability (one job, one node pair), the cause of the tm hang (tm was not used), more than 2 nodes,
full 64-core nodes, Platinum 8452Y nodes, or the charged cpu_node pool.

### Pilot job 1514774, 3 Nov 20:50 SGT (one submission, failed at entry)

The whole PBS log is `...SC: line 17: jobs/vanda/measure.sh: No such file or directory`. PBS starts a job in $HOME;
pilot.pbs sourced that relative path, and the `cd "$PBS_O_WORKDIR"` was inside measure.sh, so it never ran.
Cause confirmed by the log, and reproduced by tests/jobs/pbs_entry_test.sh. bench1, bench2 and bench4 had the same bug.
Simulations started in code/, so they could not see it.

**Usable for sizing: 0 of 20 planned runs.** Also 0 failed, 0 timed out and 0 skipped, because none started. No run
directory, gates, environment or timing exist. Nothing about 64-core behaviour or IN-009 is known. Approval consumed.

Fix, local only: the four wrappers change directory first. pbs_entry_test passes, and fails on a restored copy of
the bug. In Docker, pilot.pbs started from another directory passed allocation, build, placement and analyze with
manifests/local_e2e.json; `runs` failed only on that manifest's deliberate 3 s timeout probe. Not run on Vanda.

### GPU validation job 1514775, 3 Nov 21:43 SGT (one submission, real GPU execution)

Commit fa9da68, rate 0, 55 s, GN-A40-005, NVIDIA A40, Platinum 8452Y host, nvc++ 26.1-0, Exit_status 0. Evidence:
artifacts/cluster/runs/gpu_validate-20261103T134410Z-1514775/, logs/1514775.stdct-mgmt-02.OU. All 14 files, with
the pilot log, byte-identical to Vanda before commit. execution_context=pbs_batch: first real run of that label.

**Real GPU, not host fallback**, from independent records:
- Program: `num_devices=1 kernel_on_device=1 separate_memory=1`; --require-device and OMP_TARGET_OFFLOAD=MANDATORY accepted.
- Driver: gpu_samples.csv, 0% then 100% in the last 6 of 8 samples, 521 MiB; gpu_apps.txt lists bh_gpu on the GPU.
- Compiler: "Generating NVIDIA GPU code" (optional gate, record only).
- `real_gpu_executed=true`, which means only that --expect-device was set and no check failed, so it does not stand alone.
- PBS resources_used.ngpus=0 is not evidence either way; exec_vnode shows ngpus=1 allocated.

**Correctness on the device:** 23 of 23 checks. theta=0 against direct 4.986e-14 (limit 1e-10); theta>0 agrees with
the host tree (agree_worst <= 0.0017 of the allowed 1e-12); device trajectory against serial 9.682e-14 (limit 1e-10);
self-test 58 cases, including buffers reused as the tree grows.

Not shown: fault detection on the GPU, because mutation checks run only in no-device mode; the separate `cpu` backend
checks are not device evidence; more than one GPU or job. Tree build and integration stay on the host. The single
timed run (N=10^6) is not a measurement: no repeats, and no CPU comparison. G2 needs runner support.

The watch for these jobs stopped updating, and I reported 1514775 as queued at about 22:11 when PBS shows it had
finished at 21:45. `ssh` also outlived a perl alarm by 17 minutes. Status must come from `qstat -xf`, with a hard limit.

### Pilot deadline check, 4 Nov (arithmetic, no job)

Runner rule: a run starts only if its whole limit + 45 s fits before the deadline, about 3258 s after job start. In
`pilot_single_node.json` the serial cases come first, with 615, 615, 615 and 1215 s worst-case slots. If they all use
their limits, **all 6 of the 64-core hybrid and schedule cases, plus leaf, accuracy and theta_cost (16 of 20), are
skipped.** Estimate from the only timing we have, a local Docker serial run (50,000 bodies, 1.67 s per step), scaled
by N log N: about 1200 s in total, so at the estimate all 20 run. At 2x all still run. At 3x six are skipped, leaving
the first three 64-core sets in. At 4x two serial runs time out and every 64-core case is skipped. The estimate
comes from another machine, so 075ec51's essential cases are likely, but not guaranteed, to run.

`pilot_single_node_v2.json` has the same 20 runs and arguments (checked by plan comparison), with 64-core cases first
and shorter limits. Worst case, 1x64, 8x8, 64x1, serial up to 10^6, schedules and one theta_cost run still start;
11 others may be skipped. 2,000,000 serial has 600 s rather than 1200 s, which it might exceed. Nothing has run yet.

### G2 GPU timing support, 4 Nov (local only, no GPU)

`manifests/gpu_timing.json` (frozen): N = 10^5, 3x10^5, 10^6, 3x10^6, 5 timed steps, 3 interleaved repetitions, same
bh_gpu binary on both backends with 36 host threads. Worst case 2880 s, so nothing is skipped on time alone. Sizes
rest on job 1514775's one device run; no CPU-backend run on Vanda has informed them.

Fallback is refused at four points: device runs get --require-device and OMP_TARGET_OFFLOAD=MANDATORY; run_case.py
rejects a result that does not report the device; analyze.py checks again, ignoring a stored ok; the job's device gate
stops it first. A device row is compared only with the cpu row of the same problem, threads, binary, CPU model and
source tree.

tests/gpu_timing_e2e.sh 33/33, with a stub bh_gpu and the real no-device GCC build, whose 6 device runs exit 7.
pipeline_e2e 42/42, pbs_entry_test and check-context pass. Not shown: nvc++ running this path, the 36-core CPU
backend's time, or anything about speed. The CPU backend is the same kernel built by nvc++, not the GCC hybrid
solver, so the comparison says nothing about bh_hybrid. Hash of run records now includes gpu/*.cpp.

### G2 review, 4 Nov (local only, no GPU)

Defects found in the code above, and fixed:
- `threads_effective` was `omp_get_max_threads()` printed twice, so its check could never fail. bh_gpu now measures the
  team in a parallel region, and records distinct CPUs, proc_bind and the effective schedule. Both backends must show the
  requested team, one CPU per thread and `close`.
- The cpu kernel used `schedule(runtime)` with OMP_SCHEDULE unset, so its schedule was an unrecorded runtime default on
  an irregular workload. Runner now sets dynamic,64, the hybrid default; a cpu run on anything else is refused.
- Device tree remapping was inside wall_s but in no phase. It is now `map_nodes_s`.
- Pairing ignored placement and host, and hid unequal repetition counts. It now matches both, and shows counts.
- package_submission.sh failed on an absolute output path, and packaged the internal root README with dead links.

Timing boundaries as they now are: wall_s covers `steps` steps after setup and warmup, and is integrate + build + flatten
+ map_nodes + to_device + kernel + from_device. Tree build, flatten and integrate use one host thread on both backends, and
the CPU backend pays flatten too, so the ratio is for this program, not the best possible CPU code. Kernel placement rests
on a probe plus mandatory offload and --require-device, not a check inside the kernel; gpu_busy is the outside view. A
36-thread team is 36 physical cores on these nodes (1 thread per core, job 1514775).

Checks: gpu_timing_e2e 43/43, check-gpu 29/29, pipeline_e2e 42/42, pbs_entry_test. Package audit on a real zip: 71 text
files, no logs, evidence, binaries or credentials found by name or content scan; the extracted package builds and passes
its serial, hybrid, GPU, context, G2 and entry tests. None of this ran under nvc++: the new probe code is unbuilt there.


### G2 GPU timing, job 1519638, 4 Nov (Vanda)

Queued 19:10, started 19:17:47, finished 19:22:16 SGT, exit 0, walltime 4 min 26 s, `gpu` queue, GN-A40-004, charge rate 0.
Commit 8a50c8f, manifest `gpu-timing-v1` frozen before this run, 24 of 24 runs. Gates: build, device, gpu_busy, runs and
analyze passed; cleanup clean. 88 files retrieved, each matching its Vanda checksum.

First build of the G2 probes under nvc++. Rechecked from the raw records after retrieval with `gpu_problems`, ignoring
stored `ok`: 0 problems. All 12 device runs report the kernel on a device with separate memory, with
OMP_TARGET_OFFLOAD=MANDATORY and --require-device. All 24 report 36 threads on 36 distinct CPUs, `close`, dynamic,64.
One binary, host, CPU model and GPU throughout.

| N | device wall s | cpu wall s | cpu/device | device kernel s | cpu kernel s | device map+transfers s |
|---|---|---|---|---|---|---|
| 1e5 | 0.615 | 0.283 | 0.46 | 0.560 | 0.231 | 0.004 |
| 3e5 | 1.633 | 0.988 | 0.61 | 1.442 | 0.807 | 0.011 |
| 1e6 | 6.019 | 3.768 | 0.63 | 5.255 | 3.059 | 0.040 |
| 3e6 | 19.866 | 14.622 | 0.74 | 16.834 | 11.714 | 0.121 |

Medians of 3. The GPU was slower at every size. The kernel is at least 97% of the wall-time gap; mapping and transfers are
under 1% of device wall time. nvc++ reports the device loop as "teams and threads(128), schedule(static)"; the kernel was not tuned
for the GPU. Why it is slower was not tested, and nothing above 3e6 ran, so the rising ratio does not show a crossover.

Limits:
- One job, one node, one GPU, 3 repetitions.
- `gpu_busy` sampled `nvidia-smi` (100%) in its own N=1e6 run before the timed runs, not during them. Those rest on mandatory
  offload, --require-device and the program's report.
- Timed on GN-A40-004; correctness (G1) ran on GN-A40-005 from fa9da68. The diff to 8a50c8f touches timers, probes and
  the result line, not the kernel. G1 was not rerun with this binary.
- The result field `compiler` reads "EDG g++ 11.2.1 mode", the compiler's GNU compatibility string. `gate_build.log` shows
  nvc++ built it.

### Preparation for 256 cores, 4 Nov (local only, no job)

Pilot 1519637 still queued at 23:13 SGT (`Insufficient amount of resource: node_pool`); one status check, nothing changed.

Added `pilot2.pbs` (free rehearsal), `pilot4.pbs`, their manifests, `scripts/plan_budget.py` and a `bound` suite in
`validate_hybrid.py`, run through new critical gates in `measure.sh` (`SCALE_CHECKS=1`). `bench4` manifest is now v1 with provisional limits.
Plan: [plan_256core.md](plan_256core.md). The running pilot uses clone 8a50c8f, so these changes do not affect it.

GPU table now spans the page, without scaling, and has the CPU kernel time; the figure has base-10 labels, distinct marks and a legend clear of
the data. Report compiles at 6 pages with no overfull box; pages 5 and 6 inspected as images.

Memory probe: `artifacts/local/memory_probe_20261104.txt`, local Docker, 17 MiB + 136.4 MiB per million particles per rank.

Checks: plan_budget_test 8 of 8, including 4 refusal checks; pbs_entry_test; gpu_timing_e2e 43/43; pipeline_e2e 42/42;
default check-hybrid; `--suite bound` refuses a core count it cannot place. `pilot2.pbs` ran end to end on two simulated nodes
(`artifacts/local/runs/simulated-pilot2-20261104/`, ssh, 8 cores each, tiny sizes): 9 of 9 gates, 6 of 6 bound cases exact against serial.
Not shown: `pbs_tmrsh` at 64 ranks per node, more than two nodes, `cpu_node` nodes, or any timing or memory on Vanda.
Dry runs of `submit.sh` printed the `qsub` lines for pilot2, pilot4 and bench4 locally, with no `qsub` on this machine and nothing sent.

### Checks before the pilot's results, 4 Nov 23:20 SGT

Pilot 1519637 still queued (`Insufficient amount of resource: node_pool`), nothing retrieved. Balance not read: `hpc project` asks
for `amgr login`, and `amgr balance` failed with an error in the tool. Clean clone `~/dsa5208-p3-0ae5573` created on Vanda and dry runs
recorded (`artifacts/cluster/discovery/vanda_dryrun_0ae5573_*.txt`). The first clone step left an empty directory because the bundle
had no HEAD; `origin/main` was checked out in it, and commit and tree match. No job was submitted.

`studies_single_node.json` is v1: 3 timed steps, each size with its own limit, serial leaf study at 3e5; `bench1` walltime is 4 h provisional.
Estimates in `plan_budget.py` now scale with theta and leaf size. Decision rules for the pilot's results are in plan_256core.md,
set before any result existed.

### Pilot 1519637 failed at `placement`, 5 Nov (Vanda)

Source `8a50c8f`, IN-020 (Gold 6438N, all 64 CPUs), queue `cpu_parallel`, rate 0. Queued 4 Nov 19:10:25, ran 5 Nov 05:11:16 to
05:13:07, walltime 00:01:50, run_count 1, Exit_status 5. `allocation` PASS, `build` PASS, `placement` TIMEOUT at 90 s (8 x 8, the
first bound launch). Later gates and all 20 runs did not start; there is no `summary.csv`. Cleanup was CLEAN after all three gates.
All 11 retrieved files matched by SHA-256; originals remain in `~/dsa5208-p3-8a50c8f`. Evidence:
`artifacts/cluster/runs/pilot1-20261104T211117Z-1519637/`, `logs/1519637.stdct-mgmt-02.OU`, `logs/1519637_qstat_xf.txt`.

**Sizing: none.** Rule 1 of `plan_256core.md` applies. Only rule 3 has a value, the CPU model. No time, memory or efficiency exists.

Observed:
- The job's launcher line had only `--hostfile`, but `launch_verbose.txt` shows `plm` selected `tm`. The allocation check printed
  this and passed: it did not test the launcher on one node. Fixed.
- mpirun started a daemon on its only node: daemon `[[50209,0],1]`, ancestry `bash<orted<pbs_shepherd<pbs_mom`. Job 1514458 also
  started daemons on its head node, through `pbs_tmrsh`.
- At 81 s mpirun waited in `poll` with no daemon or rank visible, and no probe trace or binding report printed. Job 1514029's `tm`
  hang, `d2_bind_pe4`, shows the same state.

Inferred, not shown: this is the 1514029 `tm` hang. Job 1503779 probably passed on one node because `correctness.pbs` does not add
`/opt/pbs/lib`, without which `tm` cannot load (1506687); its launch log was not recorded. Why `tm` hangs with binding is unknown.

Fix, `3f77e87`: every `measure.sh` job launches through `pbs_tmrsh`, and `REQUIRE_PBS_TM=0` must be given by name for local
simulation. The allocation check fails a hostfile launch that selects `tm`, and checks `pbs_tmrsh` on one node.

Local checks at `3f77e87`, Docker, stand-in agent over ssh, never measurements:
- `launcher_selftest` 82 of 82 (`artifacts/local/runs/launcher-selftest-20261105T052251Z/`), including one host with no rank on
  mpirun's node: three mappings and 12 of 12 runner cases.
- The allocation check on 1519637's real records now fails, on `plm_not_tm` alone.
- Control: with the old line restored in a copy, `pilot.pbs` chose hostfile and began its gates; the new test requires exit 3.
- `pilot.pbs` end to end with `REQUIRE_PBS_TM=0` (`artifacts/local/runs/simulated-pilot1-20261105/`): 36 runs passed; only the
  manifest's deliberate timeout probe failed, so `runs` shows FAIL as designed.
- `pbs_entry_test` and `plan_budget_test` pass.

Not shown: PBS, `tm`, the fix on Vanda, or `pbs_tmrsh` at 64 ranks on a node. The most shown there is 8 ranks per node in job 1514458.

### Pilot rerun submitted, job 1522998, 5 Nov (Vanda)

Leon approved one rerun. Commit `3f77e87`, tree, manifest hash, resources, scheduling, queues and rate 0 were rechecked, with no
unfinished job and no other `p3_pilot1` in history. Submitted once at 13:46:25 SGT from `~/dsa5208-p3-3f77e87/code`; state Q in
`cpu_parallel`, rate 0. PBS shows `project = personal-leonyil.qian`. Nothing measured yet. Record:
`artifacts/cluster/discovery/vanda_pilot_rerun_submit_3f77e87_20261105T134621.txt`.

### Preparation while 1522998 waits, 5 Nov (local, no job changed)

One read-only snapshot at 14:20 SGT: `1522998` state Q, `node_pool`; free cores in `artifacts/cluster/discovery/vanda_free_core_snapshot_20261105T142003.txt`.
`pilot16.pbs` and `pilot_single_node_16core.json` are prepared at `96a37ba`, not approved. Local checks, never measurements:
`plan_budget_test`, `pbs_entry_test`, and the wrapper end to end in Docker with `REQUIRE_PBS_TM=0` and the local test manifest
(`artifacts/local/runs/simulated-pilot16-20261105/`): 36 runs passed, and only the deliberate timeout probe failed. Dry run recorded locally.

Source package at `c8b7495`: `package_test` passes, with 80 files, no logs, text output, evidence or binaries, and three refusal
controls. Unzipped alone, it passes `make check` and `make check-hybrid` in Docker. Report compiled in a scratch copy: 8 pages, no
overfull box; pages 1, 3, 4, 7 and 8 inspected as images. Figure code reviewed: time, N and core-count axes are logarithmic.

### Status check and pilot16 readiness, 5 Nov 14:29-14:31 SGT

`1522998` still queued (`node_pool`), unchanged, no run directory. Because it had not started, clone `~/dsa5208-p3-96a37ba` was prepared
and the `pilot16` dry run run without `--yes`; every check passed and nothing was submitted. Record:
`artifacts/cluster/discovery/vanda_pilot16_dryrun_96a37ba_20261105T143058.txt`.

Report: all 8 pages now inspected as images. Terms added for warm-up, schedule, chunk, NUMA, kernel and flattening; the GPU timing
paragraph separated from validation; Table 6 moved next to its text. No overfull box. No numbers changed.

### Pilot16 submitted, job 1523275, 5 Nov (Vanda)

Leon approved one job. All rechecks passed, and `1522998` was still Q with no start time, run count or run directory. Submitted once at
14:36:19 SGT from `~/dsa5208-p3-96a37ba/code`; state Q in `cpu_parallel`, rate 0. `1522998` unchanged afterwards. PBS shows
`project = personal-leonyil.qian`. Nothing measured yet. Record: `artifacts/cluster/discovery/vanda_pilot16_submit_96a37ba_20261105T143606.txt`.

### Pilot16 finished, job 1523275, 5 Nov (Vanda): provisional sizing only

Ran 14:36:22-14:51:42 on IN-002 (Gold 6438N), exit 0, 15 min 12 s, rate 0. Gates `allocation`, `build`, `placement`, `runs`, `analyze`
all PASS. 20 of 20 runs completed; none skipped or timed out. **One repetition on 16 cores of a possibly shared node: this is not a
scaling result, and says nothing about 64 or 256 cores.** Retrieved read-only by tar over ssh; 73 files, 0 checksum mismatches. Originals
stay in `~/dsa5208-p3-96a37ba`. Record: `artifacts/cluster/discovery/vanda_pilot16_retrieval_20261105T1650.txt`.

Revalidated with the new `scripts/verify_run.py`, which catches a changed record, a changed summary and a missing record (controls run).
`analyze.py` regenerates `summary.csv` identically apart from the folder name. All 16 timed records share one source tree, CPU model,
host and pair of binaries.

| Case, N = 10^6 unless given, 2 timed steps | Wall s | Traverse s | Exchange s (share) | Peak RSS per rank, MiB |
|---|---:|---:|---:|---:|
| Serial 10^5 / 3 x 10^5 | 3.44 / 13.74 | 3.42 / 13.66 | | 17.0 / 46.1 |
| Serial 10^6 / 2 x 10^6 | 62.71 / 156.77 | 62.22 / 155.83 | | 142.4 / 277.5 |
| Hybrid 1 x 1 | 60.05 | 59.68 | 0 | 156.1 |
| Hybrid 1 x 16 | 3.54 | 3.19 | 0 | 159.0 |
| Hybrid 4 x 4 | 5.46 | 5.06 | 0.036 (0.7%) | 155.8 |
| Hybrid 16 x 1 | 6.70 | 6.13 | 0.087 (1.3%) | 156.2 |

Findings, all from one repetition and unexplained until repeated:

- **Same 16 cores, very different times:** 1 x 16 took 3.54 s and 16 x 1 took 6.70 s, and exchange explains almost none of the gap. The traverse is about 1.9 times
  longer. A possible cause is 16 separate tree copies competing for one shared cache, against one tree shared by threads. **Untested.**
  `bench16` measures this with repetitions.
- **Efficiency above 1 at 1 x 16:** 1.11 against serial, and 1.06 against hybrid 1 x 1. Efficiency above 1 (superlinear speedup) is possible, for example when the combined caches of many cores hold what one core's cache cannot. One repetition cannot say whether it is real here. *Corrected 6 Nov: an earlier summary called it impossible; `bench16` repeated it, see below.*
- **Run-to-run conditions moved:** `integrate_s` differs by a factor of 2 between the serial 3 x 10^5 runs (0.0048 s at 14:37; about 0.0098 s at 14:41 to 14:43), though it does not depend on leaf size. So the leaf comparison is not clean.
- **Placement:** the 4 x 4 probe passed, with 16 threads on 16 distinct CPUs. All 16 allocated CPUs are odd-numbered, so all are on NUMA node 1, one socket. **16 x 1 had no probe**; its traverse times per rank match within 2%
  (6.03 to 6.13 s), which argues against ranks sharing a core but does not prove it. `bench16` adds that probe.
- **Budget fault found:** a run does one more force evaluation than `plan_budget.py` counted, because warmup includes the initial one (`setup_s` is about equal to `wall_s`). Fixed. The refit estimate is within 6% of the four largest serial and hybrid runs.

Accuracy (N = 20,000, serial `--validate`), max and mean relative error: theta 0.3: 1.41e-2, 4.2e-4; 0.5: 6.76e-2, 1.7e-3; 0.7: 0.229, 4.5e-3; 0.9: 0.390, 9.7e-3.

Sizing rules applied in `plan_256core.md`. Local checks for the new plans, never measurements: `plan_budget_test`, `pbs_entry_test`, and the `bench16` wrapper in Docker
with a frozen 8-core copy of its plan at N/100 (`artifacts/local/runs/simulated-bench16-20261105/`): 9 of 9 gates, 64 of 64 runs. It refuses a plan that is not frozen
(`simulated-bench16-refuse-20261105`). Docker cannot bind, so `verify_run.py` flags its stderr warnings there, which is the intended behaviour. `1522998` stayed queued and unchanged.

### `bench16` submitted, job 1523703, 5 Nov (Vanda)

Leon approved one job. Clone `~/dsa5208-p3-e86bf5d` created from a bundle of commit `e86bf5d`; commit, tree `96eed32`, manifest hash, resources, scheduling, queues and rate 0 verified; no `p3_bench16` in current jobs or history. Dry run without `--yes`, then submitted once at 17:20:38 SGT. It started at 17:20:44 on IN-002 in `cpu_parallel`, rate 0, and was running at 17:20:47. PBS shows `project = personal-leonyil.qian`. `1522998` unchanged, still Q. Nothing measured yet. Records: `artifacts/cluster/discovery/vanda_bench16_dryrun_e86bf5d_20261105T1719.txt`, `artifacts/cluster/discovery/vanda_bench16_submit_e86bf5d_20261105T1720.txt`.

### `bench16` 1523703 and 64-core pilot 1522998 finished, retrieved 6 Nov (Vanda)

Both finished on 5 Nov with exit 0, and both passed every gate. `1523703`: 17:20:44-18:49:06 on IN-002, 1 h 28 min, 9 of 9 gates. `1522998`: 17:39:00-17:47:51
on IN-016, a whole node across both sockets (`exec_vnode` IN-016[0] and IN-016[1], 32 cores each), 8 min 49 s, 5 of 5 gates. Rate 0 for both; PBS shows `project =
personal-leonyil.qian`. Retrieved read-only: 382 and 73 files, 0 checksum mismatches. `verify_run.py` passed every record: **121 of 121** and **20 of 20**, none failed, timed
out or skipped, each with one commit, source tree, CPU model (Gold 6438N), host and pair of binaries. Both jobs used byte-identical binaries. Every cleanup check was CLEAN. At
17:09-17:12 the login node could not map the user ID to a name and `qstat` refused every job ID; it worked at 17:23. Record: `artifacts/cluster/discovery/vanda_retrieval_1523703_1522998_20261106.txt`.

Redaction: `PBS_JOBCOOKIE` removed from every committed `env/environment.txt` (12 files), with hashes in `artifacts/cluster/REDACTIONS.md`. Originals kept outside the repository,
owner-only, and still on Vanda; older copies remain in earlier commits, which are not rewritten.

**`1523703`, formal, 16 cores of a shared node, 3 interleaved repetitions.** Analysed into `artifacts/cluster/analysis/bench16-1523703/`, which reproduces the job's own
`summary.csv`; figures and tables regenerated into `report/generated/`. Findings, measured only:

- Serial slope 1.33 on log-log axes from N = 10^4 to 2 x 10^6, above the 1.09 that N log N would give over that range. Cause not tested.
- Traversal at least 88% of every strong and weak run; exchange at most 1.9% in medians, 2.8% in one repetition; tree build at most 10%.
- At 16 cores, 1 x 16 took 5.64 s and 16 x 1 took 9.24 s; most of the gap is in the traversal.
- **Variability:** repetitions of one case differ by up to 61% (median 18%). Serial against hybrid 1 x 1, the same algorithm on one core, ranges 0.95 to 1.30 across repetitions.
- **Efficiency above 1:** against serial, 1 x 4, 1 x 8 and 1 x 16 reach 1.42-1.48 in medians. Part of that is the baseline: serial was slower than 1 x 1 in two of three repetitions.
  Against 1 x 1 of the same repetition the thread-only runs still stay above 1 (1.06-1.27). Cache behaviour was not measured, so no cause is claimed.
- Same binary, same CPU model: serial 10^6 took 42.7 s per step here and 19.4 s per step in `1522998`, which had a whole node. The records cannot show other jobs on IN-002.

**`1522998`, sizing only, one repetition.** Rules in `plan_256core.md`: keep N_s = 10^6, 50,000 per core, theta 0.5, leaf 8, dynamic 64. 64 x 1 efficiency 0.34, RSS 161 MiB per
rank, exchange 9.2% of wall. 1 x 64 efficiency 0.46; no efficiency above 1 on this node. Kernel core-time against serial: 2.08 at 64 x 1, 1.71 at 8 x 8, 1.59 at 1 x 64.

Then: budget constants refit (threads now cost at 64, exchange has a floor); every measured run of both jobs falls at 0.34 to 1.83 times its estimate. `bench1` frozen;
`pilot2`, `pilot4`, `bench4` resized and still proposed; `bench4` needs 2 h 50 min, 725 core-hours. Clean clone `~/dsa5208-p3-367c630` of commit `367c630`, tree verified,
`pilot2` and `bench1` dry runs printed their commands and submitted nothing. Record: `artifacts/cluster/discovery/vanda_dryrun_367c630_20261106T1723.txt`. Report Results rewritten for the 16-core data; 256 cores still pending.

