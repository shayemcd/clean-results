# Changelog

## cleanresults 0.1.0

First public release.

### Tables

- [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
  fits linear, logistic, Poisson, negative binomial, ordinal, and
  Bayesian (brms) models for one or several outcomes, with mixed-model
  versions when `random` is given.
- Robust standard errors by default (HC3; CR2 with Satterthwaite df for
  clustered and mixed models), explicit reference-category rows,
  pairwise contrasts (emmeans) corrected within each factor, and an
  optional correction across outcomes. Each table carries an automatic
  methods note.
- [`cr_table()`](https://shayemcd.github.io/clean-results/reference/cr_table.md)
  and
  [`cr_contrast_table()`](https://shayemcd.github.io/clean-results/reference/cr_contrast_table.md)
  render in Quarto (HTML, Word, PDF) and export with
  [`cr_save()`](https://shayemcd.github.io/clean-results/reference/cr_save.md)
  to Word, LaTeX, HTML, and CSV. Styles: `"apa"`, `"stargazer"`,
  `"compact"`.
- Baseline adjustment (ANCOVA, Lin 2013), simple effects
  (`contrast_by`), and equivalence tests
  ([`cr_equivalence()`](https://shayemcd.github.io/clean-results/reference/cr_equivalence.md)).

### Results text and checks

- [`cr_inline()`](https://shayemcd.github.io/clean-results/reference/cr_inline.md),
  [`cr_direction()`](https://shayemcd.github.io/clean-results/reference/cr_direction.md),
  [`cr_sig()`](https://shayemcd.github.io/clean-results/reference/cr_direction.md),
  [`cr_sentence()`](https://shayemcd.github.io/clean-results/reference/cr_sentence.md),
  and
  [`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md)
  build results prose from the fitted objects.
- [`cr_hypotheses()`](https://shayemcd.github.io/clean-results/reference/cr_hypotheses.md)
  /
  [`cr_h()`](https://shayemcd.github.io/clean-results/reference/cr_h.md)
  map hypotheses to tests and robustness checks;
  [`cr_expect()`](https://shayemcd.github.io/clean-results/reference/cr_expect.md)
  fails a render when a claim stops being true.
- [`cr_verify()`](https://shayemcd.github.io/clean-results/reference/cr_verify.md)
  checks numbers typed in a `.qmd`, `.Rmd`, or `.docx` against the
  results;
  [`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md)
  and
  [`cr_diff()`](https://shayemcd.github.io/clean-results/reference/cr_diff.md)
  report what changed between runs, flagging sign flips and significance
  changes.
- Simple tests with effect sizes:
  [`cr_d()`](https://shayemcd.github.io/clean-results/reference/cr_d.md),
  [`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md),
  [`cr_chisq()`](https://shayemcd.github.io/clean-results/reference/cr_chisq.md),
  [`cr_anova()`](https://shayemcd.github.io/clean-results/reference/cr_anova.md),
  [`cr_cor()`](https://shayemcd.github.io/clean-results/reference/cr_cor.md).

### Figures

- [`cr_plot_means()`](https://shayemcd.github.io/clean-results/reference/cr_plot_means.md),
  [`cr_plot_interaction()`](https://shayemcd.github.io/clean-results/reference/cr_plot_interaction.md),
  [`cr_plot_coef()`](https://shayemcd.github.io/clean-results/reference/cr_plot_coef.md),
  and
  [`cr_plot_hist()`](https://shayemcd.github.io/clean-results/reference/cr_plot_hist.md)
  return ordinary ggplot objects, with
  [`theme_cr()`](https://shayemcd.github.io/clean-results/reference/theme_cr.md),
  colour-vision-checked palettes, and
  [`cr_save()`](https://shayemcd.github.io/clean-results/reference/cr_save.md)
  export at journal widths.

### Other

- [`cr_example_data()`](https://shayemcd.github.io/clean-results/reference/cr_example_data.md)
  provides simulated data for the documentation.
