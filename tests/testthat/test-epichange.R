test_that("trendbreaker works", {
  model_constant <- trending::lm_model(hp ~ 1)
  model1 <- trending::glm_model(hp ~ 1 + cyl, poisson)
  model2 <- trending::lm_model(hp ~ 1 + cyl)
  model3 <- trending::glm_nb_model(hp ~ 1 + cyl)
  models <- list(
    null = model_constant,
    glm_poisson = model1,
    lm_trend = model2,
    negbin = model3
  )
  expect_silent(
    res <- asmodee(mtcars, models, method = trending::evaluate_aic)
  )
  expect_true(res$k >= 0)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))
})
