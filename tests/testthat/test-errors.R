test_that("asmodee errors as expected", {

  x <- 1:10
  y <- 2 * x + 3
  dat <- data.frame(x, y)
  model1 <- trending::lm_model(y ~ 1)
  model2 <- trending::lm_model(y ~ x)
  models <- list(
    constant = model1,
    lm_trend = model2
  )

  # basic errors
  expect_error(
    asmodee(dat, models=list(), x, method = evaluate_aic, k = 2),
    "models has a length of zero",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, alpha = "test"),
    "`alpha` must be a finite number",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, alpha = Inf),
    "`alpha` must be a finite number",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = "test"),
    "`k` must be a finite number",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = Inf),
    "`k` must be a finite number",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, simulate_pi = "test"),
    "`simulate_pi` should be TRUE or FALSE",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, uncertain = "test"),
    "`uncertain` should be TRUE or FALSE",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, include_fitting_warnings = "test"),
    "`include_fitting_warnings` should be TRUE or FALSE",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, include_prediction_warnings = "test"),
    "`include_prediction_warnings` should be TRUE or FALSE",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, force_positive = "test"),
    "`force_positive` should be TRUE or FALSE",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 2, keep_intermediate = "test"),
    "`keep_intermediate` should be TRUE or FALSE",
    fixed = TRUE
  )

  expect_error(asmodee(dat, models, x, method = evaluate_aic, k = 2, test = "test"))

  expect_error(
    asmodee(dat, models, x, method = evaluate_aic, k = 7),
    "`k` (7) is too high for the dataset size (10)",
    fixed = TRUE
  )

  expect_error(
    asmodee(dat, models, date_index = "test", method = evaluate_aic, k = 2),
    "Column `test` doesn't exist",
    fixed = TRUE
  )



})
