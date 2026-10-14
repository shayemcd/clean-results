# Point a hypothesis at one result

Point a hypothesis at one result

## Usage

``` r
cr_h(
  source,
  dv,
  variable = NULL,
  level = NULL,
  expect = c("any", "+", "-", "ns", "equiv"),
  robustness = NULL,
  subgroup = NULL,
  alpha = 0.05
)
```

## Arguments

- source:

  A `clean_results` or `cr_tests` object.

- dv:

  Outcome name (raw or displayed label).

- variable:

  Predictor or grouping variable, or a coefficient name such as `"age"`.
  For correlations, the other variable.

- level:

  Factor level as in the data (`"LossFraming"`) or as displayed
  (`"Loss framing"`); for contrasts, `"Loss vs. Gain"` in either form.

- expect:

  The preregistered expectation: `"+"` (positive and significant), `"-"`
  (negative and significant), `"ns"` (not significant), or `"any"` (no
  expectation; nothing is checked).

- robustness:

  Robustness checks for this result: a named list whose elements are
  either another source with the same outcome, variable, and level (e.g.
  the model refit without outliers) or a `cr_h()` pointing somewhere
  else. Names describe each check ("excluding outliers").

- subgroup:

  For tests run with `by`, which subgroup.

- alpha:

  Significance threshold for `expect`.

## Value

A `cr_h` object.
