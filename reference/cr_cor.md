# Correlations between every pair of variables

Correlations between every pair of variables

## Usage

``` r
cr_cor(
  data,
  vars,
  method = c("pearson", "spearman"),
  adjust = "none",
  by = NULL,
  conf_level = 0.95,
  labels = NULL,
  clean_labels = TRUE
)
```

## Arguments

- data:

  A data frame.

- vars:

  Columns to correlate (every pair is tested).

- method:

  `"pearson"` or `"spearman"`.

- adjust:

  Correction across all pairs.

- by:

  Optional column: run every comparison within each subgroup.

- conf_level:

  Confidence level.

- labels:

  Named vector of display labels for variables.

- clean_labels:

  Tidy names without an explicit label (see
  [`clean_label()`](https://shayemcd.github.io/clean-results/reference/clean_label.md)).

## Value

A `cr_tests` object.
