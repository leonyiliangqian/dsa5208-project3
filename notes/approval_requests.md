# Approval requests, 4 November 2026

Nothing below has been submitted. The earlier approvals are consumed: pilot 1514774 failed at entry and GPU
validation 1514775 passed. Immediately before any submission, recheck `scheduling = True`, queue enabled and started,
charge rate 0, current jobs and duplicates. A failure is not retried automatically.

## 1. Single-node pilot, rerun with the entry fix

Commit `075ec5191ab1251b34c1f458be3b29b2acc1a438`. Later commits on `main` add only notes. The dry run so far is
local: a clean clone of origin printed the command below, except for the clone path, and `tests/jobs/pbs_entry_test.sh`
passed there. **Nothing has been uploaded to Vanda and this revision has not run there.** After approval, and with
the SSH session open:

```sh
git clone -q . /tmp/p3-075ec51 && git -C /tmp/p3-075ec51 checkout -q -B main 075ec5191ab1251b34c1f458be3b29b2acc1a438
git -C /tmp/p3-075ec51 bundle create /tmp/dsa5208-p3-075ec51.bundle main
scp /tmp/dsa5208-p3-075ec51.bundle vanda:~/
```

On Vanda, in a new clone, leaving earlier clones alone:

```sh
git clone -b main ~/dsa5208-p3-075ec51.bundle ~/dsa5208-p3-075ec51 && cd ~/dsa5208-p3-075ec51/code
git log --oneline -1
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project        # dry run on Vanda first
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --yes  # only after approval
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=075ec5191ab1251b34c1f458be3b29b2acc1a438 -o /home/svu/leonyil.qian/dsa5208-p3-075ec51/code/artifacts/cluster/logs/ jobs/vanda/pilot.pbs
```

Request: `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min, `auto_free` (routed to `cpu_parallel` last time), no
`-P`, charge rate 0. Manifest: `manifests/pilot_single_node.json` (`pilot-single-node-v1`, status `proposed`, sha256
`d1cd10a5`), 20 runs, one repetition each.

| Gate | Kind | Question |
|---|---|---|
| `allocation` | critical | One host, exact 64-CPU cpuset, one CPU model |
| `build` | critical | `-march=native` build on the node |
| `placement` | critical | 8 ranks x 8 threads bound correctly |
| `runs` | required | Manifest cases, each with its own time limit and a job deadline |
| `analyze` | required | Records parse into a summary |

Purpose: choose the formal sizes, walltimes and leaf size. These are pilot numbers, not report results. No job has
yet passed the entry point on a full 64-core allocation. The worst case is 12,000 s against a 3,600 s limit, so runs
reaching the deadline are recorded as skipped; that would limit the sizing data without proving a fault. The
node may be Gold 6438N or Platinum 8452Y; the model is recorded, and later baselines must match it.

## 2. Other decisions

- Run `amgr login` to read projects and balance. Only Leon can do this.
- Ask the lecturer about a course project or free-queue exception for 256 cores, and how to submit
  source code when Canvas lists PDF only. Nothing has been sent.
- Later: the 4-node pilot and `bench4` (charged, `batch_cpu`). See [requirements_plan.md](requirements_plan.md).
- GPU timing (G2) needs runner support and its own request, after the pilot. Not proposed yet.
- Open gap: no bound two-node result has been compared with serial (job 1514458's comparison was unbound).
  No job for this is proposed yet.
