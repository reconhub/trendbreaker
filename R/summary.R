#' Summary for trendbreaker outputs
#'
#' @aliases summary.trendbreaker
#'
#' @author Thhibaut Jombart
#'
#' @export
#'
#' @param object the `trendbreaker` object to summarise
#'
#' @param ... further arguments to be passed to other functions (currently ignored)
#'
#' @return a `data.frame` containing the following colums:
#' * n_recent: number of data points in recent set
#' * n_recent_increases: number of recent increases
#' * n_recent_decreases: number of recent decreases
#' * n_recent_outliers: number of recent outliers
#' * p_recent_outliers: the binomial p-value for the number of recent outliers
#' * n_training: number of data points in training set
#' * n_training_increases: number of increases in training set
#' * n_training_decreases: number of decreases in training set
#' * n_training_outliers: number of outliers in training set
#' * p_training_outliers: the binomial p-value for the number of outliers
#' in the training set
#'
#' @rdname summary.trendbreaker
#'
summary.trendbreaker <- function(object, ...) {
  x <- object$results
  alpha <- object$alpha
  n_recent <- sum(!x$training)
  n_recent_increases <- sum(!x$training &
                             x$classification == "increase",
                             na.rm = TRUE)
  n_recent_decreases <- sum(!x$training &
                             x$classification == "decrease",
                            na.rm = TRUE)
  n_recent_outliers <- n_recent_increases + n_recent_decreases
  p_recent_outliers <- stats::pbinom(
                                  n_recent_outliers,
                                  size = n_recent,
                                  prob = alpha,
                                  lower.tail = FALSE)

  n_training <- sum(x$training)
  n_training_increases <- sum(x$training &
                             x$classification == "increase",
                             na.rm = TRUE)
  n_training_decreases <- sum(x$training &
                             x$classification == "decrease",
                             na.rm = TRUE)
  n_training_outliers <- n_training_increases + n_training_decreases
  p_training_outliers <- stats::pbinom(
                                  n_training_outliers,
                                  size = n_training,
                                  prob = alpha,
                                  lower.tail = FALSE)

  data.frame(n_recent,
             n_recent_increases,
             n_recent_decreases,
             n_recent_outliers,
             p_recent_outliers,
             n_training,
             n_training_increases,
             n_training_decreases,
             n_training_outliers,
             p_training_outliers)

}




#' @rdname summary.trendbreaker
#' @export
summary.trendbreaker_incidence2 <- function(object, ...) {
  object <- object$output # TODO - this won't work if someone has renamed columns
  out <- lapply(object, summary)
  out <- dplyr::bind_rows(out)
  if (!is.null(names(object))) {
    out$group <- names(object)
    out <- dplyr::select(out, "group", dplyr::everything())
  }
  out
}
