#' @export
glm_model <- function(formula, family, ...) {
  eval(bquote(list(
    train = function(data) {
      model <- glm(formula = .(formula), family = .(family), data = data, ...)
      model_fit(model, formula)
    }
  )))
}

#' @export
glm_nb_model <- function(formula, ...) {
  eval(bquote(list(
    train = function(data) {
      model <- MASS::glm.nb(formula = .(formula), data = data, ...)
      model_fit(model, formula)
    }
  )))
}

#' @export
lm_model <- function(formula, ...) {
  eval(bquote(list(
    train = function(data) {
      model <- lm(formula = .(formula), data = data, ...)
      model_fit(model, formula)
    }
  )))
}

model_fit <- function(model, formula) {
  list(
    model = model,
    predict = function(newdata, alpha = 0.05) {
      res <- ciTools::add_pi(
        tb = newdata,
        fit = model,
        alpha = alpha,
        names = c("lower", "upper")
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
