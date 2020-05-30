#' @export
evaluate_resampling <- function(model, data, metrics = list(yardstick::rmse), v = 10, repeats = 1) {
  training_split <- rsample::vfold_cv(data, v = v, repeats = repeats)
  metrics <- do.call(yardstick::metric_set, metrics)
  res <- lapply(training_split$splits, function(split) {
    fit <- model$train(rsample::analysis(split))
    validation <- fit$predict(rsample::assessment(split))
    # TODO: always sort by time component
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
evaluate_aic <- function(model, data, ...) {
  full_model_fit <- model$train(data)

  tibble::tibble(
    metric = "aic",
    score = stats::AIC(full_model_fit$model, ...)
  )
}



#' @export
evaluate_models <- function(data, models, method = evaluate_resampling, ...) {
  # dplyr::bind_rows(out, .id = "model")
  # data <- dplyr::select(data, ..., everything())
  # TODO: think about one metric per col
  out <- lapply(models, function(model) method(model, data, ...))
  out <- dplyr::bind_rows(out, .id = "model")
  tidyr::pivot_wider(
    out,
    id_cols = model,
    names_from = metric,
    values_from = score
  )
}


#' @export
select_model <- function(data, models, method = evaluate_resampling, ...) {
  stats <- evaluate_models(data = data, models = models, method = method, ...)
  stats <- stats[order(stats[, 2, drop = TRUE]), ]
  # per convention the first row is the best model sorted by the first metric
  list(best_model = models[[stats$model[[1]]]], leaderboard = stats)
}
