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
#' @param training A `data.frame` used as training set.
#' 
#' @param testing A `data.frame` used as testing set.


check_level_consistency <- function(model, training, testing) {

  # Auxiliary functions
  
  
  ## Extract a dataset of all predictors of a model, keeping only factors
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


  
  
}
