#' Check if a model can be used for predictions for specific data
#'
#' This function ensures that a model trained on a given dataset can be used to
#' make predictions on another specific dataset. It performs two types of
#' checks: i) level compatibility, and ii) missing data. For i) checks ensure
#' that factors of the testing set do not contain any new levels. For ii), it
#' ensures that there are no NAs in predictors of the testing set.
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
#' @param warn A `logical` indicating if warnings should be generated issues are
#'     found.
#'
#' @return A single logical indicating if all checks were OK (TRUE); FALSE if
#'     there was a single issue, either due to incompatible levels or missing
#'     data.

sanitize_model <- function(model,
                           x_training,
                           x_testing,
                           warn = TRUE) {
    
  # Auxiliary functions
  
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
           FUN.VALUE = logical(1))
  }


  # Extract data.frame of predictors
  x_training <- get_predictor_data(model, x_training)
  x_testing <-  get_predictor_data(model, x_testing)

  # Check factors have consistent levels (no new levels in testing set)
  is_factor_training <- vapply(x_training, is.factor, logical(1))
  factors_training <- x_training[is_factor_training]
  is_factor_testing <- vapply(x_testing, is.factor, logical(1))
  factors_testing <- x_testing[is_factor_testing]

  factors_ok <- check_factors(factors_training, factors_testing)
  res_levels <- all(factors_ok)
  if (!res_levels & warn) {
    msg <- "some factors of the prediction set have new, unknown levels"
    warning(msg)
  }


  # Check that there are no NAs in testing set
  res_missing <- any(is.na(x_testing))
 if (!res_missing & warn) {
    msg <- "predictors of prediction set contain NAs"
    warning(msg)
  }
  
  # Combine results
  out <- res_levels & res_missing
  out
}




#' Retain models which have consistent levels
#'
#' @param models A list of [`trending_model()`] objects.
#'
#' @return A list of [`trending_model()`] object which have consistent levels
#'   for all categorical predictors between the training and testing data.

retain_level_consistent_models <- function(models,
                                           x_training,
                                           x_testing,
                                           warn = TRUE) {
  ## Ensure there are no ghost levels in any of the data
  x_training <- droplevels(x_training)
  x_testing <- droplevels(x_testing)

  ## Apply checks to all mnodels, output a vector of logicals; TRUE means checks
  ## are OK.
  out <- vapply(
      models,
      check_level_consistency,
      x_training,
      x_testing,
      warn = FALSE,
      FUN.VALUE = logical(1))
  
  allgood <- all(out)

  if (!allgood & warn) {
    msg <- paste("some models were disabled because of new",
                 "levels in the prediction set")
    warning(msg)
  }
  
  models[out]
}
