# These are used to remove notes in R CMD check due to scoping in `dplyr`
# functions

utils::globalVariables(
  c(".estimate", ".metric", "classification", "observed",
    "outlier", "pred"))
