# Save a results table to Word, LaTeX, HTML, or CSV

The format follows the file extension:

- `.docx`: Word table (also the best route into Google Docs: upload the
  file to Drive and open it with Google Docs, or copy the table from
  Word).

- `.tex`: booktabs LaTeX float for Overleaf; `\input{}` it from your
  document.

- `.html`: standalone page; open it in a browser, select the table, and
  paste into Google Docs or an email.

- `.csv`: the formatted cells, for anything else.

## Usage

``` r
cr_save(x, path, caption = NULL, label = NULL, landscape = FALSE, ...)
```

## Arguments

- x:

  A `clean_results`, `cr_table`, `cr_text`, `cr_ground_truth`, or ggplot
  object. Pass a `cr_table` to control the table style, e.g.
  `cr_save(cr_table(res, style = "se"), "t2.tex")`.

- path:

  Output file path.

- caption:

  Table caption (LaTeX and Word/HTML).

- label:

  LaTeX `\label{}` key, e.g. `"tab:main"`.

- landscape:

  Word only: put the table on a landscape page.

- ...:

  Passed to
  [`cr_flextable()`](https://shayemcd.github.io/clean-results/reference/cr_flextable.md)
  (Word/HTML) or
  [`cr_latex()`](https://shayemcd.github.io/clean-results/reference/cr_latex.md)
  (LaTeX).

## Value

`path`, invisibly.

## Details

Report text from
[`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md)
saves to `.tex` (for `\input{}` in Overleaf), `.md`, `.html` (open in a
browser and paste into Google Docs to keep italics), or `.txt`. A
[`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md)
saves to `.json`, `.md`, or `.csv`.

A ggplot (e.g. from
[`cr_plot_means()`](https://shayemcd.github.io/clean-results/reference/cr_plot_means.md))
saves as a figure: `.pdf` (vector, fonts embedded), `.svg`, `.eps`,
`.png`, or `.tiff` (600 dpi). Pass `width = "1col"`, `"1.5col"`
(default), `"2col"`, or a width in mm, and optionally `height` in mm.
