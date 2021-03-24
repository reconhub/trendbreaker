#' Extract a data.frame of a model's predictors
#'
#' This internal function extract predictors from a model's formula and extracts
#' the corresponding columns from a data.frame.
#'
#' @noRd
#'
#' @author Thibaut Jombart
#'
#' @param model A [`trending_model()`] object.
#'
#' @param df A `data.frame` containing data required by the models (and possibly
#'   non-relevant columns as well).
#'
#' @return A `data.frame` containing exactly the predictors of the model; if
#'   some data are missing, an error is issued.
#'
get_predictor_data <- function(model, df) {
  ## Extract variable names from the formula
  form <- trending::get_formula(model)
  vars <- unlist(strsplit(as.character(form)[3], "[-:+*|]"))
  vars <- gsub("[ ]+", "", vars)
  vars <- vars[vars != "1"] # remove intercept

  ## Ensure informative error if some variables are missing
  missing_vars <- vars[!vars %in% names(df)]
  if (length(missing_vars)) {
    msg <- sprintf(
        "Some predictors are missing from `df`:\n%s",
        paste(missing_vars, collapse = ", ")
        )
  }
  
  ## Return the relevant columns
  df[vars]
}

