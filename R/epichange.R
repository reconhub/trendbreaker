#' General wrapper
#'
#' @export
epichange <- function(data,
                      models,
                      alpha = 0.05,
                      max_k = 7,
                      fixed_k = NULL,
                      method = evaluate_resampling,
                      ...) {

  n <- nrow(data)

  ## There are two modes for this function:
  ## 1. (default) auto-detection of the value of 'k', in which case we use the
  ## `detect_changepoint` routine to select the 'best' value of `k`
  ## 2. use a user-specified value of `k`, passed through the `fixed_k` argument
  
  if (is.null(fixed_k)) {
    res_changepoint <- detect_changepoint(
      data = data,
      models = models,
      alpha = alpha,
      max_k = max_k,
      method = method,
      ...
    )
    selected_model <- res_changepoint$model
    selected_k <- res_changepoint$k
  } else {
    if (!is.numeric(fixed_k) |
          !is.finite(fixed_k)) {
      msg <- "`fixed_k` must be a finite number"
      stop(msg)
    }
    k <- as.integer(max(fixed_k, 0L))
    n_train <- n - k
    data_train <- data[seq_len(n_train), ]
    selected_model <- select_model(data = data_train,
                                   models = models,
                                   method = method,
                                   ...)$best_model
    selected_model <- selected_model$train(data_train)
    selected_k <- k
  }


  ## find outliers
  res_outliers <- detect_outliers(data = data,
                                  model = selected_model,
                                  alpha = alpha)


  ## form output
  n_train <- n - selected_k
  n_outliers <- sum(res$outlier, na.rm = TRUE)
  outliers_train <- res$outlier & (1:n <= n_train)
  n_outliers_train <- sum(outliers_train, na.rm = TRUE)
  n_outliers_recent <- n_outliers - n_outliers_train
  p_value <- stats::pbinom(n_outliers,
                           size = n,
                           prob = alpha,
                           lower.tail = FALSE)
  
  out <- list(
    k = selected_k,
    model = selected_model,
    n_outliers = n_outliers,
    n_outliers_train = n_outliers_train,
    n_outliers_recent = n_outliers_recent,
    p_value = p_value,
    results = res_outliers
  )
  class(out) <- c("epichange", class(out))
  out
}
