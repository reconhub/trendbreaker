#' Check level consistency across training / testing set
#'
#' This function ensures that a model used in asmodee contain compatible levels
#' in the testing and training set. All levels in the testing set must be
#' present in the training set (but the converse is not a requirement). It
#' returns a list of models which comply with the requirement, and issues
#' warnings for the models which got discarded.
#'
#' @author Thibaut Jombart
#'
#' @noRd
#'
#' @param model A [`trending_model()`] object.
#'
#' @param x_training A `data.frame` used as training set.
#' 
#' @param x_testing A `data.frame` used as testing set.
#'
#' @param quiet A `logical` indicating if warnings should be generated when
#'   factor level mismatches are found.


check_level_consistency <- function(model, x_training, x_testing,
                                    quiet = TRUE) {

  # Auxiliary functions
  
  ## Extract a dataset of all predictors of a model, outputting a data.frame
  ## containing only factors used in the model formula
  get_model_factors <- function(model, df) {
    ### Extract variable names from the formula
    form <- trending::get_formula(model)
    vars <- unlist(strsplit(as.character(form)[3], "[-:+*|]"))
    vars <- gsub("[ ]+", "", vars)
    vars <- vars[vars != "1"] # remove intercept

    ### Subset the relevant columns, then only keep factors
    out <- df[vars]
    factors <- vapply(out, is.factor, logical(1))
    out[factors]
  }

  ## Check level consistency for a single factor
  ##
  ## Returns TRUE if levels are okay, FALSE otherwise
  check_factor <- function(f_train, f_test) {
    all(levels(f_test) %in% levels(f_train))
  }

  ## Check level consistency for multiple factors
  ##
  ## This simply loops over all columns of testing data.frame, ensuring matching
  ## names, and assuming all variables are factors.
  check_factors <- function(df_train, df_test) {
    vars_test <- names(df_test)
    vapply(vars_test,
           function(e)
             check_factor(df_train[[e]], df_test[[e]]),
           logical(1))     
  }


  # Make the checks
  factors_training <- get_model_factors(model, x_training)
  factors_testing <- get_model_factors(model, x_testing)
  is_ok <- check_factors(factors_training, factors_testing)
  out <- all(is_ok)
  if (!out) {
    msg <- "some factors of the prediction set have new, unknown levels"
    warning(msg)
  }
  out
}
