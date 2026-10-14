# Equivalence tests (TOST) for any reported result

Tests whether an effect is smaller than a smallest effect size of
interest (SESOI): two one-sided tests against the lower and upper bounds
(Lakens, 2017). The effect is declared equivalent when both are
significant, which is the same as the 90% CI (for alpha = .05) lying
inside the bounds. Uses each result's own estimate, SE, and df, so
robust and cluster-robust SEs carry over.

## Usage

``` r
cr_equivalence(
  x,
  bounds,
  dv = NULL,
  variable = NULL,
  level = NULL,
  scale = c("raw", "d"),
  alpha = 0.05,
  subgroup = NULL
)
```

## Arguments

- x:

  A `clean_results` or `cr_tests` object (t-tests and regression rows).

- bounds:

  Equivalence bounds: one number `b` for `c(-b, b)`, or
  `c(lower, upper)`. On the estimate's scale (raw units, or ratios such
  as `c(0.8, 1.25)` for odds ratios), or in *d* units with
  `scale = "d"`.

- dv, variable, level:

  Which result(s) to test; `NULL` tests every non-intercept estimate (or
  every comparison for simple tests).

- scale:

  `"raw"` or `"d"` (bounds in standardized units; needs a *d*).

- alpha:

  Alpha for each one-sided test.

- subgroup:

  For results with subgroups or moderator levels.

## Value

A `cr_tests` object with one row per tested result; it works with
[`cr_inline()`](https://shayemcd.github.io/clean-results/reference/cr_inline.md),
[`cr_sentence()`](https://shayemcd.github.io/clean-results/reference/cr_sentence.md),
[`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md),
[`cr_h()`](https://shayemcd.github.io/clean-results/reference/cr_h.md),
and
[`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md).

## Examples

``` r
if (FALSE) { # \dontrun{
eq <- cr_equivalence(res, bounds = 0.2, dv = "trust", variable = "condition")
cr_report(eq)
} # }
```
