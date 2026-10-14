# Results text that updates itself

Everything here comes from the same objects as the tables, so prose
rebuilt on render can’t drift from the numbers. We start from one fitted
model set.

``` r

library(cleanresults)

d <- cr_example_data()
res <- clean_regress(
  d,
  dvs = c(trust = "linear", share = "logistic"),
  predictors = ~ condition + age,
  random = ~ (1 | id),
  contrasts = "condition",
  labels = c(condition = "Condition", age = "Age (years)"),
  dv_labels = c(trust = "Trust", share = "Shared")
)
#> Registered S3 method overwritten by 'clubSandwich':
#>   method    from    
#>   bread.mlm sandwich
```

## Numbers, words, and sentences

``` r

cr_inline(res, "share", "condition", "Loss")
#> [1] "*OR* = 2.39, 95% CI [1.21, 4.69], *p* = .012"
cr_inline(res, "share", "condition", "Loss", style = "econ")
#> [1] "OR = 2.39 (SE = 0.82, p = 0.012)"
cr_inline(res, "trust", "condition", "Gain", stats = c("est", "ci", "p", "es"))  # adds d
#> [1] "*b* = 0.42, 95% CI [-0.07, 0.90], *p* = .095, *d* = 0.31, 95% CI [-0.06, 0.68]"

cr_direction(res, "share", "condition", "Loss")   # "higher" / "lower"
#> [1] "higher"
cr_sig(res, "share", "condition", "Loss")         # "was" / "was not"
#> [1] "was"
cr_sentence(res, "share", "condition", "Loss")
#> [1] "Compared with Control, Loss was associated with higher odds of shared, *OR* = 2.39, 95% CI [1.21, 4.69], *p* = .012."
```

In a Quarto or R Markdown document, call these inline:

> Loss framing increased sharing relative to control, *OR* = 2.39, 95%
> CI \[1.21, 4.69\], *p* = .012.

The source for that sentence is:

``` markdown
Loss framing increased
sharing relative to control, *OR* = 2.39, 95% CI [1.21, 4.69], *p* = .012.
```

Use `format = "latex"` for Overleaf and `"plain"` or `"html"` for Google
Docs.

Sentences are mechanical by design. They give the direction, whether the
result was significant (non-significant results get “did not differ
significantly” wording), and the statistics, never interpretation.

## Hypothesis map and results paragraphs

``` r

# a robustness check: refit without the youngest participants
res_strict <- clean_regress(
  d[d$age >= 30, ],
  dvs = c(trust = "linear", share = "logistic"),
  predictors = ~ condition + age, random = ~ (1 | id), contrasts = "condition",
  labels = c(condition = "Condition", age = "Age (years)"),
  dv_labels = c(trust = "Trust", share = "Shared")
)

hyp <- cr_hypotheses(
  H1 = cr_h(res, "share", "condition", "Loss", expect = "+",
            robustness = list("excluding under-30s" = res_strict)),
  H2 = cr_h(res, "trust", "condition", "Gain", expect = "+"),
  labels = c(H1 = "Loss framing increases sharing",
             H2 = "Gain framing increases trust")
)
hyp
#> H1: Loss framing increases sharing
#>   Shared ~ Condition [Loss]
#>     OR = 2.39, 95% CI [1.21, 4.69], p = .012
#>     expect: + -> expectation met
#>     robustness (excluding under-30s): OR = 2.89, 95% CI [1.15, 7.25], p = .024
#> H2: Gain framing increases trust
#>   Trust ~ Condition [Gain]
#>     b = 0.42, 95% CI [-0.07, 0.90], p = .095
#>     expect: + -> expectation not met
```

Each test is listed with its robustness checks and whether its
expectation was met. In this simulated data H2’s expectation is not met,
which is what an unmet expectation looks like.

``` r

cr_report(hyp)     # one paragraph per hypothesis, robustness checks attached
```

**H1: Loss framing increases sharing.** Compared with Control, Loss was
associated with higher odds of shared, *OR* = 2.39, 95% CI \[1.21,
4.69\], *p* = .012. In the robustness check (excluding under-30s), the
corresponding estimate was *OR* = 2.89, 95% CI \[1.15, 7.25\], *p* =
.024.

**H2: Gain framing increases trust.** Trust did not differ significantly
between Gain and Control, *b* = 0.42, 95% CI \[-0.07, 0.90\], *p* =
.095.

`cr_report(res)` writes a paragraph for every estimate in a results
object instead. Save a report for a manuscript with
`cr_save(cr_report(hyp), "results/h_results.tex")` (for `\input{}` in
Overleaf) or `"results/h_results.html"` (paste into Google Docs with
italics intact).

