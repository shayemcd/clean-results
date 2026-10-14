# Report one result in text

Use inside Quarto/R Markdown inline code, e.g.
`` `r cr_inline(res, "trust", "condition", "Loss")` `` gives "*b* =
-0.46, 95% CI \\-0.83, -0.09\\, *p* = .017". Works for
[`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
results and for simple tests such as
[`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md).

## Usage

``` r
cr_inline(
  x,
  dv,
  variable = NULL,
  level = NULL,
  stats = NULL,
  format = c("markdown", "latex", "html", "plain"),
  style = c("apa", "econ"),
  subgroup = NULL,
  digits = 2,
  p_digits = 3
)
```

## Arguments

- x:

  A `clean_results` or `cr_tests` object.

- dv:

  Outcome name (raw or displayed label).

- variable:

  Predictor or grouping variable, or a coefficient name such as `"age"`.
  For correlations, the other variable.

- level:

  Factor level as in the data (`"LossFraming"`) or as displayed
  (`"Loss framing"`); for contrasts, `"Loss vs. Gain"` in either form.

- stats:

  Which pieces to include, in order: any of `"est"`, `"se"`, `"ci"`,
  `"test"`, `"p"`, `"es"` (effect size). `NULL` uses the style's
  default.

- format:

  `"markdown"` (Quarto/R Markdown), `"latex"`, `"html"`, or `"plain"`
  (for pasting into Google Docs or Word).

- style:

  `"apa"` (italic symbols, no leading zero for *p*, *r*) or `"econ"`
  (estimate with SE and *p* in parentheses, leading zeros).

- subgroup:

  For tests run with `by`, which subgroup.

- digits, p_digits:

  Decimal places.

## Value

A character string.
