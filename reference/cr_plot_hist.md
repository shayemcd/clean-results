# Histograms

A histogram with a dashed line at the mean; with `by`, one panel per
group in the package palette (or overlaid).

## Usage

``` r
cr_plot_hist(
  data,
  var,
  by = NULL,
  layout = c("facet", "overlay"),
  bins = 30,
  binwidth = NULL,
  mean_line = TRUE,
  palette = NULL,
  style = "nature",
  labels = NULL,
  level_labels = NULL
)
```

## Arguments

- data:

  A data frame.

- var:

  Variable to plot.

- by:

  Optional grouping variable.

- layout:

  With `by`: `"facet"` (one panel per group) or `"overlay"`.

- bins, binwidth:

  Passed to
  [`ggplot2::geom_histogram()`](https://ggplot2.tidyverse.org/reference/geom_histogram.html).

- mean_line:

  Draw the mean as a dashed line.

- palette:

  Palette name or colors.

- style:

  Theme style passed to
  [`theme_cr()`](https://shayemcd.github.io/clean-results/reference/theme_cr.md).

- labels, level_labels:

  Display labels.

## Value

A ggplot object.
