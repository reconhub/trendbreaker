#' Detect outliers given a fitted model
#'
#' This function uses a trained model stored as an`trendbing_model_fit` object
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
#' @param model a fitted model as [`trending::trending_model_fit`] object;
#'   this can be obtained by running [trending::fit()] on a
#'   [`trending::trending_model`].
#'
#' @param alpha the alpha threshold to be used for prediction intervals,
#'   defaulting to 0.05, i.e. 95% prediction intervals are derived
#'
#' @author Thibaut Jombart, Dirk Schumacher
#'
#'
detect_outliers <- function(data, model, alpha = 0.05) {
  if (inherits(model, "trending_model")) {
    msg <- paste("`model` has not been trained on data;",
                  "use `train()` to train your model, then detect outliers")
    stop(msg)
  }
  if (!inherits(model, "trending_model_fit")) {
    msg <- sprintf("`model` should be an `trending_model_fit` object, but is a `%s`",
                   paste(class(model), collapse = ", "))
    stop(msg)
  }
  observed <- as.character(formula(model$fitted_model))[2]
  preds <- predict(model, new_data = data, alpha = alpha)
  out <- dplyr::mutate(
    preds,
    outlier = .data[[observed]] < .data$lower_pi | .data[[observed]] > .data$upper_pi,
    classification = dplyr::case_when(
      .data[[observed]] < .data$lower_pi ~ "decrease",
      .data[[observed]] > .data$upper_pi ~ "increase",
      TRUE ~ "normal"
    ),
    classification = factor(.data$classification,
      levels = c("increase", "normal", "decrease")
    )
  )
  out
}
