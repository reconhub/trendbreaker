
<!-- README.md is generated from README.Rmd. Please edit that file -->

# trendbreaker

<!-- badges: start -->

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3888494.svg)](https://doi.org/10.5281/zenodo.3888494)
[![R build
status](https://github.com/reconhub/trendbreaker/workflows/R-CMD-check/badge.svg)](https://github.com/reconhub/trendbreaker/actions)
[![Codecov test
coverage](https://codecov.io/gh/reconhub/trendbreaker/branch/master/graph/badge.svg)](https://codecov.io/gh/reconhub/trendbreaker?branch=master)
<!-- badges: end -->

The *trendbreaker* package implements tools for detecting changes in
temporal trends of a single response variable. It implements the
**A**utomatic **S**election of **M**odels and **O**utlier **De**tection
for **E**pidemmics (ASMODEE), an algorithm originally designed for
detecting changes in COVID-19 case incidence.

ASMODEE proceeds by:

1.  defining a training set excluding the last *k* data points
2.  identifying the temporal trend in the training set by fitting a
    range of (user-specified) models to the data and retaining the best
    predicting / fitting model
3.  calculating the prediction interval (PI) of the temporal trend
4.  classifying any data point outside the PI as outlier

The algorithm can be applied with fixed, user-specified value of *k*, so
as to monitor potential changes in this recent time period.
Alternatively, the optimal value of *k* can be determined automatically.

**Disclaimer:** this is work in progress. Please reach out to the
authors before using this package. Also note this package may soon be
renamed to avoid clashes with other projects and reflect a more general
scope.

## Getting started

Once it is released on [CRAN](https://CRAN.R-project.org), you will be
able to install the stable version of the package with:

``` r
install.packages("trendbreaker")
```

The development version can be installed from
[GitHub](https://github.com/) with:

``` r
if (!require(remotes)) {
  install.packages("remotes")
}
remotes::install_github("reconhub/trendbreaker")
```

The best place to start for using this package is to read the
documentation of the function `asmodee` and run its example:

``` r
library(trendbreaker)
?asmodee
example(asmodee)
```

## Main features

The package implements the following main functions

  - `asmodee`: implements the Automatic Selection of Models and Outlier
    DEtection for Epidemics

  - `detect_changepoint`: a function to detect the points at which
    recent data deviate from previous temporal trends using a fitted
    model and data

  - `detect_outliers`: a function to identify outliers using a fitted
    model and data

### ASMODEE

We illustrate ASMODEE using publicly available NHS pathways data
recording self-reporting of potential COVID-19 cases in England (see
`?nhs_pathways_covid19` for more information).

``` r
library(trendbreaker) # for ASMODEE
library(dplyr)        # for data manipulation
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

# load data
data(nhs_pathways_covid19)

# select last 6 weeks of data
first_date <- max(nhs_pathways_covid19$date, na.rm = TRUE) - 6*7
pathways_recent <- nhs_pathways_covid19 %>%
  filter(date >= first_date)

# define candidate models
models <- list(
  regression = lm_model(count ~ day),
  poisson_constant = glm_model(count ~ 1, family = "poisson"),
  negbin_time = glm_nb_model(count ~ day),
  negbin_time_weekday = glm_nb_model(count ~ day + weekday)
)

# analyses on all data
counts_overall <- pathways_recent %>%
  group_by(date, day, weekday) %>%
  summarise(count = sum(count))
#> `summarise()` has grouped output by 'date', 'day'. You can override using the `.groups` argument.

# results with automated detection of 'k'
res <- asmodee(counts_overall, models, method = evaluate_aic, simulate_pi = TRUE)
res
#> $k
#> [1] 0
#> 
#> $model
#> $fitted_model
#> 
#> Call:  MASS::glm.nb(formula = count ~ day + weekday, data = data, init.theta = 43.15973225, 
#>     link = log)
#> 
#> Coefficients:
#>    (Intercept)             day   weekdaymonday  weekdayweekend  
#>       11.08605        -0.02695         0.20493        -0.13056  
#> 
#> Degrees of Freedom: 42 Total (i.e. Null);  39 Residual
#> Null Deviance:       250.7 
#> Residual Deviance: 43.18     AIC: 806.4
#> 
#> $predict
#> function (newdata, alpha = 0.05, add_pi = TRUE, uncertain = TRUE) 
#> {
#>     if (missing(newdata)) {
#>         newdata <- data[all.vars(formula(model))]
#>     }
#>     result <- add_confidence_interval(model, newdata, alpha)
#>     if (add_pi) {
#>         result <- add_prediction_interval(model, result, alpha, 
#>             uncertain)
#>     }
#>     result
#> }
#> <bytecode: 0x7fb0f46d48d0>
#> <environment: 0x7fb0fa2ec940>
#> 
#> attr(,"class")
#> [1] "trending_model_fit" "list"              
#> 
#> $n_outliers
#> [1] 1
#> 
#> $n_outliers_train
#> [1] 1
#> 
#> $n_outliers_recent
#> [1] 0
#> 
#> $p_value
#> [1] 0.6404551
#> 
#> $results
#> [90m# A tibble: 43 x 11[39m
#> [90m# Groups:   date, day [43][39m
#>    date         day weekday count estimate lower_ci upper_ci lower_pi upper_pi
#>    [3m[90m<date>[39m[23m     [3m[90m<int>[39m[23m [3m[90m<fct>[39m[23m   [3m[90m<int>[39m[23m    [3m[90m<dbl>[39m[23m    [3m[90m<dbl>[39m[23m    [3m[90m<dbl>[39m[23m    [3m[90m<dbl>[39m[23m    [3m[90m<dbl>[39m[23m
#> [90m 1[39m 2020-04-16    29 rest_o… [4m2[24m[4m9[24m497   [4m2[24m[4m9[24m866.   [4m2[24m[4m6[24m976.   [4m3[24m[4m3[24m066.    [4m1[24m[4m9[24m529    [4m4[24m[4m3[24m643
#> [90m 2[39m 2020-04-17    30 rest_o… [4m2[24m[4m7[24m007   [4m2[24m[4m9[24m072.   [4m2[24m[4m6[24m337.   [4m3[24m[4m2[24m091.    [4m1[24m[4m9[24m067    [4m4[24m[4m2[24m355
#> [90m 3[39m 2020-04-18    31 weekend [4m2[24m[4m5[24m453   [4m2[24m[4m4[24m835.   [4m2[24m[4m2[24m200.   [4m2[24m[4m7[24m783.    [4m1[24m[4m6[24m071    [4m3[24m[4m6[24m671
#> [90m 4[39m 2020-04-19    32 weekend [4m2[24m[4m3[24m387   [4m2[24m[4m4[24m175.   [4m2[24m[4m1[24m659.   [4m2[24m[4m6[24m983.    [4m1[24m[4m5[24m679    [4m3[24m[4m5[24m615
#> [90m 5[39m 2020-04-20    33 monday  [4m2[24m[4m9[24m287   [4m3[24m[4m2[24m913.   [4m2[24m[4m8[24m548.   [4m3[24m[4m7[24m944.    [4m2[24m[4m0[24m668    [4m5[24m[4m0[24m079
#> [90m 6[39m 2020-04-21    34 rest_o… [4m2[24m[4m3[24m134   [4m2[24m[4m6[24m101.   [4m2[24m[4m3[24m915.   [4m2[24m[4m8[24m486.    [4m1[24m[4m7[24m313    [4m3[24m[4m7[24m599
#> [90m 7[39m 2020-04-22    35 rest_o… [4m2[24m[4m1[24m803   [4m2[24m[4m5[24m407.   [4m2[24m[4m3[24m341.   [4m2[24m[4m7[24m656.    [4m1[24m[4m6[24m897    [4m3[24m[4m6[24m502
#> [90m 8[39m 2020-04-23    36 rest_o… [4m2[24m[4m2[24m298   [4m2[24m[4m4[24m731.   [4m2[24m[4m2[24m779.   [4m2[24m[4m6[24m851.    [4m1[24m[4m6[24m490    [4m3[24m[4m5[24m441
#> [90m 9[39m 2020-04-24    37 rest_o… [4m2[24m[4m2[24m027   [4m2[24m[4m4[24m074.   [4m2[24m[4m2[24m227.   [4m2[24m[4m6[24m073.    [4m1[24m[4m6[24m091    [4m3[24m[4m4[24m414
#> [90m10[39m 2020-04-25    38 weekend [4m1[24m[4m8[24m861   [4m2[24m[4m0[24m565.   [4m1[24m[4m8[24m640.   [4m2[24m[4m2[24m689.    [4m1[24m[4m3[24m493    [4m2[24m[4m9[24m949
#> [90m# … with 33 more rows, and 2 more variables: outlier [3m[90m<lgl>[90m[23m,[39m
#> [90m#   classification [3m[90m<fct>[90m[23m[39m
#> 
#> attr(,"class")
#> [1] "trendbreaker" "list"
plot(res, "date")
```

<img src="man/figures/README-asmodee-1.png" style="display: block; margin: auto;" />

ASMODEE would typically be more useful to investigate shifts in temporal
trends from a large number of time series (e.g. at a fine geographic
scale). To make this sort of analysis easier *trendbreaker* also works
with [*incidence2*](https://github.com/reconhub/incidence2/) objects. To
illustrate this we can consider trends over NHS regions.

``` r
library(incidence2)   # for `incidence()` objects

# select last 6 weeks of data
first_date <- max(nhs_pathways_covid19$date, na.rm = TRUE) - 6*7
pathways_recent <- filter(nhs_pathways_covid19, date >= first_date)

# create incidence object with extra variables
lookup <- select(pathways_recent, date, day, weekday) %>%  distinct()

dat <-
  pathways_recent %>%
  incidence(date_index = date, groups = nhs_region, count = count) %>%
  left_join(lookup, by = "date")

# define candidate models
models <- list(
  regression = lm_model(count ~ day),
  poisson_constant = glm_model(count ~ 1, family = "poisson"),
  negbin_time = glm_nb_model(count ~ day),
  negbin_time_weekday = glm_nb_model(count ~ day + weekday)
)

# analyses on all data
res <- asmodee(dat, models, method = evaluate_aic)

plot(res, "date")
```

<img src="man/figures/README-incidence2-1.png" style="display: block; margin: auto;" />
