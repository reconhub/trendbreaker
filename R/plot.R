#' @export
  
plot.epichange <- function(x,
                           point_size = 2,
                           col_normal = "#8B8B8C",
                           col_increase = "#CB3355",
                           col_decrease = "#32AB96",
                           guide = TRUE,
                           ...) {

  stop_train <- max(x$results$day) - x$k
  col_model <- "#BBB67E"
  
  scale_classification <- ggplot2::scale_color_manual(
    "Change in trend:",
    values = c(decrease = col_decrease, increase = col_increase, normal = col_normal),
    labels = c(decrease = "Decrease", increase = "Increase", normal = "Same trend"),
    drop = FALSE)

  custom_guide <- if (guide) ggplot2::guide_legend(override.aes = list(size = c(4, 4, 3))) else FALSE
  
  ggplot2::ggplot(x$results, aes(x = day, y = count)) +
    ggplot2::theme_bw() +
      ##ggplot2::large_txt +
      ggplot2::geom_vline(xintercept = stop_train, linetype = 2) +
      ggplot2::geom_ribbon(ggplot2::aes(ymin = lower, ymax = upper),
                           alpha = 0.4, fill = col_model) +
      ggplot2::geom_point(ggplot2::aes(color = classification),
                          size = point_size + x$results$outlier) +
      ggplot2::geom_line(alpha = 0.3) +
      scale_classification +
      ggplot2::theme(legend.position = "bottom") +
      ggplot2::guides(color = custom_guide)
}
