
#' Accessors for epichange_model objects
#'
#' These functions can be used to access information stored in `epichange`
#' objects. See details.
#'
#' @details The following accessors are available:
#'
#' * `get_formula`: get the formula used to model temporal trends
#' 
#' * `get_response`: get the name of the response variable
#' 
#' * `get_family`: get the model family, indicating the type of distribution
#' assumed for the response variable
#' 
#' @author Thibaut Jombart, Dirk Schumacher
#' 
#' @aliases epichange_model-accessors epichange_model-class
#' 
#' @param model the output of functions `lm_model`, `glm_model`, or
#'   `glm_nb_model`
#' 
#' @export
#' @rdname epichange_model-accessors
#' @aliases get_formula get_formula.epichange 
get_formula.epichange_model <- function(model) {
  as.list(environment(model$train))$formula
}


#' @export
#' @rdname epichange_model-accessors
#' @aliases get_response get_response.epichange_model
get_response.epichange_model <- function(model) {
  form <- get_formula(model)
  as.character(form)[2]
}


#' @export
#' @rdname epichange_model-accessors
#' @aliases get_family get_family.epichange_model
get_family.epichange_model <- function(model) {
  as.list(environment(model$train))$family
}
