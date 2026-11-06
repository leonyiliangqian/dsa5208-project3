# Approval requests

**No approval is open.** Two free jobs are ready to request below. Each job needs Leon's own approval. Preparing a clone on Vanda writes to Vanda, so it needs approval too.

## Ready to request: `pilot2`, free 128-core rehearsal on two nodes

**Why:** it is the only free test of launch, binding and correctness across nodes at 64 ranks per node before anything is charged. `pilot4` and `bench4`
should not be approved until it passes. It gives sizing only, not results, and cannot show 256 cores.

| | |
|---|---|
| Source | `367c63046583a2d7f26a0ddc1109bd07d99b2fad`, tree `f0ba7fae95dc917837ac7f0370736313189ad985`, clone `~/dsa5208-p3-367c630`, prepared and clean |
| Manifest | `pilot_two_node.json`, status `proposed` (allowed for a pilot), SHA-256 `27ea797af4203fd5ba72880b8b514ca7d2d23d6660e17740fbe932d770e68b74`, 6 runs |
| Request | `select=2:ncpus=64:mpiprocs=64:mem=120gb`, `place=scatter`, 30 min, 64 core-hours at most; about 9 min expected. Worst case 730 s fits the 1040 s budget |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck. PBS has shown `project = personal-leonyil.qian` on free jobs, and the balance is unread |
| Gates | `allocation`, `build`, `placement`, `place_mpi`, `internode`, `serial`, `bound_vs_serial`, `runs`, `analyze` |
| With `bench1` | 128 + 64 cores is over the 160-CPU limit, so PBS runs them one after the other if both are approved |
| Wait | Needs two whole free nodes, which may take hours |

> Leon explicitly approves exactly ONE pilot2 submission: source `367c63046583a2d7f26a0ddc1109bd07d99b2fad` in ~/dsa5208-p3-367c630, manifest pilot_two_node.json SHA256 27ea797af4203fd5ba72880b8b514ca7d2d23d6660e17740fbe932d770e68b74,
> 2 nodes x 64 cores, 120 GB each, scatter, 30 min, auto_free, no -P, ZERO CHARGE ONLY. Before submitting, use hard-bounded existing-auth checks to verify
> commit, tree, manifest and resources, scheduling and queues enabled and started with rate 0, and no duplicate p3_pilot2 in current jobs or history. If all
> pass, submit the command below exactly once and record the job ID. No retries, other jobs, spending, credential or security changes, monitoring loops,
> lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-367c630/code
bash jobs/vanda/submit.sh pilot2 --queue auto_free --no-project --yes
```

## Ready to request: `bench1`, formal free studies on one whole 64-core node

**Why:** a whole node gives the serial, single-node strong and weak, ranks x threads, schedule, leaf and theta studies to 64 cores without the sharing
that widened `bench16`'s ranges. It does not supply 256 cores.

| | |
|---|---|
| Source | `367c63046583a2d7f26a0ddc1109bd07d99b2fad`, tree `f0ba7fae95dc917837ac7f0370736313189ad985`, clone `~/dsa5208-p3-367c630`, prepared and clean |
| Manifest | `studies_single_node.json`, status `frozen`, SHA-256 `ea1ceb2c734b08009ce4a582ed8d1c0e2d8d6a877d0e30d0d392274de7c1c64b`, 148 runs |
| Request | `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 5 h, 320 core-hours at most; about 100 min expected. Worst case 16140 s fits the 17358 s budget |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck |
| Wait | Needs a whole free node: `1522998` waited about 4 h for one |

