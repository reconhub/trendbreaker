## S3 generics

#' @export
get_model <- function (x, ...) {
  UseMethod("get_model", x)
 }

#' @export
get_k <- function (x, ...) {
  UseMethod("get_k", x)
 }

#' @export
get_results <- function (x, ...) {
  UseMethod("get_results", x)
 }

#' @export
get_outliers <- function (x, ...) {
  UseMethod("get_outliers", x)
 }

#' @export
get_classification <- function (x, ...) {
  UseMethod("get_classification", x)
 }
