#' General wrapper
#'
#' @export
epichange <- function(models, data,
                      alpha = 0.05, max_k = 7,
                      method = evaluate_resampling,
                      ...) {
  data <- dplyr::select(data, ..., everything())
  res_changepoint <- detect_changepoint(
    models = models,
    data = data,
    alpha = alpha,
    max_k = max_k,
    method = method
  )

  res <- detect_outliers(res_changepoint$model, data, alpha = alpha)
  list(
    k = res_changepoint$k,
    model = res_changepoint$model,
    results = res
  )
}
