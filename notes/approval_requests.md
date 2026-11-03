# Approval requests, 3 November 2026

Nothing below has been submitted or uploaded. Each item needs its own yes from Leon. Recheck
`scheduling = True` and charge rate 0 immediately before any submission.

## 1. Diagnostic rerun (new job ID; 1513781 stays as it is)

Revision: `main` at `56d3de5`. Local rehearsal from a clean clone passes
(`code/artifacts/local/runs/simulated-diag-tmoutput-20261103-56d3de5`), but that is not Vanda.
Request: 2 x 8 cores, 4 GB each, `place=scatter`, 20 min, `auto_free`, no `-P`, charge rate 0.

On the Mac, with the SSH session open:

```sh
git bundle create /tmp/dsa5208-p3-56d3de5.bundle 56d3de5 main
scp /tmp/dsa5208-p3-56d3de5.bundle vanda:~/
```

On Vanda:

```sh
git clone -b main ~/dsa5208-p3-56d3de5.bundle ~/dsa5208-p3-56d3de5 && cd ~/dsa5208-p3-56d3de5/code
git log --oneline -1                                      # must print 56d3de5
bash jobs/vanda/submit.sh diag --queue auto_free --no-project        # dry run
bash jobs/vanda/submit.sh diag --queue auto_free --no-project --yes  # only after approval
```

Expected `qsub` line:

```
qsub -q auto_free -v SOURCE_GIT_REV=56d3de57a64f031e882194d705bfcbd3358b2a1d -o <clone>/code/artifacts/cluster/logs/ jobs/vanda/diag.pbs
```

Success means every step ran and left a clean report on both nodes, so the stall can be
compared step by step. d5 and d9 are the setup that stalled in job 1507215, and either result is
useful. A pass does not establish two-node solver correctness; that is the separate `twonode` job.
If the job stops at `cleanup` again, the read-back over Vanda's shared filesystem failed.

## 2. GPU validation

Revision: branch `gpu/omp-target`; use its tip and confirm the commit on Vanda.
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
| `compiled` | Build log shows GPU code generation | |
| `gpu_gate` | theta=0 against direct; theta>0 against host tree; closed form; trajectory against serial; device buffers reused while the tree grows | 1e-10; 1e-12; 1e-12; 1e-10 |
| `gpu_busy` | `nvidia-smi` shows nonzero utilisation during a 1,000,000-particle run | |

Known risks, none tested: `nvc++` may reject or miscompile something GCC accepted; the 2 KB
per-thread traversal stack may not fit on the device; the `compiled` pattern was written from
memory of `-Minfo` output and could be wrong, which would stop the job safely. The job produces no
timing for the report. G2 needs runner support and its own approval, after this passes.

A failure does not get retried automatically: bring back the evidence, fix, and ask again.

## 3. Optional checks before item 2, no cluster job

Either could catch a compiler rejection without waiting in the GPU queue:

- **Local:** add Debian's `gcc-12-offload-nvptx` to a Docker image (a package download). This compiles
  the kernel for NVIDIA targets but still cannot run it here, and it is GCC, not `nvc++`.
- **Vanda login node:** compile only with the recommended module, no execution. The earlier
  policy kept compilers off the login node, so this needs an explicit exception.

## 4. Other decisions

- Merge and push `gpu/omp-target`. It is local only at the moment.
- Run `amgr login` to read projects and balance. Only Leon can do this.
- Ask the lecturer about a course project or free-queue exception for 256 cores, and how to submit
  source code when Canvas lists PDF only. Nothing has been sent.
- Later, after `twonode`: `pilot` (free), then the 4-node pilot and `bench4` (charged, `batch_cpu`). See
  [requirements_plan.md](requirements_plan.md).
