# Stop rendering when a claim in your text stops holding

Put `cr_expect()` calls in a hidden chunk next to hand-written claims
(in the abstract or discussion, say). If a re-run changes the sign or
the significance of a result, rendering fails with a message naming the
claim, instead of the old sentence silently surviving.

## Usage

``` r
cr_expect(
  x,
  dv = NULL,
  variable = NULL,
  level = NULL,
  sign = NULL,
  sig = NULL,
  alpha = 0.05,
  action = c("error", "warning"),
  claim = NULL,
  subgroup = NULL
)
```

## Arguments

- x:

  A `clean_results`/`cr_tests` object, or a `cr_hypotheses` object (then
  every test with an `expect` is checked).

- dv:

  Outcome name (raw or displayed label).

- variable:

  Predictor or grouping variable, or a coefficient name such as `"age"`.
  For correlations, the other variable.

- level:

  Factor level as in the data (`"LossFraming"`) or as displayed
  (`"Loss framing"`); for contrasts, `"Loss vs. Gain"` in either form.

- sign:

  `"+"`, `"-"`, or `NULL` (don't check).

- sig:

  `TRUE` (must be significant), `FALSE` (must not be), or `NULL`.

- alpha:

  Significance threshold.

- action:

  `"error"` (stop rendering) or `"warning"`.

- claim:

  Optional text of the claim, shown in the message.

- subgroup:

  For tests run with `by`, which subgroup.

## Value

`TRUE` invisibly when every check passes.
