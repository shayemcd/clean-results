# Direction and significance words that update with the results

Write your own sentence and let these fill in the words that depend on
the data, so the text stays correct when results change: "Gain framing
`` `r cr_direction(res, "trust", "condition", "Gain")` `` trust" gives
"increased" or "decreased".

## Usage

``` r
cr_direction(
  x,
  dv,
  variable = NULL,
  level = NULL,
  words = c("higher", "lower"),
  subgroup = NULL
)

cr_sig(
  x,
  dv,
  variable = NULL,
  level = NULL,
  words = c("was", "was not"),
  alpha = 0.05,
  subgroup = NULL
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

- words:

  For `cr_direction()`, the words for a positive and a negative estimate
  (odds ratios above and below 1). For `cr_sig()`, the words for a
  significant and a non-significant result.

- subgroup:

  For tests run with `by`, which subgroup.

- alpha:

  Significance threshold applied to the reported (adjusted) *p*.

## Value

A character string.
