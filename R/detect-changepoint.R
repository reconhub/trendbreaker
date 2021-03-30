#' Detect change in temporal trend
#'
#' This function looks for the 'optimal' number of recent days to exclude from
#' the temporal trend fitting in [`asmodee`](asmodee). The procedure selects
#' the value of `k` which maximises the sum if i) the number of non-outliers in
#' training set (before the last `k` points) ii) the number of outliers in the
#' last `k` points. Note that for each value of `k` investigated, model
#' selection is performed as described in `?asmodee`.
#'
#' @inheritParams asmodee
#'
#' @author Thibaut Jombart
#'
#' @seealso [asmodee](asmodee)
#'
#' @export
#'

detect_changepoint <- function(data, models, date_index,
                               alpha = 0.05, max_k = 7,
                               method = trendeval::evaluate_resampling,
                               include_warnings = FALSE, ...) {

  ## identify the date column for subsetting data
  date_index <- rlang::enquo(date_index)
  idx <- tidyselect::eval_select(date_index, data)
  date_index <- names(data)[idx]
  dates <- data[[date_index]]

  ## prep output (empty)
  res <- vector(mode = "list", length = max_k + 1)
  res_models <- vector(mode = "list", length = max_k + 1)

  n_dates <- length(unique(dates))
  if (max_k > (n_dates - 4)) {
    msg <- sprintf(
      "`max_k` (%d) is too high for the dataset size (%d)",
      max_k,
      n_dates
    )
    stop(msg)
  }

  for (k in 0:max_k) {
    ## isolate training data
    ## the 'set...' function adds a '$training' column to the data (logical
    ## indicating if the corresponding row belongs to the training set'
    data <- set_training_data(data, date_index, k)
    data_train <- get_training_data(data, date_index, k)

    ## sanitize models
    models <- retain_sanitized_models(models,
                                      data_train,
                                      data,
                                      warn = FALSE,
                                      error_if_void = TRUE)
    
    ## select best model on training data
    current_model <- select_model(
      models = models,
      data = data_train,
      method = method,
      include_warnings = include_warnings,
      ...
    )
    current_model <- trending::fit(current_model, data_train)

    ## find outliers in entire dataset
    outliers <-  detect_outliers(
      model = current_model,
      data = data,
      alpha = alpha
    )$outlier
  

    # Calculate model score for the current value of 'k'; the score is defined
    # as the sum of two components:
    # 1. the number of non-outliers before the last 'k' days
    # 2. the number of outliers in the last 'k' days
    #
    # the model with the highest score will be retained; in case of ties, then
    # the first component is used to break ties

    n_outliers_train <- sum(outliers & data$training, na.rm = TRUE)
    n_non_outliers_train <- sum(!outliers & data$training, na.rm = TRUE)
    n_outliers_test <- sum(outliers & !data$training, na.rm = TRUE)
    n_non_outliers_test <- sum(!outliers & !data$training, na.rm = TRUE)
    model_score <- n_non_outliers_train + n_outliers_test

    ## save outputs
    res[[k + 1]] <- data.frame(
      k = k,
      n_outliers_train = n_outliers_train,
      n_non_outliers_train = n_non_outliers_train,
      n_outliers_test = n_outliers_test,
      n_non_outliers_test = n_non_outliers_test,
      model_score = model_score
    )
    res_models[[k + 1]] <- current_model
  }

  res <- dplyr::bind_rows(res)
  res <- dplyr::arrange(
    res,
    dplyr::desc(model_score),
    dplyr::desc(n_non_outliers_train)
    #dplyr::desc(n_outliers_test)
  )
  best_k <- res$k[1]
  best_model <- res_models[[best_k + 1]]
  list(
    results = res,
    k = best_k,
    model = best_model
  )
}