> Leon explicitly approves exactly ONE bench1 submission: source `367c63046583a2d7f26a0ddc1109bd07d99b2fad` in ~/dsa5208-p3-367c630, manifest studies_single_node.json SHA256 ea1ceb2c734b08009ce4a582ed8d1c0e2d8d6a877d0e30d0d392274de7c1c64b,
> 1 node x 64 cores, 120 GB, 5 h, auto_free, no -P, ZERO CHARGE ONLY. Same checks as for pilot2, with no duplicate p3_bench1; then submit once and record
> the job ID. No retries, other jobs, spending, credential or security changes, monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-367c630/code
bash jobs/vanda/submit.sh bench1 --queue auto_free --no-project --yes
```

Dry runs of both printed these and submitted nothing: `code/artifacts/cluster/discovery/vanda_dryrun_367c630_20261106T1723.txt`. Each runs `qsub -q auto_free -v SOURCE_GIT_REV=367c63046583a2d7f26a0ddc1109bd07d99b2fad -o /home/svu/leonyil.qian/dsa5208-p3-367c630/code/artifacts/cluster/logs/ jobs/vanda/<job>.pbs`.

## Conditional: `pilot4` and `bench4`, charged, not ready

Both need `pilot2` to pass, **Leon's `amgr login`, the project ID, the balance, and charge approval**. `bench4` also needs its plan frozen from `pilot4`'s
result, which changes its hash. Neither has a Vanda dry run, because `submit.sh` needs the real project ID for a correct one.

| Job | Request | Most it could charge, at 1 per core-hour (assumed) | Expected use | Manifest SHA-256 at `367c630` |
|---|---|---|---|---|
| `pilot4` | 4 x 64 cores, 240 GB each, 45 min, `auto` | 192 | 12 min | `0372e6b05b96810a6ef2c9f687b66904e5c414a8143bad87de756377ff8af823` |
| `bench4` | 4 x 64 cores, 240 GB each, 2 h 50 min, `auto` | 725 | 56 min | `45c24936ec8185f0c0d86695fe1b3f8ef18136982d8259a777f212f62d39772d`, proposed |

## Consumed, 5 November 2026: `bench16`, formal free 16-core studies

**Approved by Leon and submitted once on 5 Nov at 17:20:38 SGT as job `1523703`. This approval is used up.** All rechecks passed first; `1522998` was left untouched. A failure is not retried. Records:
`code/artifacts/cluster/discovery/vanda_bench16_dryrun_e86bf5d_20261105T1719.txt`, `code/artifacts/cluster/discovery/vanda_bench16_submit_e86bf5d_20261105T1720.txt`. The request as reviewed:

**Why now:** it secures serial runtime against N and the parameter studies for the report without waiting for a whole 64-core node,
which `1522998` has been waiting for since 13:46. At 16:47 SGT no free-pool node had 32 cores free, and 2 had at least 16. That is one
moment and counts cores only. It does **not** supply 256-core scaling, and it does not replace `pilot2`, `pilot4` or `bench4`.

| | |
|---|---|
| Source | `e86bf5d076c51c01f131f3980fc17618e9c24f61`, tree `96eed32b4aec96fdaee9082e5e41b35552c64415`, in a new clone `~/dsa5208-p3-e86bf5d` |
| Manifest | `studies_16core.json`, status `frozen`, SHA-256 `2525574ba733e4a74c44100daa0a8ec2b8a89e7e9e81c7a8025ea44439226dcd` |
| Runs | 121: 3 interleaved repetitions of 39 cases, plus 4 accuracy runs |
| Request | `select=1:ncpus=16:mpiprocs=16:mem=16gb`, 4 h, 64 core-hours at most; about 95 min expected. Worst case 12285 s fits the 13158 s budget |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck. PBS has shown `project = personal-leonyil.qian` on free jobs, and the balance is unread |
| With `1522998` | Untouched. 64 + 16 cores is inside the 160-CPU, 2-running-job limit |
| Gates | `allocation`, `build`, `placement` (4 x 4), `place_mpi` (16 x 1, the probe the pilot lacked), `internode`, `serial`, `bound_vs_serial`, `runs`, `analyze` |
| If a gate fails | The job stops, with no retry |
| Limits of the results | Possibly shared node of either CPU model; speedups only inside this job. |

Text that was proposed:

> Leon explicitly approves exactly ONE bench16 submission: source `e86bf5d076c51c01f131f3980fc17618e9c24f61` in a new clone ~/dsa5208-p3-e86bf5d, manifest studies_16core.json
> SHA256 2525574ba733e4a74c44100daa0a8ec2b8a89e7e9e81c7a8025ea44439226dcd, 1 node x 16 cores, 16 GB, 4 h, auto_free, no -P, ZERO CHARGE ONLY. Prepare the clone from an exact-source bundle, then use
> hard-bounded existing-auth checks to verify commit, tree, manifest and resources, scheduling and queues enabled and started with rate 0,
> and no duplicate p3_bench16 in current jobs or history. Run the dry run without --yes, then if all conditions pass submit the command
> below exactly once and record the job ID. Leave 1522998 untouched. No retries, other jobs, spending, credential or security changes,
> monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-e86bf5d/code
bash jobs/vanda/submit.sh bench16 --queue auto_free --no-project --yes
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=e86bf5d076c51c01f131f3980fc17618e9c24f61 -o /home/svu/leonyil.qian/dsa5208-p3-e86bf5d/code/artifacts/cluster/logs/ jobs/vanda/bench16.pbs
```

