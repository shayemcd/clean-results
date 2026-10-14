# Cohen's d for every pair of conditions

For a data frame, the same as
[`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md).
For
[`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
results, returns the model-based standardized differences: each factor
level versus the reference and every pairwise contrast, divided by the
pooled within-group SD of the outcome (`lm`) or the total SD (`lmer`),
with CIs from the same robust SEs.

## Usage

``` r
cr_d(x, ...)
```

## Arguments

- x:

  A data frame or a `clean_results` object.

- ...:

  For data frames, arguments to
  [`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md).
  For results, `dv` and `variable` to filter, and `pairs` (`"all"`
  contrasts, `"ref"` levels versus the reference, or `"A vs. B"`
  strings).

## Value

A `cr_tests` object (data) or a data frame (results).
