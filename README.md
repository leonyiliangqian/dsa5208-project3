# DSA5208 Project 3: Barnes–Hut with MPI+OpenMP

Due **13 November 2026, 23:59 Singapore time**, 35 points. Group listing to confirm: Yan Yixin, Zhang Yue, Leon Yiliang Qian.

This repository is the group's internal research record. It holds the code, the report source, and every job's evidence. **What gets
handed in is smaller:** a PDF report and a clean source package built from `code/`, as [notes/submission_audit.md](notes/submission_audit.md)
explains. **Job status changes daily and lives only in [HANDOFF.md](HANDOFF.md).** Start there if you are writing the report.

## What it is

Gravitational n-body simulation with the Barnes–Hut tree approximation, on Plummer-profile synthetic input, in C++17:

| Program | Source | Parallelism |
|---|---|---|
| `bh_serial` | `code/serial/barnes_hut.cpp` | None: the reference, and the denominator for speedup |
| `bh_hybrid` | `code/hybrid/bh_hybrid.cpp` | MPI between ranks with a replicated global tree, OpenMP inside each rank |
| `bh_gpu` | `code/gpu/bh_gpu.cpp` | OpenMP target offload of the force traversal |

Shared physics and tree code is in `code/common/`.

## Folder map

| Path | Holds | Goes in the hand-in? |
|---|---|---|
| [code/](code/) | Source, `Makefile`, tests, scripts, plans, job scripts, Docker, and the [run README](code/README.md) | Yes, through the package script |
| [code/artifacts/](code/artifacts/) | Evidence: Vanda runs in `cluster/`, local tests in `local/`. Never edited. Indexed in [notes/evidence_index.md](notes/evidence_index.md) | No |
| [report/](report/) | Working report source ([how it is laid out](report/README.md)) | Only as the final PDF |
| [notes/](notes/) | Requirements, design, experiment history, approvals, group review ([index](notes/README.md)) | No |
| [HANDOFF.md](HANDOFF.md) | Current status, and a dated history below it | No |

## Quick start

Docker Desktop must be running for the commands that use `docker/run.sh`.

```sh
cd code
make check                                   # serial gate
docker/run.sh make check-hybrid              # MPI+OpenMP against serial
docker/run.sh make check-gpu                 # GPU solver's logic, on the host
docker/run.sh bash tests/pipeline_e2e.sh     # measurement pipeline on tiny inputs

bash scripts/package_submission.sh ../dsa5208-project3-source.zip   # source package, from the committed tree
bash tests/jobs/package_test.sh              # what the package must and must not hold
python3 tests/repo_links_test.py             # every path the documents name exists
```

Build commands, dependencies and options are in [code/README.md](code/README.md). The report is compiled as [report/README.md](report/README.md) describes.

## Verified results

These are stable results from real Vanda jobs. Sources and limits are in [notes/evidence_index.md](notes/evidence_index.md).

| Result | Job | Scope |
|---|---|---|
| Serial and hybrid correctness, one node | `1503779` | 8 cores, all 9 gates |
| Hybrid matches serial across two nodes | `1514458` | One node pair, 16 cores, comparison unbound |
| GPU solver correct on a real device | `1514775` | NVIDIA A40 |
| GPU against CPU timing | `1519638` | GPU slower than 36 CPU cores at all 4 sizes; one job, three repetitions |

**The graded CPU scaling results do not exist yet:** serial runtime against N, and MPI and MPI+OpenMP strong and weak scaling to 256
cores. Pilot `1523275` set provisional sizes only, and is not a scaling result. Local Docker runs are tests and never results.
