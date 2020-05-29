#' @export
#'
#' @param model is a trained model
#' @importFrom dplyr .data
detect_outliers <- function(model, data, alpha = 0.05, ...) {
  data <- dplyr::select(data, ..., dplyr::everything())
  preds <- model$predict(data, alpha = alpha)
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
