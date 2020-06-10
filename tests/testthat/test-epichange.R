test_that("trendbreaker works", {
  model_constant <- lm_model(hp ~ 1)
  model1 <- glm_model(hp ~ 1 + cyl, poisson())
  model2 <- lm_model(hp ~ 1 + cyl)
  model3 <- glm_nb_model(hp ~ 1 + cyl)
  models <- list(
    null = model_constant,
    glm_poisson = model1,
    lm_trend = model2,
    negbin = model3
  )
  expect_silent(
    res <- asmodee(mtcars, models, method = evaluate_aic)
  )
  expect_true(res$k >= 0)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))
})
