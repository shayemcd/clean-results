# Export every reportable number, model, and hypothesis link

Produces three tables: `terms` (one row per estimate, with the exact
reported string), `models` (one row per model: N, fit, SE method,
corrections), and `hypotheses` (which result answers which hypothesis,
and its robustness checks). Save it as JSON for an LLM or for
[`cr_diff()`](https://shayemcd.github.io/clean-results/reference/cr_diff.md),
or as Markdown to paste into a chat.

## Usage

``` r
cr_ground_truth(
  ...,
  path = NULL,
  compare = TRUE,
  style = "apa",
  digits = 2,
  p_digits = 3
)
```

## Arguments

- ...:

  Sources: `clean_results`, `cr_tests`, or `cr_hypotheses` objects. Name
  them (`main = res`) to control how they are labelled; a
  `cr_hypotheses` object also contributes every source it points to.

- path:

  Optional file to write: `.json`, `.md`, or `.csv` (terms only).

- compare:

  When `path` already exists as JSON, compare against it and report what
  changed before overwriting (see
  [`cr_diff()`](https://shayemcd.github.io/clean-results/reference/cr_diff.md)).

- style, digits, p_digits:

  Used for the `reported` strings.

## Value

A `cr_ground_truth` object (invisibly when `path` is given).
