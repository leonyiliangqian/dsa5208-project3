# Plan to 256 cores: requests for approval

Written 4 November 2026. **Nothing here is approved or submitted, and every size and time is provisional.** No job here
has run on Vanda. Simulated and local checks are in `notes/experiments.md`.

## Decision needed

Lecture 12 gives 10 points to MPI scaling to at least 256 CPU cores. The free queue stops at 160 CPUs per job, so 256 cores
needs one of these:

| Route | What it takes | Effect |
|---|---|---|
| Lecturer's course project or free exception | Send [lecturer_questions_draft.md](lecturer_questions_draft.md) | No charge to Leon, if granted |
| Charged `batch_cpu` | Leon's `amgr login`, then approval of each job below | Up to 896 core-hours requested in total |
| Stop at 128 cores on the free queue | `bench1` and `bench2` | Does not meet "at least 256"; the report must say so |

Ask the lecturer first: an answer could remove the charge. Leave time for queue waits, because the free pilot has already
waited over 3.5 hours and the wait on `batch_cpu` has never been tested. Due 13 Nov 23:59 SGT.

## Order of jobs

Each job needs its own approval. A failure stops the sequence until it is fixed locally and approved again.

| Step | Job | Request | Queue, rate | Core-hours requested | Expected use | Needs first |
|---|---|---|---|---|---|---|
| 0 | `pilot` `1519637` | 1 x 64 cores, 120 GB, 60 min | `cpu_parallel`, 0 | 64 | | Already queued |
| A | `pilot2`, free rehearsal | 2 x 64 cores, 120 GB each, 30 min | `auto_free`, 0 | 64 | 8 min, 17 core-hours | Step 0 finished; 64 + 128 cores exceeds the 160 limit |
| B | `pilot4`, 256-core correctness and sizing | 4 x 64 cores, 240 GB each, 45 min | `auto`, 1 | **192** | 10 min, 42 core-hours | Step A passed, project and charge or exception |
| C | `bench4`, formal strong and weak | 4 x 64 cores, 240 GB each, 2 h 45 min | `auto`, 1 | **704** | 47 min, 199 core-hours | Step B passed, manifest resized and frozen, charge or exception |
| D | `bench1`, serial against N, schedule, leaf, theta | 1 x 64 cores, walltime not set | `auto_free`, 0 | Not sized | About 130 min estimated | Step 0, manifest trimmed and frozen |

"Expected use" comes from `scripts/plan_budget.py` and is rough. The same estimate could be off by a factor of two or more:
one local Docker run was about 2.5 times slower per particle, though on a different machine.

Step A can be skipped to save queue time. It costs nothing, and it is the only way to find a launch fault at 64 ranks per
node before paying for one. `bench2` is needed only if the 256-core route fails.

## Charge assumptions

- **Assumed: 1 credit per core-hour at rate 1.** The site's conversion is **not confirmed**. Only the queue's
  `queue_charge_rate = 1` is known.
- **Upper bound: charged on the request.** PBS records `job.walltime` and `job.ncpus` for the allocation manager
  (`am_job_cache`), which suggests a request-based hold or charge. Whether unused time comes back is unknown.
- Under these assumptions B + C is 896 credits at most, or 9% of the last balance read, 10000.0 on 29 Oct. That reading
  predates every later job. **Leon must read the current balance with `amgr login`.**
- A job that fails early may still be charged. Compare the balance before and after step B before approving step C.
- Omitting `-P` charges personal credits. `submit.sh` refuses a run with no project unless `--no-project` is passed.

## What each requirement rests on

