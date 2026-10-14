# Check every number in a manuscript against the results

Pulls each number out of a text (a string, or a `.qmd`, `.Rmd`, `.md`,
`.tex`, `.txt`, `.html`, or `.docx` file) and looks for a matching value
in the results, allowing for legitimate rounding. Numbers produced by
inline R code in a `.qmd`/`.Rmd` are skipped because they come from the
results by construction: what is left are the numbers someone typed. Run
it on a `.docx` downloaded from Google Docs to catch edits made after
export.

## Usage

``` r
cr_verify(text, ..., strict = FALSE, ignore = NULL)
```

## Arguments

- text:

  A character string or a file path.

- ...:

  Sources: `clean_results`, `cr_tests`, `cr_hypotheses`, or
  `cr_ground_truth` objects.

- strict:

  If `TRUE`, stop with an error when any number is unmatched or matches
  only with the opposite sign (use in a render to block drift).

- ignore:

  Extra numbers to skip, e.g. sample sizes stated in Methods.

## Value

A `cr_verify` data frame: each number, its context, and the matching
result(s).

## Details

A match means the number exists somewhere in the results, not that the
sentence attaches it to the right result. Checking that the prose says
the right thing about the right comparison is a reading task: hand the
[`cr_ground_truth()`](https://shayemcd.github.io/clean-results/reference/cr_ground_truth.md)
export and the text to a reviewer or an LLM for that.
