#' Plotting method for epichange objects
#'
#' The plotting method for `epichange` objects produces a `ggplot` object, which
#' can then be modified using `ggplot2`. It accepts a few arguments for
#' customising the graphs produced.
#'
#' @param x an `epichange` object, as returned by `asmodee`
#'
#' @param x_axis the name or position of the variable in `get_results(x)` to be
#'   used on the x-axis, which represents time
#'
#' @param point_size the size of the points to be used; defaults to 2
#'
#' @param col_normal the color to be used for non-outlying observations,
#'   i.e. observations falling within the prediction interval of the estimated
#'   temporal trend
#' 
#' @param col_increase the color to be used for outlying observations which are
#'   above the prediction interval of the estimated temporal trend
#' 
#' @param col_decrease the color to be used for outlying observations which are
#'   below the prediction interval of the estimated temporal trend
#'
#' @param guide a `logical` indicating whether a color legend should be added to
#'   the plot (`TRUE`, default) or not (`FALSE`)
#'
#' @param ... unused - present for compatibility with the `plot` generic
#'
#' @export
#' @rdname plot.epichange
#' @aliases plot.epichange

plot.epichange <- function(x,
                           x_axis,
                           point_size = 2,
                           col_normal = "#8B8B8C",
                           col_increase = "#CB3355",
                           col_decrease = "#32AB96",
                           guide = TRUE,
                           ...) {
  ## ensure that x_axis is the name of a variable
  results <- get_results(x)
  if (is.numeric(x_axis)) {
    x_axis <- names(results)[x_axis]
  }
    
  n <- nrow(results)
  n_train <- n - get_k(x)
  if (n_train < n) {
    train_limit <- mean(results[n_train:(n_train + 1), x_axis, drop = TRUE])
  } else {
    train_limit <- NULL
  }

  col_model <- "#BBB67E"

  scale_classification <- ggplot2::scale_color_manual(
    "Change in trend:",
    values = c(decrease = col_decrease, increase = col_increase, normal = col_normal),
    labels = c(decrease = "Decrease", increase = "Increase", normal = "Same trend"),
    drop = FALSE
  )

  custom_guide <- if (guide) ggplot2::guide_legend(override.aes = list(size = c(4, 4, 3))) else FALSE
  ggplot2::ggplot(results, ggplot2::aes_string(x = x_axis, y = "count")) +
    ggplot2::theme_bw() +
    ggplot2::geom_vline(xintercept = train_limit, linetype = 2) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lower, ymax = upper),
      alpha = 0.4, fill = col_model
    ) +
    ggplot2::geom_point(ggplot2::aes(color = classification),
      size = point_size + results$outlier
    ) +
    ggplot2::geom_line(alpha = 0.3) +
    scale_classification +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::guides(color = custom_guide)
}
