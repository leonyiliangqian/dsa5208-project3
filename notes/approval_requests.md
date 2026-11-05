# Approval requests

## Open, 5 November 2026: rerun the single-node pilot once

**Not approved and not submitted.** It needs Leon's explicit yes.

| | |
|---|---|
| Why | Pilot `1519637` hung at `placement`, 0 of 20 runs. All sizing waits on this job |
| Change from `1519637` | Launcher only: `pbs_tmrsh` instead of a hostfile launch that selected `tm` (commit `3f77e87`) |
| Same as `1519637` | Manifest `pilot_single_node_v2.json` (SHA-256 `0a5f9f64cc5923a218ec9be9f3498be34baf2733c1aeaee1f4daa78c1e2f937a`, 20 runs), solver, gates, resources |
| Request | `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min, 64 core-hours at most |
| Queue, charge | `auto_free`, no `-P`, rate 0 last time. The dry run shows the command, and rate 0 is checked again before submitting |
| Queue wait | `1519637` waited 10 h 1 min. This is no prediction |
| If the launcher is still wrong | The `placement` gate stops the job in about 2 minutes, with no retry |

If approved, these steps run once:

```sh
# Mac: copy the commit, using the existing SSH session
git bundle create "$SP/p3-3f77e87.bundle" --all
scp "$SP/p3-3f77e87.bundle" vanda:~/

# Vanda: new clone, leaving every older clone as it is
git clone ~/p3-3f77e87.bundle ~/dsa5208-p3-3f77e87
cd ~/dsa5208-p3-3f77e87 && git checkout 3f77e8727a9876f77667d3b7d78b9934ad43897d && cd code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json
# stop here unless the commit, command, charge rate and absence of a duplicate job all check out
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json --yes
```

`$SP` is a temporary directory on the Mac. Nothing here approves `pilot2`, `pilot4`, `bench1` or `bench4`, a charged queue, a
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
