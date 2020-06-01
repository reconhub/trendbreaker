#' Detect outliers given a fitted model
#'
#' This function uses a trained model stored as an`epichange_model_fit` object
#' to derive the prediction interval (PI) for a given alpha threshold; it
#' classifies as outliers every data point falling outside the interval.
#'
#' @return A `data.frame` containing the original data, the mean model
#'   predictions, the lower and upper bounds of the prediction interval, a
#'   variable `outlier` indicating which point is an outlier as a `logical`, and
#'   the `classification` of data points as a `factor` with values `normal` for
#'   points within the PI, `increase` for outliers above the PI, and `decrease`
#'   for outliers below the PI.
#' 
#' @export
#' 
#' @importFrom dplyr .data
#'
#' @param data a `data.frame` containing data for which predictions are to be
#'   derived
#'
#' @param model a fitted model as `epichange_model_fit` object; this can be
#'   obtained by running `train()` on an `epichange_model` object
#' (see `?epichange_model`) for details
#' 
#' @param alpha the alpha threshold to be used for prediction intervals,
#'   defaulting to 0.05, i.e. 95% prediction intervals are derived
#'
#' @seealso [epichange_model](epichange_model) to create models,
#' [epichange_model-accessors](epichange_model-accessors) for training them
#' 
#' @author Thibaut Jombart, Dirk Schumacher
#'
#' 
detect_outliers <- function(data, model, alpha = 0.05) {
  if (inherits(model, "epichange_model")) {
    msg <- paste("`model` has not been trained on data;",
                  "use `train()` to train your model, then detect outliers")
    stop(msg)
  }
  if (!inherits(model, "epichange_model_fit")) {
    msg <- sprintf("`model` should be an `epichange_model_fit` object, but is a `%s`",
                   paste(class(model), collapse = ", "))
    stop(msg)
  }
  preds <- predict(model, newdata = data, alpha = alpha)
  out <- dplyr::mutate(
    preds,
    outlier = .data$observed < .data$lower | .data$observed > .data$upper,
    classification = dplyr::case_when(
      .data$observed < .data$lower ~ "decrease",
      .data$observed > .data$upper ~ "increase",
      TRUE ~ "normal"
    ),
    classification = factor(classification,
      levels = c("increase", "normal", "decrease")
    )
  )
  out
}
