# Approval requests, 3 November 2026

Nothing below has been submitted or uploaded. Each item needs its own yes from Leon. Recheck
`scheduling = True` and charge rate 0 immediately before any submission.

## Revision

Both jobs run from one clone of `main`. On the Mac, `git rev-parse main` gives the revision, and the
approval message states it. The first line on Vanda below must print the same short hash.

On the Mac, with the SSH session open:

```sh
REV=$(git rev-parse --short main)
git bundle create /tmp/dsa5208-p3-$REV.bundle main
scp /tmp/dsa5208-p3-$REV.bundle vanda:~/
```

On Vanda, with the same value of `REV`:

```sh
git clone -b main ~/dsa5208-p3-$REV.bundle ~/dsa5208-p3-$REV && cd ~/dsa5208-p3-$REV/code
git log --oneline -1
```

## 1. Two-node correctness

Not a benchmark. Diagnostic 1514029 is done; see `experiments.md`.
Request: 2 x 8 cores, 16 GB each, `place=scatter`, 30 min, `auto_free`, no `-P`, charge rate 0.
Launcher: `pbs_tmrsh` (the `twonode.pbs` default).

```sh
bash jobs/vanda/submit.sh twonode --queue auto_free --no-project        # dry run
bash jobs/vanda/submit.sh twonode --queue auto_free --no-project --yes  # only after approval
```

| Gate | Kind | Question |
|---|---|---|
| `allocation` | critical | Two hosts, exact 8-CPU cpusets, remote daemon under `pbs_mom` and not `sshd`, `PBS_JOBID` on both |
| `build`, `flags`, `toolchain` | critical | Portable build on the node; OpenMP and MPI work |
| `internode_2` / `internode_16` | critical / required | Data exchange across hosts |
| `place_2x4_1..3` | required | PE=4, repeated: this mapping hung under tm |
| `place_4x2`, `place_8x1` | required | Other per-node mappings |
| `serial`, `hybrid` | required | Serial gate, then hybrid results against serial across both nodes |
| `recorder` | required | A bound PE=4 solver run through the measurement recorder |
| `place_1x8_1..3` | required | PE=8, repeated: the mapping from job 1507215 |

How to read the result: `allocation` failing on `remote_under_pbs_mom` means the daemons may run outside PBS
ownership, and nothing else in the job can run. Three passes of each mapping are evidence for this route, not
proof it is reliable, and they would not explain the tm hang. This route adds two options d8 did not use.
A pass on these nodes does not cover the charged `cpu_node` pool. A failure is not retried automatically.

## 2. GPU validation

Request: `select=1:ngpus=1:ncpus=36:mem=60gb`, 30 min, `auto_free`, no `-P`, charge rate 0.
Module: `nvhpc-hpcx-cuda12/26.1`. Routing to the `gpu` queue is expected, not yet seen.

```sh
bash jobs/vanda/submit.sh gpu_validate --queue auto_free --no-project        # dry run
bash jobs/vanda/submit.sh gpu_validate --queue auto_free --no-project --yes  # only after approval
```

| Gate | Passes when | Limit fixed in advance |
|---|---|---|
| `build` | `nvc++ -mp=gpu` builds serial and GPU programs on the node | 300 s |
| `device` | Kernel ran on a device with separate memory | exit 7 otherwise |
| `gpu_gate` | theta=0 against direct; theta>0 against host tree; closed form; trajectory against serial; device buffers reused while the tree grows | 1e-10; 1e-12; 1e-12; 1e-10 |
| `gpu_busy` | `nvidia-smi` shows nonzero utilisation during a 1,000,000-particle run | |
| `compiled` (optional, record only) | Compiler messages mention GPU code generation; does not affect the verdict | |

Known risks, none tested: `nvc++` may reject or miscompile something GCC accepted; the 2 KB
per-thread traversal stack may not fit on the device. The job produces no timing for the report. G2 needs runner support and its own approval, after this passes.

A failure does not get retried automatically: bring back the evidence, fix, and ask again.

## 3. Other decisions

- Run `amgr login` to read projects and balance. Only Leon can do this.
- Ask the lecturer about a course project or free-queue exception for 256 cores, and how to submit
  source code when Canvas lists PDF only. Nothing has been sent.
- Later, after `twonode`: `pilot` (free), then the 4-node pilot and `bench4` (charged, `batch_cpu`). See
  [requirements_plan.md](requirements_plan.md).
