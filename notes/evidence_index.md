# Experiment and evidence index

Original evidence is never edited. Paths are under `code/artifacts/`. **Supports** says what a job can be cited for: *correctness*,
*provisional sizing*, *formal report result*, *diagnosis* (explains a fault), or *nothing measured*. Dated detail is in
[experiments.md](experiments.md). Formal CPU results exist for one node only: 16 shared cores (`1523703`) and a whole 64-core node (`1528774`).

## Real Vanda jobs

| Job | Date | Purpose | Source | Outcome | Evidence | Supports |
|---|---|---|---|---|---|---|
| `1503779` | 28 Oct | First correctness, 1 x 8 cores | `d959217` | Passed, 9 of 9 gates, IN-003 | `cluster/runs/correctness-20261028T123124Z-1503779/`, `cluster/logs/1503779.stdct-mgmt-02.OU` | **Correctness**, formal in report |
| `1506687` | 29 Oct | Two-node correctness | `3c76d5e` | **Failed**, exit 5: allocation check found mixed CPU models | `cluster/runs/twonode-20261029T053005Z-1506687/`, `cluster/logs/1506687.stdct-mgmt-02.OU` | Nothing measured; diagnosis |
| `1507215` | 29 Oct | Two-node correctness, forced `tm` | `494af8b` | **Failed**: killed at walltime, `place_1x8` hung | `cluster/runs/twonode-20261029T071525Z-1507215/`, `cluster/logs/1507215.stdct-mgmt-02.OU` | Diagnosis |
| `1513781` | 3 Nov | Locate the stall | `18c0d24` | **Failed**, exit 6: own harness lost a cleanup report; steps never ran | `cluster/runs/diag-20261103T073541Z-1513781/`, `cluster/logs/1513781.stdct-mgmt-02.OU` | Nothing measured; diagnosis |
| `1514029` | 3 Nov | Locate the stall | `aa763c9` | Diagnostic finished, verdict FAIL by design: `tm` with binding hangs, cause unknown | `cluster/runs/diag-20261103T082648Z-1514029/`, `cluster/logs/1514029.stdct-mgmt-02.OU` | Diagnosis |
| `1514458` | 3 Nov | Two-node correctness, `pbs_tmrsh` | `0b1f36b` | Passed, 17 of 17 gates, IN-002 + IN-005; 22 of 22 comparisons exact, unbound | `cluster/runs/twonode-20261103T102750Z-1514458/`, `cluster/logs/1514458.stdct-mgmt-02.OU` | **Correctness**, formal in report, within those limits |
| `1514774` | 3 Nov | 64-core pilot | `fa9da68` | **Failed** at entry in 1 s, 0 runs; no run directory | `cluster/logs/1514774.stdct-mgmt-02.OU` | Nothing measured |
| `1514775` | 3 Nov | GPU validation | `fa9da68` | Passed, A40, GN-A40-005 | `cluster/runs/gpu_validate-20261103T134410Z-1514775/`, `cluster/logs/1514775.stdct-mgmt-02.OU` | **Correctness** on a device, formal in report |
| `1519637` | 4-5 Nov | 64-core pilot | `8a50c8f` | **Failed**, exit 5: `placement` timed out, 0 of 20 runs, IN-020 | `cluster/runs/pilot1-20261104T211117Z-1519637/`, `cluster/logs/1519637.stdct-mgmt-02.OU`, `cluster/logs/1519637_qstat_xf.txt` | Nothing measured; diagnosis. CPU model only |
| `1519638` | 4 Nov | GPU timing | `8a50c8f` | Passed, 5 of 5 gates, 24 of 24 runs, A40, GN-A40-004 | `cluster/runs/gpu_timing-20261104T111747Z-1519638/`, `cluster/logs/1519638.stdct-mgmt-02.OU` | **Formal report result**, one job, one GPU, three repetitions |
| `1522998` | 5 Nov | 64-core pilot rerun | `3f77e87` | Passed, exit 0, 8 min 49 s, 5 of 5 gates, 20 of 20 runs verified, whole node IN-016 | `cluster/runs/pilot1-20261105T093901Z-1522998/`, `cluster/logs/1522998.stdct-mgmt-02.OU`, `cluster/logs/1522998_qstat_xf.txt`, `cluster/discovery/vanda_retrieval_1523703_1522998_20261106.txt` | **Provisional sizing only.** One repetition. Not a result; shows nothing across nodes |
| `1523275` | 5 Nov | 16-core pilot | `96a37ba` | Passed, exit 0, 15 min 12 s, 5 of 5 gates, 20 of 20 runs, IN-002 | `cluster/runs/pilot16-20261105T063623Z-1523275/`, `cluster/logs/1523275.stdct-mgmt-02.OU`, `cluster/logs/1523275_qstat_xf.txt`, `cluster/discovery/vanda_pilot16_retrieval_20261105T1650.txt` | **Provisional sizing only.** One repetition. Not a scaling result, and proves nothing at 64 or 256 cores |
| `1523703` | 5 Nov | `bench16`: formal studies on 16 cores | `e86bf5d` | Passed, exit 0, 1 h 28 min, 9 of 9 gates, 121 of 121 runs verified, IN-002 (shared) | `cluster/runs/bench16-20261105T092045Z-1523703/`, `cluster/logs/1523703.stdct-mgmt-02.OU`, `cluster/logs/1523703_qstat_xf.txt`, `cluster/analysis/bench16-1523703/`, `cluster/discovery/vanda_retrieval_1523703_1522998_20261106.txt` | **Formal report result, 1 to 16 cores only**, three repetitions. Never 64 or 256 cores |
| `1526470` | 6-7 Nov | `pilot2`: 128 cores on 2 nodes | `367c630` | **Failed** at the first gate, exit 5, 13 s, 7 Nov 07:38: `allocation` found mixed CPU models (IN-004 Gold 6438N + CN-158 Platinum 8452Y), as designed; both nodes CLEAN | `cluster/runs/pilot2-20261106T233758Z-1526470/`, `cluster/logs/1526470.stdct-mgmt-02.OU`, `cluster/logs/1526470_qstat_xf.txt`, `cluster/discovery/vanda_pilot2_submit_367c630_20261106T1837.txt`, `cluster/discovery/vanda_retrieval_1526470_1526501_20261107.txt` | Nothing measured; diagnosis |
| `1526501` | 6 Nov | `bench1`: formal studies on one 64-core node | `0647895` | **Failed** at `internode`, exit 5, 35 s, 21:03, CN-158 (cpuset 36 + 28): `allocation`, `build`, `placement` (8 x 8) and `place_mpi` (64 x 1) passed; Open MPI lost its second daemon in the unbound 64-rank exchange; 0 runs; 5 of 5 cleanups CLEAN | `cluster/runs/bench1-20261106T130250Z-1526501/`, `cluster/logs/1526501.stdct-mgmt-02.OU`, `cluster/logs/1526501_qstat_xf.txt`, `cluster/discovery/vanda_bench1_submit_0647895_20261106T1843.txt`, `cluster/discovery/vanda_retrieval_1526470_1526501_20261107.txt` | Nothing measured; diagnosis. Placement on an uneven cpuset |
| `1528774` | 7 Nov | `bench1` rerun: formal studies on one whole 64-core node, fixed `internode` | `a64e0fe` | Passed, exit 0, 54 min 36 s, IN-008 (whole node, Gold 6438N), 9 of 9 gates, 148 of 148 runs verified, 9 of 9 cleanups CLEAN | `cluster/runs/bench1-20261107T033925Z-1528774/`, `cluster/logs/1528774.stdct-mgmt-02.OU`, `cluster/logs/1528774_qstat_xf.txt`, `cluster/analysis/bench1-1528774/`, `cluster/discovery/vanda_retrieval_1528774_20261107.txt`, `cluster/discovery/vanda_bench1_submit_a64e0fe_20261107T1139.txt` | **Formal report result, 1 to 64 cores of one node**, three repetitions. Never more than one node or 256 cores |
| `1528798` | 7-10 Nov | `pilot2` rerun: 128 cores on 2 nodes, fixed `internode` | `a64e0fe` | **Held by PBS** (system hold) on 10 Nov after 21 failed launch attempts, exit -10; no run directory or output; cause not established | `cluster/discovery/vanda_pilot2_submit_a64e0fe_20261107T1150.txt`, `cluster/discovery/vanda_pilot2_hold_1528798_20261110T1644.txt` | Nothing measured |
| `1535562` | 10 Nov | Launch test: can PBS start a job for this account, and does the account resolve on the node | none (no project code) | Passed: exit 0 first attempt, CN-161, `cpu_serial`, rate 0; account, primary group and home-directory write resolved | `cluster/discovery/vanda_launch_test_1535562_20261110.txt` (summary; raw output kept on Vanda) | One free-pool node at one moment. Not a measurement |
| `1535640` | 10 Nov | `pilot4`: 256 cores on 4 nodes, charged, cap 192 CPU-hours | `7f1b5a6` | **Running** at 17:42 on GN-A40-079/080/083/085. Status in [HANDOFF.md](../HANDOFF.md) | `cluster/discovery/vanda_pilot4_submit_7f1b5a6_20261110T1742.txt`, `cluster/discovery/vanda_pilot4_staging_dryrun_7f1b5a6_20261108T1330.txt` | Nothing yet. Would be sizing and 256-core correctness only |

