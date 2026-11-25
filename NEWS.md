# cleanresults 0.2.0

## Bug fixes

* Factor levels with no observations in a model's sample (for example a
  condition that only another study had) are now dropped before fitting, so
  they get no table rows, contrasts, or plot categories. Before, they showed as
  blank rows, and an empty *reference* level silently shifted the labels: each
  estimate was printed against the wrong level. When the reference level is
  empty, the next level becomes the reference and a message says so.

* Pairwise contrasts, `cr_plot_means()` brackets and CIs, and
  `cr_plot_interaction()` CIs now use the CR2 Satterthwaite *df* whenever the
  coefficients do (all mixed linear models, and lm/logit/Poisson/negative
  binomial models with `cluster`). Before, `emmeans` received the CR2 matrix
  but kept the model's own *df* (model-based Satterthwaite for `lmer`,
  residual *df* for `lm`, *z* for `glm`), so with few clusters these outputs
  were too liberal and could disagree with the identical coefficient row (for
  example a bracket showing *** next to a table *p* of .068).

## New

* `clean_regress()` gains `d_method` to choose how *d* is standardized, with
  the source of each documented in `?clean_regress` ("Standardized
  differences (d)"): `"adjusted"` (default), `"baseline"`, `"dppc2"`,
  `"partial"`, or `"none"`, plus `d_sd` for an external SD. `cr_d()` takes the
  same arguments to recompute *d* without refitting, and the table note names
  the method and its reference.
  * `"adjusted"`: linear *d* is now Hedges' *g*, the covariate-adjusted
    difference over the pooled within-group SD of the outcome times Hedges'
    small-sample correction (What Works Clearinghouse, 2022; Olejnik &
    Algina, 2000). Before, it had no correction, so linear *d* shrinks by a
    factor of c(N - k): about 3% at N = 30, under 0.3% at N = 300.
    Logistic and ordinal *d* now also adds the variance of the other fixed
    effects' linear predictor to the latent variance, so covariates no longer
    make *d* larger (Nakagawa & Schielzeth, 2013); with no covariates it is
    unchanged.
  * `"baseline"`: for linear models with a `baseline`, the adjusted
    difference over the Hedges-corrected pooled pre-treatment SD (the
    denominator of `d_ppc2`, Morris, 2008).
  * `"dppc2"`: Morris's (2008) `d_ppc2` itself, the difference in mean
    pre-post change over the pooled pre-treatment SD, on complete pre/post
    pairs, with CIs from his sampling variance.
  * `"partial"`: over the residual SD (for logistic and ordinal, over
    \eqn{\pi/\sqrt{3}} alone, Chinn, 2000).
* `clean_regress()` gains `vcov_type` to choose the heteroskedasticity-consistent
  estimator (`"HC3"` by default, or `"HC1"`, `"HC0"`, `"HC2"`, `"HC4"`) for
  unclustered robust SEs; the table note names the estimator used. Clustered and
  mixed models still use CR2.
* `clean_regress()` drops rows whose numeric outcome is `Inf` or `-Inf` (for
  example a percent change from a zero baseline), as it already did for `NA`,
  instead of letting `lm()` stop with an error.
* `cr_table()` notes how many CR2 tests have Satterthwaite *df* below 4.
* Model-based *d* (`cr_d()`, `cr_table(effect_size = TRUE)`) now covers logistic
  and ordinal (cumulative logit) models, for factor levels and contrasts. *d* is
  the log odds ratio divided by the latent logistic SD, \eqn{\pi/\sqrt{3}}
  (Chinn, 2000); mixed models (`glmer`, `clmm`) add the random-effect variance,
  as for linear mixed models. Other links and Poisson / negative binomial models
  have no *d*. CIs follow the estimate when adjusted across outcomes.
* The table note now describes only the kinds of *d* the table shows, and says the
  logistic/ordinal *d* is an approximation. New `cr_d_note()` returns the same note
  for *d* reported in prose or figures; `cr_d()` carries it as `attr(, "note")`.

# cleanresults 0.1.0

First public release.

## Tables

* `clean_regress()` fits linear, logistic, Poisson, negative binomial, ordinal,
  and Bayesian (brms) models for one or several outcomes, with mixed-model
  versions when `random` is given.
* Robust standard errors by default (HC3; CR2 with Satterthwaite df for
  clustered and mixed models), explicit reference-category rows, pairwise
  contrasts (emmeans) corrected within each factor, and an optional correction
  across outcomes. Each table carries an automatic methods note.
* `cr_table()` and `cr_contrast_table()` render in Quarto (HTML, Word, PDF) and
  export with `cr_save()` to Word, LaTeX, HTML, and CSV. Styles: `"apa"`,
  `"stargazer"`, `"compact"`.
* Baseline adjustment (ANCOVA, Lin 2013), simple effects (`contrast_by`), and
  equivalence tests (`cr_equivalence()`).

## Results text and checks

* `cr_inline()`, `cr_direction()`, `cr_sig()`, `cr_sentence()`, and
  `cr_report()` build results prose from the fitted objects.
* `cr_hypotheses()` / `cr_h()` map hypotheses to tests and robustness checks;
  `cr_expect()` fails a render when a claim stops being true.
* `cr_verify()` checks numbers typed in a `.qmd`, `.Rmd`, or `.docx` against
  the results; `cr_ground_truth()` and `cr_diff()` report what changed between
  runs, flagging sign flips and significance changes.
* Simple tests with effect sizes: `cr_d()`, `cr_ttest()`, `cr_chisq()`,
  `cr_anova()`, `cr_cor()`.

## Figures

* `cr_plot_means()`, `cr_plot_interaction()`, `cr_plot_coef()`, and
  `cr_plot_hist()` return ordinary ggplot objects, with `theme_cr()`,
  colour-vision-checked palettes, and `cr_save()` export at journal widths.

## Other

* `cr_example_data()` provides simulated data for the documentation.
