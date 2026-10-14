# One-way ANOVA with eta squared

One-way ANOVA with eta squared

## Usage

``` r
cr_anova(
  data,
  dv,
  group,
  by = NULL,
  welch = FALSE,
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

- by:

  Optional column: run every comparison within each subgroup.

- welch:

  Use Welch's ANOVA (unequal variances).

- labels, level_labels, dv_labels, clean_labels:

  Display labels, as in
  [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md).

## Value

A `cr_tests` object. For pairwise follow-ups use
[`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md),
or
[`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
with `contrasts` for model-based (e.g. Tukey) contrasts.
