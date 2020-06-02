---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# epichange

<!-- badges: start -->
[![R build status](https://github.com/reconhub/epichange/workflows/R-CMD-check/badge.svg)](https://github.com/reconhub/epichange/actions)
<!-- badges: end -->

The goal of *epichange* to do outlier detection on count series. This is work in
progress. Please reach out to the authors before using this package.

## Getting started

You can install the released version of epichange from [CRAN](https://CRAN.R-project.org) with:

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

The best place to start for using this package is to read the documentation of
the function `asmodee` and run its example:


```r
library(epichange)
?asmodee
example(asmodee)
```


## Main features

The package implements the following main functions

* `asmodee`: implements the Automatic Selection of Models and Outlier DEtection
  for Epidemics
  
* `select_model`: a function to select the best-fitting/best-predicting model
  from a range of user-specified models
  
* `detect_changepoint`: a function to detect the points at which recent data
  deviate from previous temporal trends using a fitted model and
  data

* `detect_outliers`: a function to identify outliers using a fitted model and
  data

