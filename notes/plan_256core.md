# Plan to 256 cores: requests for approval

Written 4 November 2026, resized 5 November from pilot `1523275`. **Nothing here is approved or submitted beyond the jobs marked, and every size and
time is provisional.** Current status is in `../HANDOFF.md`; simulated and local checks are in `experiments.md`.

## Decision needed

Lecture 12 gives 10 points to MPI scaling to at least 256 CPU cores. The free queue stops at 160 CPUs per job, so 256 cores
needs one of these:

| Route | What it takes | Effect |
|---|---|---|
| Charged `batch_cpu` | Leon's `amgr login`, then approval of each job below | Up to 896 core-hours requested in total |
| Stop at 128 cores on the free queue | `bench1` and `bench2` | Does not meet "at least 256"; the report must say so |

Leave time for queue waits, because the free pilot has already
waited 10 h 1 min and the wait on `batch_cpu` has never been tested. Due 13 Nov 23:59 SGT.

## Order of jobs

Each job needs its own approval. A failure stops the sequence until it is fixed locally and approved again.

| Step | Job | Request | Queue, rate | Core-hours requested | Expected use | Needs first |
|---|---|---|---|---|---|---|
| 0 | `pilot` `1519637` | 1 x 64 cores, 120 GB, 60 min | `cpu_parallel`, 0 | 64 | | **Failed at `placement`, 0 of 20 runs** |
| 0b | `pilot` rerun, commit `3f77e87` | 1 x 64 cores, 120 GB, 60 min | `auto_free`, 0 | 64 | 9 min, measured | **Passed as `1522998`**, whole node IN-016. Sizing only: see "64-core pilot results" |
| 0c | `pilot16` `1523275` | 1 x 16 cores, 16 GB, 60 min | `auto_free`, 0 | 16 | 15 min, measured | **Passed.** Provisional sizing only: see "Pilot16 results" |
| 0d | `bench16`, formal studies on 16 cores | 1 x 16 cores, 16 GB, 4 h | `auto_free`, 0 | 64 | 95 min, 25 core-hours | **Passed as `1523703`**, 121 of 121 runs: formal 16-core data. Does not supply 256 cores |
| A | `pilot2`, free rehearsal | 2 x 64 cores, 120 GB each, 30 min | `auto_free`, 0 | 64 | 9 min, 20 core-hours | **Ready to request.** Needs two whole free nodes; 128 + 64 cores with `bench1` is over the 160 limit, so one waits |
| B | `pilot4`, 256-core correctness and sizing | 4 x 64 cores, 240 GB each, 45 min | `auto`, 1 | **192** | 12 min, 52 core-hours | Step A passed, project, balance and charge approval |
| C | `bench4`, formal strong and weak | 4 x 64 cores, 240 GB each, 2 h 50 min | `auto`, 1 | **725** | 56 min, 240 core-hours | Step B passed, manifest resized and frozen, charge approval |
| D | `bench1`, serial against N, schedule, leaf, theta, and single-node strong and weak | 1 x 64 cores, 120 GB, 5 h | `auto_free`, 0 | 320 | 100 min, 106 core-hours | **Plan frozen, ready to request.** | Step 0, manifest resized and frozen |

"Expected use" comes from `scripts/plan_budget.py`, refit to pilot `1523275`. It matches that pilot closely, but 64 and 256 ranks and N above 2 x 10^6 are
extrapolated, so it could still be off by a factor of two or more there.

Step A can be skipped to save queue time. It costs nothing, and it is the only way to find a launch fault at 64 ranks per
node before paying for one. `bench2` is needed only if the 256-core route fails.

`bench1` has 148 runs. Its 5 h covers the worst case, 16020 s, if every run uses its whole limit. A long request may wait
longer in the queue. If `bench4` is approved, `bench1` can drop its strong and weak runs after the serial baseline, and if `bench16` passes it can drop its serial and parameter runs.

## 64-core pilot results: sizing, one whole node

Job `1522998` passed all gates on IN-016 with all 64 cores of both sockets: 20 of 20 runs. **One repetition. Sizing only, not a result. Nothing here is shown across
nodes or at 256 cores.** The rules were set before any result existed.