Site checks, dry runs and submission records are in `cluster/discovery/`, and name the job or commit in the file name. `cluster/analysis/` holds summaries derived from run directories, which are never overwritten. `PBS_JOBCOOKIE` values are redacted from committed copies: see `cluster/REDACTIONS.md`.

## Local simulations and tests: never results

Run in Docker or on macOS, in `local/`. They test logic and tooling. **No timing from them may appear as a result.**

| Evidence | What it tested |
|---|---|
| `local/serial_validation_linux.json`, `local/serial_validation_darwin.json`, `local/hybrid_validation_linux.json`, `local/gpu_validation_linux.json` | Local gate results |
| `local/energy_study_linux.json` | Energy and timestep behaviour; the report's table cites it as a local run |
| `local/memory_probe_20261104.txt` | First memory estimate, since replaced by the pilot's values for planning |
| `local/runs/simulated-*` | Job scripts end to end with stand-ins for PBS. `simulated-bench16-refuse-20261105` shows refusal of a plan that is not frozen. `simulated-bench1-alias-20261107` and `simulated-pilot2-alias-20261107` run the fixed wrappers (`0339f20`) with Open MPI's head-node alias forced as on Vanda; `simulated-bench1-internode-fail-20261107` shows a failed `internode` stopping the job with nothing measured and cleanup CLEAN |
| `local/runs/gates-selftest-*`, `local/runs/launcher-selftest-*` | Fault injection on the gate library and launcher, on simulated nodes |
| `local/runs/pipeline-e2e-*` | Plan, runs, analysis and figures on tiny inputs |
| `local/runs/pilot-*`, `local/runs/binding-*`, `local/runs/leafsweep-*` | Early local exercises, 28 Oct |

Three `pipeline-e2e` folders from 3 and 4 Nov exist only on Leon's machine and are not tracked.

## Rechecking a run

```sh
cd code
python3 scripts/verify_run.py artifacts/cluster/runs/<run>     # records against the plan, phases, summary
python3 scripts/analyze.py <copy of the run>                   # regenerates the summary; never overwrite the original
```
