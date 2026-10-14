# cleanresults

<!-- badges: start -->
[![R-CMD-check](https://github.com/shayemcd/clean-results/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/shayemcd/clean-results/actions/workflows/R-CMD-check.yaml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](#status)
<!-- badges: end -->

One call fits regressions for several outcomes and gives back one
publication-ready table, plus the results text and figures that go with it,
all built from the same fitted objects so the manuscript can't drift from the
numbers.

- **Robust SEs by default**: HC3 for lm/logit, and CR2 cluster-robust with
  Satterthwaite df for mixed models
- **Reference categories shown as rows**, e.g. `Control (ref.)  —`
- **Pairwise contrasts** (emmeans) with a correction within each factor, and
  an optional correction across outcomes
- **An automatic methods note** that says exactly which SEs and corrections
  were used
- **Results text** (`cr_inline()`, `cr_sentence()`, `cr_report()`) and a
  **hypothesis map** that checks each claim against its estimate
- **Drift checks**: `cr_verify()` compares numbers typed in a manuscript to
  the results, and `cr_ground_truth()` reports what changed between runs
- **Figures** as ordinary ggplots: group means with significance brackets,
  interactions, forest plots, histograms

The same table renders in Quarto (HTML, Word, and PDF), in Overleaf, in Word,
and in Google Docs.

## Install

```r
# install.packages("remotes")
remotes::install_github("shayemcd/clean-results")

# optional, depending on the models you fit
install.packages(c("lme4", "lmerTest"))       # mixed models
install.packages(c("ordinal", "glmmTMB"))     # ordinal and negative binomial mixed models
```

## Quick start

```r
library(cleanresults)

d <- cr_example_data()        # simulated data, so this runs as is

res <- clean_regress(
  d,
  dvs = c(trust = "linear", share = "logistic"),
  predictors = ~ condition + age,
  random = ~ (1 | id),                # makes "linear"/"logistic" mixed models
  contrasts = "condition",            # pairwise contrasts
  contrast_adjust = "holm",           # correction within factor
  dv_adjust = "holm",                 # correction across outcomes
  dv_adjust_terms = "condition",      # ...only for condition rows
  labels = c(condition = "Condition", age = "Age (years)"),
  dv_labels = c(trust = "Trust", share = "Shared")
)

res                                                   # table preview
cr_save(res, "table1.docx")                           # Word (also .tex, .html, .csv)
cr_inline(res, "share", "condition", "Loss")          # "OR = 2.39, 97.5% CI [1.10, 5.17], p = .023"
cr_plot_means(res, "trust", "condition")              # means with significance brackets
```

In a Quarto or R Markdown document, put `cr_table(res)` in a chunk with
`#| label: tbl-main` and `#| tbl-cap: "..."`, then cite it with `@tbl-main`.

## Learn more

The guides and the function reference are on the
[documentation site](https://shayemcd.github.io/clean-results/):

| Guide | Covers |
|---|---|
| **Getting started** | Model types, table options, contrasts, labels, saving to Word / LaTeX / Google Docs |
| **Results text that updates itself** | Inline numbers and sentences, hypothesis map, `cr_verify()`, `cr_ground_truth()`, simple tests and Cohen's *d* |
| **Figures** | Means, interactions, forest plots, themes, palettes, export |
| **Methods defaults** | Exactly which SEs, corrections, and effect sizes are computed |

The same guides are in the package as vignettes
(`browseVignettes("cleanresults")` when installed with
`build_vignettes = TRUE`) and in `vignettes/`.

## Status

Version 0.1.0. The tables, text, and figures are tested against `emmeans`,
`effectsize`, `sandwich`, and the underlying model packages (see
`tests/testthat/`), but the API may still change before 1.0. Bug reports and
suggestions are welcome as
[issues](https://github.com/shayemcd/clean-results/issues).

## AI assistance

cleanresults was written with substantial help from Claude (Anthropic), used
through Claude Code, for code, tests, and documentation. Shaye Hopkins
directed the work, reviewed the changes, and is responsible for the package.
Its numerical output is tested against independent implementations (see
[Status](#status)).

## Citation

```r
citation("cleanresults")
```

or see [`CITATION.cff`](CITATION.cff).

## License

MIT, see [`LICENSE.md`](LICENSE.md).
