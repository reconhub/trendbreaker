test_that("trendbreaker accessors", {

  x <- 1:10
  y <- 2 * x + 3
  dat <- data.frame(x, y)
  model1 <- trending::lm_model(y ~ 1)
  model2 <- trending::lm_model(y ~ x)
  models <- list(
    constant = model1,
    lm_trend = model2
  )

  res <- asmodee(dat, models, method = trending::evaluate_aic, fixed_k = 1)
  expect_output(print(get_model(res)), "y ~ x")
  expect_equal(get_k(res), 1)

  nms <- c(colnames(dat), "pred", "lower-ci", "upper-ci", "lower-pi", "upper-pi", "observed", "outlier", "classification")
  expect_equal(names(get_results(res)), nms)

  outliers <- get_outliers(res)
  expect_equal(nrow(outliers), 0)
  expect_equal(ncol(outliers), 10)

  pred <- predict(res, dat)
  nms <- c(colnames(dat), "pred", "lower-ci", "upper-ci", "lower-pi", "upper-pi", "observed")
  expect_equal(pred$pred, y)
  expect_equal(names(pred), nms)

})


