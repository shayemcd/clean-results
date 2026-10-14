# Methods defaults and reporting conventions

This page states what cleanresults computes by default, so you can
describe it accurately in a methods section. Each table’s note also
states which of these applied to that table.

## Standard errors

| Model | `se = "robust"` (default) | `se = "model"` |
|----|----|----|
| lm | HC3; CR2 + Satterthwaite df if `cluster` is set | OLS SEs |
| logit | HC3 (z); CR2 if `cluster` is set | Wald z |
| lmer | CR2 clustered on the first grouping factor (or `cluster`), Satterthwaite df | Satterthwaite (lmerTest) |
| Poisson, negative binomial | HC3 (z); CR2 if `cluster` is set | Wald z |
| ordinal (clm) | sandwich SEs; cluster-robust if `cluster` is set | Wald z |
| glmer, Poisson/negbin/ordinal mixed | **Model-based Wald z.** No small-sample cluster-robust estimator exists for these, and the table note says so | Wald z |
| Bayesian (brms) | Posterior median, MAD, equal-tailed 95% credible interval, probability of direction (*pd*); not adjusted for multiple comparisons | same |

## Reporting conventions

- **Logistic models** report odds ratios. CIs are exponentiated from the
  log-odds scale. In the SE style, SEs are delta-method SEs.
- **Pairwise contrasts** compare estimated marginal means, averaged over
  the other predictors, using the same covariance matrix as the
  coefficients. `contrast_adjust` adjusts their *p*-values and CIs
  within each factor.
- **The across-outcome correction** (`dv_adjust`) treats each row as one
  family across outcomes, and widens those rows’ CIs to match
  (Bonferroni across the outcomes, on top of any within-factor
  adjustment). Text output prints each CI’s real level, for example
  “98.3% CI” for a Holm-adjusted contrast among three conditions. The
  three “Gain” *p*-values for three outcomes are corrected together.
  When both corrections are on, contrasts are adjusted within the factor
  first and then across outcomes, which is conservative.
  [`cr_tidy()`](https://shayemcd.github.io/clean-results/reference/cr_tidy.md)
  keeps both `p.within` and the final `p.value`.
- **Fit block:** *N*, random-effect variances, adjusted ICC, Nakagawa
  marginal and conditional *R*² for random-intercept models, *R*² (lm),
  Tjur *R*² (logit), and AIC.
- **Missing data:** each model uses complete cases on its own variables.
  *N* is reported per model.

## Effect sizes

- *d*, *g*, and *d_z* (with CIs) from the simple-test helpers match the
  `effectsize` package.
- When `adjust` is on, CIs (including *d*’s) are Bonferroni-adjusted to
  match the corrected *p*-values, so a CI that excludes zero always
  comes with a significant adjusted *p*.
- Model-based *d* (`cr_d(res)`, `cr_table(res, effect_size = TRUE)`)
  divides by the pooled within-group SD of the outcome for linear
  models, so covariates don’t inflate it. For mixed models it divides by
  the total SD of one observation: the residual variance plus the
  variance the random effects add, random slopes included.

## What the checks can and can’t do

[`cr_verify()`](https://shayemcd.github.io/clean-results/reference/cr_verify.md)
can tell that a number exists in the results, not that the sentence
attaches it to the right comparison.
[`cr_expect()`](https://shayemcd.github.io/clean-results/reference/cr_expect.md)
checks the sign and significance of the estimate you name. Neither
replaces reading the results; they catch drift between the analysis and
the text.
