# cleanresults (development version)

## Bug fixes

* Pairwise contrasts, `cr_plot_means()` brackets and CIs, and
  `cr_plot_interaction()` CIs now use the CR2 Satterthwaite *df* whenever the
  coefficients do (all mixed linear models, and lm/logit/Poisson/negative
  binomial models with `cluster`). Before, `emmeans` received the CR2 matrix
  but kept the model's own *df* (model-based Satterthwaite for `lmer`,
  residual *df* for `lm`, *z* for `glm`), so with few clusters these outputs
  were too liberal and could disagree with the identical coefficient row (for
  example a bracket showing *** next to a table *p* of .068).

## New

* `cr_table()` notes how many CR2 tests have Satterthwaite *df* below 4.

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
