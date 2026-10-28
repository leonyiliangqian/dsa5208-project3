# Vanda access discovery — 28 October 2026

Observed through the user's authenticated Vanda browser shell. No compute job was submitted, no compiler was run on the login node, and no allocation was consumed by this inspection.

- Portal shell: `https://vanda.nus.edu.sg/pun/sys/shell/ssh/default`.
- `hostname`: `stdct-login-01` (shell prompt labels the system `vanda`).
- Scheduler: PBS.
- `PAGER=cat hpc interactive | cat` completed without an interactive pager.
- Site CPU-session example: `qsub -I -l select=1 -l walltime=02:00:00 -P <projectid>`.
- Site describes the default `select=1` as one socket, 36 cores and 250 GB memory; maximum interactive walltime is 12 hours. Verify the actual allocated compute-node topology before benchmarking.
- Site explicitly says omitting `-P` defaults to personal credits. Do not omit allocation settings inadvertently.
- `hpc project` requires a separate `amgr login` with the user's NUS password. Allocation/project membership has not yet been inspected.
- Available module listing includes `OpenMPI/4.1.6-GCC-13.2.0`, `OpenMPI/5.0.3-GCC-13.3.0`, `OpenMPI/5.0.7-GCC-14.2.0`, and `OpenMPI/5.0.8-GCC-14.3.0`, plus `foss/2023b`, `foss/2024a`, and later toolchains. These have not yet been loaded or tested; confirm dependencies and versions on a compute node.
- `qstat -Qf auto_free`: queue type `Route`, `resources_default.queue_charge_rate = 0`, destinations `cpu_serial,cpu_parallel,gpu`, `enabled = True`, `started = True`. Execution-queue resource limits and eligibility remain to be checked; this does not establish immediate capacity or permission for a specific request.

The site login notice supplied by the user announces scheduling stopping on 29 October at 18:00, cluster access stopping/running jobs terminating on 31 October at 06:00, and planned reopening on 2 November at 17:00 (Singapore time).

## Next gate

1. User completes `amgr login` privately.
2. Inspect `hpc project` and CPU execution-queue limits.
3. Select the allocation and a small, bounded CPU request.
4. Transfer the project, allocate a compute node, discover/load its compatible compiler and MPI modules, and rerun correctness gates before timing experiments.

Compile on a compute node: the login notice explicitly warns that login and compute architectures differ. This note is access/setup evidence, not Atlas/Vanda runtime evidence.