Local dry run from a clean clone of this commit: `code/artifacts/local/bench16_dryrun_20261105.txt`. There is no `qsub` on this machine, so its paths differ. The Vanda dry run passed before submission.

## Superseded 6 Nov: conditional requests as of 5 Nov

Each needs a new clean clone of the commit, its dry run, and the conditions here first. Sizes remain provisional.

| Job | Needs first | Request, charge | Expected use | Manifest SHA-256 at `e86bf5d` |
|---|---|---|---|---|
| `pilot2` | `1522998` passed, so 64 ranks on a node is shown. Two whole free nodes must also come up | 2 x 64 cores, 120 GB each, 30 min, `auto_free`, rate 0 | 9 min | `c3ac455c7993821903e5f77b35cf00baeadd1b526756ee04994230194c662e67` |
| `bench1` | `1522998` passed and plan frozen. After `bench16`, its serial and parameter runs can drop | 1 x 64 cores, 120 GB, 5 h, `auto_free`, rate 0 | 97 min | `ebea537b5731feba7ad2f0e71b1d5b5a5c338dce9c3efe23b98112273c395990` |
| `pilot4` | `pilot2` passed, **Leon's `amgr login`, project ID and charge approval** | 4 x 64 cores, 240 GB each, 45 min, `auto`, **192 core-hours** | 12 min | `609267a4ff94d63822b5b69ca7af1582c1990c936b5f16aae1f519ea577a313e` |
| `bench4` | `pilot4` passed, plan frozen from it, balance compared, **charge approval** | 4 x 64 cores, 240 GB each, 2 h 45 min, `auto`, **704 core-hours** | 54 min | `937a701bf930b698dee7a89f6ccbd2333259562af93a2186873059d4335e99e6`; changes when frozen |

## Consumed, 5 November 2026: 16-core pilot

**Approved by Leon and submitted once on 5 Nov at 14:36:19 SGT as job `1523275`. This approval is used up.**
All rechecks passed first, including that `1522998` was still queued and had never started; it was left untouched. The job was queued
in `cpu_parallel` at rate 0. A failure is not retried. Record:
`code/artifacts/cluster/discovery/vanda_pilot16_submit_96a37ba_20261105T143606.txt`. Reasoning is in `plan_256core.md`, "Smaller pilot".

| | |
|---|---|
| Source | `96a37ba1d5dfa810dfa24bb740e58aad9aa5388d`, in a new clone `~/dsa5208-p3-96a37ba` |
| Manifest | `pilot_single_node_16core.json`, SHA-256 `340af523ae17b4f996426dffe7d4bd42adcd4bf400a8807a9b2a61cd545c0690`, 20 runs |
| Request | `select=1:ncpus=16:mpiprocs=16:mem=16gb`, 60 min, 16 core-hours at most |
| Queue, charge | `auto_free`, no `-P`, recheck rate 0 before submitting |
| With `1522998` | It stays queued. 64 + 16 cores is inside the 160-CPU, 2-running-job limit |
| If a gate fails | The job stops, with no retry |

