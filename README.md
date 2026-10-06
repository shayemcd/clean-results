# cleanresults

One call fits linear, logistic, and mixed-effects regressions for several
outcomes. You get back one publication-ready table with:

- **robust SEs by default**: HC3 for lm/logit, and CR2 cluster-robust with Satterthwaite df for mixed models
- **reference categories shown as rows**, e.g. `Control (ref.)  —`
- **pairwise contrasts** (emmeans) with a correction **within each factor**
- an optional correction **across outcomes**
- an **automatic methods note** that says exactly which SEs and corrections were used

The same table renders in Quarto (HTML, Word, and PDF), in Overleaf, in Word,
and in Google Docs.

## Install

```r
# install.packages("remotes")
remotes::install_github("shayemcd/clean-results")
install.packages(c("lme4", "lmerTest"))   # for mixed models
```

## Quick start

```r
library(cleanresults)

res <- clean_regress(
  d,
  dvs = c(trust = "linear", donated = "logistic", shared = "logistic"),
  predictors = ~ condition + age,
  random = ~ (1 | id),                # makes "linear"/"logistic" mixed models
  formulas = list(donated = donated ~ condition + age),  # one person-level outcome
  contrasts = "condition",            # pairwise contrasts
  contrast_adjust = "holm",           # correction within factor
  dv_adjust = "holm",                 # correction across outcomes
  dv_adjust_terms = "condition",      # ...only for condition rows
  labels = c(condition = "Condition", age = "Age (years)"),
  dv_labels = c(trust = "Trust", donated = "Donated", shared = "Shared")
)

res                          # console preview
cr_table(res, style = "se")  # stargazer style: estimate with stars over (SE)
```

**Model types:** `"linear"` and `"logistic"` become mixed models automatically
when you give `random`. You can also name the type explicitly with `"lm"`,
`"logit"`, `"lmer"` or `"glmer"`. Use `formulas` to give one outcome different
predictors.

## Where the table goes

| Destination | How |
|---|---|
| **Quarto / R Markdown** | Put `cr_table(res)` in a chunk with `#| label: tbl-main` and `#| tbl-cap: "..."`, then cite it with `@tbl-main`. It renders natively to HTML, Word and PDF. |
| **Overleaf** | `cr_save(res, "table1.tex", caption = "...", label = "tab:main")`, then `\input{table1.tex}`. The preamble needs `\usepackage{booktabs}` and `\usepackage{threeparttable}`. Compiles with pdfLaTeX. |
| **Word** | `cr_save(res, "table1.docx")` gives a native Word table (APA booktabs look, Times New Roman). Add `landscape = TRUE` for wide tables. |
| **Google Docs** | Upload the `.docx` to Drive and choose *Open with Google Docs*. Or save `.html`, open it in a browser, select the table and paste. |
| **Anything else** | `cr_save(res, "table1.csv")` for the formatted cells, or `cr_tidy(res)` for the raw numbers. |

To use the stargazer style in a file, pass a `cr_table`:
`cr_save(cr_table(res, style = "se"), "table1.tex")`.

## Numbers in text

```r
cr_inline(res, "trust", "condition", "Gain")
#> "*b* = 0.46, 95% CI [0.04, 0.89], *p* = .065"

cr_inline(res, "shared", "condition", "Loss vs. Gain",
          stats = c("est", "ci", "test", "p"), format = "plain")
#> "OR = 2.82, 95% CI [1.39, 5.72], z = 3.50, p = .004"
```

In a qmd, write `` `r cr_inline(res, "trust", "age")` ``. Use
`format = "latex"` for Overleaf and `"plain"` for Google Docs. Because these
strings come from the same object as the table, the text can't drift from it.

## Methods defaults

| Model | `se = "robust"` (default) | `se = "model"` |
|---|---|---|
| lm | HC3; CR2 + Satterthwaite df if `cluster` is set | OLS SEs |
| logit | HC3 (z); CR2 if `cluster` is set | Wald z |
| lmer | CR2 clustered on the first grouping factor (or `cluster`), Satterthwaite df | Satterthwaite (lmerTest) |
| glmer | **Model-based Wald z.** clubSandwich doesn't support glmer, and the table note says so | Wald z |

- **Logistic models** report odds ratios. CIs are exponentiated from the
  log-odds scale. In the SE style, SEs are delta-method SEs.
- **Pairwise contrasts** compare estimated marginal means, averaged over the
  other predictors, using the same covariance matrix as the coefficients.
  `contrast_adjust` adjusts their p-values and CIs within each factor.
- **The across-outcome correction** (`dv_adjust`) treats each row as one
  family across outcomes. For example, the three "Gain" p-values for three
  outcomes are corrected together. When both corrections are on, contrasts
  are adjusted within the factor first and then across outcomes, which is
  conservative. `cr_tidy()` keeps both `p.within` and the final `p.value`.
- **Fit block:** N, random-effect variances, adjusted ICC, Nakagawa
  marginal/conditional R² for random-intercept models, R² (lm), Tjur R²
  (logit), and AIC.
- **Missing data:** each model uses complete cases on its own variables. N is
  reported per model.
