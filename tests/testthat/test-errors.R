test_that("errors", {

  x <- 1:10
  y <- 2 * x + 3
  dat <- data.frame(x, y)
  model1 <- trending::lm_model(y ~ 1)
  model2 <- trending::lm_model(y ~ x)
  models <- list(
    constant = model1,
    lm_trend = model2
  )

  # detect_changepoint error
  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 7),
    "`k` (7) is too high for the dataset size (10)",
    fixed = TRUE
  )

  # # detect_outliers errors
  # msg <- paste("`model` has not been trained on data;",
  #                "use `train()` to train your model, then detect outliers")
  # expect_error(detect_outliers(dat, model1),
  #              msg,
  #              fixed = TRUE)
  #
  # msg <- "`model` should be an `trending_model_fit` object, but is a `character`"
  # expect_error(detect_outliers(dat, "batman"),
  #              msg,
  #              fixed = TRUE)

})
