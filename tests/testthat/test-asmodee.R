test_that("asmodee works with data.frame", {
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

  # fixed_k = NULL
  expect_silent(
    res <- asmodee(mtcars, models, method = trending::evaluate_aic)
  )
  expect_true(res$k >= 0)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))

  # fixed_k as character
  expect_error(
    asmodee(mtcars, models, method = trending::evaluate_aic, fixed_k = "bob"),
    "`fixed_k` must be a finite number"
  )

  # fixed_k = 7
  res2 <- asmodee(mtcars, models, method = trending::evaluate_aic, fixed_k = 7)
  expect_true(res2$k == 7)
  expect_true(is.logical(res2$results$outlier))
  expect_true(!anyNA(res2$results$outlier))
})



test_that("asmodee works with incidence2 object", {
  dat <- outbreaks::ebola_sim_clean$linelist

  model1 <- trending::lm_model(count ~ date)
  model2 <- trending::glm_nb_model(count ~ date)
  models <- list(
    lm_trend = model1,
    glm_nb_trend = model2
  )

  # ungrouped incidence
  x <- incidence2::incidence(dat, date_index = date_of_onset)
  res <- asmodee(x, models, method = trending::evaluate_aic)

  expect_true(res[[1]]$k >= 0)
  expect_true(is.logical(res[[1]]$results$outlier))
  expect_true(!anyNA(res[[1]]$results$outlier))

  # grouped incidence
  x <- incidence2::incidence(dat, date_index = date_of_onset, groups = gender)
  res <- asmodee(x, models, method = trending::evaluate_aic)

  expect_true(res[[2]]$k >= 0)
  expect_true(is.logical(res[[2]]$results$outlier))
  expect_true(!anyNA(res[[2]]$results$outlier))


})

