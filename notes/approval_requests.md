# Approval requests

## Open, 5 November 2026: 16-core pilot, not approved

**Not approved and not submitted.** Reasoning is in `plan_256core.md`, "Smaller pilot". Use it only if `1522998` has not started;
if `1522998` has started or passed its gates, this request lapses.

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

After approval: recheck commit, tree, manifest hash, rate 0, queues, duplicates and that `1522998` has not started, then run once:

```sh
cd ~/dsa5208-p3-96a37ba/code
bash jobs/vanda/submit.sh pilot16 --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_16core.json --yes
```


## Consumed, 5 November 2026: rerun the single-node pilot once

**Approved by Leon and submitted once on 5 Nov at 13:46:25 SGT as job `1522998`. This approval is used up, and no approval is open.**
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
