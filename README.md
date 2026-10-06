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

res                          # console preview (APA style)
```

**Model types.** `"linear"`, `"logistic"`, `"poisson"`, `"negbin"`, and
`"ordinal"` become mixed models automatically when you give `random`:

| Type | No `random` | With `random` | Reported as |
|---|---|---|---|
| `"linear"` | `lm` | `lmerTest::lmer` | *b* |
| `"logistic"` | `glm` binomial | `lme4::glmer` | OR |
| `"poisson"` | `glm` Poisson (also Poisson quasi-ML for skewed non-negative outcomes such as miles driven) | `glmer` Poisson | IRR (ratio of means) |
| `"negbin"` | `MASS::glm.nb` | `glmmTMB` nbinom2 | IRR |
| `"ordinal"` (alias `"polr"`) | `ordinal::clm` | `ordinal::clmm` | cumulative OR |
| `"bayes_linear"`, `"bayes_logistic"`, `"bayes_ordinal"`, `"bayes_poisson"`, `"bayes_negbin"` | `brms::brm` | `brms::brm` | posterior median, 95% CrI, *pd* |

`"polr"` fits the same proportional-odds model as `MASS::polr`, through
`ordinal::clm` because it supports robust SEs and mixed versions. Use
`formulas` to give one outcome different predictors. Bayesian models take
priors and sampler settings through `fit_args`, e.g.
`fit_args = list(prior = brms::prior(normal(0, 1), class = "b"), chains = 4, iter = 4000)`.

### Baseline adjustment, simple effects, equivalence

```r
clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition,
              baseline = c(trust = "trust_pre"))        # ANCOVA, baseline centered
clean_regress(..., baseline = c(trust = "trust_pre"), lin = "condition")  # Lin (2013)

clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition * ideology,
              contrasts = "condition", contrast_by = "ideology")  # simple effects

eq <- cr_equivalence(res, bounds = 0.2, dv = "trust", variable = "condition")  # TOST
cr_equivalence(res, bounds = c(0.8, 1.25), dv = "shared", variable = "condition")  # ratios
cr_equivalence(cr_ttest(d, "trust", "condition"), bounds = 0.3, scale = "d")       # d units
cr_report(eq)
cr_h(eq, "trust", "condition", "Gain", expect = "equiv")   # in a hypothesis map
```

## Table options

Start from a preset and override any piece:

| `style` | `uncertainty` | `p` | `layout` | Looks like |
|---|---|---|---|---|
| `"apa"` (default) | `"ci"` | `"value"` | `"columns"` | `b` · `95% CI` · `p` columns |
| `"stargazer"` | `"se"` | `"stars"` | `"stacked"` | `0.46*` with `(0.21)` on the line below |
| `"compact"` | `"ci"` | `"stars"` | `"inline"` | `0.46* [0.04, 0.89]` in one cell |

```r
cr_table(res, uncertainty = "se")                       # SE column instead of CI
cr_table(res, p = "stars")                              # stars, no p column
cr_table(res, p = "both")                               # stars and a p column
cr_table(res, uncertainty = "se", layout = "inline",
         p = "stars")                                   # 0.46* (0.21), one column per outcome
cr_table(res, fit = FALSE, random = FALSE)              # coefficients only
```

### Contrasts: same table or separate

```r
cr_table(res)                          # contrasts as a section of the main table
cr_table(res, contrasts = "exclude")   # main table without them
cr_contrast_table(res)                 # contrasts in their own table
cr_contrast_table(res, uncertainty = "se", layout = "inline", p = "stars")
```

The note under each table only describes what that table shows.

### Clean labels

Names are cleaned automatically: `GainFraming` → "Gain framing",
`age_years` → "Age years", `Loss-Framing` → "Loss framing",
`participant_id` → "Participant ID". Number ranges keep a dash: `18-24` →
"18–24". Capitalized acronyms like `SES` stay as they are. Contrast labels are
built from the cleaned level names.

```r
clean_regress(...,
  labels = c(age_years = "Age"),                                  # predictors / outcomes
  level_labels = list(frame_condition = c(GainFraming = "Gain frame")),
  dv_labels = c(trust_score = "Trust"),
  label_case = "sentence",     # or "title", "asis"
  clean_labels = TRUE)         # FALSE shows raw names
clean_label("GainFraming")     # use the cleaner anywhere
```

## Where the table goes

| Destination | How |
|---|---|
| **Quarto / R Markdown** | Put `cr_table(res)` in a chunk with `#| label: tbl-main` and `#| tbl-cap: "..."`, then cite it with `@tbl-main`. It renders natively to HTML, Word and PDF. |
| **Overleaf** | `cr_save(res, "table1.tex", caption = "...", label = "tab:main")`, then `\input{table1.tex}`. The preamble needs `\usepackage{booktabs}` and `\usepackage{threeparttable}`. Compiles with pdfLaTeX. |
| **Word** | `cr_save(res, "table1.docx")` gives a native Word table (APA booktabs look, Times New Roman). Add `landscape = TRUE` for wide tables. |
| **Google Docs** | Upload the `.docx` to Drive and choose *Open with Google Docs*. Or save `.html`, open it in a browser, select the table and paste. |
| **Anything else** | `cr_save(res, "table1.csv")` for the formatted cells, or `cr_tidy(res)` for the raw numbers. |

