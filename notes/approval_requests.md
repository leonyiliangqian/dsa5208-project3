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

## 1. Diagnostic rerun (new job ID; 1513781 stays as it is)

The local rehearsal from a clean clone passes, but that is not Vanda.
Request: 2 x 8 cores, 4 GB each, `place=scatter`, 20 min, `auto_free`, no `-P`, charge rate 0.

```sh
bash jobs/vanda/submit.sh diag --queue auto_free --no-project        # dry run
bash jobs/vanda/submit.sh diag --queue auto_free --no-project --yes  # only after approval
```

Success means every step ran and left a clean report on both nodes, so the stall can be
compared step by step. d5 and d9 are the setup that stalled in job 1507215, and either result is
useful. A pass does not establish two-node solver correctness; that is the separate `twonode` job.
If the job stops at `cleanup` again, the read-back over Vanda's shared filesystem failed.

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
