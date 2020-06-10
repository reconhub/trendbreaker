
#' Accessors for epichange objects
#'
#' These functions can be used to access information stored in `epichange`
#' objects. See details.
#'
#' @details The following accessors are available:
#'
#' * `get_model()`: fitted model capturing the temporal trend in the data as an
#' `epichange_model_fit` object
#' 
#' * `get_k()`: number of recent days excluded from the temporal trend
#' 
#' * `get_results()`: main `data.frame` containing the original data, the
#' predicted values with lower and upper bounds for the prediction interval, a
#' `logical` variable `outlier` which is `TRUE` for data points falling outside
#' the prediction interval, and `classification` of outliers as a `factor`.
#'
#' * `get_outliers()`: returns data points (as rows of `get_results(x)`
#' corresponding to outliers
#'
#' * `predict()`: function to make model predictions from the fitted model in the
#' `epichange` object; accepts two arguments `newdata`, a mandatory input
#' containing data for which predictions are derived, and `alpha`, the threshold
#' used for prediction intervals, defaulting to 0.05.
#' 
#' @author Thibaut Jombart, Dirk Schumacher
#' 
#' @aliases epichange-accessors epichange-class
#'
#' @param x an `epichange` object, as returned by [`asmodee`](asmodee)
#'
#' @param ... further arguments passed to other methods
#' 
#' @export
#' @rdname epichange-accessors
#' @aliases get_model.epichange
get_model.epichange <- function(x, ...) {
  x$model
}


#' @export
#' @rdname epichange-accessors
#' @aliases get_k.epichange
get_k.epichange <- function(x, ...) {
  x$k
}


#' @export
#' @rdname epichange-accessors
#' @aliases get_results.epichange
get_results.epichange <- function(x, ...) {
  x$results
}


#' @export
#' @rdname epichange-accessors
#' @aliases get_outliers.epichange
get_outliers.epichange <- function(x, ...) {
  dplyr::filter(get_results(x), outlier)
}


#' @export
#' @rdname epichange-accessors
#' @aliases predict.epichange
#' @param object an `epichange` object, as returned by [`asmodee`](asmodee)
#' @param newdata a `data.frame` containing data for which predictions are to be
#'   derived
#' @param alpha the alpha threshold to be used for prediction intervals,
#'   defaulting to 0.05, i.e. 95% prediction intervals are derived
predict.epichange <- function(object, newdata, alpha = 0.05, ...) {
  get_model(object)$predict(newdata = newdata, alpha = alpha)
}
