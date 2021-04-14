check_suggests <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    msg <- sprintf("Suggested package '%s' not present.", package)
    stop(msg, call. = FALSE)
  }
}


base_transpose <- function(l) {
  lapply(seq_along(l[[1]]), function(x) lapply(l, "[[", x))
}


safely <- function(fun) {
  function(...) {
    warn <- err <- NULL
    res <- withCallingHandlers(
      tryCatch(
        fun(...),
        error = function(e) {
          err <<- conditionMessage(e)
          NULL
        }
      ),
      warning = function(w) {
        warn <<- append(warn, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    list(res, warn = warn, err = err)
  }
}
