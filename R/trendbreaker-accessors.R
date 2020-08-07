
#' Accessors for trendbreaker objects
#'
#' These functions can be used to access information stored in `trendbreaker`
#' objects. See details.
#'
#' @details The following accessors are available:
#'
#' * `get_model()`: fitted model capturing the temporal trend in the data as an
#' `trendbreaker_model_fit` object
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
#' `trendbreaker` object; accepts two arguments `newdata`, a mandatory input
#' containing data for which predictions are derived, and `alpha`, the threshold
#' used for prediction intervals, defaulting to 0.05.
#'
#' @author Thibaut Jombart, Dirk Schumacher
#'
#' @aliases trendbreaker-accessors trendbreaker-class
#'
#' @param x an `trendbreaker` object, as returned by [`asmodee`](asmodee)
#'
#' @param ... further arguments passed to other methods
#'
#' @export
#' @rdname trendbreaker-accessors
#' @aliases get_model.trendbreaker
get_model.trendbreaker <- function(x, ...) {
  x$model
}


#' @export
#' @rdname trendbreaker-accessors
#' @aliases get_k.trendbreaker
get_k.trendbreaker <- function(x, ...) {
  x$k
}


#' @export
#' @rdname trendbreaker-accessors
#' @aliases get_results.trendbreaker
get_results.trendbreaker <- function(x, ...) {
  x$results
}


#' @export
#' @rdname trendbreaker-accessors
#' @aliases get_outliers.trendbreaker
get_outliers.trendbreaker <- function(x, ...) {
  dplyr::filter(get_results(x), .data$outlier)
}


#' @export
#' @rdname trendbreaker-accessors
#' @aliases predict.trendbreaker
#' @param object an `trendbreaker` object, as returned by [`asmodee`](asmodee)
#' @param newdata a `data.frame` containing data for which predictions are to be
#'   derived
#' @param alpha the alpha threshold to be used for prediction intervals,
#'   defaulting to 0.05, i.e. 95% prediction intervals are derived
predict.trendbreaker <- function(object, newdata, alpha = 0.05, ...) {
  trending::get_model(object)$predict(newdata = newdata, alpha = alpha)
}
