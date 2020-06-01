#' S3 generics for epichange
#'
#' These are generic functions used by the *epichange* package, mostly used for
#' accessing content of various objects. See `?epichange-accessors` for methods
#' relating to `epichange` objects, and `epichange_model-accessors` for methods
#' relating to `epichange_model` objects.
#'
#' @seealso [epichange-accessors](epichange-accessors),
#'   [epichange_model-accessors](epichange_model-accessors)
#'
#' @rdname epichange-generics
#' @aliases epichange-generics

#' @export
#' @rdname epichange-generics
get_model <- function (x, ...) {
  UseMethod("get_model", x)
}


#' @export
#' @rdname epichange-generics
get_k <- function (x, ...) {
  UseMethod("get_k", x)
}


#' @export
#' @rdname epichange-generics
get_results <- function (x, ...) {
  UseMethod("get_results", x)
}


#' @export
#' @rdname epichange-generics
get_outliers <- function (x, ...) {
  UseMethod("get_outliers", x)
}


#' @export
#' @rdname epichange-generics
get_classification <- function (x, ...) {
  UseMethod("get_classification", x)
}


#' @export
#' @rdname epichange-generics
get_formula <- function (x, ...) {
  UseMethod("get_formula", x)
}


#' @export
#' @rdname epichange-generics
get_response <- function (x, ...) {
  UseMethod("get_response", x)
}


#' @export
#' @rdname epichange-generics
get_family <- function (x, ...) {
  UseMethod("get_family", x)
}
