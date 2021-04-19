check_suggests <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    msg <- sprintf("Suggested package '%s' not present.", package)
    stop(msg, call. = FALSE)
  }
}

make_catcher <- function(fun) {
  function(...) {

    # create variables in environment to store output
    warn <- err <- NULL
    env <- environment()

    # define handlers
    warning_handler <- function(w) {
      assign("warn", c(warn, conditionMessage(w)), env, inherits = TRUE)
      invokeRestart("muffleWarning")
    }

    error_handler <- function(e) {
      assign("err", conditionMessage(e), env, inherits = TRUE)
      NULL
    }

    # capture output
    res <- withCallingHandlers(
      tryCatch(
        fun(...),
        error = error_handler
      ),
      warning = warning_handler
    )

    list(result = res, warnings = warn, errors = err)
  }
}


clapply <- function(X, FUN, ...) {
  f <- make_catcher(FUN)
  res <- lapply(X, f, ...)
  res <- lapply(seq_along(res[[1]]), function(x) lapply(res, "[[", x))
  if (requireNamespace("tibble", quietly = TRUE)) {
    out <- tibble::tibble(
      result = res[[1]],
      warnings = res[[2]],
      errors = res[[3]]
    )
  } else {
    out <- data.frame(
      result = I(res[[1]]),
      warnings = I(res[[2]]),
      errors = I(res[[3]])
    )
  }
  out
}


future_clapply <- function(X, FUN, ...) {
  f <- make_catcher(FUN)
  res <- future.apply::future_lapply(X, f, ...)
  res <- lapply(seq_along(res[[1]]), function(x) lapply(res, "[[", x))
  if (requireNamespace("tibble", quietly = TRUE)) {
    out <- tibble::tibble(
      result = res[[1]],
      warnings = res[[2]],
      errors = res[[3]]
    )
  } else {
    out <- data.frame(
      result = I(res[[1]]),
      warnings = I(res[[2]]),
      errors = I(res[[3]])
    )
  }
  out
}



