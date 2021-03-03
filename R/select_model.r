select_model <- function(data, models, method, include_warnings, ...) {
  model_results <- trendeval::evaluate_models(
      data = data,
      models = models,
      method = method,
      ...
      )
  model_results <- is_ok(model_results, include_warnings = include_warnings)
  if (nrow(model_results) == 0) {
    msg <- paste(
        "Unable to fit a model to the data without warnings or errors.",
        "Consider using `include_warnings = TRUE` to include models",
        "which issued warnings.",
        sep = "\n")
    stop(msg)
  } else {
    model_results <- model_results[order(model_results[, ncol(model_results), drop = TRUE]), ]
  }
  model_results$model[[1]]
}
