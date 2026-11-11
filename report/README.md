# Project 3 report

Group members as listed in the title block: Yan Yixin, Zhang Yue, Leon Yiliang Qian (membership and student IDs not yet confirmed by the group).

**This folder is the working report.** All measured results are in it: Vanda jobs 1528774 (one node), 1535991 (four nodes, 256
cores) and 1519638 (GPU). As of the 11 Nov revision it compiles to 14 pages. One red `[PENDING]` marker remains, for how source
code reaches Canvas, and three group decisions are open: that route, names and student IDs, and the AI declaration (see
[../notes/ai_declaration_review.md](../notes/ai_declaration_review.md)). The group has also not yet read the text. The **final submission PDF** is a separate file made at the end, kept as
`report/DSA5208_Project3_Report.pdf`. No such file exists yet, so nothing here is ready to hand in. Due 17 November 2026 (lecturer's
Canvas extension); 23:59 is an unverified planning assumption.

| Path | Purpose | Edit by hand? |
|---|---|---|
| `main.tex` | Report text. Text that depends on cluster results is marked `\pending{...}`, which renders in red | Yes |
| `generated/*.tex` | Tables, sentences and plots written from retained evidence, and read with `\input`. `fig_*` are pgfplots plots, `tab_*` tables, the rest tables and notes | **Never**: regenerate |
| `figures/` | Hand-drawn static images only ([why](figures/README.md)). None yet. Data plots are in `generated/`, not here | Yes |
| `rho.bib` | Bibliography; every entry checked against its DOI/ADS record (28 Oct 2026) | Yes |
| `rho-class/` | Two-column template (`rho.cls` and style files) | No |

A missing `generated/fig_*` or `tab_*` file is not an error: `\resultslot` in `main.tex` prints a `[PENDING]` marker until a real run produces it.

## Compiling on Overleaf

The group compiles in Overleaf, as for Project 2. Upload this whole `report/`
folder (keeping `generated/`, `figures/` and `rho-class/` as subfolders) to the
Overleaf project, or sync it. Settings: compiler pdfLaTeX, main document
`main.tex`; Overleaf runs biber automatically for biblatex. The class uses
`minted`, which needs shell escape (on by default in Overleaf). Locally:
`code/docker/tex` compiles it (`pdflatex -shell-escape`, `biber`). No local TeX
installation is needed.

Without Overleaf, compile a scratch copy, so that build files stay out of this folder. The image comes from `code/docker/tex/Dockerfile`:

```sh
docker build -t dsa5208-p3-tex:bookworm code/docker/tex
cp -R report /tmp/report-build && cd /tmp/report-build
docker run --rm -v "$PWD":/w -w /w dsa5208-p3-tex:bookworm sh -c \
  'pdflatex -shell-escape main.tex && biber main && pdflatex -shell-escape main.tex && pdflatex -shell-escape main.tex'
```

## Regenerating content from evidence

From `code/`:

```sh
python3 scripts/report_tables.py                     # validation tables and notes, from retained evidence
python3 scripts/report_figures.py <summary.json> ... # scaling plots and tables, from Vanda runs only
```

Then re-upload the changed `generated/` files. Numbers in the report's tables and generated sentences come only from files under
`code/artifacts/`. Rerunning `report_tables.py` with unchanged evidence must leave `generated/` unchanged.

## Before submission

1. No `\pending{` remains: `grep -n 'pending{' main.tex` prints nothing.
2. The Overleaf source matches this folder. Download the Overleaf project as a
   ZIP (Menu → Download → Source), unzip it to a scratch folder and compare:
   `diff -r <unzipped> report/ -x '*.pdf'`. Resolve every difference in the repository first.
3. The downloaded PDF has the latest results, figures, names, student IDs and
   the final AI declaration; read every page.
4. Commit the final source and keep the submitted PDF as `report/DSA5208_Project3_Report.pdf`.