**Prepared on Vanda, 5 Nov 14:31 SGT:** clone `~/dsa5208-p3-96a37ba` created from a bundle holding only this commit. Commit, tree
`2e833d8567bba10e71da1b6ad63017262c215bd2` and manifest hash verified, and the clone is clean. Scheduling on, `auto_free` and
`cpu_parallel` enabled and started, rate 0. The only unfinished job is `1522998`, and no `p3_pilot16` exists. Dry run printed the
command and submitted nothing. Record: `code/artifacts/cluster/discovery/vanda_pilot16_dryrun_96a37ba_20261105T143058.txt`.

After approval: recheck commit, tree, manifest hash, rate 0, queues, duplicates and that `1522998` has not started, then run once. This is what ran:

```sh
cd ~/dsa5208-p3-96a37ba/code
bash jobs/vanda/submit.sh pilot16 --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_16core.json --yes
```


## Consumed, 5 November 2026: rerun the single-node pilot once

**Approved by Leon and submitted once on 5 Nov at 13:46:25 SGT as job `1522998`. This approval is used up.**
All rechecks passed first. The job was queued in `cpu_parallel` at rate 0. A failure is not retried: it needs a local fix and a new
approval. Record: `code/artifacts/cluster/discovery/vanda_pilot_rerun_submit_3f77e87_20261105T134621.txt`.

**Prepared on Vanda, 5 Nov 13:31 SGT:** clone `~/dsa5208-p3-3f77e87` created from a bundle holding only this commit. Commit, tree
`00bf445fb0350de806d83aa0c10a5097bc32c636` and manifest hash verified, and the clone is clean. Scheduling on, `auto_free` and
`cpu_parallel` enabled and started, rate 0, no unfinished job. `p3_pilot1` history holds only finished `1514774` and `1519637`. Dry
run printed the command and submitted nothing. Recheck these just before submitting. Record:
`code/artifacts/cluster/discovery/vanda_pilot_rerun_dryrun_3f77e87_20261105T133115.txt`.

| | |
|---|---|
| Why | Pilot `1519637` hung at `placement`, 0 of 20 runs. All sizing waits on this job |
| Change from `1519637` | Launcher only: `pbs_tmrsh` instead of a hostfile launch that selected `tm` (commit `3f77e87`) |
| Same as `1519637` | Manifest `pilot_single_node_v2.json` (SHA-256 `0a5f9f64cc5923a218ec9be9f3498be34baf2733c1aeaee1f4daa78c1e2f937a`, 20 runs), solver, gates, resources |
| Request | `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min, 64 core-hours at most |
| Queue, charge | `auto_free`, no `-P`, rate 0 last time. The dry run shows the command, and rate 0 is checked again before submitting |
| Queue wait | `1519637` waited 10 h 1 min. This is no prediction |
| If the launcher is still wrong | The `placement` gate stops the job in about 2 minutes, with no retry |

The command that was run once:

```sh
cd ~/dsa5208-p3-3f77e87/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json --yes
```

Nothing here approves `pilot2`, `pilot4`, `bench1` or `bench4`, a charged queue, a
retry, or monitoring. It also tests `pbs_tmrsh` at 64 ranks on one node for free, which no job has yet done.

## Closed, 4 November 2026

**Both requests below were approved and submitted once on 4 Nov at 19:10 SGT: pilot `1519637` and GPU timing `1519638`.** GPU timing finished. The pilot ran on 5 Nov and failed at `placement`, exit 5. A failure is not retried
automatically: it needs a local fix and a new approval.

**Vanda state, 4 Nov 18:59 SGT:** clean clone `~/dsa5208-p3-8a50c8f` created, commit and tree verified, dry runs printed the
commands below. Scheduling on, charge rate 0 on `auto_free`, `cpu_parallel` and `gpu`, no current jobs, no duplicates.
Record: `code/artifacts/cluster/discovery/vanda_pilot_gpu_timing_dryrun_8a50c8f_20261104T185923.txt`. Commits after `8a50c8f` add only notes and evidence. The earlier `075ec51`
and `6493ced` preparations are withdrawn: neither clone was created, and `6493ced` lacks the G2 review fixes.

Both jobs: revision `8a50c8f754f716aad91f81343f7eeb6d950a4cf6`, clone `~/dsa5208-p3-8a50c8f`, `auto_free` with no `-P`,
charge rate 0.

## 1. Single-node pilot, manifest v2

`select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min (routed to `cpu_parallel` last time).

