# Tidy results as a data frame

One row per coefficient, reference level, or contrast per outcome, with
the within-factor p-value (`p.within`) and the final reported p-value
(`p.value`, after any across-outcome correction).

## Usage

``` r
cr_tidy(x)
```

## Arguments

- x:

  A `clean_results` object.

## Value

A data frame.
