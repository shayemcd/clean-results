# Pairwise t-tests with Cohen's d for every pair of conditions

Compares groups two at a time (all pairs, each versus a reference, or
pairs you choose), with Welch *t*-tests, a multiple-comparison
correction across the pairs, and Cohen's *d* (or Hedges' *g*) with a
noncentral-*t* CI.
[`cr_d()`](https://shayemcd.github.io/clean-results/reference/cr_d.md)
is the same function, named for when *d* is what you are after.

## Usage

``` r
cr_ttest(
  data,
  dv,
  group,
  pairs = "all",
  ref = NULL,
  id = NULL,
  by = NULL,
  adjust = "holm",
  dv_adjust = "none",
  effect = c("d", "g"),
  conf_level = 0.95,
  labels = NULL,
  level_labels = NULL,
  dv_labels = NULL,
  clean_labels = TRUE
)
```

## Arguments

- data:

  A data frame.

- dv:

  One or more outcome columns.

- group:

  Grouping (condition) column.

- pairs:

  `"all"` (every pair), `"ref"` (each level versus `ref`), or specific
  pairs as `"Loss vs. Control"` strings or `c("Loss", "Control")`
  vectors. Each pair reports the first level minus the second.

- ref:

  Reference level when `pairs = "ref"` (default: first level).

- id:

  Participant column for within-subject (paired) comparisons.

- by:

  Optional column: run every comparison within each subgroup.

- adjust:

  Correction across the pairs of each outcome (any
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method).
  When on, CIs (mean difference and *d*) are Bonferroni-adjusted to
  match, e.g. 98.3% CIs for 3 pairs, so a CI that excludes zero agrees
  with the corrected *p*. `adjust = "none"` gives ordinary 95% CIs.

- dv_adjust:

  Correction across outcomes for each pair. CIs widen to match
  (Bonferroni across pairs x outcomes).

- effect:

  `"d"` (Cohen's *d*: pooled SD between subjects, *d_z* paired) or `"g"`
  (Hedges' small-sample correction).

- conf_level:

  Confidence level.

- labels, level_labels, dv_labels, clean_labels:

  Display labels, as in
  [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md).

## Value

A `cr_tests` object.

## Examples

``` r
d <- data.frame(cond = rep(c("Control", "Gain", "Loss"), each = 30),
                trust = rnorm(90, rep(c(3, 3.4, 3.1), each = 30)))
cr_d(d, "trust", "cond")                    # all three pairs
#> Welch t-test (3 results)
#> p-values adjusted: Holm across pairs; CIs Bonferroni-adjusted for 3 comparisons (98.3% level) 
#>   Trust ~ Cond [Gain vs. Control]
#>     Mdiff = 0.78, 98.3% CI [0.09, 1.47], t(58.00) = 2.79, p = .022, d = 0.72, 98.3% CI [0.08, 1.35]
#>   Trust ~ Cond [Loss vs. Control]
#>     Mdiff = 0.49, 98.3% CI [-0.18, 1.16], t(57.81) = 1.80, p = .153, d = 0.47, 98.3% CI [-0.16, 1.09]
#>   Trust ~ Cond [Loss vs. Gain]
#>     Mdiff = -0.29, 98.3% CI [-0.96, 0.38], t(57.82) = -1.06, p = .293, d = -0.27, 98.3% CI [-0.89, 0.35]
cr_d(d, "trust", "cond", pairs = "ref")      # each vs. Control
#> Welch t-test (2 results)
#> p-values adjusted: Holm across pairs; CIs Bonferroni-adjusted for 2 comparisons (97.5% level) 
#>   Trust ~ Cond [Gain vs. Control]
#>     Mdiff = 0.78, 97.5% CI [0.14, 1.42], t(58.00) = 2.79, p = .014, d = 0.72, 97.5% CI [0.12, 1.31]
#>   Trust ~ Cond [Loss vs. Control]
#>     Mdiff = 0.49, 97.5% CI [-0.14, 1.12], t(57.81) = 1.80, p = .077, d = 0.47, 97.5% CI [-0.12, 1.05]
```
