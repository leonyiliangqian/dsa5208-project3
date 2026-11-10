# Approval requests

**No approval is open.** The `pilot4` charge approval (10 Nov, cap 192 CPU-hours) was used: job `1535640`, submitted once on 10 Nov 17:42:15 SGT. Nothing else is approved. The `bench1` rerun (job `1528774`) and the `pilot2` rerun (job `1528798`) were each approved and submitted once on 7 Nov;
both approvals are used up. `pilot2` (`1526470`) and `bench1` (`1526501`) both failed before any timing, and their approvals are used up. Each job needs Leon's own approval. Preparing a clone on Vanda writes to Vanda, so it needs approval too.

## Proposed, 10 November 2026: `bench4` staging, then `bench4`: not approved

Formal strong and weak scaling from 1 to 256 cores in one 4-node job, three repetitions, every point against a serial baseline from the same job and CPU model.
Based on verified `pilot4` `1535640` (sizing only). Two separate approvals; neither is given.

| | |
|---|---|
| Source | `a72ce26e13e315af0686a5ddf1286e36e749eea8`, tree `fb393ec86dff907013c78976e9adafb2c34290ff` (commit `a72ce26`) |
| Manifest | `studies_four_node.json`, `studies-four-node-v1`, **frozen**, SHA-256 `0ddec3b7b31d0d30bfc49c54010c6d25d31954dc0eccece63b7c9a5d615edf6c`; 30 cases x 3 repetitions = 90 runs: strong at N = 10^6 (serial; 2 to 256 ranks x 1 thread; 1 to 32 ranks x 8 threads), weak at 50,000 particles per core to N = 12.8 x 10^6 (same layouts) |
| Request | `select=4:ncpus=64:mpiprocs=64:mem=240gb`, `place=scatter`, `walltime=03:00:00`; queue `auto` to `batch_cpu`, rate 1, `-P personal-leonyil.qian`. PBS rewrote `pilot4`'s memory to 444 GB per chunk; the charge basis was CPUs x walltime |
| Gates | As `pilot4`, all critical: same CPU model on 4 hosts, placement 8 x 8 and 64 x 1 per node, bound exchange on 256 ranks, serial, bound comparison with serial on 256 cores; then runs and analysis; cleanup checked on every node after each |
| Runtime | Expected about 40-60 min including gates: 35 min of runs from measured times (51 min by the model) plus 6-10 min of gates. Worst case, every run at its limit: 9390 s of runs plus up to 600 s of gates, within 3 h |
| Memory | Largest case 12.8 x 10^6 at 64 ranks per node: 1.78 GiB per rank measured, about 114 GiB per node, of 240 GB requested |
| Charge | **Expected debit 768 CPU-hours** = 256 cores x 3 h x rate 1, whatever the run time: `pilot4` was debited its full request (10,000.0 to 9,808.0, Leon, 10 Nov) after using 10.5 of 45 min. Leaves about 9,040 if the rate and balance stay the same |
| Not verified | Queue wait; which nodes `batch_cpu` gives (`pilot4` got four GN-A40 hosts, Platinum 8452Y); the 8 x 8 schedule choice (kept at dynamic 64, see `plan_256core.md`, 10 Nov) |

### Step 1: stage a clean clone of `a72ce26` and dry-run it (no job, no charge): done 10 Nov, approval used

**Approved by Leon for staging only and done on 10 Nov 18:28-18:29 SGT.** Bundle transferred once (SHA-256 `6e88a940...`, 1,614,928 bytes, local = remote),
cloned to `~/dsa5208-p3-a72ce26-bench4`: commit, tree `fb393ec`, frozen manifest hash and resources verified; no modified, untracked or ignored files before or
after. Budget passes with 400 or 600 s of gates. Dry run printed
`qsub -q auto -P personal-leonyil.qian -v SOURCE_GIT_REV=a72ce26e13e315af0686a5ddf1286e36e749eea8 -o /home/svu/leonyil.qian/dsa5208-p3-a72ce26-bench4/code/artifacts/cluster/logs/ jobs/vanda/bench4.pbs`
and submitted nothing: no `p3_bench4` in current jobs or history before or after. `auto` and `batch_cpu` enabled and started at rate 1, scheduling on.
Left for step 2: Leon's fresh available-balance reading and his charge approval (expected debit 768). Record:
`code/artifacts/cluster/discovery/vanda_bench4_staging_dryrun_a72ce26_20261110T1829.txt`. As proposed:


Same actions as `pilot4`'s step 1 (8 Nov), with `a72ce26`, bundle `dsa5208-p3-a72ce26.bundle`, clone `~/dsa5208-p3-a72ce26-bench4`, and the dry run
`bash jobs/vanda/submit.sh bench4 --queue auto --project personal-leonyil.qian` without `--yes`. `bench4` refuses to run unless the manifest status begins
with `frozen`, which it does.

> Leon approves staging only: create ~/dsa5208-p3-a72ce26-bench4 from an exact-source bundle of a72ce26e13e315af0686a5ddf1286e36e749eea8 with bounded existing-auth operations,
> verify commit, tree fb393ec86dff907013c78976e9adafb2c34290ff, a clean clone and studies_four_node.json SHA256 0ddec3b7b31d0d30bfc49c54010c6d25d31954dc0eccece63b7c9a5d615edf6c, and run
> submit.sh bench4 --queue auto --project personal-leonyil.qian WITHOUT --yes. No submission, charge, authentication or permission change.

### Step 2: `bench4` (charged; needs step 1, Leon's fresh available-balance reading, and his charge approval)

> Leon explicitly approves exactly ONE bench4 submission, CHARGED, at most 768 CPU-hours requested from personal-leonyil.qian: source a72ce26e13e315af0686a5ddf1286e36e749eea8,
> tree fb393ec86dff907013c78976e9adafb2c34290ff, clone ~/dsa5208-p3-a72ce26-bench4, manifest studies_four_node.json SHA256 0ddec3b7b31d0d30bfc49c54010c6d25d31954dc0eccece63b7c9a5d615edf6c,
> 4 nodes x 64 cores, 240 GB per node, place=scatter, 3 h, queue auto, -P personal-leonyil.qian, rate 1. Balance read by Leon at <time>: <value>. Before
> submitting, use bounded existing-auth checks to verify commit, tree, clean clone, manifest, resources, account lookups, scheduling on, auto and batch_cpu
> enabled and started at rate 1, and no p3_bench4 in current jobs or history. If anything fails, authentication is needed or the charge could exceed the cap,
> stop and report. Otherwise submit once with submit.sh bench4 --queue auto --project personal-leonyil.qian --yes and record the job ID. No retries,
> cancellations, other jobs, credential or security changes, monitoring loops or final submission.

