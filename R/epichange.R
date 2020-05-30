#' General wrapper
#'
#' @export
epichange <- function(data,
                      models,
                      alpha = 0.05, max_k = 7,
                      method = evaluate_resampling,
                      ...) {

  res_changepoint <- detect_changepoint( data = data,
                                        models = models,
                                        alpha = alpha,
                                        max_k = max_k,
                                        method = method,
                                        ...)

  res <- detect_outliers(data = data, model = res_changepoint$model, alpha = alpha)
  out <- list(k = res_changepoint$k,
       model = res_changepoint$model,
       results = res)
  class(out) <- c("epichange", class(out))
  out
}
