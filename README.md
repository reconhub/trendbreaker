
<!-- README.md is generated from README.Rmd. Please edit that file -->

# epichange

<!-- badges: start -->

[![R build
status](https://github.com/reconhub/epichange/workflows/R-CMD-check/badge.svg)](https://github.com/reconhub/epichange/actions)
<!-- badges: end -->

The goal of *epichange* to do outlier detection on count series. This is
work in progress. Please reach out to the authors before using this
package.

## Getting started

You can install the released version of epichange from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("epichange")
```

And the development version from [GitHub](https://github.com/) with:

``` r
if (!require(remotes)) {
  install.packages("remotes")
}
remotes::install_github("reconhub/epichange")
```

The best place to start for using this package is to read the
documentation of the function `asmodee` and run its example:

``` r
library(epichange)
?asmodee
example(asmodee)
```

## Main features

The package implements the following main functions

  - `asmodee`: implements the Automatic Selection of Models and Outlier
    DEtection for Epidemics

  - `select_model`: a function to select the
    best-fitting/best-predicting model from a range of user-specified
    models

  - `detect_changepoint`: a function to detect the points at which
    recent data deviate from previous temporal trends using a fitted
    model and data

  - `detect_outliers`: a function to identify outliers using a fitted
    model and data

### Model selection

You can define a number of different regression models using a common
interface. Once defined you can use different strategies to select the
best-fitting/best-predicting model.

As an example we try to predict `hp` of the famous `mtcars` dataset. Of
course, this is just a toy example. Usually you would use the package to
predict counts data in a time series.

First we define some potential models:

``` r
library(epichange)
stan_cache <- tempfile() # stan compile to c++ and we cache the code
models <- list(
  null = lm_model(hp ~ 1),
  glm_poisson = glm_model(hp ~ 1 + cyl + drat + wt + qsec + am, poisson),
  lm_complex = lm_model(hp ~ 1 + cyl + drat + wt + qsec + am),
  negbin_complex = glm_nb_model(hp ~ 1 + cyl + drat + wt + qsec + am),
  brms_complex = brms_model(
    hp ~ 1 + cyl + drat + wt + qsec + am, 
    family = brms::negbinomial(), 
    file = stan_cache
  )
)
```

Then we evaluate them using [N-Fold cross
validation](https://en.wikipedia.org/wiki/Cross-validation_\(statistics\)).

``` r
# we do CV and evaluate three loss function:
# Root-mean-squared error, the huber-loss and mean absolute error.
# The package works with `yardstick` by default.
out <- capture.output( # no log output in readme :)
  auto_select <- select_model(mtcars, models,
    method = evaluate_resampling,
    metrics = list(yardstick::rmse, yardstick::huber_loss, yardstick::mae)
  )
)
auto_select$leaderboard
#> # A tibble: 5 x 4
#>   model          huber_loss   mae  rmse
#>   <chr>               <dbl> <dbl> <dbl>
#> 1 brms_complex         17.9  18.3  22.0
#> 2 negbin_complex       22.6  23.1  27.2
#> 3 glm_poisson          23.1  23.6  28.2
#> 4 lm_complex           26.4  26.9  34.5
#> 5 null                 57.6  58.1  64.9
```
