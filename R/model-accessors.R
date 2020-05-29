
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
