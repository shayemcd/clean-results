# Clean a variable or level name for display

Splits camelCase (`GainFraming` -\> "Gain framing"), turns underscores,
dots, and word hyphens into spaces (`low-income` -\> "Low income"),
keeps numeric ranges as en dashes (`18-24` -\> "18-24" with an en dash),
and applies a case. Acronyms written in capitals (`SES`, `GPA`) are
kept, and `id` becomes "ID".

## Usage

``` r
clean_label(x, case = c("sentence", "title", "asis"))
```

## Arguments

- x:

  Character vector.

- case:

  `"sentence"` (default), `"title"`, or `"asis"`.

## Value

Character vector.

## Examples

``` r
clean_label(c("GainFraming", "age_years", "low-income", "18-24", "SES_score"))
#> [1] "Gain framing" "Age years"    "Low income"   "18–24"        "SES score"   
```
