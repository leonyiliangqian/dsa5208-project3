# Approval requests, 4 November 2026

Nothing below has been submitted, and no approval is open. Immediately before any submission, recheck
`scheduling = True`, queue enabled and started, charge rate 0, current jobs and duplicates. A failure is not retried
automatically.

**Vanda state: `~/dsa5208-p3-075ec51` has NOT been created.** The login node stopped responding on 4 Nov at about
18:03 SGT and the SSH session closed before the transfer, so nothing was uploaded. No Vanda dry run exists for either
request; both commands below come from dry runs in a clean local clone of origin. The two requests run from different
revisions. Commit `6493ced` holds the G2 code and pilot v2.

## 1. Single-node pilot, rerun (choose one)

Both: `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min, `auto_free` (routed to `cpu_parallel` last time), no `-P`,
charge rate 0. Pilot numbers, not report results. No job has yet passed the entry point on a 64-core allocation. The
node may be Gold 6438N or Platinum 8452Y; the model is recorded, and later baselines must match it. Gates: `allocation`,
`build`, `placement`, `runs`, `analyze`.

**1A, recommended: revision 6493ced, manifest v2.** Clone `~/dsa5208-p3-6493ced` is not created, and creating it needs
this approval. Same 20 runs as v1, 64-core cases first; those essential cases start even if every run uses its whole
limit. Manifest sha256 `0a5f9f64cc59`, status `proposed`.

```sh
cd ~/dsa5208-p3-6493ced/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json --yes
qsub -q auto_free -v MANIFEST=manifests/pilot_single_node_v2.json,SOURCE_GIT_REV=6493cedda64a2e2d9105ffeb476450c953536f59 -o /home/svu/leonyil.qian/dsa5208-p3-6493ced/code/artifacts/cluster/logs/ jobs/vanda/pilot.pbs   # what the line above runs
```

**1B: revision 075ec51, manifest v1, as previously prepared.** Manifest sha256 `d1cd10a5`. All 20 runs start if timings
are within about 2x a local estimate; at about 4x, every 64-core case is skipped. See `experiments.md`.

```sh
cd ~/dsa5208-p3-075ec51/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --yes
qsub -q auto_free -v SOURCE_GIT_REV=075ec5191ab1251b34c1f458be3b29b2acc1a438 -o /home/svu/leonyil.qian/dsa5208-p3-075ec51/code/artifacts/cluster/logs/ jobs/vanda/pilot.pbs   # what the line above runs
```

## 2. GPU timing (G2)

Revision `6493cedda64a2e2d9105ffeb476450c953536f59`, the same new clone as 1A. Request:
`select=1:ngpus=1:ncpus=36:mem=60gb`, **60 min**, `auto_free` (routed to `gpu` last time), no `-P`, charge rate 0.

```sh
cd ~/dsa5208-p3-6493ced/code
bash jobs/vanda/submit.sh gpu_timing --queue auto_free --no-project --yes
qsub -q auto_free -v SOURCE_GIT_REV=6493cedda64a2e2d9105ffeb476450c953536f59 -o /home/svu/leonyil.qian/dsa5208-p3-6493ced/code/artifacts/cluster/logs/ jobs/vanda/gpu_timing.pbs   # what the line above runs
```

Manifest `manifests/gpu_timing.json` (`gpu-timing-v1`, frozen, sha256 `36b00fe2c12e`): N = 10^5, 3x10^5, 10^6, 3x10^6;
device and CPU backends; 36 host threads; 5 timed steps; 3 repetitions; 24 runs; worst case 2880 s.

| Gate | Kind | Question |
|---|---|---|
| `build` | critical | `nvc++ -mp=gpu` builds `bh_gpu` on the node |
| `device` | critical | Kernel on a device with separate memory, offload mandatory |
| `gpu_busy` | required | `nvidia-smi` shows the GPU working during a run |
| `runs` | required | All 24 runs; a device run that falls back is recorded as failed |
| `analyze` | required | Summary from raw records, refusing fallback; ratio only for matching workloads |

This job's timing would be report data if it passes, from one GPU in one job. Only the force traversal is offloaded. The
CPU backend is the same kernel built by `nvc++`, not the GCC hybrid solver, so the ratio says nothing about `bh_hybrid`.
This path has only run with a stub and a no-device build. A failure is not retried.

## 3. Other decisions

- Run `amgr login` to read projects and balance. Only Leon can do this.
- Ask the lecturer about a course project or free-queue exception for 256 cores, and how to submit
  source code when Canvas lists PDF only. Nothing has been sent.
- Later: the 4-node pilot and `bench4` (charged, `batch_cpu`). See [requirements_plan.md](requirements_plan.md).
- Open gap: no bound two-node result has been compared with serial (job 1514458's comparison was unbound).
  No job for this is proposed yet.