## Proposed, 8 November 2026: `pilot4` staging, then `pilot4`: not approved

Two separate approvals. Step 1 (staging) was approved and done on 8 Nov; step 2, charged, is not approved. The current plan still needs `pilot2`
(`1528798`, queued) to pass before step 2, unless Leon decides at the proposed Mon 9 Nov 18:00 SGT point to go without it (`plan_256core.md`, 8 Nov).
Checks behind this: `code/artifacts/cluster/discovery/vanda_pilot4_readiness_7f1b5a6_20261108T1256.txt`.

**Verified on 8 Nov (local clean clone of `7f1b5a6` and read-only Vanda queries):**

| | |
|---|---|
| Source | `7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079`, tree `90488b5b3e83fd0078597b80e18ecc713d78a750`. The `pilot4` job path is identical to `a64e0fe`, which `1528774` ran; since then only `bench4.pbs` and a README changed |
| Manifest | `pilot_four_node.json`, `pilot-four-node-v1`, status `proposed` (allowed for a pilot), SHA-256 `0372e6b05b96810a6ef2c9f687b66904e5c414a8143bad87de756377ff8af823`, 9 runs, one repetition each: strong at N = 10^6 (256 x 1, 32 x 8, 128 x 1 on 2 nodes, 64 x 1, serial), weak at 6.4 and 12.8 x 10^6 (256 x 1, 32 x 8) |
| Request | `select=4:ncpus=64:mpiprocs=64:mem=240gb`, `place=scatter`, 45 min |
| Gates | `allocation` (4 hosts, 64 CPUs each, **one CPU model**, `pbs_tmrsh` under `pbs_mom`), `build`, `placement` 8 x 8 per node, `place_mpi` 64 x 1 per node, `internode` 256 bound ranks across 4 hosts, `serial`, `bound_vs_serial` on 256 cores, then `runs`, `analyze`; cleanup checked on every node after each. All critical gates stop the job on failure |
| Budget | Worst case 1255 s; fits with up to 600 s of gates (1404 s budget). Largest node memory 143 of 240 GB. Expected 12-17 min |
| Queue | `auto` (route, rate 1) to `batch_cpu` (rate 1, 720 CPUs, 10 nodes, 240 h, 6 running jobs per user), enabled and started. 447 queued, 149 running at 12:56 |
| Dry run | Local, no `--yes`: `qsub -q auto -P personal-leonyil.qian -v SOURCE_GIT_REV=7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079 -o <clone>/code/artifacts/cluster/logs/ jobs/vanda/pilot4.pbs`; nothing submitted |
| Clones | None reusable: `~/dsa5208-p3-a64e0fe-pilot2` is clean but is the working tree of queued `1528798`; `~/dsa5208-p3-a64e0fe-bench1` holds `1528774`'s outputs. A new clone is needed |

**Charging:**

| | |
|---|---|
| Verified | Rate 1 on `auto` and `batch_cpu`. Balance 10,000 CPU-hours in `personal-leonyil.qian` on 7 Nov (Leon). PBS shows that project on our jobs |
| Not readable now | `hpc project` asked for `amgr login` again on 8 Nov 12:56; no login was attempted. **Leon must read the balance fresh before step 2** |
| Assumed | 1 CPU-hour per core-hour at rate 1: at most 4 x 64 x 0.75 h = **192 CPU-hours** (1.9% of 10,000) if charged on the request |
| Estimate | 53-74 core-hours used (12-17 min). The model overestimated `1528774` by 1.8 times on one node; 4 nodes untested |
| Unknown | Request or use billing; whether a job failing at its first gate is charged; whether `-P personal-leonyil.qian` is accepted (if rejected, `qsub` fails and nothing runs). Compare the balance before and after |

**Risks:** `batch_cpu` nodes all have 72 CPUs, so each node gives 64 of 72 cores, possibly split unevenly between sockets as on CN-158; their CPU model
is unverified, and the same-model gate stops a mixed set (possibly still charged). Queue wait unknown. Results would be on a different CPU model from `1528774`
if the nodes are Platinum 8452Y; within-job comparisons stay valid.

### Step 1: stage a clean clone and dry-run it on Vanda (no job, no charge): done 8 Nov, approval used