To save a specific layout, pass a `cr_table`:
`cr_save(cr_table(res, style = "stargazer"), "table1.tex")` or
`cr_save(cr_contrast_table(res), "table2.docx")`.

## Results text that updates itself

Everything below comes from the same objects as the tables, so prose rebuilt
on render can't drift from the numbers.

### Numbers, words, and sentences

```r
cr_inline(res, "trust", "condition", "Gain")
#> "*b* = 0.46, 95% CI [0.04, 0.89], *p* = .032"
cr_inline(res, "trust", "condition", "Gain", style = "econ")
#> "b = 0.46 (SE = 0.21, p = 0.032)"
cr_inline(res, "trust", "condition", "Gain", stats = c("est", "ci", "p", "es"))  # adds d

cr_direction(res, "trust", "condition", "Gain")       # "higher" / "lower"
cr_sig(res, "trust", "condition", "Gain")             # "was" / "was not"
cr_sentence(res, "trust", "condition", "Gain")
#> "Compared with Control, Gain was associated with higher trust, *b* = 0.46, ..."
```

In a qmd: `` Gain framing `r cr_direction(res, "trust", "condition", "Gain", words = c("raised", "lowered"))` trust, `r cr_inline(res, "trust", "condition", "Gain")`. ``
Use `format = "latex"` for Overleaf and `"plain"` or `"html"` for Google Docs.

Sentences are mechanical by design. They give the direction, whether the
result was significant (non-significant results get "did not differ
significantly" wording), and the statistics, never interpretation.

### Hypothesis map and results paragraphs

```r
hyp <- cr_hypotheses(
  H1 = cr_h(res, "trust", "condition", "Gain", expect = "+",
            robustness = list("excluding speeders" = res_strict,
                              "t-test" = cr_h(tt, "trust", "condition", "Gain vs. Control"))),
  H2 = list(cr_h(res, "shared", "condition", "Loss", expect = "+"),
            cr_h(res, "shared", "condition", "Loss vs. Gain", expect = "+")),
  labels = c(H1 = "Gain framing increases trust", H2 = "Loss framing increases sharing")
)
hyp                      # each test, its robustness checks, expectation met or not
cr_report(hyp)           # one paragraph per hypothesis, robustness checks attached
cr_report(res)           # or every estimate in a results object
cr_save(cr_report(hyp), "results/h_results.tex")   # \input{} in Overleaf
cr_save(cr_report(hyp), "results/h_results.html")  # paste into Google Docs with italics
```

### Guarding against drift

| Risk | Tool |
|---|---|
| A hand-written claim ("framing increased sharing") stops being true after a re-run | `cr_expect(res, "shared", "condition", "Loss", sign = "+", sig = TRUE)` in a hidden chunk makes the render **fail**; `cr_expect(hyp)` checks every hypothesis with an `expect` |
| A number typed by hand doesn't match the results | `cr_verify("paper.qmd", res)` checks every typed number (inline R output is skipped because it's correct by construction). Also works on a `.docx` downloaded from Google Docs. `strict = TRUE` fails the render |
| You changed code or data and don't know which sentences to re-read | `cr_ground_truth(res, hyp, path = "results/ground_truth.json")` on every render prints what changed since last time, flagging **sign flips** and **significance changes**. `cr_diff(old, new)` does the same on demand |
| An LLM drafts or checks the prose | Give it `cr_ground_truth(..., path = "ground_truth.md")`: every estimate, its exact reported string, models, and the hypothesis map |

`cr_verify()` can tell a number exists in the results, not that the sentence
attaches it to the right comparison. That reading check is the LLM's (or a
co-author's) job, working from the ground-truth export.

## Simple tests and Cohen's d

```r
cr_d(d, "trust", "condition")                         # every pair of conditions
cr_d(d, "trust", "condition", pairs = "ref", ref = "Control")
cr_d(d, "trust", "condition", pairs = c("Loss vs. Gain", "Loss vs. Control"))
cr_d(d, c("trust", "liking"), "condition", by = "study", effect = "g")
cr_ttest(d, "trust", "time", id = "pid")              # paired, d_z
cr_d(res)                                             # model-based d for every contrast
cr_table(res, effect_size = TRUE)                     # d column in the table

cr_chisq(d, "shared", "condition", pairs = "all")     # chi-square/Fisher, V, pairwise h
cr_anova(d, "trust", "condition")                     # F, eta squared
cr_cor(d, c("trust", "liking", "age"))                # every pair
```

