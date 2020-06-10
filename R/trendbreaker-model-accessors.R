
#' Accessors for trendbreaker_model objects
#'
#' These functions can be used to access information stored in `trendbreaker_model`
#' objects. See details.
#'
#' @details The following accessors are available:
#'
#' * `get_formula()`: get the formula used to model temporal trends
#' 
#' * `get_response()`: get the name of the response variable
#' 
#' * `get_family()`: get the model family, indicating the type of distribution
#' assumed for the response variable
#'
#' * `train()`: train a model using data to obtain a
#' [`trendbreaker_model_fit`](trendbreaker_model_fit) object
#' 
#' @author Thibaut Jombart, Dirk Schumacher
#' 
#' @param x the output of functions `lm_model`, `glm_model`, or
#'   `glm_nb_model`
#' 
#' @param data a `data.frame` to be used to train the model#'
#' 
#' @param ... further arguments passed to other methods
#' 
#' @aliases trendbreaker_model-accessors trendbreaker_model-class
#' 
#' @export
#' @rdname trendbreaker_model-accessors
#' @aliases get_formula.trendbreaker_model
get_formula.trendbreaker_model <- function(x, ...) {
  as.list(environment(x$train))$formula
}


#' @export
#' @rdname trendbreaker_model-accessors
#' @aliases get_response.trendbreaker_model
get_response.trendbreaker_model <- function(x, ...) {
  form <- get_formula(x)
  as.character(form)[2]
}


#' @export
#' @rdname trendbreaker_model-accessors
#' @aliases get_family.trendbreaker_model
get_family.trendbreaker_model <- function(x, ...) {
  if (inherits(x, "trendbreaker_lm")) {
    "gaussian"
  } else {
    as.list(environment(x$train))$family
  }
}


#' @export
#' @rdname trendbreaker_model-accessors
#' @aliases train.trendbreaker_model
train.trendbreaker_model <- function(x, data, ...) {
  x$train(data)
}
