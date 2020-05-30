#' @export
get_model <- function(x) {
  x$model$model
}


#' @export
get_k <- function(x) {
  x$k
}


#' @export
get_results <- function(x) {
  x$results
}


#' @export
get_outliers <- function(x) {
  dplyr::filter(get_results(x), outlier)
}


#' @export
predict.epichange <- function(object, ...) {
  x$model$predict(object, ...)
}