```sh
cd ~/dsa5208-p3-8a50c8f/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json --yes
```

That runs:

```sh
qsub -q auto_free -v MANIFEST=manifests/pilot_single_node_v2.json,SOURCE_GIT_REV=8a50c8f754f716aad91f81343f7eeb6d950a4cf6 -o /home/svu/leonyil.qian/dsa5208-p3-8a50c8f/code/artifacts/cluster/logs/ jobs/vanda/pilot.pbs
```

Manifest `pilot-single-node-v2`, status `proposed` (allowed for a pilot), sha256 `0a5f9f64cc59`: 20 runs, one repetition,
64-core cases first. Those essential cases start even if every run uses its whole limit; up to 11 others could be skipped.
Gates: `allocation`, `build`, `placement`, `runs`, `analyze`.

These are pilot numbers, not report results. No job has yet passed the entry point on a 64-core allocation. The node may be
Gold 6438N or Platinum 8452Y; the model is recorded, and later baselines must match it.

## 2. GPU timing (G2)

`select=1:ngpus=1:ncpus=36:mem=60gb`, **60 min** (routed to `gpu` last time).

```sh
cd ~/dsa5208-p3-8a50c8f/code
bash jobs/vanda/submit.sh gpu_timing --queue auto_free --no-project --yes
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=8a50c8f754f716aad91f81343f7eeb6d950a4cf6 -o /home/svu/leonyil.qian/dsa5208-p3-8a50c8f/code/artifacts/cluster/logs/ jobs/vanda/gpu_timing.pbs
```

Manifest `manifests/gpu_timing.json` (`gpu-timing-v1`, frozen, sha256 `36b00fe2c12e`): N = 10^5, 3x10^5, 10^6, 3x10^6;
device and CPU backends; 36 bound threads; schedule dynamic,64 on the CPU kernel; 5 timed steps; 3 repetitions; 24 runs;
worst case 2880 s.

| Gate | Kind | Question |
|---|---|---|
| `build` | critical | `nvc++ -mp=gpu` builds `bh_gpu` on the node |
| `device` | critical | Kernel on a device with separate memory, offload mandatory |
| `gpu_busy` | required | `nvidia-smi` shows the GPU working during a run |
| `runs` | required | All 24 runs; a fallback, wrong team, stacked CPUs, no binding or wrong schedule is recorded as failed |
| `analyze` | required | Summary from raw records, refusing the same faults; ratio only for matching workload, binary, host and placement |

If it passes this would be report data, from one GPU in one job. Only the force traversal differs; the tree build, flatten and
integrate use one host thread on both backends and are in the timed region. The CPU side is this program's kernel built by
`nvc++`, not the GCC hybrid solver, so the ratio says nothing about `bh_hybrid`. This path has only run with a stub and a
no-device build, and the team and schedule probes have not been compiled by `nvc++`. If `nvc++` runs them differently, runs
are refused rather than timed, and the job would need a fix and new approval.

## 3. Other decisions

Next requests, not yet open: `pilot2`, `pilot4`, `bench4` and `bench1`, in [plan_256core.md](plan_256core.md). Each needs its own approval.

- Run `amgr login` to read projects and balance. Only Leon can do this.
- Open gap: no bound two-node result has been compared with serial (job 1514458's comparison was unbound).
  `pilot2` and `pilot4` include this comparison, on every core.