| Rule | Reading at 64 cores | Outcome |
|---|---|---|
| 1, 2 | All gates passed; nothing timed out or skipped | Sizing may proceed |
| 3, CPU model | Gold 6438N | Later baselines stay within their own job |
| 4, serial time per step | 19.4 s at 10^6; 46.3 s at 2 x 10^6 | Under 20 s, but 2 x 10^6 is over its 40 s condition, so **keep N_s = 10^6**. 3 steps is 58 s, just under the 60-120 s target |
| 5, `hybrid 1x1` | 1.3% slower than serial | Fine |
| 6, 64 x 1 efficiency | 0.34 | Above 0.25: keep N_s |
| 7, peak RSS per rank, 64 x 1 | 161.2 MiB | Under 240 MiB: **keep 50,000 per core** |
| 8, exchange share, 64 x 1 | 9.2% | Under 50% |
| 9, schedules at 1 x 64 | guided 7.3% and static 4.8% faster than dynamic 64 | Under 10%: **keep dynamic, chunk 64**. `bench16` gave the lowest median to dynamic 64 |
| 10, leaf at 3 x 10^5 | 16 was 0.8% faster than 8; 4 and 32 slower | **Keep 8** |
| 11, theta | 0.3 took 3.75 times the traverse of 0.5; 0.5's accuracy run exited 0 | **Keep 0.5** |
| 12, constants | Kernel core-time against serial: 2.08 at 64 x 1, 1.71 at 8 x 8, 1.59 at 1 x 64. Exchange 0.076 s per step at 8 x 8 | Thread cost added, exchange floor added; every plan rerun |

Previously "still needs 64 cores": launch at 64 ranks on a node through `pbs_tmrsh` (done, 64 x 1 ran), 64 x 1 efficiency, RSS and exchange (above), 1 x 64 across both
sockets (done), a whole node (done). **Still not shown:** more than one node at 64 ranks each, the charged pool, and the network exchange.

**Budgets after rule 12**, at commit `367c630`. The 2.5x margin stays only for what is extrapolated: more than one node, or N above 2 x 10^6.

| Plan | Runs | Worst case and budget, s | Core-hours requested | Status |
|---|---|---|---|---|
| `pilot2` | 6 | 730 of 1040 | 64 | Proposed (a pilot may run a proposed plan) |
| `bench1` | 148 | 16140 of 17358 | 320 | **Frozen** |
| `pilot4` | 9 | 1255 of 1704 | 192 | Proposed |
| `bench4` | 90 | 8940 of 9204 | **725**, from 704 | Proposed. 5 more minutes keep every point; dropping strong 2 x 1 instead would keep 704 |

**`bench4` must also check its own allocation (Leon, 6 Nov):** it lacks `SCALE_CHECKS`, so it would not probe 64 ranks per node, the exchange or bound correctness on its own 256 cores. These gates are mandatory before a formal run, not optional to save cost. Add them and include their time in the budget when `bench4` is frozen after `pilot4`.

The kernel constant stays at 31 core-microseconds: whole-node runs took 19.3 and the shared node 31 to 44. Every measured run of `1522998` and `1523703` took 0.34 to 1.83 times its estimate.

## Pilot16 results: provisional sizing, 16 cores only

Job `1523275` passed all gates, with 20 of 20 runs (details in `experiments.md`). **One repetition, on a possibly shared node. Not a scaling result. None of this
is proven at 64 or 256 cores.** The rules below were set before any result existed.

