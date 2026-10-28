# Cluster access, transfer and discovery

For the group member doing the cluster login. Nothing here submits a job.
Replace `NUSNETID` with your NUSNET ID; the commands use Atlas, swap in
`vanda.nus.edu.sg` if that is the cluster you have.

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
