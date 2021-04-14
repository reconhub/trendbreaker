
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
library(future)
plan("multisession")

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
res <- asmodee(counts_overall, models, date_index = "date", method = evaluate_aic, simulate_pi = TRUE)
res
#> $k
#> [1] 1
#> 
#> $model_name
#> [1] "negbin_time_weekday"
#> 
#> $trending_model_fit
#> $fitted_model
#> 
#> Call:  MASS::glm.nb(formula = count ~ day + weekday, data = data, init.theta = 42.98833929, 
#>     link = log)
#> 
#> Coefficients:
#>    (Intercept)             day   weekdaymonday  weekdayweekend  
#>       11.06830        -0.02649         0.19929        -0.13539  
#> 
#> Degrees of Freedom: 41 Total (i.e. Null);  38 Residual
#> Null Deviance:       230.4 
#> Residual Deviance: 42.18     AIC: 789.4
#> 
#> $predict
#> function (newdata, alpha = 0.05, add_pi = TRUE, simulate_pi = TRUE, 
#>     uncertain = TRUE) 
#> {
#>     if (missing(newdata)) {
#>         newdata <- data[all.vars(formula(model))]
#>     }
#>     result <- add_confidence_interval(model, newdata, alpha)
#>     if (add_pi) {
#>         if (simulate_pi) {
#>             result <- add_prediction_interval(model, result, 
#>                 alpha, simulate_pi, uncertain)
#>         }
#>         else {
#>             result <- add_prediction_interval(model, result, 
#>                 alpha, simulate_pi, uncertain)
#>         }
#>     }
#>     result
#> }
#> <bytecode: 0x55ff9a9e76c8>
#> <environment: 0x55ff9a108580>
#> 
#> attr(,"class")
#> [1] "trending_model_fit" "list"              
#> 
#> $alpha
#> [1] 0.05
#> 
#> $results
#>          date day      weekday count training  estimate  lower_ci upper_ci
#> 1  2020-04-16  29 rest_of_week 29497     TRUE 29737.341 26841.579 32945.51
#> 2  2020-04-17  30 rest_of_week 27007     TRUE 28960.014 26220.406 31985.87
#> 3  2020-04-18  31      weekend 25453     TRUE 24631.828 21978.663 27605.27
#> 4  2020-04-19  32      weekend 23387     TRUE 23987.958 21455.713 26819.06
#> 5  2020-04-20  33       monday 29287     TRUE 32646.622 28274.728 37694.51
#> 6  2020-04-21  34 rest_of_week 23134     TRUE 26048.655 23859.609 28438.54
#> 7  2020-04-22  35 rest_of_week 21803     TRUE 25367.750 23298.530 27620.74
#> 8  2020-04-23  36 rest_of_week 22298     TRUE 24704.643 22748.361 26829.16
#> 9  2020-04-24  37 rest_of_week 22027     TRUE 24058.869 22208.739 26063.13
#> 10 2020-04-25  38      weekend 18861     TRUE 20463.178 18530.598 22597.31
#> 11 2020-04-26  39      weekend 19569     TRUE 19928.276 18076.090 21970.25
#> 12 2020-04-27  40       monday 25628     TRUE 27121.562 23749.117 30972.90
#> 13 2020-04-28  41 rest_of_week 24236     TRUE 21640.224 20148.573 23242.31
#> 14 2020-04-29  42 rest_of_week 25552     TRUE 21074.554 19656.406 22595.02
#> 15 2020-04-30  43 rest_of_week 22387     TRUE 20523.670 19172.757 21969.77
#> 16 2020-05-01  44 rest_of_week 19852     TRUE 19987.186 18697.348 21366.00
#> 17 2020-05-02  45      weekend 17761     TRUE 17000.024 15526.990 18612.80
#> 18 2020-05-03  46      weekend 19349     TRUE 16555.648 15130.182 18115.41
#> 19 2020-05-04  47       monday 24385     TRUE 22531.554 19845.563 25581.08
#> 20 2020-05-05  48 rest_of_week 20218     TRUE 17977.868 16873.790 19154.19
#> 21 2020-05-06  49 rest_of_week 16498     TRUE 17507.931 16436.703 18648.97
#> 22 2020-05-07  50 rest_of_week 15257     TRUE 17050.278 16007.012 18161.54
#> 23 2020-05-08  51 rest_of_week 13230     TRUE 16604.588 15584.731 17691.18
#> 24 2020-05-09  52      weekend 12780     TRUE 14122.968 12906.814 15453.72
#> 25 2020-05-10  53      weekend 14946     TRUE 13753.797 12561.857 15058.84
#> 26 2020-05-11  54       monday 19542     TRUE 18718.351 16486.818 21251.93
#> 27 2020-05-12  55 rest_of_week 17299     TRUE 14935.324 13971.137 15966.05
#> 28 2020-05-13  56 rest_of_week 16891     TRUE 14544.918 13587.132 15570.22
#> 29 2020-05-14  57 rest_of_week 14750     TRUE 14164.717 13211.099 15187.17
#> 30 2020-05-15  58 rest_of_week 13638     TRUE 13794.455 12843.129 14816.25
#> 31 2020-05-16  59      weekend 12874     TRUE 11732.821 10641.971 12935.49
#> 32 2020-05-17  60      weekend 12635     TRUE 11426.128 10346.634 12618.25
#> 33 2020-05-18  61       monday 21868     TRUE 15550.489 13616.583 17759.06
#> 34 2020-05-19  62 rest_of_week 18207     TRUE 12407.694 11452.978 13442.00
#> 35 2020-05-20  63 rest_of_week 12966     TRUE 12083.360 11125.945 13123.16
#> 36 2020-05-21  64 rest_of_week 10543     TRUE 11767.504 10807.063 12813.30
#> 37 2020-05-22  65 rest_of_week  9212     TRUE 11459.904 10496.268 12512.01
#> 38 2020-05-23  66      weekend  8030     TRUE  9747.178  8717.784 10898.12
#> 39 2020-05-24  67      weekend  8123     TRUE  9492.389  8469.482 10638.84
#> 40 2020-05-25  68       monday  8079     TRUE 12918.750 11188.383 14916.73
#> 41 2020-05-26  69 rest_of_week  9275     TRUE 10307.837  9332.143 11385.54
#> 42 2020-05-27  70 rest_of_week  8486     TRUE 10038.393  9060.304 11122.07
#> 43 2020-05-28  71 rest_of_week  8411    FALSE  9775.991  8795.879 10865.32
#>    lower_pi upper_pi outlier classification
#> 1     21256    39622   FALSE         normal
#> 2     20620    39369   FALSE         normal
#> 3     17250    33065   FALSE         normal
#> 4     16983    32581   FALSE         normal
#> 5     23108    44722   FALSE         normal
#> 6     18512    34785   FALSE         normal
#> 7     18318    33826   FALSE         normal
#> 8     17932    32973   FALSE         normal
#> 9     17485    32431   FALSE         normal
#> 10    14700    27509   FALSE         normal
#> 11    14183    26421   FALSE         normal
#> 12    18966    36889   FALSE         normal
#> 13    15668    29023   FALSE         normal
#> 14    15094    28270   FALSE         normal
#> 15    14683    27166   FALSE         normal
#> 16    14417    26618   FALSE         normal
#> 17    12166    22603   FALSE         normal
#> 18    11753    22189   FALSE         normal
#> 19    15732    30580   FALSE         normal
#> 20    12921    23809   FALSE         normal
#> 21    12729    23377   FALSE         normal
#> 22    12170    22745   FALSE         normal
#> 23    12045    22446   FALSE         normal
#> 24    10094    18952   FALSE         normal
#> 25     9776    18373   FALSE         normal
#> 26    13358    25205   FALSE         normal
#> 27    10806    19804   FALSE         normal
#> 28    10454    19470   FALSE         normal
#> 29    10098    19140   FALSE         normal
#> 30     9841    18579   FALSE         normal
#> 31     8271    15552   FALSE         normal
#> 32     8162    15619   FALSE         normal
#> 33    11217    20911    TRUE       increase
#> 34     8836    16334    TRUE       increase
#> 35     8756    15883   FALSE         normal
#> 36     8428    15805   FALSE         normal
#> 37     8089    15391   FALSE         normal
#> 38     6856    12946   FALSE         normal
#> 39     6821    12762   FALSE         normal
#> 40     9047    17732    TRUE       decrease
#> 41     7390    13814   FALSE         normal
#> 42     7218    13293   FALSE         normal
#> 43     6840    13268   FALSE         normal
#> 
#> $date_index
#> [1] "date"
#> 
#> $last_training_date
#> [1] "2020-05-27"
#> 
#> $first_testing_date
#> [1] "2020-05-28"
#> 
#> $.fitted_results
#> NULL
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
  left_join(lookup, by = c("date_index" = "date"))

# define candidate models
models <- list(
  regression = lm_model(count ~ day),
  poisson_constant = glm_model(count ~ 1, family = "poisson"),
  negbin_time = glm_nb_model(count ~ day),
  negbin_time_weekday = glm_nb_model(count ~ day + weekday)
)

# analyses on all data
res <- asmodee(dat, models, method = evaluate_aic, k = 7)

plot(res)
```

<img src="man/figures/README-incidence2-1.png" style="display: block; margin: auto;" />
