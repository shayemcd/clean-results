# Write results paragraphs that rebuild on every render

With a
[`cr_hypotheses()`](https://shayemcd.github.io/clean-results/reference/cr_hypotheses.md)
map, writes one paragraph per hypothesis: each primary test, then each
robustness check attached to it. With a results object, writes a
sentence for every reported estimate (optionally filtered). Put it in a
chunk or inline code in Quarto/R Markdown; save it for Overleaf or
Google Docs with
[`cr_save()`](https://shayemcd.github.io/clean-results/reference/cr_save.md).

## Usage

``` r
cr_report(
  x,
  dv = NULL,
  variables = NULL,
  contrasts = TRUE,
  intercept = FALSE,
  status = FALSE,
  stats = NULL,
  format = c("markdown", "latex", "html", "plain"),
  style = c("apa", "econ"),
  alpha = 0.05,
  digits = 2,
  p_digits = 3
)
```

## Arguments

- x:

  A `cr_hypotheses`, `clean_results`, or `cr_tests` object.

- dv, variables:

  Optional filters for a results object.

- contrasts:

  Include pairwise contrasts (results objects).

- intercept:

  Include the intercept (results objects).

- status:

  Add each hypothesis's mechanical status (expectation met or not) after
  its paragraph. Off by default: that call is yours to make.

- stats:

  Which pieces to include, in order: any of `"est"`, `"se"`, `"ci"`,
  `"test"`, `"p"`, `"es"` (effect size). `NULL` uses the style's
  default.

- format:

  `"markdown"` (Quarto/R Markdown), `"latex"`, `"html"`, or `"plain"`
  (for pasting into Google Docs or Word).

- style:

  `"apa"` (italic symbols, no leading zero for *p*, *r*) or `"econ"`
  (estimate with SE and *p* in parentheses, leading zeros).

- alpha:

  Threshold for the significance wording.

- digits, p_digits:

  Decimal places.

## Value

A `cr_text` object (a character string that prints as text and renders
as-is in documents).
