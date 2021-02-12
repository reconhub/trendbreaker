
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
#> function (newdata, alpha = 0.05, add_pi = TRUE, simulate_pi = FALSE, 
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
#> <bytecode: 0x564280c3ddf0>
#> <environment: 0x564286959b30>
#> 
#> attr(,"class")
#> [1] "trending_model_fit" "list"              
#> 
#> $n_outliers
#> [1] 3
#> 
#> $n_outliers_train
#> [1] 3
#> 
#> $n_outliers_recent
#> [1] 0
#> 
#> $p_value
#> [1] 0.1665987
#> 
#> $results
#>          date day      weekday count  estimate  lower_ci upper_ci lower_pi
#> 1  2020-04-16  29 rest_of_week 29497 29866.112 26975.633 33066.31    21387
#> 2  2020-04-17  30 rest_of_week 27007 29071.949 26337.005 32090.90    20622
#> 3  2020-04-18  31      weekend 25453 24835.238 22200.222 27783.01    17925
#> 4  2020-04-19  32      weekend 23387 24174.851 21658.947 26983.00    17141
#> 5  2020-04-20  33       monday 29287 32912.569 28548.286 37944.04    23354
#> 6  2020-04-21  34 rest_of_week 23134 26100.933 23915.207 28486.42    18801
#> 7  2020-04-22  35 rest_of_week 21803 25406.890 23341.012 27655.62    18093
#> 8  2020-04-23  36 rest_of_week 22298 24731.302 22778.559 26851.45    18050
#> 9  2020-04-24  37 rest_of_week 22027 24073.678 22227.471 26073.23    17434
#> 10 2020-04-25  38      weekend 18861 20565.374 18640.176 22689.41    14767
#> 11 2020-04-26  39      weekend 19569 20018.526 18172.629 22051.92    14138
#> 12 2020-04-27  40       monday 25628 27253.989 23884.320 31099.06    19113
#> 13 2020-04-28  41 rest_of_week 24236 21613.462 20129.447 23206.88    15486
#> 14 2020-04-29  42 rest_of_week 25552 21038.744 19629.754 22548.87    15040
#> 15 2020-04-30  43 rest_of_week 22387 20479.308 19139.321 21913.11    14733
#> 16 2020-05-01  44 rest_of_week 19852 19934.748 18657.846 21299.04    14223
#> 17 2020-05-02  45      weekend 17761 17029.618 15559.416 18638.74    12052
#> 18 2020-05-03  46      weekend 19349 16576.788 15154.130 18133.00    11961
#> 19 2020-05-04  47       monday 24385 22568.275 19886.020 25612.32    16403
#> 20 2020-05-05  48 rest_of_week 20218 17897.510 16816.496 19048.02    12797
#> 21 2020-05-06  49 rest_of_week 16498 17421.602 16376.348 18533.57    12605
#> 22 2020-05-07  50 rest_of_week 15257 16958.349 15944.040 18037.18    12315
#> 23 2020-05-08  51 rest_of_week 13230 16507.414 15519.528 17558.18    11847
#> 24 2020-05-09  52      weekend 12780 14101.756 12891.373 15425.78    10402
#> 25 2020-05-10  53      weekend 14946 13726.780 12541.540 15024.03     9868
#> 26 2020-05-11  54       monday 19542 18688.165 16466.954 21208.99    13367
#> 27 2020-05-12  55 rest_of_week 17299 14820.434 13899.746 15802.11    10745
#> 28 2020-05-13  56 rest_of_week 16891 14426.347 13514.648 15399.55    10488
#> 29 2020-05-14  57 rest_of_week 14750 14042.740 13137.637 15010.20    10008
#> 30 2020-05-15  58 rest_of_week 13638 13669.333 12768.780 14633.40     9936
#> 31 2020-05-16  59      weekend 12874 11677.275 10600.167 12863.83     8308
#> 32 2020-05-17  60      weekend 12635 11366.767 10302.312 12541.20     8117
#> 33 2020-05-18  61       monday 21868 15475.153 13561.555 17658.77    10744
#> 34 2020-05-19  62 rest_of_week 18207 12272.392 11375.758 13239.70     8768
#> 35 2020-05-20  63 rest_of_week 12966 11946.060 11048.148 12916.95     8444
#> 36 2020-05-21  64 rest_of_week 10543 11628.405 10728.741 12603.51     8448
#> 37 2020-05-22  65 rest_of_week  9212 11319.197 10417.477 12298.97     7983
#> 38 2020-05-23  66      weekend  8030  9669.629  8662.868 10793.39     7004
#> 39 2020-05-24  67      weekend  8123  9412.506  8413.406 10530.25     6676
#> 40 2020-05-25  68       monday  8079 12814.547 11114.981 14773.99     9039
#> 41 2020-05-26  69 rest_of_week  9275 10162.428  9252.027 11162.41     7298
#> 42 2020-05-27  70 rest_of_week  8486  9892.202  8979.999 10897.07     7180
#> 43 2020-05-28  71 rest_of_week  8411  9629.161  8715.443 10638.67     6713
#>    upper_pi outlier classification
#> 1     40395   FALSE         normal
#> 2     39562   FALSE         normal
#> 3     32848   FALSE         normal
#> 4     32085   FALSE         normal
#> 5     44723   FALSE         normal
#> 6     34805   FALSE         normal
#> 7     33776   FALSE         normal
#> 8     32834   FALSE         normal
#> 9     31986   FALSE         normal
#> 10    27228   FALSE         normal
#> 11    27043   FALSE         normal
#> 12    37563   FALSE         normal
#> 13    28870   FALSE         normal
#> 14    28030   FALSE         normal
#> 15    27078   FALSE         normal
#> 16    26863   FALSE         normal
#> 17    22464   FALSE         normal
#> 18    21948   FALSE         normal
#> 19    30715   FALSE         normal
#> 20    23651   FALSE         normal
#> 21    23245   FALSE         normal
#> 22    22257   FALSE         normal
#> 23    21742   FALSE         normal
#> 24    18730   FALSE         normal
#> 25    18274   FALSE         normal
#> 26    25428   FALSE         normal
#> 27    19810   FALSE         normal
#> 28    19134   FALSE         normal
#> 29    18463   FALSE         normal
#> 30    18331   FALSE         normal
#> 31    15388   FALSE         normal
#> 32    15243   FALSE         normal
#> 33    20871    TRUE       increase
#> 34    16244    TRUE       increase
#> 35    16234   FALSE         normal
#> 36    15615   FALSE         normal
#> 37    15050   FALSE         normal
#> 38    13004   FALSE         normal
#> 39    12702   FALSE         normal
#> 40    17313    TRUE       decrease
#> 41    13677   FALSE         normal
#> 42    13171   FALSE         normal
#> 43    12804   FALSE         normal
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
