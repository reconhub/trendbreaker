#' @export
evaluate_resampling <- function(model, data, ...) {
  training_split <- rsample::vfold_cv(data, ...)
  metrics <- yardstick::metric_set(
    yardstick::rmse
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
evaluate_aic <- function(model, data) {
  full_model_fit <- model$train(data)

  tibble::tibble(
    metric = "aic",
    score = stats::AIC(full_model_fit$model)
  )
}



#' @export
evaluate_models <- function(models, data, method = evaluate_resampling, ...) {
  data <- dplyr::select(data, ..., everything())
  out <- lapply(models, function(model) method(model, data))
  dplyr::bind_rows(out, .id = "model")
}



#' @export
select_model <- function(models, data, method = evaluate_resampling,
                         scores = TRUE, ...) {
  stats <- evaluate_models(models = models, data = data, method = method, ...)
  best_model <- dplyr::arrange(stats, score)$model[1]
  out <- list(model = models[[best_model]])
  if (scores) out$scores <- stats
  out
}
