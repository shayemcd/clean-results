# Map hypotheses to results

Map hypotheses to results

## Usage

``` r
cr_hypotheses(..., labels = NULL)
```

## Arguments

- ...:

  Named hypotheses, each a
  [`cr_h()`](https://shayemcd.github.io/clean-results/reference/cr_h.md)
  or a list of them (when one hypothesis is tested several ways), e.g.
  `H1 = cr_h(res, "trust", "condition", "Gain", expect = "+")`.

- labels:

  Optional named vector of hypothesis statements, e.g.
  `c(H1 = "Gain framing increases trust")`, used as paragraph leads.

## Value

A `cr_hypotheses` object. Print it to see each test, its robustness
checks, and whether the expectation is met.

## Examples

``` r
if (FALSE) { # \dontrun{
hyp <- cr_hypotheses(
  H1 = cr_h(res, "trust", "condition", "Gain", expect = "+",
            robustness = list("excluding speeders" = res_strict)),
  H2 = list(cr_h(res, "shared", "condition", "Loss", expect = "+"),
            cr_h(res, "shared", "condition", "Loss vs. Gain", expect = "+")),
  labels = c(H1 = "Gain framing increases trust",
             H2 = "Loss framing increases sharing")
)
hyp
cr_report(hyp)
cr_expect(hyp)
} # }
```
