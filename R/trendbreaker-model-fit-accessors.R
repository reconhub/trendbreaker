
#' Accessors for trendbreaker_model_fit objects
#'
#' These functions can be used to access information stored in
#' `trendbreaker_model_fit` objects. See details.
#'
#' @details The following accessors are available:
#'
#' * `get_model()`: get the fitted model stored in the object
#' 
#' * `predict()`: get model predictions for user-provided data, including
#' average predictions and prediction intervals
#' 
#' @author Thibaut Jombart, Dirk Schumacher
#' 
#' @param x the output of functions `lm_model`, `glm_model`, or
#'   `glm_nb_model`
#'
#' @param ... further arguments passed to other methods
#' 
#' @aliases trendbreaker_model_fit-accessors trendbreaker_model_fit-class

#' @export
#' @rdname trendbreaker_model_fit-accessors
#' @aliases get_model.trendbreaker_model_fit
get_model.trendbreaker_model_fit <- function(x, ...) {
  x$model
}


#' @export
#' @rdname trendbreaker_model_fit-accessors
#' @aliases predict.trendbreaker_model_fit
#' @param object an `trendbreaker_model_fit` object
#' @param newdata a `data.frame` containing data for which predictions are to be
#'   derived
#' @param alpha the alpha threshold to be used for prediction intervals,
#'   defaulting to 0.05, i.e. 95% prediction intervals are derived
predict.trendbreaker_model_fit <- function(object, newdata, alpha = 0.05, ...) {
  object$predict(newdata = newdata, alpha = alpha)
}
