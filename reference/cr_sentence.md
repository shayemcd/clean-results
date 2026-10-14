# Write one result as a sentence

Templates state direction and significance and then the statistics, e.g.
"Compared with Control, Gain was associated with higher trust, *b* =
0.46, 95% CI \\0.04, 0.89\\, *p* = .032." Non-significant results get
"did not differ significantly" wording. Words come from the data, so the
sentence stays true when results change.

## Usage

``` r
cr_sentence(
  x,
  dv,
  variable = NULL,
  level = NULL,
  stats = NULL,
  format = c("markdown", "latex", "html", "plain"),
  style = c("apa", "econ"),
  alpha = 0.05,
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

- alpha:

  Threshold for the significance wording.

- subgroup:

  For tests run with `by`, which subgroup.

- digits, p_digits:

  Decimal places.

## Value

A character string.