| Rule | Reading | Provisional outcome |
|---|---|---|
| 1, gates | All 5 passed | Sizing may proceed |
| 2, timeouts | None; none skipped | No lower bounds needed |
| 3, CPU model | Gold 6438N, IN-002 | Later baselines stay within their own job and model |
| 4, serial time per step | 31.4 s at 10^6; 78.4 s at 2 x 10^6 | **Keep N_s = 10^6**. 3 steps is 94 s, inside the 60-120 s target |
| 5, `hybrid 1x1` | 4.2% faster than serial | Under the 20% limit, nothing to investigate |
| 6, 16 x 1 efficiency | 0.58 | Warning not raised. Says nothing about 64 x 1 |
| 7, peak RSS per rank | 156.2 MiB at 16 x 1 | **Keep 50,000 per core** as an estimate. MPI memory may grow with ranks |
| 8, exchange share | 1.3% at 16 x 1 | Under 50%. A lower bound, since volume per node grows with ranks |
| 9, schedules at 1 x 16 | static 2.3% and guided 1.8% slower than dynamic | **Keep dynamic, chunk 64** |
| 10, leaf size at 3 x 10^5 | 4, 16, 32 took 27.6%, 17.0%, 37.4% longer than 8 | **Keep 8.** The runs were minutes apart and conditions moved, so `bench16` repeats this |
| 11, theta | 0.3 / 0.7 / 0.9 traverse 3.75 / 0.41 / 0.22 times theta 0.5's; 0.5's accuracy run exited 0 | **Keep 0.5**. Estimate now theta^-2.6 |
| 12, constants | Replaced in `plan_budget.py`, plus one more force evaluation per run | Every plan rerun, below |

**Budgets after rule 12.** Rule 12 says raise walltime on free queues, and on `bench4` lower N_s or drop the ranks x threads points. Rule 4 keeps N_s, so:

| Plan | Change | Runs | Worst case and budget, s | Core-hours requested |
|---|---|---|---|---|
| `pilot2` | None | 6 | 1020 of 1040 | 64 |
| `pilot4` | Serial limit 240 to 260 s and others resized | 9 | 1225 of 1704 | 192, unchanged |
| `bench4` | Limits raised. **Dropped ranks x threads at 256 (12 runs) and strong hybrid 1 x 1 (3 runs)** so as not to raise the charge | 90 | 8700 of 8904 | 704, unchanged |
| `bench1` | Limits raised, walltime 4 h to 5 h | 148 | 16020 of 17358 | 320 |
| `bench16` | New, frozen | 121 | 12285 of 13158, with 900 s of gates | 64 |

Dropping the hybrid 1 x 1 point means `bench4`'s strong curves start from the serial baseline, and ranks x threads would rest on `bench16` and `bench1`. The group can restore them with a longer request: 3 h 15 min would hold all 105 runs (worst case 10245 s), at 832 core-hours.

**Not answered, and still needs 64 cores:** launch at 64 ranks on a node (16 is now the most shown on one node, with `pbs_tmrsh`); 64 x 1 efficiency, RSS and exchange;
1 x 64 across both sockets (all of this job was on one socket); a whole node. `1522998` or `pilot2` must supply these before any plan is frozen for a charged job.

## Smaller pilot: `pilot16`, why and how, written before it ran

**Why:** `1522998` waits for a whole 64-core node. A snapshot at 14:20 SGT on 5 Nov had no free-pool node with 64 or even 32 cores
free, and 6 with at least 16 (5 Gold 6438N, 1 Platinum 8452Y). That counts cores only, not memory, and it is one moment, so it does
not promise a start. It is why this pilot uses 16 cores rather than 32. At 14:31, one node had 32 free and still 6 had 16.

**Request:** 1 x 16 cores, 16 GB, 60 min, 16 core-hours at most, rate 0. Same 20 runs, sizes and order as the 64-core pilot, with
1 x 16, 4 x 4 and 16 x 1 in place of 1 x 64, 8 x 8 and 64 x 1.

**Memory:** at most 3 GB estimated (16 ranks at 1.3 x (17 + 136.4) MiB, from a local Docker probe), so 16 GB leaves a factor of
about 5. **Runtime:** estimated 21 min including 5 min of gates. Limits are shorter than the 64-core pilot's, and the worst case of
2900 s fits the 2958 s budget, so all 20 runs can start. These are estimates, not measurements, and a slower shared node could time
out. The serial 10^6 limit of 300 s is still 100 s per step, enough to tell the bands of rule 4 apart.

