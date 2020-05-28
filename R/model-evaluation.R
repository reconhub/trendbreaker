#' @export
evaluation_resampling <- function(model, training_set, ...) {
  training_split <- rsample::vfold_cv(training_set, ...)
  metrics <- yardstick::metric_set(
    yardstick::rmse,
    yardstick::mae
  )
  res <- lapply(training_split$splits, function(split) {
    fit <- model$train(rsample::analysis(split))
    validation <- fit$predict(rsample::assessment(split))
    metrics(validation, observed, pred)
  })
  res <- dplyr::bind_rows(res)
  res <- dplyr::group_by(res, .metric)
  res <- dplyr::summarise(res, estimate = mean(.estimate))
  tibble::tibble(
    metric = res$.metric,
    score = res$estimate
  )
}

#' @export
evaluation_aic <- function(model, training_set) {
  full_model_fit <- model$train(training_set)

  tibble::tibble(
    metric = "aic",
    score = stats::AIC(full_model_fit$model)
  )
}
