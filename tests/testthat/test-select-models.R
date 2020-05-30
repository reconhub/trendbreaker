test_that("an example select models process", {
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
  training_data <- mtcars
  suppressWarnings(
    auto_fit <- select_model(training_data, models, evaluate_resampling,
      metrics = list(yardstick::rmse), v = 2, repeats = 1
    )
  )
  res <- auto_fit$leaderboard
  expect_equal(colnames(res), c("model", "rmse"))
  expect_setequal(res$model, names(models))
})
