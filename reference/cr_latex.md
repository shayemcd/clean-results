# Render a results table as LaTeX (booktabs + threeparttable)

Produces a self-contained `table` float for Overleaf (`\input{}` it), or
only the `threeparttable` block when `float = FALSE` (used inside
Quarto, which supplies the float and caption). Requires
`\usepackage{booktabs}` and `\usepackage{threeparttable}`; compiles with
pdfLaTeX, XeLaTeX, or LuaLaTeX.

## Usage

``` r
cr_latex(
  x,
  caption = NULL,
  label = NULL,
  float = TRUE,
  placement = "htbp",
  size = "\\small"
)
```

## Arguments

- x:

  A `clean_results` or `cr_table` object.

- caption, label:

  Caption and `\label{}` key (e.g. `"tab:main"`).

- float:

  Wrap in a `table` environment.

- placement:

  Float placement specifier.

- size:

  Font size command applied inside the float, e.g. `"\\small"`.

## Value

A character string of LaTeX code.
