# Pick colors for n groups

Pick colors for n groups

## Usage

``` r
cr_palette(n, palette = NULL)
```

## Arguments

- n:

  Number of groups.

- palette:

  `NULL` (the validated default for `n`: 2 to 5 groups), a palette name
  from
  [cr_palettes](https://shayemcd.github.io/clean-results/reference/cr_palettes.md),
  or a character vector of colors. Set a project default with
  `options(cleanresults.palette = "forest_lilac")`.

## Value

A character vector of `n` colors.
