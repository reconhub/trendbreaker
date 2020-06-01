
#' Accessors for epichange_model objects
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

#' @param model the output of functions `lm_model`, `glm_model`, or
#'   `glm_nb_model`

get_formula <- function(model) {
  as.list(environment(model$train))$formula
}



#' @param model the output of functions `lm_model`, `glm_model`, or
#'   `glm_nb_model`

get_response <- function(model) {
  form <- get_formula(model)
  as.character(form)[2]
}



#' @param model the output of functions `lm_model`, `glm_model`, or
#'   `glm_nb_model`

get_family <- function(model) {
  as.list(environment(model$train))$family
}
