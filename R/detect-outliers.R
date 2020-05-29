#' @export
#'
#' @param model is a trained model
#' 
detect_outliers <- function(model, data, alpha = 0.05, ...) {
  data <- dplyr::select(data, ..., everything())
  preds <- model$predict(data, alpha = alpha)
  out <- dplyr::mutate(
    preds,
    outlier = observed < lower | observed > upper,
    classification = case_when(
      observed < lower ~ "decrease",
      observed > upper ~ "increase",
      TRUE ~ "normal"),
    classification = factor(classification,
                            levels = c("increase", "normal", "decrease")))
  out
}
