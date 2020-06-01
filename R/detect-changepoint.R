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

detect_changepoint <- function(data, models, alpha = 0.05, max_k = 7,
                               method = evaluate_resampling, ...) {
  res <- vector(mode = "list", length = max_k + 1)
  res_models <- vector(mode = "list", length = max_k + 1)

  n <- nrow(data)
  if (max_k > (n - 4)) {
    msg <- sprintf(
      "`max_k` (%d) is too high for the dataset size (%d)",
      max_k,
      n
    )
    stop(msg)
  }

  for (k in 0:max_k) {
    ## isolate training data
    n_train <- n - k
    data_train <- data[seq_len(n_train), , drop = FALSE]

    ## select best model on training data
    current_model <- select_model(
      models = models,
      data = data_train,
      method = method,
      ...
    )$best_model
    current_model <- train(current_model, data_train)

    ## find outliers in entire dataset
    outliers <-  detect_outliers(
      model = current_model,
      data = data,
      alpha = alpha
    )$outlier
    outliers_train <- outliers & (1:n <= n_train)
    outliers_test <- outliers & (1:n > n_train)
    

    # Calculate model score for the current value of 'k'; the score is defined
    # as the sum of two components:
    # 1. the number of non-outliers before the last 'k' days
    # 2. the number of outliers in the last 'k' days
    #
    # the model with the highest score will be retained; in case of ties, then
    # the first component is used to break ties
    
    n_outliers_train <- sum(outliers_train, na.rm = TRUE)
    n_non_outliers_train <- n_train - n_outliers_train
    n_outliers_test <- sum(outliers_test, na.rm = TRUE)
    model_score <- n_non_outliers_train + n_outliers_test
    
    ## save outputs
    res[[k + 1]] <- data.frame(
      k = k,
      n_outliers_train = n_outliers_train,
      n_non_outliers_train = n_non_outliers_train,
      n_outliers_test = n_outliers_test,
      n_non_outliers_test = k - n_outliers_test,
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
