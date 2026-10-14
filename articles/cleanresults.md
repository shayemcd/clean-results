# Getting started with cleanresults

One call fits regressions for several outcomes and gives back one
publication-ready table. This guide covers fitting, the model types, the
table options, and where the table goes. The other guides cover [results
text and drift
checks](https://shayemcd.github.io/clean-results/articles/results-text.md),
[figures](https://shayemcd.github.io/clean-results/articles/figures.md),
and the [methods
defaults](https://shayemcd.github.io/clean-results/articles/methods.md).

## Fit models and get a table

``` r

library(cleanresults)

d <- cr_example_data()   # simulated: 80 people x 4 observations

res <- clean_regress(
  d,
  dvs = c(trust = "linear", share = "logistic", bought = "logistic"),
  predictors = ~ condition + age,
  random = ~ (1 | id),                # makes "linear"/"logistic" mixed models
  contrasts = "condition",            # pairwise contrasts
  contrast_adjust = "holm",           # correction within factor
  dv_adjust = "holm",                 # correction across outcomes
  dv_adjust_terms = "condition",      # ...only for condition rows
  labels = c(condition = "Condition", age = "Age (years)"),
  dv_labels = c(trust = "Trust", share = "Shared", bought = "Bought")
)
#> Registered S3 method overwritten by 'clubSandwich':
#>   method    from    
#>   bread.mlm sandwich

res
```

|  | Trust |  |  | Shared |  |  | Bought |  |  |
|----|----|----|----|----|----|----|----|----|----|
|  | Linear mixed |  |  | Logistic mixed |  |  | Logistic mixed |  |  |
|  | b | 95% CI | p | OR | 95% CI | p | OR | 95% CI | p |
| Intercept | 4.27 | \[3.43, 5.10\] | \< .001 | 0.83 | \[0.32, 2.13\] | .691 | 0.66 | \[0.24, 1.80\] | .419 |
| Condition |  |  |  |  |  |  |  |  |  |
| Control (ref.) | — |  |  | — |  |  | — |  |  |
| Gain | 0.42 | \[-0.19, 1.02\] | .286 | 1.06 | \[0.54, 2.07\] | 1.000 | 1.12 | \[0.55, 2.27\] | 1.000 |
| Loss | -0.30 | \[-1.04, 0.43\] | .608 | 2.39 | \[1.05, 5.44\] | .035 | 0.90 | \[0.38, 2.12\] | .770 |
| Age (years) | -0.02 | \[-0.04, 0.00\] | .025 | 1.00 | \[0.98, 1.02\] | .780 | 1.02 | \[0.99, 1.04\] | .177 |
| Pairwise contrasts |  |  |  |  |  |  |  |  |  |
| Condition |  |  |  |  |  |  |  |  |  |
| Gain vs. Control | 0.42 | \[-0.28, 1.11\] | .565 | 1.06 | \[0.49, 2.30\] | 1.000 | 1.12 | \[0.49, 2.54\] | 1.000 |
| Loss vs. Control | -0.30 | \[-1.14, 0.53\] | .599 | 2.39 | \[0.92, 6.20\] | .105 | 0.90 | \[0.33, 2.43\] | 1.000 |
| Loss vs. Gain | -0.72 | \[-1.59, 0.15\] | .127 | 2.25 | \[0.88, 5.75\] | .105 | 0.81 | \[0.30, 2.15\] | 1.000 |
| Random effects |  |  |  |  |  |  |  |  |  |
| σ² | 1.06 |  |  | 3.29 |  |  | 3.29 |  |  |
| τ₀₀ (ID) | 0.72 |  |  | 0.16 |  |  | 0.29 |  |  |
| ICC | 0.40 |  |  | 0.05 |  |  | 0.08 |  |  |
| N (ID) | 80 |  |  | 80 |  |  | 80 |  |  |
| Model fit |  |  |  |  |  |  |  |  |  |
| Observations | 320 |  |  | 320 |  |  | 320 |  |  |
| Marginal R² | 0.07 |  |  | 0.03 |  |  | 0.01 |  |  |
| Conditional R² | 0.44 |  |  | 0.08 |  |  | 0.09 |  |  |
| AIC | 1050.56 |  |  | 443.27 |  |  | 445.04 |  |  |
| Note. b = unstandardized coefficient; OR = odds ratio; CI = confidence interval. CIs and p-values use CR2 cluster-robust SEs clustered by ID with Satterthwaite df (Trust); model-based (Wald) SEs (Shared, Bought). Robust SEs are not available for logistic mixed models, so those models use model-based Wald SEs. (ref.) marks the reference category for each factor. Pairwise contrasts compare estimated marginal means averaged over other predictors (ratios for logistic, ordinal, and count models); their p-values are Holm-adjusted and their CIs Bonferroni-adjusted within each factor. p-values and CIs for Condition are additionally Holm-adjusted across the 3 outcomes. |  |  |  |  |  |  |  |  |  |

The table has robust SEs by default, reference categories as rows,
pairwise contrasts with a correction within each factor, an optional
correction across outcomes, and a methods note that states exactly which
SEs and corrections were used. Use
`formulas = list(outcome = outcome ~ other_predictors)` to give one
outcome a different set of predictors.

## Model types

`"linear"`, `"logistic"`, `"poisson"`, `"negbin"`, and `"ordinal"`
become mixed models automatically when you give `random`.

| Type | No `random` | With `random` | Reported as |
|----|----|----|----|
| `"linear"` | `lm` | [`lmerTest::lmer`](https://rdrr.io/pkg/lmerTest/man/lmer.html) | *b* |
| `"logistic"` | `glm` binomial | [`lme4::glmer`](https://rdrr.io/pkg/lme4/man/glmer.html) | OR |
| `"poisson"` | `glm` Poisson (also Poisson quasi-ML for skewed non-negative outcomes such as miles driven) | `glmer` Poisson | IRR (ratio of means) |
| `"negbin"` | [`MASS::glm.nb`](https://rdrr.io/pkg/MASS/man/glm.nb.html) | `glmmTMB` nbinom2 | IRR |
| `"ordinal"` (alias `"polr"`) | [`ordinal::clm`](https://rdrr.io/pkg/ordinal/man/clm.html) | [`ordinal::clmm`](https://rdrr.io/pkg/ordinal/man/clmm.html) | cumulative OR |
| `"bayes_linear"`, `"bayes_logistic"`, `"bayes_ordinal"`, `"bayes_poisson"`, `"bayes_negbin"` | `brms::brm` | `brms::brm` | posterior median, 95% CrI, *pd* |

`"polr"` fits the same proportional-odds model as
[`MASS::polr`](https://rdrr.io/pkg/MASS/man/polr.html), through
[`ordinal::clm`](https://rdrr.io/pkg/ordinal/man/clm.html) because it
supports robust SEs and mixed versions. Bayesian models take priors and
sampler settings through `fit_args`, for example
`fit_args = list(prior = brms::prior(normal(0, 1), class = "b"), chains = 4, iter = 4000)`.
The optional packages (`lme4`, `lmerTest`, `ordinal`, `glmmTMB`, `brms`)
are only needed for the model types that use them.

### Baseline adjustment, simple effects, equivalence

``` r

set.seed(1)
d$trust_pre <- d$trust + rnorm(nrow(d))

# ANCOVA with the baseline centered; add lin = "condition" for Lin (2013)
clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
              baseline = c(trust = "trust_pre"))
```

|  | Trust |  |  |
|----|----|----|----|
|  | Linear |  |  |
|  | b | 95% CI | p |
| Intercept | 3.46 | \[3.31, 3.61\] | \< .001 |
| Condition |  |  |  |
| Control (ref.) | — |  |  |
| Gain | 0.18 | \[-0.02, 0.38\] | .078 |
| Loss | -0.08 | \[-0.31, 0.15\] | .501 |
| Baseline (centered) | 0.66 | \[0.61, 0.71\] | \< .001 |
| Model fit |  |  |  |
| Observations | 320 |  |  |
| R² | 0.67 |  |  |
| AIC | 759.75 |  |  |
| Note. b = unstandardized coefficient; CI = confidence interval. CIs and p-values use HC3 robust SEs. (ref.) marks the reference category for each factor. |  |  |  |

``` r

# simple effects of condition within each level of female
clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition * female,
              contrasts = "condition", contrast_by = "female")
```

|  | Trust |  |  |
|----|----|----|----|
|  | Linear |  |  |
|  | b | 95% CI | p |
| Intercept | 3.05 | \[2.74, 3.35\] | \< .001 |
| Condition |  |  |  |
| Control (ref.) | — |  |  |
| Gain | 0.63 | \[0.22, 1.04\] | .003 |
| Loss | 0.31 | \[-0.19, 0.82\] | .218 |
| Female | 0.81 | \[0.38, 1.24\] | \< .001 |
| Gain × Female | -0.37 | \[-1.07, 0.32\] | .289 |
| Loss × Female | -1.68 | \[-2.44, -0.92\] | \< .001 |
| Pairwise contrasts |  |  |  |
| Condition (Female: FALSE) |  |  |  |
| Gain vs. Control | 0.63 | \[0.13, 1.13\] | .008 |
| Loss vs. Control | 0.31 | \[-0.30, 0.93\] | .401 |
| Loss vs. Gain | -0.32 | \[-0.91, 0.28\] | .401 |
| Condition (Female: TRUE) |  |  |  |
| Gain vs. Control | 0.26 | \[-0.43, 0.94\] | .369 |
| Loss vs. Control | -1.37 | \[-2.07, -0.67\] | \< .001 |
| Loss vs. Gain | -1.62 | \[-2.45, -0.80\] | \< .001 |
| Model fit |  |  |  |
| Observations | 320 |  |  |
| R² | 0.09 |  |  |
| AIC | 1087.98 |  |  |
| Note. b = unstandardized coefficient; CI = confidence interval. CIs and p-values use HC3 robust SEs. (ref.) marks the reference category for each factor. Pairwise contrasts within each level of female compare estimated marginal means averaged over other predictors; their p-values are Holm-adjusted and their CIs Bonferroni-adjusted within each factor and moderator level. |  |  |  |

``` r

# two one-sided tests against bounds of +/- 0.2 outcome units
eq <- cr_equivalence(res, bounds = 0.2, dv = "trust", variable = "condition")
eq
#> equivalence (TOST) (3 results)
#>   Trust ~ Condition [Gain vs. Control]
#>     b = 0.42, 90% CI [0.01, 0.82], t(76.00) = 0.88, p = .809
#>   Trust ~ Condition [Loss vs. Control]
#>     b = -0.30, 90% CI [-0.79, 0.18], t(76.00) = -0.36, p = .639
#>   Trust ~ Condition [Loss vs. Gain]
#>     b = -0.72, 90% CI [-1.23, -0.21], t(76.00) = -1.70, p = .953
```

For ratio-scale outcomes pass `bounds = c(0.8, 1.25)`. To test in *d*
units, pass a
[`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md)
result with `scale = "d"`.

## Table options

Start from a preset and override any piece.

| `style` | `uncertainty` | `p` | `layout` | Looks like |
|----|----|----|----|----|
| `"apa"` (default) | `"ci"` | `"value"` | `"columns"` | `b` · `95% CI` · `p` columns |
| `"stargazer"` | `"se"` | `"stars"` | `"stacked"` | `0.46*` with `(0.21)` on the line below |
| `"compact"` | `"ci"` | `"stars"` | `"inline"` | `0.46* [0.04, 0.89]` in one cell |

``` r

cr_table(res, uncertainty = "se", layout = "inline", p = "stars")
```

|  | Trust | Shared | Bought |
|----|----|----|----|
|  | Linear mixed | Logistic mixed | Logistic mixed |
|  | b (SE) | OR (SE) | OR (SE) |
| Intercept | 4.27\*\*\* (0.41) | 0.83 (0.40) | 0.66 (0.34) |
| Condition |  |  |  |
| Control (ref.) | — | — | — |
| Gain | 0.42 (0.24) | 1.06 (0.30) | 1.12 (0.33) |
| Loss | -0.30 (0.29) | 2.39\* (0.82) | 0.90 (0.32) |
| Age (years) | -0.02\* (0.01) | 1.00 (0.01) | 1.02 (0.01) |
| Pairwise contrasts |  |  |  |
| Condition |  |  |  |
| Gain vs. Control | 0.42 (0.24) | 1.06 (0.30) | 1.12 (0.33) |
| Loss vs. Control | -0.30 (0.29) | 2.39 (0.82) | 0.90 (0.32) |
| Loss vs. Gain | -0.72 (0.31) | 2.25 (0.76) | 0.81 (0.28) |
| Random effects |  |  |  |
| σ² | 1.06 | 3.29 | 3.29 |
| τ₀₀ (ID) | 0.72 | 0.16 | 0.29 |
| ICC | 0.40 | 0.05 | 0.08 |
| N (ID) | 80 | 80 | 80 |
| Model fit |  |  |  |
| Observations | 320 | 320 | 320 |
| Marginal R² | 0.07 | 0.03 | 0.01 |
| Conditional R² | 0.44 | 0.08 | 0.09 |
| AIC | 1050.56 | 443.27 | 445.04 |
| Note. b = unstandardized coefficient; OR = odds ratio; SE = standard error. SEs and p-values use CR2 cluster-robust SEs clustered by ID with Satterthwaite df (Trust); model-based (Wald) SEs (Shared, Bought). Robust SEs are not available for logistic mixed models, so those models use model-based Wald SEs. Standard errors in parentheses (delta-method SEs for ratios). (ref.) marks the reference category for each factor. Pairwise contrasts compare estimated marginal means averaged over other predictors (ratios for logistic, ordinal, and count models); their p-values are Holm-adjusted and their CIs Bonferroni-adjusted within each factor. p-values and CIs for Condition are additionally Holm-adjusted across the 3 outcomes. \* p \< .05. \*\* p \< .01. \*\*\* p \< .001. |  |  |  |

``` r

cr_table(res, style = "stargazer", fit = FALSE)
```

|  | Trust | Shared | Bought |
|----|----|----|----|
|  | Linear mixed | Logistic mixed | Logistic mixed |
|  | b | OR | OR |
| Intercept | 4.27\*\*\* | 0.83 | 0.66 |
|  | (0.41) | (0.40) | (0.34) |
| Condition |  |  |  |
| Control (ref.) | — | — | — |
| Gain | 0.42 | 1.06 | 1.12 |
|  | (0.24) | (0.30) | (0.33) |
| Loss | -0.30 | 2.39\* | 0.90 |
|  | (0.29) | (0.82) | (0.32) |
| Age (years) | -0.02\* | 1.00 | 1.02 |
|  | (0.01) | (0.01) | (0.01) |
| Pairwise contrasts |  |  |  |
| Condition |  |  |  |
| Gain vs. Control | 0.42 | 1.06 | 1.12 |
|  | (0.24) | (0.30) | (0.33) |
| Loss vs. Control | -0.30 | 2.39 | 0.90 |
|  | (0.29) | (0.82) | (0.32) |
| Loss vs. Gain | -0.72 | 2.25 | 0.81 |
|  | (0.31) | (0.76) | (0.28) |
| Random effects |  |  |  |
| σ² | 1.06 | 3.29 | 3.29 |
| τ₀₀ (ID) | 0.72 | 0.16 | 0.29 |
| ICC | 0.40 | 0.05 | 0.08 |
| N (ID) | 80 | 80 | 80 |
| Note. b = unstandardized coefficient; OR = odds ratio; SE = standard error. SEs and p-values use CR2 cluster-robust SEs clustered by ID with Satterthwaite df (Trust); model-based (Wald) SEs (Shared, Bought). Robust SEs are not available for logistic mixed models, so those models use model-based Wald SEs. Standard errors in parentheses (delta-method SEs for ratios). (ref.) marks the reference category for each factor. Pairwise contrasts compare estimated marginal means averaged over other predictors (ratios for logistic, ordinal, and count models); their p-values are Holm-adjusted and their CIs Bonferroni-adjusted within each factor. p-values and CIs for Condition are additionally Holm-adjusted across the 3 outcomes. \* p \< .05. \*\* p \< .01. \*\*\* p \< .001. |  |  |  |

Other useful arguments: `p = "both"` (stars and a *p* column),
`fit = FALSE` (no fit block), `random = FALSE` (no random-effect rows),
and `effect_size = TRUE` (a Cohen’s *d* column).

### Contrasts: same table or separate

``` r

cr_table(res, contrasts = "exclude")   # main table without the contrasts
```

|  | Trust |  |  | Shared |  |  | Bought |  |  |
|----|----|----|----|----|----|----|----|----|----|
|  | Linear mixed |  |  | Logistic mixed |  |  | Logistic mixed |  |  |
|  | b | 95% CI | p | OR | 95% CI | p | OR | 95% CI | p |
| Intercept | 4.27 | \[3.43, 5.10\] | \< .001 | 0.83 | \[0.32, 2.13\] | .691 | 0.66 | \[0.24, 1.80\] | .419 |
| Condition |  |  |  |  |  |  |  |  |  |
| Control (ref.) | — |  |  | — |  |  | — |  |  |
| Gain | 0.42 | \[-0.19, 1.02\] | .286 | 1.06 | \[0.54, 2.07\] | 1.000 | 1.12 | \[0.55, 2.27\] | 1.000 |
| Loss | -0.30 | \[-1.04, 0.43\] | .608 | 2.39 | \[1.05, 5.44\] | .035 | 0.90 | \[0.38, 2.12\] | .770 |
| Age (years) | -0.02 | \[-0.04, 0.00\] | .025 | 1.00 | \[0.98, 1.02\] | .780 | 1.02 | \[0.99, 1.04\] | .177 |
| Random effects |  |  |  |  |  |  |  |  |  |
| σ² | 1.06 |  |  | 3.29 |  |  | 3.29 |  |  |
| τ₀₀ (ID) | 0.72 |  |  | 0.16 |  |  | 0.29 |  |  |
| ICC | 0.40 |  |  | 0.05 |  |  | 0.08 |  |  |
| N (ID) | 80 |  |  | 80 |  |  | 80 |  |  |
| Model fit |  |  |  |  |  |  |  |  |  |
| Observations | 320 |  |  | 320 |  |  | 320 |  |  |
| Marginal R² | 0.07 |  |  | 0.03 |  |  | 0.01 |  |  |
| Conditional R² | 0.44 |  |  | 0.08 |  |  | 0.09 |  |  |
| AIC | 1050.56 |  |  | 443.27 |  |  | 445.04 |  |  |
| Note. b = unstandardized coefficient; OR = odds ratio; CI = confidence interval. CIs and p-values use CR2 cluster-robust SEs clustered by ID with Satterthwaite df (Trust); model-based (Wald) SEs (Shared, Bought). Robust SEs are not available for logistic mixed models, so those models use model-based Wald SEs. (ref.) marks the reference category for each factor. p-values and CIs for Condition are additionally Holm-adjusted across the 3 outcomes. |  |  |  |  |  |  |  |  |  |

``` r

cr_contrast_table(res)                 # contrasts in their own table
```

|  | Trust |  |  | Shared |  |  | Bought |  |  |
|----|----|----|----|----|----|----|----|----|----|
|  | Linear mixed |  |  | Logistic mixed |  |  | Logistic mixed |  |  |
|  | Diff. | 95% CI | p | OR | 95% CI | p | OR | 95% CI | p |
| Condition |  |  |  |  |  |  |  |  |  |
| Gain vs. Control | 0.42 | \[-0.28, 1.11\] | .565 | 1.06 | \[0.49, 2.30\] | 1.000 | 1.12 | \[0.49, 2.54\] | 1.000 |
| Loss vs. Control | -0.30 | \[-1.14, 0.53\] | .599 | 2.39 | \[0.92, 6.20\] | .105 | 0.90 | \[0.33, 2.43\] | 1.000 |
| Loss vs. Gain | -0.72 | \[-1.59, 0.15\] | .127 | 2.25 | \[0.88, 5.75\] | .105 | 0.81 | \[0.30, 2.15\] | 1.000 |
| Note. Diff. = difference in estimated marginal means; OR = ratio of odds; CI = confidence interval. CIs and p-values use CR2 cluster-robust SEs clustered by ID with Satterthwaite df (Trust); model-based (Wald) SEs (Shared, Bought). Robust SEs are not available for logistic mixed models, so those models use model-based Wald SEs. Contrasts compare estimated marginal means averaged over other predictors (ratios for logistic, ordinal, and count models); their p-values are Holm-adjusted and their CIs Bonferroni-adjusted within each factor. p-values and CIs for Condition are additionally Holm-adjusted across the 3 outcomes. |  |  |  |  |  |  |  |  |  |

The note under each table only describes what that table shows.

### Clean labels

Names are cleaned automatically: `GainFraming` becomes “Gain framing”,
`age_years` becomes “Age years”, `Loss-Framing` becomes “Loss framing”,
and `participant_id` becomes “Participant ID”. Number ranges keep a dash
(`18-24` becomes “18–24”), and capitalized acronyms like `SES` stay as
they are.

``` r

clean_label("GainFraming")
#> [1] "Gain framing"
clean_label("participant_id")
#> [1] "Participant ID"
clean_label("18-24")
#> [1] "18–24"
```

Override any of them with `labels` (predictors and outcomes),
`level_labels` (factor levels, as a named list per factor), and
`dv_labels`. Use `label_case = "sentence"`, `"title"`, or `"asis"`, and
`clean_labels = FALSE` to show raw names.

## Where the table goes

| Destination | How |
|----|----|
| **Quarto / R Markdown** | Put `cr_table(res)` in a chunk with `#| label: tbl-main` and `#| tbl-cap: "..."`, then cite it with `@tbl-main`. It renders natively to HTML, Word and PDF. |
| **Overleaf** | `cr_save(res, "table1.tex", caption = "...", label = "tab:main")`, then `\input{table1.tex}`. The preamble needs `\usepackage{booktabs}` and `\usepackage{threeparttable}`. Compiles with pdfLaTeX. |
| **Word** | `cr_save(res, "table1.docx")` gives a native Word table (APA booktabs look, Times New Roman). Add `landscape = TRUE` for wide tables. |
| **Google Docs** | Upload the `.docx` to Drive and choose *Open with Google Docs*. Or save `.html`, open it in a browser, select the table and paste. |
| **Anything else** | `cr_save(res, "table1.csv")` for the formatted cells, or `cr_tidy(res)` for the raw numbers. |

``` r

out <- tempdir()
cr_save(res, file.path(out, "table1.tex"), caption = "Effects of condition",
        label = "tab:main")
cr_save(res, file.path(out, "table1.docx"))
cr_save(res, file.path(out, "table1.html"))
cr_save(res, file.path(out, "table1.csv"))
list.files(out, pattern = "^table1")
#> [1] "table1.csv"  "table1.docx" "table1.html" "table1.tex"
```

To save a specific layout, pass a `cr_table`:
`cr_save(cr_table(res, style = "stargazer"), "table1.tex")` or
`cr_save(cr_contrast_table(res), "table2.docx")`.

The raw numbers behind every table:

``` r

head(cr_tidy(res))
#>      dv  section    variable            level             term            label
#> 1 trust    fixed (Intercept)             <NA>      (Intercept)        Intercept
#> 2 trust    fixed   condition          Control             <NA>   Control (ref.)
#> 3 trust    fixed   condition             Gain    conditionGain             Gain
#> 4 trust    fixed   condition             Loss    conditionLoss             Loss
#> 5 trust    fixed         age             <NA>              age      Age (years)
#> 6 trust contrast   condition Gain vs. Control Gain vs. Control Gain vs. Control
#>   is_ref   estimate   std.error statistic       df    conf.low    conf.high
#> 1  FALSE  4.2650619 0.406192068 10.500111 27.49249  3.43232263  5.097801127
#> 2   TRUE         NA          NA        NA       NA          NA           NA
#> 3  FALSE  0.4150165 0.244869393  1.694848 59.92341 -0.18810751  1.018140536
#> 4  FALSE -0.3044150 0.291382874 -1.044725 32.80557 -1.03957720  0.430747225
#> 5  FALSE -0.0217106 0.008986676 -2.415865 20.86963 -0.04040652 -0.003014671
#> 6  FALSE  0.4150165 0.244869393  1.694848 76.00000 -0.28392164  1.113954666
#>       p.within      p.value dv_adjusted model_type estimate_type
#> 1 4.005541e-11 4.005541e-11       FALSE       lmer             b
#> 2           NA           NA       FALSE       lmer             b
#> 3 9.529545e-02 2.858863e-01        TRUE       lmer             b
#> 4 3.037875e-01 6.075750e-01        TRUE       lmer             b
#> 5 2.495395e-02 2.495395e-02       FALSE       lmer             b
#> 6 1.883963e-01 5.651890e-01        TRUE       lmer             b
```
