# Lecturer draft: inactive, not sent

**INACTIVE. Kept as a record only; never sent.** Leon decided on 4 Nov 2026 that lecturer contact is no longer needed. Do not send
or revise this. See `project_memory.md`.

**To:** cygnari@nus.edu.sg

**Subject:** DSA5208 Project 3: Vanda allocation for 256 cores, and how to submit code

Dear Prof. Chen,

We are doing Project 3 (Barnes–Hut n-body, MPI+OpenMP, with a GPU test) and have two questions.

**1. Running on 256 CPU cores**

Lecture 12 asks for MPI scaling to at least 256 CPU cores. On Vanda, the free queue (`auto_free`, routing to `cpu_parallel`)
allows 160 CPUs per job and per user, so one MPI run cannot reach 256 cores there. `batch_cpu` allows it, at charge rate 1.

Our plan is one short test job and one measurement job, each on 4 nodes with 64 cores per node. Together they would request
up to about 900 core-hours, and we expect to use about 240. These are estimates.

- Is there a course project or a free-queue exception we should use for this?
- If not, are students expected to use their personal credits?
- If neither is possible, would results up to 128 or 160 cores be accepted, with the gap stated in the report?

**2. Submitting the source code**

Lecture 12 asks us to include source code and to leave out log files and terminal output, but the Canvas assignment lists PDF
only. How should we submit the code: a separate upload, an appendix in the PDF, or a repository link?

Thank you,
Leon Yiliang Qian (A0355825W)
On behalf of our group, with Yan Yixin (A0327039A) and Zhang Yue (A0333668U)
