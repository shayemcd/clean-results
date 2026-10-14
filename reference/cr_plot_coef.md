# Coefficient (forest) plots

Dot-and-whisker plot of the estimates in the results table: one row per
term, outcomes in the package palette, a dashed line at no effect, a
thick inner 90% CI and a thin outer CI at the table's level (the same
interval the table reports), and the estimate with stars (or the
*p*-value) above each point. Ratios (OR, IRR) use a log axis.

## Usage

``` r
cr_plot_coef(
  x,
  dv = NULL,
  terms = NULL,
  contrasts = FALSE,
  inner = 0.9,
  p = c("stars", "value", "none"),
  show_values = TRUE,
  palette = NULL,
  style = "polsci",
  digits = 2
)
```

## Arguments

- x:

  A `clean_results` object.

- dv:

  Outcomes to include (default: all).

- terms:

  Variables to include (default: all but the intercept).

- contrasts:

  Plot the pairwise contrasts instead of the coefficients.

- inner:

  Level of the inner (thick) interval, or `NULL` for one interval. Not
  drawn for contrasts whose CIs are multiplicity-adjusted.

- p:

  `"stars"`, `"value"`, or `"none"` for the point labels.

- show_values:

  Print the estimate above each point.

- palette:

  Palette name or colors.

- style:

  Theme style (default `"polsci"`, the forest style).

- digits:

  Decimal places.

## Value

A ggplot object.