## Guarding against drift

| Risk | Tool |
|----|----|
| A hand-written claim (“framing increased sharing”) stops being true after a re-run | `cr_expect(res, "share", "condition", "Loss", sign = "+", sig = TRUE)` in a hidden chunk makes the render **fail**; `cr_expect(hyp)` checks every hypothesis with an `expect` |
| A number typed by hand doesn’t match the results | `cr_verify("paper.qmd", res)` checks every typed number (inline R output is skipped because it’s correct by construction). Also works on a `.docx` downloaded from Google Docs. `strict = TRUE` fails the render |
| You changed code or data and don’t know which sentences to re-read | `cr_ground_truth(res, hyp, path = "results/ground_truth.json")` on every render prints what changed since last time, flagging **sign flips** and **significance changes**. `cr_diff(old, new)` does the same on demand |
| An LLM drafts or checks the prose | Give it `cr_ground_truth(..., path = "ground_truth.md")`: every estimate, its exact reported string, models, and the hypothesis map |

### Failing a render when a claim stops being true

``` r

cr_expect(res, "share", "condition", "Loss", sign = "+", sig = TRUE)
```

If the claim no longer holds,
[`cr_expect()`](https://shayemcd.github.io/clean-results/reference/cr_expect.md)
stops with an error, so a stale sentence never reaches the manuscript.

### Checking typed numbers

``` r

tidy <- cr_tidy(res)
row <- tidy[tidy$dv == "share" & tidy$term == "Loss" & tidy$section == "coefficient", ]
manuscript <- file.path(tempdir(), "paper.qmd")
writeLines(c(
  sprintf("Loss framing raised the odds of sharing (OR = %.2f).", row$estimate),
  "Trust did not change much (b = 9.99)."   # a number that is not in the results
), manuscript)

cr_verify(manuscript, res)
#> 1 number(s) checked: 1 unmatched
#> 
#> Needs a look:
#>  value status    context                               matches
#>  9.99  unmatched Trust did not change much (b = 9.99).
```

[`cr_verify()`](https://shayemcd.github.io/clean-results/reference/cr_verify.md)
can tell that a number exists in the results, not that the sentence
attaches it to the right comparison. That reading check is the LLM’s (or
a co-author’s) job, working from the ground-truth export.

### What changed since the last run

[`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md)
keys each estimate by the name of the results object, so call it on the
same object on every render. Add `hyp` as a second argument to include
the hypothesis map. Here a small model is fitted, exported, and then
fitted again after the data change:

``` r

gt_path <- file.path(tempdir(), "ground_truth.json")

res <- clean_regress(d, dvs = c(share = "logistic"), predictors = ~ condition)
invisible(cr_ground_truth(res, path = gt_path))   # first run: writes the file

# the data change and the document is rendered again: the console reports what moved
res <- clean_regress(d[d$age >= 30, ], dvs = c(share = "logistic"),
                     predictors = ~ condition)
invisible(cr_ground_truth(res, path = gt_path))
#> Results changed since the last export (/tmp/RtmpwOeOgs/ground_truth.json):
#> 3 reported value(s) changed; 0 change direction or significance.
#> 
#> [value changed] res share::(Intercept)
#>   old: OR = 0.74, 95% CI [0.51, 1.06], p = .105
#>   new: OR = 0.73, 95% CI [0.50, 1.09], p = .122
#> 
#> [value changed] res share::condition::Gain
#>   old: OR = 1.06, 95% CI [0.64, 1.75], p = .819
#>   new: OR = 1.14, 95% CI [0.66, 1.96], p = .636
#> 
#> [value changed] res share::condition::Loss
#>   old: OR = 2.33, 95% CI [1.25, 4.32], p = .008
#>   new: OR = 2.41, 95% CI [1.08, 5.38], p = .031
```

A sign flip or a change in significance is flagged separately from a
small change in an estimate. `cr_diff(old, new)` gives the same
comparison on demand.

## Simple tests and Cohen’s d

The simple-test helpers work on a data frame directly. They assume
independent observations, so we use one row per person here.

``` r

p <- d[!duplicated(d$id), ]

cr_d(p, "trust", "condition")                         # every pair of conditions
#> Welch t-test (3 results)
#> p-values adjusted: Holm across pairs; CIs Bonferroni-adjusted for 3 comparisons (98.3% level) 
#>   Trust ~ Condition [Gain vs. Control]
#>     Mdiff = 0.42, 98.3% CI [-0.39, 1.23], t(60.80) = 1.27, p = .417, d = 0.32, 98.3% CI [-0.29, 0.93]
#>   Trust ~ Condition [Loss vs. Control]
#>     Mdiff = -0.45, 98.3% CI [-1.37, 0.48], t(35.81) = -1.21, p = .417, d = -0.36, 98.3% CI [-1.09, 0.37]
#>   Trust ~ Condition [Loss vs. Gain]
#>     Mdiff = -0.86, 98.3% CI [-1.79, 0.06], t(36.24) = -2.36, p = .072, d = -0.68, 98.3% CI [-1.41, 0.06]
cr_d(p, "trust", "condition", pairs = "ref", ref = "Control")
#> Welch t-test (2 results)
#> p-values adjusted: Holm across pairs; CIs Bonferroni-adjusted for 2 comparisons (97.5% level) 
#>   Trust ~ Condition [Gain vs. Control]
#>     Mdiff = 0.42, 97.5% CI [-0.34, 1.17], t(60.80) = 1.27, p = .417, d = 0.32, 97.5% CI [-0.25, 0.89]
#>   Trust ~ Condition [Loss vs. Control]
#>     Mdiff = -0.45, 97.5% CI [-1.31, 0.41], t(35.81) = -1.21, p = .417, d = -0.36, 97.5% CI [-1.04, 0.33]
cr_chisq(p, "share", "condition", pairs = "all")      # chi-square/Fisher, V, pairwise h
#> chi-square (4 results)
#> p-values adjusted: Holm across pairs; CIs Bonferroni-adjusted for 3 comparisons (98.3% level) 
#>   Share ~ Condition
#>     χ²(2, N = 80) = 1.62, p = .444, V = .14
#>   Share ~ Condition [Gain vs. Control]
#>     RD = 0.14, 98.3% CI [-0.16, 0.44], χ²(1, N = 63) = 1.28, p = .776, h = 0.29, 98.3% CI [-0.32, 0.89]
#>   Share ~ Condition [Loss vs. Control]
#>     RD = 0.15, 98.3% CI [-0.20, 0.51], χ²(1, N = 47) = 1.04, p = .776, h = 0.31, 98.3% CI [-0.42, 1.04]
#>   Share ~ Condition [Loss vs. Gain]
#>     RD = 0.01, 98.3% CI [-0.34, 0.36], χ²(1, N = 50) = 0.01, p = .933, h = 0.03, 98.3% CI [-0.69, 0.74]
cr_anova(p, "trust", "condition")                     # F, eta squared
#> ANOVA (1 result)
#>   Trust ~ Condition
#>     F(2, 77) = 2.65, p = .077, η² = .06
cr_cor(p, c("trust", "score", "age"))                 # every pair
#> correlation (3 results)
#>   Trust ~ Score
#>     r(78) = -.24, 95% CI [-.43, -.02], t(78) = -2.15, p = .035
#>   Trust ~ Age
#>     r(78) = -.18, 95% CI [-.38, .04], t(78) = -1.61, p = .111
#>   Score ~ Age
#>     r(78) = .03, 95% CI [-.19, .25], t(78) = 0.26, p = .797
```

``` r

# paired t-test, d_z: the same people at two times
w <- d[d$id %in% levels(d$id)[1:40], ]
w$time <- rep(c("T1", "T2"), length.out = nrow(w))
cr_ttest(w[!duplicated(w[c("id", "time")]), ], "trust", "time", id = "id")
#> paired t-test (1 result)
#>   Trust ~ Time [T2 vs. T1]
#>     Mdiff = -0.33, 95% CI [-0.79, 0.12], t(39) = -1.48, p = .147, d = -0.23, 95% CI [-0.55, 0.08]
```

Model-based *d* for every contrast in a fitted model: `cr_d(res)`. Add a
*d* column to a table with `cr_table(res, effect_size = TRUE)`.

All of these work with
[`cr_inline()`](https://shayemcd.github.io/clean-results/reference/cr_inline.md),
[`cr_sentence()`](https://shayemcd.github.io/clean-results/reference/cr_sentence.md),
[`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md),
[`cr_h()`](https://shayemcd.github.io/clean-results/reference/cr_h.md),
[`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md),
and
[`cr_verify()`](https://shayemcd.github.io/clean-results/reference/cr_verify.md).
Pairwise *p*-values are Holm-adjusted across pairs by default
(`adjust`); `dv_adjust` corrects across outcomes. When `adjust` is on,
CIs (including *d*’s) are Bonferroni-adjusted to match and reported as,
for example, “98.3% CI” for three pairs, so a CI that excludes zero
always comes with a significant adjusted *p*. *d*, *g*, and *d_z* (with
CIs) match the `effectsize` package.
