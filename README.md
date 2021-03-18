
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
res <- asmodee(counts_overall, models, date_index = "date", method = evaluate_aic, simulate_pi = TRUE)
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
#> <bytecode: 0x556cfb348d30>
#> <environment: 0x556cfc5e9c70>
#> 
#> attr(,"class")
#> [1] "trending_model_fit" "list"              
#> 
#> $alpha
#> [1] 0.05
#> 
#> $results
#>          date day      weekday count training  estimate  lower_ci upper_ci
#> 1  2020-04-16  29 rest_of_week 29497     TRUE 29866.112 26975.633 33066.31
#> 2  2020-04-17  30 rest_of_week 27007     TRUE 29071.949 26337.005 32090.90
#> 3  2020-04-18  31      weekend 25453     TRUE 24835.238 22200.222 27783.01
#> 4  2020-04-19  32      weekend 23387     TRUE 24174.851 21658.947 26983.00
#> 5  2020-04-20  33       monday 29287     TRUE 32912.569 28548.286 37944.04
#> 6  2020-04-21  34 rest_of_week 23134     TRUE 26100.933 23915.207 28486.42
#> 7  2020-04-22  35 rest_of_week 21803     TRUE 25406.890 23341.012 27655.62
#> 8  2020-04-23  36 rest_of_week 22298     TRUE 24731.302 22778.559 26851.45
#> 9  2020-04-24  37 rest_of_week 22027     TRUE 24073.678 22227.471 26073.23
#> 10 2020-04-25  38      weekend 18861     TRUE 20565.374 18640.176 22689.41
#> 11 2020-04-26  39      weekend 19569     TRUE 20018.526 18172.629 22051.92
#> 12 2020-04-27  40       monday 25628     TRUE 27253.989 23884.320 31099.06
#> 13 2020-04-28  41 rest_of_week 24236     TRUE 21613.462 20129.447 23206.88
#> 14 2020-04-29  42 rest_of_week 25552     TRUE 21038.744 19629.754 22548.87
#> 15 2020-04-30  43 rest_of_week 22387     TRUE 20479.308 19139.321 21913.11
#> 16 2020-05-01  44 rest_of_week 19852     TRUE 19934.748 18657.846 21299.04
#> 17 2020-05-02  45      weekend 17761     TRUE 17029.618 15559.416 18638.74
#> 18 2020-05-03  46      weekend 19349     TRUE 16576.788 15154.130 18133.00
#> 19 2020-05-04  47       monday 24385     TRUE 22568.275 19886.020 25612.32
#> 20 2020-05-05  48 rest_of_week 20218     TRUE 17897.510 16816.496 19048.02
#> 21 2020-05-06  49 rest_of_week 16498     TRUE 17421.602 16376.348 18533.57
#> 22 2020-05-07  50 rest_of_week 15257     TRUE 16958.349 15944.040 18037.18
#> 23 2020-05-08  51 rest_of_week 13230     TRUE 16507.414 15519.528 17558.18
#> 24 2020-05-09  52      weekend 12780     TRUE 14101.756 12891.373 15425.78
#> 25 2020-05-10  53      weekend 14946     TRUE 13726.780 12541.540 15024.03
#> 26 2020-05-11  54       monday 19542     TRUE 18688.165 16466.954 21208.99
#> 27 2020-05-12  55 rest_of_week 17299     TRUE 14820.434 13899.746 15802.11
#> 28 2020-05-13  56 rest_of_week 16891     TRUE 14426.347 13514.648 15399.55
#> 29 2020-05-14  57 rest_of_week 14750     TRUE 14042.740 13137.637 15010.20
#> 30 2020-05-15  58 rest_of_week 13638     TRUE 13669.333 12768.780 14633.40
#> 31 2020-05-16  59      weekend 12874     TRUE 11677.275 10600.167 12863.83
#> 32 2020-05-17  60      weekend 12635     TRUE 11366.767 10302.312 12541.20
#> 33 2020-05-18  61       monday 21868     TRUE 15475.153 13561.555 17658.77
#> 34 2020-05-19  62 rest_of_week 18207     TRUE 12272.392 11375.758 13239.70
#> 35 2020-05-20  63 rest_of_week 12966     TRUE 11946.060 11048.148 12916.95
#> 36 2020-05-21  64 rest_of_week 10543     TRUE 11628.405 10728.741 12603.51
#> 37 2020-05-22  65 rest_of_week  9212     TRUE 11319.197 10417.477 12298.97
#> 38 2020-05-23  66      weekend  8030     TRUE  9669.629  8662.868 10793.39
#> 39 2020-05-24  67      weekend  8123     TRUE  9412.506  8413.406 10530.25
#> 40 2020-05-25  68       monday  8079     TRUE 12814.547 11114.981 14773.99
#> 41 2020-05-26  69 rest_of_week  9275     TRUE 10162.428  9252.027 11162.41
#> 42 2020-05-27  70 rest_of_week  8486     TRUE  9892.202  8979.999 10897.07
#> 43 2020-05-28  71 rest_of_week  8411     TRUE  9629.161  8715.443 10638.67
#>    lower_pi upper_pi outlier classification
#> 1     21492    40258   FALSE         normal
#> 2     21133    39501   FALSE         normal
#> 3     17287    33551   FALSE         normal
#> 4     17379    32027   FALSE         normal
#> 5     23379    44969   FALSE         normal
#> 6     18637    35057   FALSE         normal
#> 7     18082    33923   FALSE         normal
#> 8     17811    32972   FALSE         normal
#> 9     17419    32253   FALSE         normal
#> 10    14633    27520   FALSE         normal
#> 11    14007    26788   FALSE         normal
#> 12    19284    37314   FALSE         normal
#> 13    15806    28577   FALSE         normal
#> 14    15271    27976   FALSE         normal
#> 15    14686    27261   FALSE         normal
#> 16    14148    26425   FALSE         normal
#> 17    12144    22720   FALSE         normal
#> 18    12092    22206   FALSE         normal
#> 19    15933    30879   FALSE         normal
#> 20    12915    23981   FALSE         normal
#> 21    12352    23047   FALSE         normal
#> 22    12289    22607   FALSE         normal
#> 23    11894    22035   FALSE         normal
#> 24    10256    18791   FALSE         normal
#> 25     9818    18715   FALSE         normal
#> 26    12949    25062   FALSE         normal
#> 27    10809    19816   FALSE         normal
#> 28    10345    19145   FALSE         normal
#> 29    10077    18453   FALSE         normal
#> 30     9942    18066   FALSE         normal
#> 31     8484    15617   FALSE         normal
#> 32     8102    15330   FALSE         normal
#> 33    11024    20993    TRUE       increase
#> 34     8823    16288    TRUE       increase
#> 35     8482    16041   FALSE         normal
#> 36     8339    15730   FALSE         normal
#> 37     8156    15123   FALSE         normal
#> 38     6829    13011   FALSE         normal
#> 39     6735    12635   FALSE         normal
#> 40     8904    17663    TRUE       decrease
#> 41     7298    13716   FALSE         normal
#> 42     7021    13181   FALSE         normal
#> 43     7013    13126   FALSE         normal
#> 
#> $date_index
#> [1] "date"
#> 
#> $last_training_date
#> [1] "2020-05-28"
#> 
#> $first_testing_date
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
res <- asmodee(dat, models, method = evaluate_aic, fixed_k = 7)

plot(res)
```

<img src="man/figures/README-incidence2-1.png" style="display: block; margin: auto;" />
