

#' Set training data
#'
#' This function adds a column 'training' to a `data.frame`, a `logical`
#' indicating if data points are part of the training set ('callibrartion
#' window'), or not. The last 'k' time units from a dataset to define a training
#' set. Time is known through the name of a column indicating time.
#'
#' @param x A `data.frame` or a `tibble`.
#'
#' @param time_name The name of the variable in `df` to be used as time.
#'
#' @param k The number of the last data points to exclude from the training
#'   set. These will be the last `k` unique values of the `time` column.

set_training_data <- function(x, date_index, k) {

  ## get time, sort unique values by decreasing order, and find the k-th value;
  ## this will set the (exclusive) upper bound of data retained in the training
  ## set
  dates <- x[[date_index]]
  unique_dates <- sort(unique(dates), decreasing = TRUE)
  if (k >= length(unique_dates)) {
    msg <- "`k` is too large: no point left in training set"
    stop(msg)
  }
  max_date <- unique_dates[k]

  x$training <- dates < max_date
  x
}



#' Get training data
#'
#' This function removes the last 'k' time units from a dataset to define a
#' training set. Time is known through the name of a column indicating time.
#'
#' @param x A `data.frame` or a `tibble`.
#'
#' @param time_name The name of the variable in `df` to be used as time.
#'
#' @param k The number of the last data points to exclude from the training
#'   set. These will be the last `k` unique values of the `time` column.

get_training_data <- function(x, date_index, k) {
  onames <- names(x)
  x <- set_training_data(x, date_index, k)
  x[x$training, onames, drop = FALSE]

}
