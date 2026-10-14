# Pairwise contrasts as a separate table

Shortcut for `cr_table(x, contrasts = "only", ...)`. Pair it with
`cr_table(x, contrasts = "exclude")` for the main table.

## Usage

``` r
cr_contrast_table(x, ...)
```

## Arguments

- x:

  A `clean_results` object from
  [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md).

- ...:

  Passed to
  [`cr_table()`](https://shayemcd.github.io/clean-results/reference/cr_table.md)
  (`style`, `uncertainty`, `p`, `layout`, ...).

## Value

An object of class `cr_table`.
