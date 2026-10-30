# Project 3 report

Group members: Yan Yixin, Zhang Yue, Leon Yiliang Qian (names and IDs to be confirmed).

| File | Purpose |
|---|---|
| `main.tex` | Report source. Drafted: method, parallel design, correctness, methodology. Cluster-dependent text is marked `\pending{...}` and renders in red |
| `rho.bib` | Bibliography; every entry checked against its DOI/ADS record (28 Oct 2026) |
| `generated/*.tex` | Tables and sentences generated from retained evidence. Do not edit by hand |
| `figures/` | Figures generated from cluster runs (none yet) |
| `rho-class/` | Two-column template (`rho.cls` and style files) |

## Compiling on Overleaf

The group compiles in Overleaf, as for Project 2. Upload this whole `report/`
folder (keeping `generated/`, `figures/` and `rho-class/` as subfolders) to the
Overleaf project, or sync it. Settings: compiler pdfLaTeX, main document
`main.tex`; Overleaf runs biber automatically for biblatex. The class uses
`minted`, which needs shell escape (on by default in Overleaf). Locally:
`code/docker/tex` compiles it (`pdflatex -shell-escape`, `biber`). No local TeX
installation is needed.

## Regenerating content from evidence

From `code/`:

```sh
python3 scripts/report_tables.py   # rewrites report/generated/*.tex
```

Then re-upload the changed `generated/` files. Numbers in the report's tables
and generated sentences come only from files under `code/artifacts/`.

## Before submission

1. No `\pending{` remains: `grep -n 'pending{' main.tex` prints nothing.
2. The Overleaf source matches this folder. Download the Overleaf project as a
   ZIP (Menu → Download → Source), unzip it to a scratch folder and compare:
   `diff -r <unzipped> report/ -x '*.pdf'`. Resolve every difference in the repository first.
3. The downloaded PDF has the latest results, figures, names, student IDs and
   the final AI declaration; read every page.
4. Commit the final source and keep the submitted PDF as `report/DSA5208_Project3_Report.pdf`.
