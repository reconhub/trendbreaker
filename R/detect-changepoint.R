
#' @export
#' 
detect_changepoint <- function(model, data, alpha = 0.05, max_k = 7, ...) {
  data <- dplyr::select(data, ..., everything())

  res <- vector(mode = "list", length = max_k + 1)
  
  n <- nrow(data)
  if (max_k > (n - 4)) {
    msg <- sprintf("`max_k` (%d) is too high for the dataset size (%d)",
                   max_k,
                   n)
    stop(msg)
  }
  
  for (k in 0:max_k) {
    n_train <- n - k
    data_train <- data[seq_len(n_train), , drop = FALSE]
    data_test <- data[-seq_len(n_train), ,drop = FALSE]
    current_model <- model$train(data_train)
    outliers_train <- detect_outliers(model = current_model,
                                      data = data_train,
                                      alpha = alpha)
    outliers_test <- detect_outliers(model = current_model,
                                     data = data_test,
                                     alpha = alpha)

    n_outliers_train <- sum(outliers_train$outlier, na.rm = TRUE)
    n_outliers_test <- sum(outliers_test$outlier, na.rm = TRUE)

    res[[k + 1]] <- data.frame(
      k = k,
      n_outliers_train = n_outliers_train,
      n_non_outliers_train = n_train - n_outliers_train,
      n_outliers_test = n_outliers_test,
      n_non_outliers_test = k - n_outliers_test
    )
  }

  res <- dplyr::bind_rows(res)
  res <- dplyr::arrange(res,
                        dplyr::desc(n_non_outliers_train),
                        dplyr::desc(n_outliers_test))

  list(results = res,
       k = res$k[1])
  
}

