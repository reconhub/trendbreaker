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
  tibble::tibble(result = res[[1]], warnings = res[[2]], errors = res[[3]])
}


future_clapply <- function(X, FUN, ...) {
  f <- make_catcher(FUN)
  res <- future.apply::future_lapply(X, f, ...)
  res <- lapply(seq_along(res[[1]]), function(x) lapply(res, "[[", x))
  tibble::tibble(result = res[[1]], warnings = res[[2]], errors = res[[3]])
}

# check if entries of a vector are whole numbers
is.wholenumber <- function(x, tol = .Machine$double.eps^0.5) {
  abs(x - round(x)) < tol
}


# cast a vector to an integer
int_cast <- function(x) {
  x <- unclass(x)
  if (!all(is.wholenumber(x) | is.na(x))) {
    msg <- paste(deparse1(substitute(x)), "must be a vector of whole numbers")
    stop(msg, call. = FALSE)
  }
  res <- as.integer(x)
  names(res) <- names(x)
  res
}




