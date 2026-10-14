# What changed between two runs?

Compares two ground-truth exports and lists every estimate whose
reported value changed, flagging the changes that make existing prose
wrong: a sign flip or a crossing of the significance threshold. Run it
after changing code or data to see which sentences need re-reading.

## Usage

``` r
cr_diff(old, new, alpha = 0.05)
```

## Arguments

- old, new:

  `cr_ground_truth` objects or paths to `.json` exports.

- alpha:

  Significance threshold.

## Value

A data frame with one row per changed, added, or removed estimate.
