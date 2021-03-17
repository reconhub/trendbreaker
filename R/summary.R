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
#' * 
summary.trendbreaker <- function(object, ...) {
  x <- object$results
  n_recent <- sum(!x$training)
  n_recent_increases <- sum(!x$training &
                             x$classification == "increase",
                             na.rm = TRUE)
  n_recent_decreases <- sum(!x$training &
                             x$classification == "decrease",
                             na.rm = TRUE)
  n_training <- sum(x$training)
  n_training_increases <- sum(x$training &
                             x$classification == "increase",
                             na.rm = TRUE)
  n_training_decreases <- sum(x$training &
                             x$classification == "decrease",
                             na.rm = TRUE)

  data.frame(n_recent,
             n_recent_increases,
             n_recent_decreases,
             n_recent_outliers = n_recent_increases + n_recent_decreases,
             n_training,
             n_training_increases,
             n_training_decreases,
             n_training_outliers = n_training_increases + n_training_decreases)
  
}
