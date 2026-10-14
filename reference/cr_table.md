# Build a formatted results table

Creates a table object that prints in the console, renders natively in
Quarto/R Markdown (HTML, Word, and PDF), and can be passed to
[`cr_save()`](https://shayemcd.github.io/clean-results/reference/cr_save.md).
Printing a `clean_results` object directly uses the defaults below.

## Usage

``` r
cr_table(
  x,
  style = "apa",
  uncertainty = NULL,
  p = NULL,
  layout = NULL,
  contrasts = c("include", "exclude", "only"),
  digits = 2,
  p_digits = 3,
  fit = TRUE,
  random = TRUE,
  show_model_type = TRUE,
  note = NULL,
  auto_note = TRUE,
  effect_size = FALSE,
  omit = NULL
)
```

## Arguments

- x:

  A `clean_results` object from
  [`clean_regress()`](https://shayemcd.github.io/clean-results/reference/clean_regress.md).

- style:

  Preset: `"apa"`, `"stargazer"`, or `"compact"` (see table). `"ci"` and
  `"se"` are accepted as aliases for `"apa"` and `"stargazer"`.

- uncertainty:

  `"ci"`, `"se"`, or `"none"`.

- p:

  `"value"` (a p column), `"stars"` (stars on the estimate, no p
  column), `"both"`, or `"none"`.

- layout:

  How the estimate and its uncertainty share space: `"columns"`
  (separate columns), `"stacked"` (uncertainty on the line below the
  estimate), or `"inline"` (one cell: `0.46 (0.21)` or
  `0.46 [0.04, 0.89]`).

- contrasts:

  `"include"` (contrasts as a section of this table), `"exclude"` (leave
  them out, e.g. to report them in a separate table), or `"only"` (a
  contrasts-only table; see
  [`cr_contrast_table()`](https://shayemcd.github.io/clean-results/reference/cr_contrast_table.md)).

- digits:

  Decimal places for estimates, CIs, SEs, and fit statistics.

- p_digits:

  Decimal places for p-values (APA: no leading zero).

- fit, random:

  Show the model-fit and random-effects blocks.

- show_model_type:

  Show the model type under each outcome name.

- note:

  Extra note lines appended under the automatic note.

- auto_note:

  Include the automatic methods note.

- effect_size:

  Add a Cohen's *d* column for linear models (factor levels and
  contrasts).

- omit:

  Regular expression matched against model term labels (the `variable`
  column of
  [`cr_tidy()`](https://shayemcd.github.io/clean-results/reference/cr_tidy.md),
  e.g. `"Topic"`, `"Month"`, `"age:condition"`): matching rows are left
  out of the table, typically nuisance controls. They stay in the fitted
  models and in
  [`cr_tidy()`](https://shayemcd.github.io/clean-results/reference/cr_tidy.md),
  [`cr_report()`](https://shayemcd.github.io/clean-results/reference/cr_report.md),
  and
  [`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md).
  With `auto_note = TRUE` the note lists them ("Also controls for:
  ...").

## Value

An object of class `cr_table`.

## Details

Start from a `style` preset and override any piece:

|                   |             |           |             |
|-------------------|-------------|-----------|-------------|
| style             | uncertainty | p         | layout      |
| `"apa"` (default) | `"ci"`      | `"value"` | `"columns"` |
| `"stargazer"`     | `"se"`      | `"stars"` | `"stacked"` |
| `"compact"`       | `"ci"`      | `"stars"` | `"inline"`  |

## Examples

``` r
if (FALSE) { # \dontrun{
cr_table(res)                                   # APA: b, 95% CI, p
cr_table(res, uncertainty = "se")               # b, SE, p
cr_table(res, p = "stars")                      # stars instead of a p column
cr_table(res, uncertainty = "se", layout = "inline", p = "stars")  # 0.46* (0.21)
cr_table(res, style = "stargazer")              # stacked SEs with stars
cr_table(res, contrasts = "exclude")            # main table without contrasts
cr_contrast_table(res)                          # contrasts in their own table
cr_table(res, omit = "^(region|wave)$")         # hide nuisance controls
} # }
```
