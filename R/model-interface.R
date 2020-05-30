#' @export
glm_model <- function(formula, family, ...) {
  structure(
    eval(bquote(list(
      model_class = "glm",
      train = function(data) {
        model <- glm(formula = .(formula), family = .(family), data = data, ...)
        model_fit(model, formula)
      }
    ))),
    class = c("epichange_model", "epichange_glm")
  )
}

#' @export
glm_nb_model <- function(formula, ...) {
  structure(
    eval(bquote(list(
      model_class = "MASS::glm.nb",
      train = function(data) {
        model <- MASS::glm.nb(formula = .(formula), data = data, ...)
        model_fit(model, formula)
      }
    ))),
    class = c("epichange_model", "epichange_glm_nb")
  )
}

#' @export
lm_model <- function(formula, ...) {
  structure(
    eval(bquote(list(
      model_class = "lm",
      train = function(data) {
        model <- lm(formula = .(formula), data = data, ...)
        model_fit(model, formula)
      }
    ))),
    class = c("epichange_model", "epichange_lm")
  )
}

#' @export
brms_model <- function(formula, family, ...) {
  structure(
    eval(bquote(list(
      model_class = "brms",
      train = function(data) {
        model <- brms::brm(
          formula = .(formula),
          data = data,
          family = .(family), ...
        )
        list(
          model = model,
          predict = function(newdata, alpha = 0.05) {
            fit <- predict(model, newdata)
            col_name <- as.character(formula[[2]])
            interval <- brms::predictive_interval(model,
              newdata = newdata,
              prob = 1 - alpha
            )
            dplyr::bind_cols(
              tibble::tibble(
                observed = newdata[[col_name]],
                pred = fit[, 1],
                lower = interval[, 1],
                upper = interval[, 2]
              ),
              newdata
            )
          }
        )
      }
    ))),
    class = c("epichange_model", "epichange_brms_nb")
  )
}

add_prediction_interval <- function(model, data, alpha) {
  UseMethod("add_prediction_interval")
}

add_prediction_interval.negbin <- function(model, data, alpha) {
  mu <- predict(model, newdata = data, type = "response")
  theta <- model$theta
  stopifnot(theta > 0)
  # this ignores the uncertainty around mu and theta
  dplyr::bind_cols(
    data,
    tibble::tibble(
      pred = mu,
      lower = qnbinom(alpha / 2, mu = mu, size = theta),
      upper = qnbinom(1 - alpha / 2, mu = mu, size = theta),
    )
  )
}

add_prediction_interval.default <- function(model, data, alpha) {
  suppressWarnings(
    ciTools::add_pi(
      tb = data,
      fit = model,
      alpha = alpha,
      names = c("lower", "upper")
    )
  )
}

model_fit <- function(model, formula) {
  list(
    model = model,
    predict = function(newdata, alpha = 0.05) {
      ## TODO:
      ## replace add_ci with add_pi, and fix subsequent issue occuring with
      ## negbin models
      suppressWarnings(
        res <- add_prediction_interval(
          data = newdata,
          model = model,
          alpha = alpha
        )
      )
      col_name <- as.character(formula[[2]])
      res <- dplyr::bind_cols(
        res,
        data.frame(
          observed = res[[col_name]]
        )
      )
      res
    }
  )
}

#' @export
format.epichange_model <- function(x, ...) {
  paste0("Untrained epichange model type: ", x[["model_class"]])
}

#' @export
print.epichange_model <- function(x, ...) {
  cat(format(x, ...))
}
