# Simulated example data

A small simulated data set so the examples in the documentation and
vignettes run without any files. It has repeated measures (`k`
observations for each of `n_id` participants), a three-level
between-person `condition`, a continuous and a binary outcome, and a
random participant intercept, which makes it suitable for mixed models.
The effects are arbitrary; do not read anything into them.

## Usage

``` r
cr_example_data(n_id = 80, k = 4, seed = 42)
```

## Arguments

- n_id:

  Number of participants.

- k:

  Observations per participant.

- seed:

  Random seed. The global random-number state is left unchanged.

## Value

A data frame with `n_id * k` rows and columns `id` (factor), `condition`
(factor: Control, Gain, Loss), `age`, `female` (logical), `trust` and
`score` (continuous outcomes), and `share` and `bought` (binary
outcomes).

## Examples

``` r
d <- cr_example_data()
head(d)
#>   id condition age female    trust share    score bought
#> 1  1   Control  41   TRUE 5.572484     1 1.623653      1
#> 2  1   Control  41   TRUE 3.240904     1 2.741360      0
#> 3  1   Control  41   TRUE 3.536337     0 1.900393      1
#> 4  1   Control  41   TRUE 4.321342     1 1.345710      1
#> 5  2   Control  43   TRUE 2.261628     1 2.971164      1
#> 6  2   Control  43   TRUE 2.895940     1 2.013496      1
res <- clean_regress(d, dvs = c(trust = "linear"), predictors = ~ condition)
res
#> ──────────────────────────────────────────────── 
#>                              Trust             
#>                              Linear            
#>                     b        95% CI        p   
#> ──────────────────────────────────────────────── 
#> Intercept          3.40    [3.17, 3.62]   < .001
#> Condition                                       
#>   Control (ref.)     —                          
#>   Gain             0.41    [0.08, 0.74]    .015 
#>   Loss             -0.24   [-0.65, 0.16]   .241 
#> Model fit                                       
#>   Observations      320                         
#>   R²               0.04                         
#>   AIC             1101.51                       
#> ──────────────────────────────────────────────── 
#> Note. b = unstandardized coefficient; CI = confidence
#> interval. CIs and p-values use HC3 robust SEs. (ref.) marks
#> the reference category for each factor.
```
