# Interaction plots

Means of `dv` across `x_var` for each level of `trace`, as dots joined
by dashed lines with error bars (categorical `x_var`), or as predicted
lines with confidence ribbons (continuous `x_var`). From a model, the
means are the model's predictions; from a data frame, raw means (or
linear fits for a continuous `x_var`).

## Usage

``` r
cr_plot_interaction(
  x,
  dv,
  x_var,
  trace,
  uncertainty = c("ci", "se", "sd", "none"),
  palette = NULL,
  style = "nature",
  n_points = 50,
  conf_level = 0.95,
  ...
)
```

## Arguments

- x:

  A `clean_results` object or a data frame.

- dv:

  Outcome.

- x_var:

  Variable on the x-axis.

- trace:

  Variable whose levels get separate lines.

- uncertainty:

  Error bars: `"se"`, `"ci"` (default), `"sd"` (raw data only), or
  `"none"`.

- palette:

  Palette name or colors (see
  [`cr_palette()`](https://shayemcd.github.io/clean-results/reference/cr_palette.md)).

- style:

  Theme style passed to
  [`theme_cr()`](https://shayemcd.github.io/clean-results/reference/theme_cr.md).

- n_points:

  For a continuous `x_var`: points along its range.

- conf_level:

  Confidence level for `"ci"`.

- ...:

  Passed to
  [`cr_plot_means()`](https://shayemcd.github.io/clean-results/reference/cr_plot_means.md)
  for a categorical `x_var`.

## Value

A ggplot object.