| Requirement | How it is checked | Where |
|---|---|---|
| CPU family | Every job stops before compiling unless all nodes report one CPU model, because PBS cannot request a model. The free pool mixes Gold 6438N and Platinum 8452Y. The model of `cpu_node` is unknown | `allocation` gate, critical |
| Exact resources | 4 hosts, exactly 64 allowed CPUs each, launch through `pbs_tmrsh` under PBS | `allocation` gate, critical |
| Binding | Probe at 8 x 8 and 64 x 1 per node, one thread per core inside the cpuset | `placement`, `place_mpi`, critical |
| Bound correctness | New: bound runs on every core against serial: P x 1, P/8 x 8, P/4 x 4, one-step and theta = 0 forces, ranks owning nothing. Job 1514458 compared only unbound runs on 16 cores | `bound_vs_serial`, critical |
| MPI exchange | Point-to-point and Allgatherv across all ranks | `internode`, critical |
| Serial baseline | `bh_serial` in the same job, build and CPU model. `analyze.py` only computes speedup against a matching baseline | `strong` study |
| Communication | `exchange_s` times each `MPI_Allgatherv`; the report plots its share against P | `fig_phases`, `fig_comm_fraction` |
| Repeats | Formal: 3 interleaved repetitions, median with min and max. Pilots: 1, so they only size the formal job | Manifests |
| Memory | Peak RSS per rank and summed, in each record. Checked before approval against `mem` per node | `plan_budget.py` |
| Time limits | Each run has a limit of at least twice its estimate, and the worst case must fit the walltime, or the plan is refused | `plan_budget.py` |

Critical gates stop the job, so a correctness failure does not keep spending on 256 cores.

## Provisional sizes

Strong: N = 10^6, on 1 to 256 cores. Weak: 50,000 particles per core, so N = 12.8 x 10^6 at 256 cores. Both use theta = 0.5,
leaf size 8, dynamic schedule with chunk 64, and 3 timed steps after 1 warmup step.

| Series | Points | Runs |
|---|---|---|
| Strong, MPI only | serial, 1 x 1, then P = 2, 4, ... 256 ranks | 10 x 3 |
| Strong, MPI+OpenMP | 8 threads per rank, P = 8 to 256 | 6 x 3 |
| Weak, MPI only | P = 1 to 256 | 9 x 3 |
| Weak, MPI+OpenMP | 8 threads per rank, P = 8 to 256 | 6 x 3 |
| Ranks x threads at 256 | 64 x 4, 16 x 16, 8 x 32, 4 x 64 | 4 x 3 |

Memory: about 136 MiB per rank per million particles, measured locally, plus 30%. That gives **about 143 GB of the 240 GB
requested per node** at 64 ranks x 12.8 x 10^6, the largest case. It has not been measured on Vanda, and step B measures it.

Replace all of this from steps 0 and B before freezing. If 12.8 x 10^6 does not fit or takes too long, step B's 6.4 x 10^6
case gives the fallback of 25,000 per core, and step A would show the problem at 128 cores first.

## Dry runs

These print the `qsub` line and submit nothing. Run from a clean clone of the commit to be used, so the revision is right:

```sh
cd ~/dsa5208-p3-<rev>/code
bash jobs/vanda/submit.sh pilot2 --queue auto_free --no-project
bash jobs/vanda/submit.sh pilot4 --queue auto --project <PROJECT_ID>
bash jobs/vanda/submit.sh bench4 --queue auto --project <PROJECT_ID>
```

Add `--yes` only after that job's approval. `bench4` also refuses to start until its manifest status begins with `frozen`.

Check any plan, on any machine, without touching the cluster:

```sh
cd code
python3 scripts/plan_budget.py manifests/pilot_two_node.json jobs/vanda/pilot2.pbs --runs
python3 scripts/plan_budget.py manifests/pilot_four_node.json jobs/vanda/pilot4.pbs --rate 1 --runs
python3 scripts/plan_budget.py manifests/studies_four_node.json jobs/vanda/bench4.pbs --rate 1 --runs
```

Before each submission, recheck `scheduling = True`, the queue enabled and started, its charge rate, current jobs and
duplicates, and read the balance.

## Known risks

- **Launch above two nodes is untested.** `pbs_tmrsh` has only run on two nodes, and never at 64 ranks per node.
- **Mixed CPU models:** `batch_cpu` could give a mixed set, and the job would stop at its first gate. It may still be charged.
  Nothing can prevent this in the request, and the next attempt needs a new approval.
- **Pool differences:** speedup is only computed within a job. Free-pool results do not carry over to `cpu_node` nodes.
- **Sharing on larger nodes:** 64 of 72 cores leaves 8 free on a 72-core node, where another job could run. Hosts are recorded.
  `place=excl` is not proposed because its charge effect is unknown.
- **Memory enforcement:** whether PBS kills only the process or the whole job at the limit is unknown. Weak sizes run in
  rising memory order in the pilots for this reason.
- **Below 4,000 particles per core:** N = 10^6 at 256 cores will likely be dominated by communication. That is a result to
  explain, not a fault.
