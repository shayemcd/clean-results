# Scales in the cleanresults palettes

Scales in the cleanresults palettes

## Usage

``` r
scale_fill_cr(palette = NULL, ...)

scale_colour_cr(palette = NULL, ...)

scale_color_cr(palette = NULL, ...)
```

## Arguments

- palette:

  Palette name or colors (see
  [`cr_palette()`](https://shayemcd.github.io/clean-results/reference/cr_palette.md));
  `NULL` picks the validated default for the number of groups.

- ...:

  Passed to
  [`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html).

## Value

A ggplot2 scale.
