#' Tools for model evaluation
#'
#' These functions provide tools for evaluating models, based on the goodness of
#' fit or on predictive power. `evaluate_aic` evaluates the goodness of fit of a
#' single model using Akaike's information criterion, measuring the deviance of
#' the model while penalising its complexity. `evaluate_resampling` uses K-fold
#' cross-validation and the Root Mean Square Error (RMSE) of testing sets to
#' measure the predictive power of a single model. `evaluate_aic` is faster, but
#' `evaluate_resampling` is better-suited to select best predicting
#' models. `evaluate_models` uses either `evaluate_aic` or `evaluate_resampling`
#' to compare a series of models. `select_model` does the same, but returns the
#' 'best' model according to the chosen method.
#'
#' @details These functions wrap around existing functions from several
#'   packages. `stats::AIC` is used in `evaluate_aic`, and `evaluate_resampling`
#'   uses `rsample::vfold_cv` for cross-validation and `yardstick::rmse` to
#'   calculate RMSE.
#'
#' @seealso [`stats::AIC`](stats::AIC) for computing AIC;
#'   [`rsample::vfold_cv`](rsample::vfold_cv) for cross validation;
#'   [`yardstick::rmse`](yardstick::rmse) for calculating RMSE; `yardstick` also
#'   implements a range of other metrics for assessing model fit outlined at
#'   \url{https://yardstick.tidymodels.org/};
#'   [`?epichange_model`](epichange_model) for the different ways to build
#'   `epichange_model` objects
#'
#' @param model a model specified as an `epichange_model` object, as returned by
#'   `lm_model`, `glm_model`, `glm_nb_model`, `brms_model`; see
#'   [`?epichange_model`](epichange_model) for details
#'
#' @param data a `data.frame` containing data (including the response variable
#'   and all predictors) used in `model`
#'
#' @param metrics a list of functions assessing model fit, with a similar
#'   interface to `yardstick::rmse`; see \url{https://yardstick.tidymodels.org/}
#'   for more information
#'
#' @param v the number of equally sized data partitions to be used for K-fold
#'   cross-validation; `v` cross-validations will be performed, each using `v -
#'   1` partition as training set, and the remaining partition as testing
#'   set. Defaults to 1, so that the method uses leave-one-out cross validation,
#'   akin to Jackknife except that the testing set (and not the training set) is
#'   used to compute the fit statistics.
#'
#' @param repeats the number of times the random K-fold cross validation should
#'   be repeated for; defaults to 1; larger values are likely to yield more
#'   reliable / stable results, at the expense of computational time
#'
#' @param ... further arguments passed to [`stats::AIC`](stats::AIC)
#'
#' @param models a `list` of models specified as an `epichange_model` object, as
#'   returned by `lm_model`, `glm_model`, `glm_nb_model`, `brms_model`; see
#'   [`?epichange_model`](epichange_model) for details
#'
#' @param method a `function` used to evaluate models: either
#'   `evaluate_resampling` (default, better for selecting models with good
#'   predictive power) or `evaluate_aic` (faster, focuses on goodness-of-fit
#'   rather than predictive power)
#'   
#' 
#' @export
#' @rdname evaluate_models
#' @aliases evaluate_resampling
evaluate_resampling <- function(model,
                                data,
                                metrics = list(yardstick::rmse),
                                v = nrow(data),
                                repeats = 1) {
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
#' @rdname evaluate_models
#' @aliases evaluate_aic
evaluate_aic <- function(model, data, ...) {
  full_model_fit <- model$train(data)

  tibble::tibble(
    metric = "aic",
    score = stats::AIC(full_model_fit$model, ...)
  )
}



#' @export
#' @rdname evaluate_models
#' @aliases evaluate_models
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
#' @rdname evaluate_models
#' @aliases select_model
select_model <- function(data, models, method = evaluate_resampling, ...) {
  stats <- evaluate_models(data = data, models = models, method = method, ...)
  stats <- stats[order(stats[, 2, drop = TRUE]), ]
  # per convention the first row is the best model sorted by the first metric
  list(best_model = models[[stats$model[[1]]]], leaderboard = stats)
}