**Approved by Leon for staging only and done on 8 Nov 13:29-13:31 SGT.** Bundle of `7f1b5a6` transferred once (SHA-256 `b85a34a9...`, local = remote),
cloned to `~/dsa5208-p3-7f1b5a6-pilot4`: commit, tree `90488b5`, manifest hash and resources verified; the clone is clean, with no untracked or ignored
files, before and after. Budget passes with 300 or 600 s of gates. The dry run printed
`qsub -q auto -P personal-leonyil.qian -v SOURCE_GIT_REV=7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079 -o /home/svu/leonyil.qian/dsa5208-p3-7f1b5a6-pilot4/code/artifacts/cluster/logs/ jobs/vanda/pilot4.pbs`
and submitted nothing: no `p3_pilot4` in current jobs or history before or after. `auto` and `batch_cpu` enabled and started at rate 1, scheduling on.
Blockers left for step 2: a fresh balance read (needs Leon's `amgr login`), and `pilot2` passing or Leon's skip decision.
Record: `code/artifacts/cluster/discovery/vanda_pilot4_staging_dryrun_7f1b5a6_20261108T1330.txt`. As proposed:


Writes about 90 MB (bundle and clone) to the 99%-full NFS home (7 TB free). Exact actions:

```sh
# local: exact-source bundle from a scratch clone
git clone -q --no-local <repo> <scratch>/r && git -C <scratch>/r checkout -q -B main 7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079
git -C <scratch>/r bundle create <scratch>/dsa5208-p3-7f1b5a6.bundle HEAD main && shasum -a 256 <scratch>/dsa5208-p3-7f1b5a6.bundle
ssh vanda 'test -e ~/dsa5208-p3-7f1b5a6.bundle && echo EXISTS || cat > ~/dsa5208-p3-7f1b5a6.bundle' < <scratch>/dsa5208-p3-7f1b5a6.bundle
ssh vanda 'sha256sum ~/dsa5208-p3-7f1b5a6.bundle'          # must match
ssh vanda 'test -e ~/dsa5208-p3-7f1b5a6-pilot4 || git clone -q -b main ~/dsa5208-p3-7f1b5a6.bundle ~/dsa5208-p3-7f1b5a6-pilot4'
# Vanda: verify commit, tree, clean status, manifest hash, resources and budget, then the dry run (no --yes)
cd ~/dsa5208-p3-7f1b5a6-pilot4/code && bash jobs/vanda/submit.sh pilot4 --queue auto --project personal-leonyil.qian
```

> Leon approves staging only: create ~/dsa5208-p3-7f1b5a6-pilot4 from an exact-source bundle of 7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079 with bounded
> existing-auth operations, verify commit, tree 90488b5b3e83fd0078597b80e18ecc713d78a750, clean clone and pilot_four_node.json SHA256
> 0372e6b05b96810a6ef2c9f687b66904e5c414a8143bad87de756377ff8af823, and run submit.sh pilot4 --queue auto --project personal-leonyil.qian WITHOUT --yes.
> No submission, charge, authentication or permission change.

### Step 2: `pilot4` (charged; needs `pilot2` passed or Leon's skip decision, a fresh balance read, and step 1 done)

**Used: submitted once as `1535640.stdct-mgmt-02` on 10 Nov 17:42:15 SGT.** Balance before (Leon, about 17:39): CPU Net Balance 10000.0 CPU-hours
for `personal-leonyil.qian`. Every check below passed in one session first. PBS changed the memory request to 444 GB per chunk; the charge basis it
recorded is 256 CPUs x 2700 s at rate 1, which is 192 CPU-hours. Running at 17:42:18 on GN-A40-079, -080, -083 and -085. A failure is not retried.
Record: `code/artifacts/cluster/discovery/vanda_pilot4_submit_7f1b5a6_20261110T1742.txt`.

**As approved on 10 Nov (conditional at the time).** Decisions recorded with it: go to `pilot4` directly and leave `pilot2` `1528798` held;
step 1 (staging) is done. Scope: exactly one submission of the staged run at `7f1b5a6`; 4 nodes x 64 cores, 240 GB per node, `place=scatter`,
45 min, `auto` to `batch_cpu` at rate 1, `-P personal-leonyil.qian`; charge capped at 192 CPU-hours. It covers no probe, retry, resubmission or `bench4`.

**Not submitted until all of these hold, checked in the submission session; stop if any fails or the charge could exceed the cap:**

1. Leon has given a fresh available-balance reading himself (time, figure, project name as `hpc project` shows it), and it covers 192 CPU-hours.
2. Clone `~/dsa5208-p3-7f1b5a6-pilot4`: commit `7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079`, tree `90488b5b3e83fd0078597b80e18ecc713d78a750`, no modified,
   untracked or ignored files; `pilot_four_node.json` SHA-256 `0372e6b05b96810a6ef2c9f687b66904e5c414a8143bad87de756377ff8af823`; `pilot4.pbs` requests
   `select=4:ncpus=64:mpiprocs=64:mem=240gb`, `place=scatter`, `walltime=00:45:00` (4 x 64 x 0.75 h = 192 core-hours, the cap).
3. Account lookups resolve on the login node, three in a row.
4. PBS server Active, scheduling True.
5. `auto` and `batch_cpu` enabled and started, `queue_charge_rate = 1` on both.
6. No `p3_pilot4` in current jobs or history; `1528798` still held.

Then `cd ~/dsa5208-p3-7f1b5a6-pilot4/code && bash jobs/vanda/submit.sh pilot4 --queue auto --project personal-leonyil.qian --yes` exactly once, and the job ID
is recorded. If the outcome of `qsub` is uncertain, nothing is resubmitted.

As proposed on 8 Nov:

> Leon explicitly approves exactly ONE pilot4 submission, CHARGED, at most 192 CPU-hours requested from personal-leonyil.qian: source
> 7f1b5a6cbdaabe0e625e1e98f7ee80b3b6a8f079, tree 90488b5b3e83fd0078597b80e18ecc713d78a750, clone ~/dsa5208-p3-7f1b5a6-pilot4, manifest pilot_four_node.json
> SHA256 0372e6b05b96810a6ef2c9f687b66904e5c414a8143bad87de756377ff8af823, 4 nodes x 64 cores, 240 GB per node, place=scatter, 45 min, queue auto, -P
> personal-leonyil.qian, rate 1. Balance read by Leon at <time>: <value>. Before submitting, use bounded existing-auth checks to verify commit, tree, clean
> clone, manifest, resources, scheduling on, auto and batch_cpu enabled and started at rate 1, and no p3_pilot4 in current jobs or history. If anything
> fails, authentication is needed or the charge would differ, stop and report. Otherwise run
> `cd ~/dsa5208-p3-7f1b5a6-pilot4/code && bash jobs/vanda/submit.sh pilot4 --queue auto --project personal-leonyil.qian --yes` exactly once and record the
> job ID. No retries, cancellations, other jobs, bench4, credential or security changes, monitoring loops or final submission.

## Proposed reruns, 7 November 2026: not approved

Diagnosis in [experiments.md](experiments.md) (7 Nov). Both clones were prepared and dry-run on 7 Nov at 11:33 SGT: commit, tree, manifest hash, resources
and a clean clone verified, `qsub` printed and not run. Record: `code/artifacts/cluster/discovery/vanda_dryrun_a64e0fe_20261107T1133.txt`.
Source for both: `a64e0fed6df1d5f4bb971471a6548c68f7656c3c`, tree `a9e1767dcc07d907b9b6987ffd934755cf05751a`; the code is `0339f20` plus evidence files.

**What changed since the failed jobs:** `make internode` now uses `place_mpi`'s explicit, bound placement, and the allocation check compares host names in
one form and records Open MPI's head-node alias. Nothing else in the job path, plans or budgets changed.

**Suggested order:** `bench1` first, because it gives the formal 64-core results the report needs and is the first Vanda test of the fixed `internode` gate
(64 ranks, one node). `pilot2` can be queued with it: PBS runs at most 160 CPUs per user, so they will not run together. Either may fail again; a failure
stops the job within about a minute at rate 0, and nothing is retried.

**What remains unverified, for both:** that the fixed `internode` launch passes on Vanda (only local simulations so far); the cause of `1526501`'s failure,
which is not established; behaviour on a 72-CPU node whose 64-CPU cpuset is split unevenly (CN-158 gave 36 + 28), beyond the gates that passed there;
the CPU model of `cn-159`, `cn-161` and `rn-003`.

### `bench1` rerun: consumed, job `1528774`

**Approved by Leon and submitted once on 7 Nov at 11:39:19 SGT as job `1528774.stdct-mgmt-02`. This approval is used up.** Every check passed first:
commit, tree, clean clone, frozen manifest hash, resources, the `internode` fix present, scheduling on, `auto_free` and `cpu_parallel` enabled and started
at rate 0, nothing of mine queued or running, and the only `p3_bench1` in history was `1526501` from source `0647895`. Queued in `cpu_parallel` at 11:39:19,
rate 0, `project = personal-leonyil.qian`. A failure is not retried. Record: `code/artifacts/cluster/discovery/vanda_bench1_submit_a64e0fe_20261107T1139.txt`.
The request as reviewed:

| | |
|---|---|
| Clone | `~/dsa5208-p3-a64e0fe-bench1`, prepared and dry-run 7 Nov |
| Manifest | `studies_single_node.json`, frozen, SHA-256 `ea1ceb2c734b08009ce4a582ed8d1c0e2d8d6a877d0e30d0d392274de7c1c64b` (unchanged), 148 runs |
| Request | `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 5 h, 320 core-hours at most; about 110 min expected; worst case 16140 s within 16758 s; 37 of 120 GB |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck |
| Gates | `allocation`, `build`, `placement` (8 x 8), `place_mpi` (64 x 1), `internode` (64 x 1, bound), `serial`, `bound_vs_serial`, `runs`, `analyze` |
| Risk | It may again get a 72-CPU node with an uneven cpuset and a different CPU model from `bench16` (Gold 6438N). Comparisons inside the job stay valid; any comparison with `bench16` must then say the models differ |

> Leon explicitly approves exactly ONE bench1 rerun submission: source a64e0fed6df1d5f4bb971471a6548c68f7656c3c, tree a9e1767dcc07d907b9b6987ffd934755cf05751a,
> in the existing clone ~/dsa5208-p3-a64e0fe-bench1, manifest studies_single_node.json SHA256 ea1ceb2c734b08009ce4a582ed8d1c0e2d8d6a877d0e30d0d392274de7c1c64b,
> 1 node x 64 cores, 120 GB, 5 h, auto_free, no -P, rate 0, ZERO CHARGE ONLY. Before submitting, use hard-bounded existing-auth checks to verify commit, tree,
> clean clone, manifest and resources; scheduling on; auto_free and cpu_parallel enabled and started at rate 0; no p3_bench1 from source a64e0fe in current
> jobs or history. If any check fails, authentication is needed or there is any charge, stop and report. Otherwise submit the command below exactly once and
> record the job ID. No retries, cancellations, other jobs, spending, credential or security changes, monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-a64e0fe-bench1/code
bash jobs/vanda/submit.sh bench1 --queue auto_free --no-project --yes
```

### `pilot2` rerun: consumed, job `1528798`

**Submitted once on 7 Nov at 11:50:37 SGT as job `1528798.stdct-mgmt-02` under the same approval, after Leon confirmed it was unused. This approval is used up.**
The one false-positive check was corrected: the `1526470` directory must equal the files tracked in `a64e0fe`, unmodified, and any untracked or ignored file fails
except the bytecode cache the 11:33 dry run wrote (Python bytecode of run_manifest in the Vanda clone, written 11:34:00). All checks passed again, including history
by source (only `1526470` from `367c630`). Queued in `cpu_parallel`, rate 0, while `1528774` runs; PBS enforces 160 running CPUs per user, so it waits.
Record: `code/artifacts/cluster/discovery/vanda_pilot2_submit_a64e0fe_20261107T1150.txt`.

**7 Nov 11:47 SGT: approved by Leon for one submission, stopped before `qsub`, nothing submitted.** One precheck failed: the script refused a `pilot2` run
directory already in the clone. That directory is the committed evidence of failed job `1526470`, tracked in source `a64e0fe`, so the check was wrong for
this clone, but the approval said to stop on any failed check. Every other check passed (clone, manifest, resources, same-model gate, scheduling, queues at
rate 0, running limits 160 CPUs and 2 jobs, no queued-job limit, `1528774` listed and running, only `1526470` from `367c630` in history). Leon decides whether
to approve again. Record: `code/artifacts/cluster/discovery/vanda_pilot2_precheck_stopped_a64e0fe_20261107T1147.txt`.

| | |
|---|---|
| Clone | `~/dsa5208-p3-a64e0fe-pilot2`, prepared and dry-run 7 Nov |
| Manifest | `pilot_two_node.json`, proposed (allowed for a pilot), SHA-256 `27ea797af4203fd5ba72880b8b514ca7d2d23d6660e17740fbe932d770e68b74` (unchanged), 6 runs |
| Request | `select=2:ncpus=64:mpiprocs=64:mem=120gb`, `place=scatter`, 30 min, 64 core-hours at most; about 9 min expected; worst case 730 s within 1040 s; 73 of 120 GB |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck |
| Mixed nodes | No PBS resource selects a CPU model, so it can again get one IN and one CN node. The same-model rule stays: it then stops at `allocation` in seconds, as `1526470` and `1506687` did. Hosts are not pinned |
| Use | Sizing only: launch, binding and correctness at 128 ranks across 2 nodes, one repetition |

> Leon explicitly approves exactly ONE pilot2 rerun submission: source a64e0fed6df1d5f4bb971471a6548c68f7656c3c, tree a9e1767dcc07d907b9b6987ffd934755cf05751a,
> in the existing clone ~/dsa5208-p3-a64e0fe-pilot2, manifest pilot_two_node.json SHA256 27ea797af4203fd5ba72880b8b514ca7d2d23d6660e17740fbe932d770e68b74,
> 2 nodes x 64 cores, 120 GB per node, place=scatter, 30 min, auto_free, no -P, rate 0, ZERO CHARGE ONLY. Before submitting, use hard-bounded existing-auth checks
> to verify commit, tree, clean clone, manifest and resources; scheduling on; auto_free and cpu_parallel enabled and started at rate 0; no p3_pilot2 from source
> a64e0fe in current jobs or history. If any check fails, authentication is needed or there is any charge, stop and report. Otherwise submit the command below
> exactly once and record the job ID. No retries, cancellations, other jobs, spending, credential or security changes, monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-a64e0fe-pilot2/code
bash jobs/vanda/submit.sh pilot2 --queue auto_free --no-project --yes
```

## Readiness review, 6 November 2026

Reviewed without submitting anything. Order: **`pilot2` first, then `bench1`.** They cannot run at the same time (128 + 64 cores is over the
free queue's limit of 160 running CPUs per user), though both may be queued. `pilot2` is the gate for anything charged.

**What `pilot2` checks before any timing.** Every gate is critical, and a failure stops the job:

| Gate | Establishes |
|---|---|
| `allocation` | 2 distinct hosts, each with a cpuset of exactly 64 CPUs and one CPU model; the launch is `pbs_tmrsh` (`plm rsh`, not `tm`); the remote daemon runs under `pbs_mom` with the PBS job ID, so its processes belong to this job |
| `placement` | 8 ranks x 8 threads per node: each thread bound to one CPU, all 64 distinct on each host |
| `place_mpi` | **64 ranks per node, 128 in all**, each bound to one distinct CPU on each host: the first 64-per-node launch across nodes |
| `internode` | Point-to-point and `Allgatherv` across all 128 ranks on both hosts |
| `serial` | Serial gate on the node |
| `bound_vs_serial` | Bound runs on all 128 cores against serial: 128 x 1 and 16 x 8 for 10 steps, 32 x 4 with guided, one-step forces, theta = 0, ranks that own nothing. First cross-node comparison with bound ranks |
| after every gate | Leftover processes of this job are stopped and checked on both nodes. Processes of unknown ownership are reported, never killed |

**What its six timed cases give: sizing, not results.** One repetition each, not frozen, so not formal scaling:

| Case | Use |
|---|---|
| 128 x 1 and 16 x 8 across 2 nodes, N = 10^6 | First time and exchange share across the network; speedup against the in-job serial, sizing only |
| 64 x 1 on one node, N = 10^6 | Same job, so it separates the network's cost from the second node |
| Serial, N = 10^6 | Baseline in the same job |
| 128 x 1 and 16 x 8 at N = 6.4 x 10^6 | Memory at 64 ranks per node (estimated 73 of 120 GB) and time at the weak size, for `pilot4` |

It cannot show 256 cores, more than 2 nodes, the charged pool, or the variance three repetitions would give.

**Budgets.** `pilot2`: worst case 730 s within 1040 s. The six runs still fit if the gates take up to about 600 s; `bench16`'s full gates took 76 s on 16 cores.
If they ran longer, the last runs (the weak sizes) would be skipped and recorded, not run past the walltime. `bench1`: worst case 16140 s within 17358 s, and
still fits with 900 s of gates. Largest node memory: 73 GB for `pilot2` and 37 GB for `bench1`, against 120 GB.

**Defect fixed:** `bench1` would have measured 64 cores without the 64 x 1 placement probe or a bound comparison with serial on 64 cores, and no job has run
either. Commit `0647895` adds them (`SCALE_CHECKS=1`). Locally simulated in Docker: 9 of 9 gates, 36 of 36 runs (`code/artifacts/local/runs/simulated-bench1-20261106/`).
So **`bench1` needs a new clone at `0647895`**. `pilot2` is unchanged: its job script, plan, `measure.sh` and `gates.sh` are identical, so the prepared clone stays valid.

**Required for `bench4` (Leon, 6 Nov):** its binding and correctness gates (`place_mpi`, `internode`, `serial`, `bound_vs_serial` on all 256 cores) are mandatory before a formal run. They must not be left out to reduce cost; the budget includes their time. To be done when `bench4` is frozen after `pilot4`, not now.

## Consumed, 6 November 2026: `pilot2`

**Outcome: failed, 7 Nov 07:38 SGT, exit 5 in 13 s.** `allocation` found mixed CPU models (IN-004 Gold 6438N, CN-158 Platinum 8452Y). Nothing measured.

**Approved by Leon and submitted once on 6 Nov at 18:37:48 SGT as job `1526470`. This approval is used up.** Every check passed first, and none
failed: commit, tree, clean clone, manifest hash, resources, scheduling, queues enabled and started at rate 0, no `p3_pilot2` before, 0 running CPUs
(128 with this job). Queued in `cpu_parallel` at 18:37:55. A failure is not retried. Record: `code/artifacts/cluster/discovery/vanda_pilot2_submit_367c630_20261106T1837.txt`. The request as reviewed:

| | |
|---|---|
| Source | `367c63046583a2d7f26a0ddc1109bd07d99b2fad`, tree `f0ba7fae95dc917837ac7f0370736313189ad985`, clone `~/dsa5208-p3-367c630`, prepared and dry-run on 6 Nov |
| Manifest | `pilot_two_node.json`, status `proposed` (allowed for a pilot), SHA-256 `27ea797af4203fd5ba72880b8b514ca7d2d23d6660e17740fbe932d770e68b74`, 6 runs |
| Request | `select=2:ncpus=64:mpiprocs=64:mem=120gb`, `place=scatter`, 30 min, 64 core-hours at most; about 9 min expected |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck. PBS has shown `project = personal-leonyil.qian` on free jobs; the balance is unread |
| Wait | Needs two free 64-core nodes of one CPU model at once, which may take hours |

> Leon explicitly approves exactly ONE pilot2 submission: source 367c63046583a2d7f26a0ddc1109bd07d99b2fad in the existing clone ~/dsa5208-p3-367c630, manifest pilot_two_node.json
> SHA256 27ea797af4203fd5ba72880b8b514ca7d2d23d6660e17740fbe932d770e68b74, 2 nodes x 64 cores, 120 GB per node, place=scatter, 30 min, auto_free, no -P, rate 0, ZERO CHARGE ONLY. Before submitting, use
> hard-bounded existing-auth checks to verify commit, tree, clean clone, manifest and resources; scheduling on; auto_free and cpu_parallel enabled and
> started at rate 0; no duplicate p3_pilot2 in current jobs or history; and that no other job of mine would push running CPUs over 160. If all pass,
> submit the command below exactly once and record the job ID. No retries, cancellations, other jobs, spending, credential or security changes,
> monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-367c630/code
bash jobs/vanda/submit.sh pilot2 --queue auto_free --no-project --yes
```

## Consumed, 6 November 2026: `bench1`

**Outcome: failed, 6 Nov 21:03 SGT, exit 5 in 35 s on CN-158.** Four gates passed; `internode` lost Open MPI's second daemon. 0 runs. Fixed in `1c50f92`.

**Approved by Leon and submitted once on 6 Nov at 18:43:38 SGT as job `1526501`, to wait in the queue alongside `pilot2` `1526470`. This approval is used up.**
Every check passed first: commit, tree, clean clone, frozen manifest hash, resources, scheduling, `auto_free` and `cpu_parallel` enabled and started at rate 0,
no `p3_bench1` before. Queue rules read at submission: `cpu_parallel` limits **running** jobs per user, `max_run_res.ncpus = 160` and `max_run = 2`. No
queued-job limit exists for users on the server, `auto_free` or `cpu_parallel`. So both jobs may stay queued together, and PBS starts them only within the running limit.
128 + 64 = 192 exceeds 160, so they will not run at the same time. A failure is not retried. Record: `code/artifacts/cluster/discovery/vanda_bench1_submit_0647895_20261106T1843.txt`. The request as reviewed:

| | |
|---|---|
| Source | `0647895d840a8ecae01b3fb60d6e5d2dcc1d315a`, tree `0c20858164e2ee79a254bdb730fe0de0a95693f3`, clone `~/dsa5208-p3-0647895`, **prepared and dry-run on 6 Nov 18:32**: commit, tree, manifest hash, resources and a clean clone verified. Record: `code/artifacts/cluster/discovery/vanda_bench1_dryrun_0647895_20261106T1832.txt` |
| Manifest | `studies_single_node.json`, status `frozen`, SHA-256 `ea1ceb2c734b08009ce4a582ed8d1c0e2d8d6a877d0e30d0d392274de7c1c64b` (unchanged), 148 runs |
| Request | `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 5 h, 320 core-hours at most; about 100 min expected |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck |
| Gates | `allocation`, `build`, `placement` (8 x 8), `place_mpi` (64 x 1), `internode`, `serial`, `bound_vs_serial` (64 cores), `runs`, `analyze` |

> Leon explicitly approves exactly ONE bench1 submission: source 0647895d840a8ecae01b3fb60d6e5d2dcc1d315a in the existing clone ~/dsa5208-p3-0647895,
> manifest studies_single_node.json SHA256 ea1ceb2c734b08009ce4a582ed8d1c0e2d8d6a877d0e30d0d392274de7c1c64b, 1 node x 64 cores, 120 GB, 5 h, auto_free,
> no -P, rate 0, ZERO CHARGE ONLY. Before submitting, use hard-bounded existing-auth checks to verify commit, tree, clean clone, manifest and resources;
> scheduling on; auto_free and cpu_parallel enabled and started at rate 0; no duplicate p3_bench1 in current jobs or history; and that running CPUs
> would stay within 160. If all pass, submit the command below exactly once and record the job ID. No retries, cancellations, other jobs, spending,
> credential or security changes, monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-0647895/code
bash jobs/vanda/submit.sh bench1 --queue auto_free --no-project --yes
```

## Conditional: `pilot4` and `bench4`, charged, not ready

Both need `pilot2` to pass (or Leon's decision to skip that gate: see `plan_256core.md`, 8 Nov), a fresh balance read and charge approval. Leon read the
balance on 7 Nov: 10,000 CPU-hours in `personal-leonyil.qian`. `bench4` also needs its plan frozen from `pilot4`'s result, which changes its hash, and since
8 Nov carries `SCALE_CHECKS=1`. Neither has a Vanda dry run yet; one needs a clean clone, which needs approval. Manifest hashes unchanged at `e05dea8`.

| Job | Request | Most it could charge, at 1 per core-hour (assumed) | Expected use | Manifest SHA-256 at `367c630` |
|---|---|---|---|---|
| `pilot4` | 4 x 64 cores, 240 GB each, 45 min, `auto` | 192 | 12 min | `0372e6b05b96810a6ef2c9f687b66904e5c414a8143bad87de756377ff8af823` |
| `bench4` | 4 x 64 cores, 240 GB each, 2 h 50 min, `auto` | 725 | 56 min | `45c24936ec8185f0c0d86695fe1b3f8ef18136982d8259a777f212f62d39772d`, proposed |

## Consumed, 5 November 2026: `bench16`, formal free 16-core studies

**Approved by Leon and submitted once on 5 Nov at 17:20:38 SGT as job `1523703`. This approval is used up.** All rechecks passed first; `1522998` was left untouched. A failure is not retried. Records:
`code/artifacts/cluster/discovery/vanda_bench16_dryrun_e86bf5d_20261105T1719.txt`, `code/artifacts/cluster/discovery/vanda_bench16_submit_e86bf5d_20261105T1720.txt`. The request as reviewed:

**Why now:** it secures serial runtime against N and the parameter studies for the report without waiting for a whole 64-core node,
which `1522998` has been waiting for since 13:46. At 16:47 SGT no free-pool node had 32 cores free, and 2 had at least 16. That is one
moment and counts cores only. It does **not** supply 256-core scaling, and it does not replace `pilot2`, `pilot4` or `bench4`.

| | |
|---|---|
| Source | `e86bf5d076c51c01f131f3980fc17618e9c24f61`, tree `96eed32b4aec96fdaee9082e5e41b35552c64415`, in a new clone `~/dsa5208-p3-e86bf5d` |
| Manifest | `studies_16core.json`, status `frozen`, SHA-256 `2525574ba733e4a74c44100daa0a8ec2b8a89e7e9e81c7a8025ea44439226dcd` |
| Runs | 121: 3 interleaved repetitions of 39 cases, plus 4 accuracy runs |
| Request | `select=1:ncpus=16:mpiprocs=16:mem=16gb`, 4 h, 64 core-hours at most; about 95 min expected. Worst case 12285 s fits the 13158 s budget |
| Queue, charge | `auto_free`, no `-P`, rate 0 to recheck. PBS has shown `project = personal-leonyil.qian` on free jobs, and the balance is unread |
| With `1522998` | Untouched. 64 + 16 cores is inside the 160-CPU, 2-running-job limit |
| Gates | `allocation`, `build`, `placement` (4 x 4), `place_mpi` (16 x 1, the probe the pilot lacked), `internode`, `serial`, `bound_vs_serial`, `runs`, `analyze` |
| If a gate fails | The job stops, with no retry |
| Limits of the results | Possibly shared node of either CPU model; speedups only inside this job. |

Text that was proposed:

> Leon explicitly approves exactly ONE bench16 submission: source `e86bf5d076c51c01f131f3980fc17618e9c24f61` in a new clone ~/dsa5208-p3-e86bf5d, manifest studies_16core.json
> SHA256 2525574ba733e4a74c44100daa0a8ec2b8a89e7e9e81c7a8025ea44439226dcd, 1 node x 16 cores, 16 GB, 4 h, auto_free, no -P, ZERO CHARGE ONLY. Prepare the clone from an exact-source bundle, then use
> hard-bounded existing-auth checks to verify commit, tree, manifest and resources, scheduling and queues enabled and started with rate 0,
> and no duplicate p3_bench16 in current jobs or history. Run the dry run without --yes, then if all conditions pass submit the command
> below exactly once and record the job ID. Leave 1522998 untouched. No retries, other jobs, spending, credential or security changes,
> monitoring loops, lecturer contact or final submission.

```sh
cd ~/dsa5208-p3-e86bf5d/code
bash jobs/vanda/submit.sh bench16 --queue auto_free --no-project --yes
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=e86bf5d076c51c01f131f3980fc17618e9c24f61 -o /home/svu/leonyil.qian/dsa5208-p3-e86bf5d/code/artifacts/cluster/logs/ jobs/vanda/bench16.pbs
```

Local dry run from a clean clone of this commit: `code/artifacts/local/bench16_dryrun_20261105.txt`. There is no `qsub` on this machine, so its paths differ. The Vanda dry run passed before submission.

## Superseded 6 Nov: conditional requests as of 5 Nov

Each needs a new clean clone of the commit, its dry run, and the conditions here first. Sizes remain provisional.

| Job | Needs first | Request, charge | Expected use | Manifest SHA-256 at `e86bf5d` |
|---|---|---|---|---|
| `pilot2` | `1522998` passed, so 64 ranks on a node is shown. Two whole free nodes must also come up | 2 x 64 cores, 120 GB each, 30 min, `auto_free`, rate 0 | 9 min | `c3ac455c7993821903e5f77b35cf00baeadd1b526756ee04994230194c662e67` |
| `bench1` | `1522998` passed and plan frozen. After `bench16`, its serial and parameter runs can drop | 1 x 64 cores, 120 GB, 5 h, `auto_free`, rate 0 | 97 min | `ebea537b5731feba7ad2f0e71b1d5b5a5c338dce9c3efe23b98112273c395990` |
| `pilot4` | `pilot2` passed, **Leon's `amgr login`, project ID and charge approval** | 4 x 64 cores, 240 GB each, 45 min, `auto`, **192 core-hours** | 12 min | `609267a4ff94d63822b5b69ca7af1582c1990c936b5f16aae1f519ea577a313e` |
| `bench4` | `pilot4` passed, plan frozen from it, balance compared, **charge approval** | 4 x 64 cores, 240 GB each, 2 h 45 min, `auto`, **704 core-hours** | 54 min | `937a701bf930b698dee7a89f6ccbd2333259562af93a2186873059d4335e99e6`; changes when frozen |

## Consumed, 5 November 2026: 16-core pilot

**Approved by Leon and submitted once on 5 Nov at 14:36:19 SGT as job `1523275`. This approval is used up.**
All rechecks passed first, including that `1522998` was still queued and had never started; it was left untouched. The job was queued
in `cpu_parallel` at rate 0. A failure is not retried. Record:
`code/artifacts/cluster/discovery/vanda_pilot16_submit_96a37ba_20261105T143606.txt`. Reasoning is in `plan_256core.md`, "Smaller pilot".

| | |
|---|---|
| Source | `96a37ba1d5dfa810dfa24bb740e58aad9aa5388d`, in a new clone `~/dsa5208-p3-96a37ba` |
| Manifest | `pilot_single_node_16core.json`, SHA-256 `340af523ae17b4f996426dffe7d4bd42adcd4bf400a8807a9b2a61cd545c0690`, 20 runs |
| Request | `select=1:ncpus=16:mpiprocs=16:mem=16gb`, 60 min, 16 core-hours at most |
| Queue, charge | `auto_free`, no `-P`, recheck rate 0 before submitting |
| With `1522998` | It stays queued. 64 + 16 cores is inside the 160-CPU, 2-running-job limit |
| If a gate fails | The job stops, with no retry |

**Prepared on Vanda, 5 Nov 14:31 SGT:** clone `~/dsa5208-p3-96a37ba` created from a bundle holding only this commit. Commit, tree
`2e833d8567bba10e71da1b6ad63017262c215bd2` and manifest hash verified, and the clone is clean. Scheduling on, `auto_free` and
`cpu_parallel` enabled and started, rate 0. The only unfinished job is `1522998`, and no `p3_pilot16` exists. Dry run printed the
command and submitted nothing. Record: `code/artifacts/cluster/discovery/vanda_pilot16_dryrun_96a37ba_20261105T143058.txt`.

After approval: recheck commit, tree, manifest hash, rate 0, queues, duplicates and that `1522998` has not started, then run once. This is what ran:

```sh
cd ~/dsa5208-p3-96a37ba/code
bash jobs/vanda/submit.sh pilot16 --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_16core.json --yes
```


## Consumed, 5 November 2026: rerun the single-node pilot once

**Approved by Leon and submitted once on 5 Nov at 13:46:25 SGT as job `1522998`. This approval is used up.**
All rechecks passed first. The job was queued in `cpu_parallel` at rate 0. A failure is not retried: it needs a local fix and a new
approval. Record: `code/artifacts/cluster/discovery/vanda_pilot_rerun_submit_3f77e87_20261105T134621.txt`.

**Prepared on Vanda, 5 Nov 13:31 SGT:** clone `~/dsa5208-p3-3f77e87` created from a bundle holding only this commit. Commit, tree
`00bf445fb0350de806d83aa0c10a5097bc32c636` and manifest hash verified, and the clone is clean. Scheduling on, `auto_free` and
`cpu_parallel` enabled and started, rate 0, no unfinished job. `p3_pilot1` history holds only finished `1514774` and `1519637`. Dry
run printed the command and submitted nothing. Recheck these just before submitting. Record:
`code/artifacts/cluster/discovery/vanda_pilot_rerun_dryrun_3f77e87_20261105T133115.txt`.

| | |
|---|---|
| Why | Pilot `1519637` hung at `placement`, 0 of 20 runs. All sizing waits on this job |
| Change from `1519637` | Launcher only: `pbs_tmrsh` instead of a hostfile launch that selected `tm` (commit `3f77e87`) |
| Same as `1519637` | Manifest `pilot_single_node_v2.json` (SHA-256 `0a5f9f64cc5923a218ec9be9f3498be34baf2733c1aeaee1f4daa78c1e2f937a`, 20 runs), solver, gates, resources |
| Request | `select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min, 64 core-hours at most |
| Queue, charge | `auto_free`, no `-P`, rate 0 last time. The dry run shows the command, and rate 0 is checked again before submitting |
| Queue wait | `1519637` waited 10 h 1 min. This is no prediction |
| If the launcher is still wrong | The `placement` gate stops the job in about 2 minutes, with no retry |

The command that was run once:

```sh
cd ~/dsa5208-p3-3f77e87/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json --yes
```

Nothing here approves `pilot2`, `pilot4`, `bench1` or `bench4`, a charged queue, a
retry, or monitoring. It also tests `pbs_tmrsh` at 64 ranks on one node for free, which no job has yet done.

## Closed, 4 November 2026

**Both requests below were approved and submitted once on 4 Nov at 19:10 SGT: pilot `1519637` and GPU timing `1519638`.** GPU timing finished. The pilot ran on 5 Nov and failed at `placement`, exit 5. A failure is not retried
automatically: it needs a local fix and a new approval.

**Vanda state, 4 Nov 18:59 SGT:** clean clone `~/dsa5208-p3-8a50c8f` created, commit and tree verified, dry runs printed the
commands below. Scheduling on, charge rate 0 on `auto_free`, `cpu_parallel` and `gpu`, no current jobs, no duplicates.
Record: `code/artifacts/cluster/discovery/vanda_pilot_gpu_timing_dryrun_8a50c8f_20261104T185923.txt`. Commits after `8a50c8f` add only notes and evidence. The earlier `075ec51`
and `6493ced` preparations are withdrawn: neither clone was created, and `6493ced` lacks the G2 review fixes.

Both jobs: revision `8a50c8f754f716aad91f81343f7eeb6d950a4cf6`, clone `~/dsa5208-p3-8a50c8f`, `auto_free` with no `-P`,
charge rate 0.

## 1. Single-node pilot, manifest v2

`select=1:ncpus=64:mpiprocs=64:mem=120gb`, 60 min (routed to `cpu_parallel` last time).

```sh
cd ~/dsa5208-p3-8a50c8f/code
bash jobs/vanda/submit.sh pilot --queue auto_free --no-project --var MANIFEST=manifests/pilot_single_node_v2.json --yes
```

That runs:

```sh
qsub -q auto_free -v MANIFEST=manifests/pilot_single_node_v2.json,SOURCE_GIT_REV=8a50c8f754f716aad91f81343f7eeb6d950a4cf6 -o /home/svu/leonyil.qian/dsa5208-p3-8a50c8f/code/artifacts/cluster/logs/ jobs/vanda/pilot.pbs
```

Manifest `pilot-single-node-v2`, status `proposed` (allowed for a pilot), sha256 `0a5f9f64cc59`: 20 runs, one repetition,
64-core cases first. Those essential cases start even if every run uses its whole limit; up to 11 others could be skipped.
Gates: `allocation`, `build`, `placement`, `runs`, `analyze`.

These are pilot numbers, not report results. No job has yet passed the entry point on a 64-core allocation. The node may be
Gold 6438N or Platinum 8452Y; the model is recorded, and later baselines must match it.

## 2. GPU timing (G2)

`select=1:ngpus=1:ncpus=36:mem=60gb`, **60 min** (routed to `gpu` last time).

```sh
cd ~/dsa5208-p3-8a50c8f/code
bash jobs/vanda/submit.sh gpu_timing --queue auto_free --no-project --yes
```

That runs:

```sh
qsub -q auto_free -v SOURCE_GIT_REV=8a50c8f754f716aad91f81343f7eeb6d950a4cf6 -o /home/svu/leonyil.qian/dsa5208-p3-8a50c8f/code/artifacts/cluster/logs/ jobs/vanda/gpu_timing.pbs
```

Manifest `manifests/gpu_timing.json` (`gpu-timing-v1`, frozen, sha256 `36b00fe2c12e`): N = 10^5, 3x10^5, 10^6, 3x10^6;
device and CPU backends; 36 bound threads; schedule dynamic,64 on the CPU kernel; 5 timed steps; 3 repetitions; 24 runs;
worst case 2880 s.

| Gate | Kind | Question |
|---|---|---|
| `build` | critical | `nvc++ -mp=gpu` builds `bh_gpu` on the node |
| `device` | critical | Kernel on a device with separate memory, offload mandatory |
| `gpu_busy` | required | `nvidia-smi` shows the GPU working during a run |
| `runs` | required | All 24 runs; a fallback, wrong team, stacked CPUs, no binding or wrong schedule is recorded as failed |
| `analyze` | required | Summary from raw records, refusing the same faults; ratio only for matching workload, binary, host and placement |

If it passes this would be report data, from one GPU in one job. Only the force traversal differs; the tree build, flatten and
integrate use one host thread on both backends and are in the timed region. The CPU side is this program's kernel built by
`nvc++`, not the GCC hybrid solver, so the ratio says nothing about `bh_hybrid`. This path has only run with a stub and a
no-device build, and the team and schedule probes have not been compiled by `nvc++`. If `nvc++` runs them differently, runs
are refused rather than timed, and the job would need a fix and new approval.

## 3. Other decisions

Next requests, not yet open: `pilot2`, `pilot4`, `bench4` and `bench1`, in [plan_256core.md](plan_256core.md). Each needs its own approval.

- Run `amgr login` to read projects and balance. Only Leon can do this.
- Open gap: no bound two-node result has been compared with serial (job 1514458's comparison was unbound).
  `pilot2` and `pilot4` include this comparison, on every core.
