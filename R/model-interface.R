#' @export
glm_model <- function(formula, family, ...) {
  structure(
    eval(bquote(list(
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

model_fit <- function(model, formula) {
  list(
    model = model,
    predict = function(newdata, alpha = 0.05) {
      ## TODO:
      ## replace add_ci with add_pi, and fix subsequent issue occuring with
      ## negbin models
      suppressWarnings(
        res <- ciTools::add_ci(
          tb = newdata,
          fit = model,
          alpha = alpha,
          names = c("lower", "upper")
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
