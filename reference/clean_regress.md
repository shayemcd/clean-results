# Fit regressions for one or more outcomes and collect publication-ready results

Fits one model per dependent variable (linear, logistic, Poisson,
negative binomial, or ordinal; each also as a mixed model or a Bayesian
brms model), computes robust or model-based inference, keeps reference
categories as explicit rows, optionally adds pairwise contrasts, and
applies multiple-comparison corrections within factors and/or across
outcomes. Render the result with
[`cr_table()`](https://shayemcd.github.io/clean-results/reference/cr_table.md)
(or just print it in a Quarto chunk), save it with
[`cr_save()`](https://shayemcd.github.io/clean-results/reference/cr_save.md),
and cite numbers in text with
[`cr_inline()`](https://shayemcd.github.io/clean-results/reference/cr_inline.md).

## Usage

``` r
clean_regress(
  data,
  dvs,
  predictors = NULL,
  random = NULL,
  formulas = NULL,
  type = NULL,
  cluster = NULL,
  se = c("robust", "model"),
  contrasts = NULL,
  contrast_adjust = "holm",
  dv_adjust = "none",
  dv_adjust_terms = NULL,
  exponentiate = TRUE,
  conf_level = 0.95,
  labels = NULL,
  level_labels = NULL,
  dv_labels = NULL,
  clean_labels = TRUE,
  label_case = "sentence",
  intercept = TRUE,
  baseline = NULL,
  lin = NULL,
  contrast_by = NULL,
  fit_args = list()
)
```

## Arguments

- data:

  A data frame.

- dvs:

  Named character vector mapping each outcome to a model type, e.g.
  `c(trust = "linear", donated = "logistic", liking = "ordinal")`.
  Types: `"linear"`, `"logistic"`, `"poisson"` (counts, or Poisson
  quasi-ML for skewed non-negative outcomes: ratio of means), `"negbin"`
  (overdispersed counts), `"ordinal"` (cumulative logit via
  [`ordinal::clm`](https://rdrr.io/pkg/ordinal/man/clm.html); `"polr"`
  is an alias, same model). Each becomes its mixed version when `random`
  is given (`lmer`, `glmer`, `glmmTMB` negative binomial,
  [`ordinal::clmm`](https://rdrr.io/pkg/ordinal/man/clmm.html)).
  Bayesian versions via brms: `"bayes_linear"`, `"bayes_logistic"`,
  `"bayes_ordinal"`, `"bayes_poisson"`, `"bayes_negbin"` (with or
  without `random`; pass priors, chains, iter, etc. in `fit_args`). An
  unnamed vector of outcome names is allowed when `type` is supplied.

- predictors:

  One-sided formula (`~ condition + age`) or character vector of
  predictor terms shared by all outcomes.

- random:

  Random-effects term(s) for mixed models, e.g. `~ (1 | id)`.

- formulas:

  Optional named list of full formulas that override
  `predictors`/`random` for specific outcomes.

- type:

  Model type used for every outcome when `dvs` is unnamed.

- cluster:

  Column name to cluster robust SEs on. Defaults to the first grouping
  factor for mixed models and to none (HC3) for lm/logit.

- se:

  `"robust"` (default; HC3, or CR2 when clustered or mixed) or
  `"model"`.

- contrasts:

  Pairwise contrasts: `NULL` (none), `TRUE` (every factor predictor with
  3+ levels), or a character vector of factor names.

- contrast_adjust:

  Correction across the pairwise contrasts of each factor (any `emmeans`
  adjust method: `"holm"`, `"tukey"`, `"bonferroni"`, `"fdr"`, `"none"`,
  ...).

- dv_adjust:

  Correction across outcomes, applied to each row separately (the same
  coefficient or contrast across all outcomes is one family). Any
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html) method;
  `"none"` by default.

- dv_adjust_terms:

  Variables whose rows get the across-outcome correction. `NULL` means
  every non-intercept row.

- exponentiate:

  Report ratios: odds ratios (logistic), cumulative odds ratios
  (ordinal), incidence rate ratios (Poisson, negative binomial).

- conf_level:

  Confidence level.

- labels:

  Named vector of display labels for predictors, e.g.
  `c(condition = "Framing condition")`. Unlisted names are cleaned
  automatically (see `clean_labels`).

- level_labels:

  Display labels for factor levels: a named vector applied to every
  factor (`c(GainFraming = "Gain frame")`) or a list per factor
  (`list(condition = c(GainFraming = "Gain frame"))`).

- dv_labels:

  Named vector of display labels for outcomes.

- clean_labels:

  Tidy names that have no explicit label: `GainFraming` -\> "Gain
  framing", `age_years` -\> "Age years". See
  [`clean_label()`](https://shayemcd.github.io/clean-results/reference/clean_label.md).

- label_case:

  Case for cleaned labels: `"sentence"`, `"title"`, or `"asis"`.

- intercept:

  Show the intercept row.

- baseline:

  Pre-treatment measure of each outcome, added as a covariate centered
  on the analysis sample (ANCOVA): a named vector
  `c(trust = "trust_pre")`, or one column for every outcome.

- lin:

  Treatment variable(s) to interact with the centered baseline (the Lin,
  2013 estimator); treatment rows then estimate the effect at the mean
  baseline.

- contrast_by:

  A moderator: pairwise contrasts are computed within each of its levels
  (simple effects), adjusted within each level.

- fit_args:

  List of extra arguments passed to every model fitter, e.g.
  `list(control = lme4::glmerControl(optimizer = "bobyqa"))`.

## Value

An object of class `clean_results`.

## Examples

``` r
if (FALSE) { # \dontrun{
res <- clean_regress(
  d,
  dvs = c(trust = "linear", donated = "logistic"),
  predictors = ~ condition + age,
  random = ~ (1 | id),
  contrasts = "condition",
  dv_adjust = "holm"
)
res
cr_save(res, "tables/table2.docx")
} # }
```
