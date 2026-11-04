# Draft for the lecturer: not sent

For Leon or the group to review and send. Fill in the bracketed parts first.

**Subject:** DSA5208 Project 3: Vanda allocation for 256 cores, and how to submit code

Dear [lecturer's name],

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
[Name and student ID]
On behalf of [group members]