All of these work with `cr_inline()`, `cr_sentence()`, `cr_report()`,
`cr_h()`, `cr_ground_truth()`, and `cr_verify()`. Pairwise *p*-values are
Holm-adjusted across pairs by default (`adjust`); `dv_adjust` corrects across
outcomes. When `adjust` is on, CIs (including *d*'s) are Bonferroni-adjusted to
match, reported as e.g. "98.3% CI" for three pairs, so a CI that excludes zero
always comes with a significant adjusted *p*. *d*, *g*, and *d_z* (with CIs)
match the `effectsize` package. Model-based *d* divides by the pooled within-group SD of the outcome (lm, so
covariates don't inflate it) or, for mixed models, the total SD of one
observation: residual variance plus the variance the random effects add,
random slopes included.

## Figures

Every plot is an ordinary ggplot, so `+ labs()`, `+ facet_wrap()`, `+ theme()`
and any other layer work. Styling follows the lab figure guide
(`visualization_inspo.Rmd`): a Nature/Science-style theme, the Teal & Terracotta
palette family, and journal column widths.

```r
cr_plot_means(res, "trust", "condition")                    # model means + 95% CIs, brackets
cr_plot_means(res, "trust", "condition", by = "female", type = "dot", p = "value")
cr_plot_means(d, "trust", "condition", type = "raincloud")  # raw data: cloud, box, points, mean
cr_plot_means(d, "trust", "condition", uncertainty = "sd", type = "dot", points = TRUE)
cr_plot_interaction(res, "trust", "condition", "female")    # dots + dashed lines
cr_plot_interaction(res, "trust", "age", "condition")       # predicted lines + ribbons
cr_plot_coef(res)                                            # forest plot: 90% thick, 95% thin
cr_plot_hist(d, "age", by = "condition")

p <- cr_plot_means(res, "trust", "condition") + ggplot2::labs(title = "Study 1")
attr(p, "cr_note")                                     # method note for the figure caption
cr_save(p, "figures/fig2.pdf", width = "1col")         # "1col" 88 mm, "1.5col", "2col" 178 mm
```

- **Means from models** are estimated marginal means with the model's own
  (robust) SEs; brackets use the same adjusted contrasts as the table, so a
  star on the figure always matches the table and text. From a data frame:
  raw means with SE, SD, or CI and Welch *t*-test brackets (Holm by default).
- **Brackets:** `comparisons = "ref"` (vs. the first level), `"all"`, `"sig"`,
  or named pairs; `p = "stars"`, `"value"`, or `"none"`. P-values always come
  from the full set of pairs, so showing fewer brackets never changes them.
- **Themes:** `theme_cr("nature")` (default), `"psychsci"`, `"jcr"`,
  `"polsci"`; pass `style =` to any plot or add `theme_cr()` to your own.
- **Colors:** `cr_palette(n)` picks validated defaults (2 groups: teal,
  terracotta; 3: slate control, navy, terracotta; 4: navy, teal, terracotta,
  purple). Every pair in them stays distinguishable for color-blind readers.
  Slate and teal are almost identical for red-blind readers, so avoid using
  them together. Other palettes: `"teal_terracotta"`, `"forest_lilac"`,
  `"nordic_ochre"`, `"partisan_bridge"`; set one project-wide with
  `options(cleanresults.palette = "forest_lilac")`, or use `scale_fill_cr()`.
- **Export:** `.pdf` (vector, fonts embedded via cairo), `.svg`, `.eps`,
  `.png`/`.tiff` at 600 dpi.

## Methods defaults

| Model | `se = "robust"` (default) | `se = "model"` |
|---|---|---|
| lm | HC3; CR2 + Satterthwaite df if `cluster` is set | OLS SEs |
| logit | HC3 (z); CR2 if `cluster` is set | Wald z |
| lmer | CR2 clustered on the first grouping factor (or `cluster`), Satterthwaite df | Satterthwaite (lmerTest) |
| Poisson, negative binomial | HC3 (z); CR2 if `cluster` is set | Wald z |
| ordinal (clm) | sandwich SEs; cluster-robust if `cluster` is set | Wald z |
| glmer, Poisson/negbin/ordinal mixed | **Model-based Wald z.** No small-sample cluster-robust estimator exists for these, and the table note says so | Wald z |
| Bayesian (brms) | Posterior median, MAD, equal-tailed 95% credible interval, probability of direction (*pd*); not adjusted for multiple comparisons | same |

- **Logistic models** report odds ratios. CIs are exponentiated from the
  log-odds scale. In the SE style, SEs are delta-method SEs.
- **Pairwise contrasts** compare estimated marginal means, averaged over the
  other predictors, using the same covariance matrix as the coefficients.
  `contrast_adjust` adjusts their p-values and CIs within each factor.
- **The across-outcome correction** (`dv_adjust`) treats each row as one
  family across outcomes, and widens those rows' CIs to match (Bonferroni
  across the outcomes, on top of any within-factor adjustment). Text output
  prints each CI's real level, e.g. "98.3% CI" for a Holm-adjusted contrast
  among three conditions. For example, the three "Gain" p-values for three
  outcomes are corrected together. When both corrections are on, contrasts
  are adjusted within the factor first and then across outcomes, which is
  conservative. `cr_tidy()` keeps both `p.within` and the final `p.value`.
- **Fit block:** N, random-effect variances, adjusted ICC, Nakagawa
  marginal/conditional R² for random-intercept models, R² (lm), Tjur R²
  (logit), and AIC.
- **Missing data:** each model uses complete cases on its own variables. N is
  reported per model.