| Rule | What 16 cores gives |
|---|---|
| 1, 3 | Gates and CPU model of this job. The model may not match later jobs |
| 4 | Serial time at 10^6 and 2 x 10^6: **answered**, though a shared node may read slow |
| 5 | `hybrid 1x1` against serial: **answered** |
| 6 | Efficiency at 16 x 1 only. Under 0.25 is a warning; a good value says nothing about 64 |
| 7 | RSS per rank at 16 x 1: **estimate only**, since per-rank MPI memory can grow with ranks |
| 8 | Exchange share at 16 x 1: **lower bound**, since exchange volume per node grows with ranks |
| 9 | Schedules at 1 x 16: **provisional** |
| 10 | Leaf size, serial at 3 x 10^5: **answered** |
| 11 | Theta and accuracy at 4 x 4: **answered** for cost; the theta estimate can be replaced |
| 12 | Constants in `plan_budget.py`: **provisional** |

**Still needs 64 cores:** launch through `pbs_tmrsh` at 64 ranks on a node (8 per node is the most shown); 64 x 1 efficiency, RSS and
exchange share; 1 x 64 across both sockets; a whole node with no other job on it. `pilot2` or `1522998` must supply these before any
manifest is frozen for a charged job. Results from this job size later jobs but are not reported as scaling results.

**Finding on the 64-core pilot:** `plan_budget.py` refuses `pilot_single_node_v2.json`, since its worst case of 6480 s is over the
2958 s budget. That is why its sizing runs come first. If runs are slow, `1522998` may skip its last runs (leaf, serial 2 x 10^6,
`hybrid 1x1`), and rule 2 then applies. It has not been changed.

## Charge assumptions

- **Assumed: 1 credit per core-hour at rate 1.** The site's conversion is **not confirmed**. Only the queue's
  `queue_charge_rate = 1` is known.
- **Upper bound: charged on the request.** PBS records `job.walltime` and `job.ncpus` for the allocation manager
  (`am_job_cache`), which suggests a request-based hold or charge. Whether unused time comes back is unknown.
- Under these assumptions B + C is 896 credits at most, or 9% of the last balance read, 10000.0 on 29 Oct. That reading
  predates every later job. **Leon must read the current balance with `amgr login`.**
- **Balance not available:** on 4 Nov at 23:20 SGT, `hpc project` still asked for `amgr login`, and `amgr balance` failed
  with an error before showing anything. The existing SSH login does not cover it.
- A job that fails early may still be charged. Compare the balance before and after step B before approving step C.
- Omitting `-P` charges personal credits. `submit.sh` refuses a run with no project unless `--no-project` is passed.

## After the pilot: decisions

These rules were set **before any pilot result existed**, so results cannot shape them. The pilot has one repetition per case,
so it sets sizes and limits only. Times come from `summary.csv` in the run directory; `wall_s` covers 2 timed steps.

| # | Read from the pilot | Rule | Then |
|---|---|---|---|
| 1 | Exit status and gates | Critical gate failed | Stop. Diagnose, fix locally, ask for a new approval. No sizing from this job |
| 2 | Timed-out or skipped runs | Any at 64 cores or serial 10^6 | Use the limit as a lower bound on time, and resize from the next lower size that finished |
| 3 | CPU model | Record it | Later baselines must match within their own job. Do not compare times across models |
| 4 | Serial time per step at 10^6 (t) | t < 20 s: N_s = 2 x 10^6, if serial 2 x 10^6 is at most 40 s per step | Target is 60–120 s of serial time for 3 steps |
| | | 20 to 40 s: keep 10^6 | |
| | | 40 to 80 s: N_s = 5 x 10^5 | |
| | | Over 80 s: N_s = 3 x 10^5 | |
| 5 | `hybrid 1x1` against serial, same N | More than 20% slower | Find out why before freezing; the MPI overhead should be small at one rank |
| 6 | 64 x 1 efficiency against serial | Under 0.25 | N_s is too small for the curve: raise it if rule 4 allows, otherwise keep it and explain in the report |
| 7 | Peak RSS per rank, 64 x 1 at 10^6 | At most 240 MiB: keep 50,000 particles per core | 240 MiB is where 12.8 x 10^6 at 64 ranks reaches 80% of 240 GB |
| | | Over 240 MiB: use 25,000 per core | Same rule on 120 GB nodes at 128 cores |
| 8 | Share of `exchange_s` in wall, 64 x 1 | 50% or more | Raise N_s if rule 4 allows. Otherwise keep it: this is a finding about communication, not a fault |
| 9 | static and guided against dynamic, chunk 64 | Keep dynamic, chunk 64, unless another is over 10% faster | One repetition cannot settle it. Study 3 still reports all schedules |
| 10 | Leaf size 4, 16, 32 against 8 at 3 x 10^5 | Keep 8 unless another is over 10% faster | Study 5 still reports all sizes |
| 11 | theta 0.3, 0.7, 0.9 run time; accuracy runs | Replace the theta estimate in `plan_budget.py` | Keep theta = 0.5 if its accuracy run exits 0 |
| 12 | Kernel, build and exchange times | Replace the constants in `plan_budget.py`, rerun it on every plan | If refused on free queues, raise walltime. If refused on `bench4`, lower N_s or drop the MPI+OpenMP ranks x threads points. Keep 3 repetitions |

