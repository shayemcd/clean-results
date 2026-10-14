# Chi-square (or Fisher's exact) tests

An overall test of association between an outcome and a grouping
variable, with Cramer's *V*. For a binary outcome, `pairs` adds 2 x 2
comparisons between groups with the proportions, a correction across
pairs, and Cohen's *h*.

## Usage

``` r
cr_chisq(
  data,
  dv,
  group,
  pairs = NULL,
  ref = NULL,
  by = NULL,
  exact = "auto",
  success = NULL,
  adjust = "holm",
  dv_adjust = "none",
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

  `NULL` (overall test only), `"all"`, `"ref"`, or specific pairs.

- ref:

  Reference level when `pairs = "ref"` (default: first level).

- by:

  Optional column: run every comparison within each subgroup.

- exact:

  `"auto"` (Fisher's exact test when any expected count is below 5),
  `TRUE`, or `FALSE`.

- success:

  For pairwise comparisons, the outcome value counted as a success
  (default: the last level, `TRUE`, or `1`).

- adjust:

  Correction across the pairs of each outcome (any
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method).
  When on, CIs (mean difference and *d*) are Bonferroni-adjusted to
  match, e.g. 98.3% CIs for 3 pairs, so a CI that excludes zero agrees
  with the corrected *p*. `adjust = "none"` gives ordinary 95% CIs.

- dv_adjust:

  Correction across outcomes for each pair. CIs widen to match
  (Bonferroni across pairs x outcomes).

- conf_level:

  Confidence level.

- labels, level_labels, dv_labels, clean_labels:

  Display labels, as in
  [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md).

## Value

A `cr_tests` object.
