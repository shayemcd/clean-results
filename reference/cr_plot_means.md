# Bar, dot, box, and raincloud plots of group means with significance brackets

From a
[`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
result, plots model-estimated marginal means (averaged over other
predictors, with the model's robust SEs) and labels brackets with the
same adjusted contrasts the tables report. From a data frame, plots raw
means with SE, SD, or CI and labels brackets with Welch *t*-tests
([`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md)).

## Usage

``` r
cr_plot_means(
  x,
  dv,
  variable,
  by = NULL,
  facet = NULL,
  type = c("bar", "dot", "raincloud", "box"),
  uncertainty = c("ci", "se", "sd", "none"),
  p = c("stars", "value", "none"),
  comparisons = "ref",
  ref = NULL,
  show_values = NULL,
  points = FALSE,
  ref_line = NULL,
  lines = NULL,
  palette = NULL,
  style = "nature",
  digits = 2,
  adjust = "holm",
  conf_level = 0.95,
  caption = FALSE,
  labels = NULL,
  level_labels = NULL
)
```

## Arguments

- x:

  A `clean_results` object or a data frame.

- dv:

  Outcome.

- variable:

  Grouping variable on the x-axis.

- by:

  Optional second grouping variable: dodged groups in the lab palette.
  Brackets then compare `by` levels within each `variable` level.

- facet:

  Optional variable to facet by (brackets stay within panels).

- type:

  `"bar"`, `"dot"`, or, for raw data, `"raincloud"` (density, box,
  jittered points, mean and error bar) or `"box"`.

- uncertainty:

  Error bars: `"se"`, `"ci"` (default), `"sd"` (raw data only), or
  `"none"`.

- p:

  Bracket labels: `"stars"` (with "ns"), `"value"` (*p* = .031), or
  `"none"` (no brackets).

- comparisons:

  Which brackets: `"ref"` (each level vs. `ref`), `"all"`, `"sig"` (only
  significant pairs), a character vector such as
  `c("Loss vs. Control")`, or `"none"`. P-values always come from the
  full set of pairwise comparisons with the model's correction (or
  `adjust` for raw data), so they match the tables and text.

- ref:

  Reference level for `comparisons = "ref"` (default: first level).

- show_values:

  Print the means (above bars; beside dots). Default: on for bars.

- points:

  Raw data, dot plots: show the jittered observations behind the means.

- ref_line:

  Optional y value for a dashed reference line (e.g. a scale midpoint).

- lines:

  Connect dots across x within each `by` group (interaction style).
  Default: `TRUE` for dot plots with `by`.

- palette:

  Palette name or colors (see
  [`cr_palette()`](https://shayemcd.github.io/clean-results/reference/cr_palette.md)).

- style:

  Theme style passed to
  [`theme_cr()`](https://shayemcd.github.io/clean-results/reference/theme_cr.md).

- digits:

  Decimal places for printed means.

- adjust:

  Raw data only: correction across pairs.

- conf_level:

  Confidence level for `"ci"`.

- caption:

  Put the method note under the plot. It is always available as
  `attr(plot, "cr_note")` for a figure caption.

- labels, level_labels:

  Display labels (raw data); model results use their own labels.

## Value

A ggplot object.

## Examples

``` r
if (FALSE) { # \dontrun{
cr_plot_means(res, "trust", "condition")                    # model means, 95% CIs
cr_plot_means(res, "trust", "condition", by = "female", type = "dot")
cr_plot_means(d, "trust", "condition", type = "raincloud") + ggplot2::ylim(1, 7)
} # }
```
