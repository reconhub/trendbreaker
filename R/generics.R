#' S3 generics for trendbreaker
#'
#' These are generic functions used by the *trendbreaker* package, mostly used for
#' accessing content of various objects. See `?trendbreaker-accessors` for methods
#' relating to `trendbreaker` objects, and `trendbreaker_model-accessors` for methods
#' relating to `trendbreaker_model` objects.
#'
#' @seealso [trendbreaker-accessors](trendbreaker-accessors),
#'   [trendbreaker_model-accessors](trendbreaker_model-accessors)
#'
#' @param x the object to access information from
#'
#' @param ... further arguments used in methods
#'
#' @param x a `data.frame` to be used as training set for the model
#'
#' @rdname trendbreaker-generics
#' @aliases trendbreaker-generics
#' @export
get_k <- function(x, ...) {
  UseMethod("get_k", x)
}


#' @export
#' @rdname trendbreaker-generics
get_results <- function(x, ...) {
  UseMethod("get_results", x)
}

#' @export
#' @rdname trendbreaker-generics
get_outliers <- function(x, ...) {
  UseMethod("get_outliers", x)
}
