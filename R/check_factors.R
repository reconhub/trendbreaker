#' Check level consistency for a single factor
#'
#' @noRd
#'
#' @param model A [`trending_model()`] object.
#'
#' @param f_training A `factor` used in the training set.
#' 
#' @param f_testing A `factor` used in the testing set.
#'
#' @return Returns TRUE if levels are okay, FALSE otherwise
#' 
check_factor <- function(f_train, f_test) {
    all(levels(f_test) %in% levels(f_train))
}

 

#' Check level consistency for multiple factors
#'
#' This simply loops over all columns of testing data.frame, ensuring matching
#' names, and assuming all variables are factors.
#' 
#' @noRd
#'
#' @param df_train A `data.frame` of factors used as training set.
#' 
#' @param df_test A `data.frame` of factors used as testing set.
#'
#' @return A logical vector with one value per factor in the testing dataset;
#'   TRUE if levels are okay, FALSE otherwise

check_factors <- function(df_train, df_test) {
  vars_test <- names(df_test)
  vapply(vars_test,
         function(e)
           check_factor(df_train[[e]], df_test[[e]]),
         FUN.VALUE = logical(1))
}

