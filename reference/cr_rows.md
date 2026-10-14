# Flatten results into one row per reportable estimate

The common format behind
[`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md),
[`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md),
[`cr_verify()`](https://shayemcd.github.io/clean-results/reference/cr_verify.md),
and
[`cr_expect()`](https://shayemcd.github.io/clean-results/reference/cr_expect.md).
Works for
[`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
results and for simple tests
([`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md),
[`cr_chisq()`](https://shayemcd.github.io/clean-results/reference/cr_chisq.md),
[`cr_anova()`](https://shayemcd.github.io/clean-results/reference/cr_anova.md),
[`cr_cor()`](https://shayemcd.github.io/clean-results/reference/cr_cor.md)).

## Usage

``` r
cr_rows(x, ...)
```

## Arguments

- x:

  A `clean_results` or `cr_tests` object.

- ...:

  Unused.

## Value

A data frame.
