
#' Accessors for epichange objects
#'
#' These functions can be used to access information stored in `epichange`
#' objects. See details.
#'
#' @details The following accessors are available:
#'
#' * `get_model`: fitted model capturing the temporal trend in the data as an
#' `epichange_model_fit` object
#' 
#' * `get_k`: number of recent days excluded from the temporal trend
#' 
#' * `get_results`: main `data.frame` containing the original data, the
#' predicted values with lower and upper bounds for the prediction interval, a
#' `logical` variable `outlier` which is `TRUE` for data points falling outside
#' the prediction interval, and `classification` of outliers as a `factor`.
#'
#' * `get_outliers`: returns data points (as rows of `get_results(x)`
#' corresponding to outliers
#'
#' * `get_classification`: returns a `factor` indicating if data points are
#' `normal` outliers (`TRUE`) or not (`FALSE`)
#' 
#' @author Thibaut Jombart, Dirk Schumacher
#' 
#' @export
#'
#' @rdname epichange-accessors
#' @aliases epichange-accessors epichange-class
#' @aliases get_model.epichange

get_model.epichange <- function(x) {
  x$model
}


#' @export
#' @rdname epichange-accessors
#' @aliases get_k.epichange
get_k.epichange <- function(x) {
  x$k
}


#' @export
#' @rdname epichange-accessors
#' @aliases get_results.epichange
get_results.epichange <- function(x) {
  x$results
}


#' @export
#' @rdname epichange-accessors
#' @aliases get_outliers.epichange
get_outliers.epichange <- function(x) {
  dplyr::filter(get_results(x), outlier)
}


#' @export
#' @rdname epichange-accessors
#' @aliases predict.epichange
predict.epichange <- function(object, newdata, alpha = 0.05, ...) {
  get_model(object)$predict(newdata = newdata, alpha = alpha)
}
