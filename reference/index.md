# Package index

## Fit models

- [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md)
  : Fit regressions for one or more outcomes and collect
  publication-ready results
- [`cr_example_data()`](https://shayemcd.github.io/clean-results/reference/cr_example_data.md)
  : Simulated example data

## Tables

- [`cr_table()`](https://shayemcd.github.io/clean-results/reference/cr_table.md)
  : Build a formatted results table
- [`cr_contrast_table()`](https://shayemcd.github.io/clean-results/reference/cr_contrast_table.md)
  : Pairwise contrasts as a separate table
- [`cr_save()`](https://shayemcd.github.io/clean-results/reference/cr_save.md)
  : Save a results table to Word, LaTeX, HTML, or CSV
- [`cr_latex()`](https://shayemcd.github.io/clean-results/reference/cr_latex.md)
  : Render a results table as LaTeX (booktabs + threeparttable)
- [`cr_flextable()`](https://shayemcd.github.io/clean-results/reference/cr_flextable.md)
  : Render a results table as a flextable (Word, HTML, PowerPoint)
- [`cr_tidy()`](https://shayemcd.github.io/clean-results/reference/cr_tidy.md)
  : Tidy results as a data frame
- [`cr_rows()`](https://shayemcd.github.io/clean-results/reference/cr_rows.md)
  : Flatten results into one row per reportable estimate
- [`clean_label()`](https://shayemcd.github.io/clean-results/reference/clean_label.md)
  : Clean a variable or level name for display

## Results text

- [`cr_inline()`](https://shayemcd.github.io/clean-results/reference/cr_inline.md)
  : Report one result in text
- [`cr_direction()`](https://shayemcd.github.io/clean-results/reference/cr_direction.md)
  [`cr_sig()`](https://shayemcd.github.io/clean-results/reference/cr_direction.md)
  : Direction and significance words that update with the results
- [`cr_sentence()`](https://shayemcd.github.io/clean-results/reference/cr_sentence.md)
  : Write one result as a sentence
- [`cr_text_as()`](https://shayemcd.github.io/clean-results/reference/cr_text_as.md)
  : Re-render report text in another format
- [`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md)
  : Write results paragraphs that rebuild on every render

## Hypotheses and drift checks

- [`cr_hypotheses()`](https://shayemcd.github.io/clean-results/reference/cr_hypotheses.md)
  : Map hypotheses to results
- [`cr_h()`](https://shayemcd.github.io/clean-results/reference/cr_h.md)
  : Point a hypothesis at one result
- [`cr_expect()`](https://shayemcd.github.io/clean-results/reference/cr_expect.md)
  : Stop rendering when a claim in your text stops holding
- [`cr_verify()`](https://shayemcd.github.io/clean-results/reference/cr_verify.md)
  : Check every number in a manuscript against the results
- [`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md)
  : Export every reportable number, model, and hypothesis link
- [`cr_diff()`](https://shayemcd.github.io/clean-results/reference/cr_diff.md)
  : What changed between two runs?

## Simple tests and effect sizes

- [`cr_d()`](https://shayemcd.github.io/clean-results/reference/cr_d.md)
  : Cohen's d for every pair of conditions
- [`cr_ttest()`](https://shayemcd.github.io/clean-results/reference/cr_ttest.md)
  : Pairwise t-tests with Cohen's d for every pair of conditions
- [`cr_chisq()`](https://shayemcd.github.io/clean-results/reference/cr_chisq.md)
  : Chi-square (or Fisher's exact) tests
- [`cr_anova()`](https://shayemcd.github.io/clean-results/reference/cr_anova.md)
  : One-way ANOVA with eta squared
- [`cr_cor()`](https://shayemcd.github.io/clean-results/reference/cr_cor.md)
  : Correlations between every pair of variables
- [`cr_equivalence()`](https://shayemcd.github.io/clean-results/reference/cr_equivalence.md)
  : Equivalence tests (TOST) for any reported result

## Figures

- [`cr_plot_means()`](https://shayemcd.github.io/clean-results/reference/cr_plot_means.md)
  : Bar, dot, box, and raincloud plots of group means with significance
  brackets
- [`cr_plot_interaction()`](https://shayemcd.github.io/clean-results/reference/cr_plot_interaction.md)
  : Interaction plots
- [`cr_plot_coef()`](https://shayemcd.github.io/clean-results/reference/cr_plot_coef.md)
  : Coefficient (forest) plots
- [`cr_plot_hist()`](https://shayemcd.github.io/clean-results/reference/cr_plot_hist.md)
  : Histograms
- [`theme_cr()`](https://shayemcd.github.io/clean-results/reference/theme_cr.md)
  : Publication ggplot2 themes
- [`cr_palette()`](https://shayemcd.github.io/clean-results/reference/cr_palette.md)
  : Pick colors for n groups
- [`cr_palettes`](https://shayemcd.github.io/clean-results/reference/cr_palettes.md)
  : Figure palettes
- [`scale_fill_cr()`](https://shayemcd.github.io/clean-results/reference/scale_fill_cr.md)
  [`scale_colour_cr()`](https://shayemcd.github.io/clean-results/reference/scale_fill_cr.md)
  [`scale_color_cr()`](https://shayemcd.github.io/clean-results/reference/scale_fill_cr.md)
  : Scales in the cleanresults palettes
