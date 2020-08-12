check_suggests <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    msg <- sprintf("Suggested package '%s' not present.", package)
    stop(msg, call. = FALSE)
  }
}