Then freeze each manifest, commit, make a new clean clone, rerun its dry run, and ask for approval.

| Leon's charge decision | Next |
|---|---|
| Charge approved | Leon reads the balance and approves B, then C after comparing the balance |
| Charge declined | Skip B and C. Run `bench1` and `bench2` and state the shortfall against 256 cores in the report |
| Not decided yet | Steps A and D are free, so they can go ahead with approval |

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
| Strong, MPI only | serial, then P = 2, 4, ... 256 ranks | 9 x 3 |
| Strong, MPI+OpenMP | 8 threads per rank, P = 8 to 256 | 6 x 3 |
| Weak, MPI only | P = 1 to 256 | 9 x 3 |
| Weak, MPI+OpenMP | 8 threads per rank, P = 8 to 256 | 6 x 3 |
| Ranks x threads | Dropped from `bench4` by rule 12; in `bench16` and `bench1` at 16 and 64 cores | |

Memory: about 136 MiB per rank per million particles, in line with pilot `1523275`, plus 30%. That gives **about 143 GB of the 240 GB
requested per node** at 64 ranks x 12.8 x 10^6, the largest case. Above 16 ranks it has not been measured on Vanda, and step B measures it.

Replace all of this from steps 0b and B before freezing. If 12.8 x 10^6 does not fit or takes too long, step B's 6.4 x 10^6
case gives the fallback of 25,000 per core, and step A would show the problem at 128 cores first.

## Dry runs

**Done for `0ae5573`, 4 Nov at 23:21 SGT:** clean clone `~/dsa5208-p3-0ae5573`, commit and tree verified, `pilot2`, `pilot4` and
`bench4` printed their `qsub` lines, and all three budgets passed on Vanda. Pilot `1519637` was the only job before and after.
Record: `code/artifacts/cluster/discovery/vanda_dryrun_0ae5573_*.txt`. That commit predates the resized `bench1`, and any frozen
manifest needs its own clone and dry run.

These print the `qsub` line and submit nothing. Run from a clean clone of the commit to be used, so the revision is right:

```sh
cd ~/dsa5208-p3-<rev>/code
bash jobs/vanda/submit.sh pilot2 --queue auto_free --no-project
bash jobs/vanda/submit.sh pilot4 --queue auto --project <PROJECT_ID>
bash jobs/vanda/submit.sh bench4 --queue auto --project <PROJECT_ID>
bash jobs/vanda/submit.sh bench1 --queue auto_free --no-project
```

Add `--yes` only after that job's approval. `bench4` also refuses to start until its manifest status begins with `frozen`.

Check any plan, on any machine, without touching the cluster:

```sh
cd code
python3 scripts/plan_budget.py manifests/pilot_two_node.json jobs/vanda/pilot2.pbs --runs
python3 scripts/plan_budget.py manifests/pilot_four_node.json jobs/vanda/pilot4.pbs --rate 1 --runs
python3 scripts/plan_budget.py manifests/studies_four_node.json jobs/vanda/bench4.pbs --rate 1 --runs
python3 scripts/plan_budget.py manifests/studies_single_node.json jobs/vanda/bench1.pbs --runs
python3 scripts/plan_budget.py manifests/studies_16core.json jobs/vanda/bench16.pbs --startup-s 900 --runs
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
