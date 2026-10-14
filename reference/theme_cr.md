# Publication ggplot2 themes

`theme_cr()` is the lab default (Nature/Science style): thin dark axes,
faint horizontal gridlines, bold axis titles, legend top-left, bold
lowercase panel tags. Journal variants: `"psychsci"` (APA 7 /
Psychological Science: black axes, no grid, italic note), `"jcr"`
(centered titles, legend at the bottom), and `"polsci"` (minimal, dashed
vertical grid, for coefficient plots). Sizes follow the figure guide:
axis titles about 9.5 pt bold, tick labels about 8.5 pt at the default
`base_size`.

## Usage

``` r
theme_cr(
  style = c("nature", "psychsci", "jcr", "polsci"),
  base_size = 10,
  base_family = "sans"
)
```

## Arguments

- style:

  `"nature"`, `"psychsci"`, `"jcr"`, or `"polsci"`.

- base_size:

  Base font size in points.

- base_family:

  Font family: `"sans"` (Helvetica/Arial), or e.g. `"Inter"` if
  installed.

## Value

A ggplot2 theme.
