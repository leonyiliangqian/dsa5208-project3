# Approval requests, 3 November 2026

Nothing below has been submitted. Each job needs its own yes from Leon, and neither depends on the other.
Immediately before any submission, recheck `scheduling = True`, charge rate 0 and current jobs. A failure is
not retried automatically.

## Revision

Both jobs run from the clean clone `~/dsa5208-p3-fa9da68` on Vanda, commit
`fa9da689dd4044610f799fa6464dd8048d73cede`. Commits after it on `main` add only notes and evidence. Dry-run
record: `code/artifacts/cluster/discovery/vanda_pilot_gpu_dryrun_fa9da68_20261103T191451.txt`.

## 1. Single-node pilot

Request: `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min, `auto_free`, no `-P`, charge rate 0. Routing to
`cpu_parallel` is expected from the request size, not yet seen for this job.

```sh
cd ~/dsa5208-p3-fa9da68/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --yes
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=fa9da689dd4044610f799fa6464dd8048d73cede -o /home/svu/leonyil.qian/dsa5208-p3-fa9da68/code/artifacts/cluster/logs/ jobs/vanda/pilot.pbs
```

Manifest: `manifests/pilot_single_node.json` (`pilot-single-node-v1`, status `proposed`, which this job allows;
sha256 `d1cd10a5`). One repetition per case: serial runtime against N up to 2,000,000; 1 x 1, 1 x 64, 8 x 8 and
64 x 1 at N=1,000,000; schedules; leaf size; accuracy and cost against theta.

| Gate | Kind | Question |
|---|---|---|
| `allocation` | critical | One host, exact 64-CPU cpuset, one CPU model |
| `build` | critical | `-march=native` build on the node |
| `placement` | critical | 8 ranks x 8 threads bound correctly |
| `runs` | required | Manifest cases, each with its own time limit and a job deadline |
| `analyze` | required | Records parse into a summary |

Purpose: choose the formal sizes, walltimes and leaf size. These are pilot numbers, not report results. No job has
run on a full 64-core allocation yet. The node may be Gold 6438N or Platinum 8452Y; the model is recorded, and
later baselines must match it. A hybrid case can time out or be skipped at the deadline without proving a fault.

## 2. GPU validation

Request: `select=1:ngpus=1:ncpus=36:mem=60gb`, 30 min, `auto_free`, no `-P`, charge rate 0. Module
`nvhpc-hpcx-cuda12/26.1` is listed on the login node; it has not been loaded here. Routing to `gpu` is expected, not yet seen.

```sh
cd ~/dsa5208-p3-fa9da68/code
bash jobs/vanda/submit.sh gpu_validate --queue auto_free --no-project --yes
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=fa9da689dd4044610f799fa6464dd8048d73cede -o /home/svu/leonyil.qian/dsa5208-p3-fa9da68/code/artifacts/cluster/logs/ jobs/vanda/gpu_validate.pbs
```

| Gate | Passes when | Limit fixed in advance |
|---|---|---|
| `build` | `nvc++ -mp=gpu` builds serial and GPU programs on the node | 300 s |
| `device` | Kernel ran on a device with separate memory | exit 7 otherwise |
| `gpu_gate` | theta=0 against direct; theta>0 against host tree; closed form; trajectory against serial; device buffers reused while the tree grows | 1e-10; 1e-12; 1e-12; 1e-10 |
| `gpu_busy` | `nvidia-smi` shows nonzero utilisation during a 1,000,000-particle run | |
| `compiled` (optional, record only) | Compiler messages mention GPU code generation; does not affect the verdict | |

Known risks, none tested: `nvc++` may reject or miscompile something GCC accepted; the 2 KB per-thread traversal
stack may not fit on the device. The job produces no timing for the report. G2 needs runner support and its own
approval, after this passes.

## 3. Other decisions

- Run `amgr login` to read projects and balance. Only Leon can do this.
- Ask the lecturer about a course project or free-queue exception for 256 cores, and how to submit
  source code when Canvas lists PDF only. Nothing has been sent.
- Later: the 4-node pilot and `bench4` (charged, `batch_cpu`). See [requirements_plan.md](requirements_plan.md).
- Open gap: no bound two-node result has been compared with serial (job 1514458's comparison was unbound).
  No job for this is proposed yet.
