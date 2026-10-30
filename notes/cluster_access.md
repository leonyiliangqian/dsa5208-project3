# Cluster access, transfer and discovery

For the group member doing the cluster login. Replace `NUSNETID` with your
NUSNET ID. Vanda (PBS) is the working cluster; its runbook is at the end.
Sections 1–4 were written before access and use Atlas host names; on Vanda use
`vanda.nus.edu.sg` or the OnDemand portal instead.

## 1. Account and login (per course handout `comp_res.pdf`)

- Account: NUS IT HPC registration form, https://nusit.nus.edu.sg/hpc/get-an-hpc-account/
  (course sponsor Anthony Chen, cygnari@nus.edu.sg). Approval is required first.
- Off campus, connect to NUS VPN before any of the steps below.
- First login: `ssh NUSNETID@atlas8.nus.edu.sg`. SSH will show the server's key
  fingerprint and ask to continue. Compare it with the fingerprint published by
  NUS IT before typing `yes`. Never bypass the check (no
  `StrictHostKeyChecking=no`). Passwords and OTPs are typed by you only and never
  stored in the repository.

## 2. Copy the project (from the Mac)

Use a git bundle, so the cluster copy has the exact checkpoint commit and run
records carry its revision:

```sh
cd ~/Desktop/DSA5208/dsa5208-project3
git status --short                       # commit first if anything is listed
git bundle create /tmp/dsa5208-p3.bundle --all
scp /tmp/dsa5208-p3.bundle NUSNETID@atlas8.nus.edu.sg:~/
```

On the cluster:

```sh
git clone ~/dsa5208-p3.bundle ~/dsa5208-p3 && cd ~/dsa5208-p3
git log --oneline -1                     # must match the Mac's commit
```

To send later commits: re-create the bundle, copy it, then on the cluster
`git pull ~/dsa5208-p3.bundle <branch>`.

## 3. Run discovery (login node, read-only)

```sh
cd ~/dsa5208-p3
bash code/scripts/cluster_discover.sh > discover_$(hostname -s)_$(date +%Y%m%d).txt 2>&1
tail -1 discover_*.txt                   # should print "discovery complete"
```

The script runs only inventory commands (CPU, memory, modules, compilers, MPI,
scheduler and queue listings, storage). It submits no jobs, changes no files
except its output, and reads no credentials. It takes under a minute.

## 4. Bring the output back (from the Mac)

```sh
mkdir -p code/artifacts/cluster/discovery
scp 'NUSNETID@atlas8.nus.edu.sg:~/dsa5208-p3/discover_*.txt' code/artifacts/cluster/discovery/
```

Read it once before sharing: it lists your username, groups and home path.
Then hand it to Claude; scheduler-specific job scripts, the cluster correctness
gates and pilot runs are written from it.

## Until job scripts exist

- Do not run simulations or `make check-hybrid` on the login node; correctness
  and benchmark runs go through the scheduler on compute nodes.
- Building on the login node is normally allowed, but wait for the module
  choice from discovery; the default `-march=native` flag must match the compute
  nodes, not the login node.

## Vanda runbook: first correctness job (scheduling stops 29 Oct 18:00 SGT)

Site facts from `notes/vanda_discovery_2026-10-28.md`: PBS; default `select=1`
is one socket (36 cores, 250 GB); omitting `-P` charges personal credits;
`auto_free` routes to `cpu_serial`/`cpu_parallel`/`gpu` with charge rate 0;
compile on compute nodes (login and compute architectures differ).

1. **Get the code onto Vanda.** On the Mac, from the repository root:
   `git bundle create /tmp/dsa5208-p3.bundle --all`. Upload the bundle with the
   OnDemand Files app (https://vanda.nus.edu.sg, Files → Home → Upload) or with
   `scp /tmp/dsa5208-p3.bundle NUSNETID@vanda.nus.edu.sg:~/`. Then in the Vanda
   shell: `git clone ~/dsa5208-p3.bundle ~/dsa5208-p3 && cd ~/dsa5208-p3 && git log --oneline -1`.
   The commit must match the Mac's `git log --oneline -1`.
2. **Allocation.** Run `amgr login` yourself (NUS password), then continue.
3. **Preflight (read-only).** `cd ~/dsa5208-p3/code && bash jobs/vanda/preflight.sh`.
   It prints queue limits for `auto_free`, `cpu_serial` and `cpu_parallel`, the
   OpenMPI/Python modules and `hpc project`, and saves the output under
   `artifacts/cluster/discovery/`. Check: the job asks for 8 cores, 16 GB and
   30 minutes on one node; is that within the queue's limits, and which project
   ID should pay (or is `auto_free` without `-P` free for you)?
4. **Dry run.** `bash jobs/vanda/submit.sh correctness --queue auto_free --project <ID>`
   prints the exact `qsub` command and submits nothing.
5. **Submit.** Repeat with `--yes`. Note the job ID; `qstat -u $USER` shows its state.
6. **Results.** The job writes `artifacts/cluster/runs/correctness-<UTC>-<jobid>/`
   (`job.log`, `gates.txt`, one log per gate, environment record, validation
   JSON) and a PBS log in `artifacts/cluster/logs/`. `gates.txt` must list every
   critical and required gate as PASS (optional gates are listed in the
   `verdict` line but do not decide it). Each line reads
   `NAME PASS|FAIL|TIMEOUT|SKIP rc=.. secs=.. kind=critical|required|optional`;
   every gate has a time limit (jobs/vanda/gates.sh), a timed-out gate leaves
   `gate_NAME.snapshot` (process states on every node) and `cleanup.log` shows
   the leftover-process check after each gate. Exit 5 = a critical gate did not
   pass; exit 6 = cleanup could not be verified, including an MPI process of
   unknown ownership on a node, which is reported but never killed. Bring the directory back with
   `tar czf ~/correctness.tgz artifacts/cluster` and download it via OnDemand or
   `scp NUSNETID@vanda.nus.edu.sg:~/correctness.tgz .`,
   then unpack it into `code/` on the Mac.

If the module names differ, override without editing the script, e.g.
`bash jobs/vanda/submit.sh correctness --queue auto_free --project <ID> --var PY_MODULE=<python module> --yes`.
