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

  res <- asmodee(dat, models, x, method = trendeval::evaluate_aic, k = 1)
  # TODO - these need changing as they are just duplicating the implementation!
  expect_identical(get_model(res), res$trending_model_fit$fitted_model)
  expect_equal(get_k(res), 1)
  expect_identical(get_formula(res), formula(res$trending_model_fit$fitted_model))
  expect_identical(get_response(res), "y")


  nms <- c(colnames(dat), "training", "estimate", "lower_ci", "upper_ci", "lower_pi",
           "upper_pi", "outlier", "classification")

  expect_equal(names(get_results(res)), nms)

  outliers <- get_outliers(res)
  expect_equal(nrow(outliers), 0)
  expect_equal(ncol(outliers), 10)

  pred <- predict(res, dat)
  nms <- c(colnames(dat), "estimate", "lower_ci", "upper_ci", "lower_pi", "upper_pi")
  expect_equal(pred$estimate, y)
  expect_equal(names(pred), nms)

})




test_that("trendbreaker_incidence2 subsetting", {

  dat <- outbreaks::ebola_sim_clean$linelist
  dat <- dat[dat$date_of_onset > as.Date("2014-10-01"), ]

  model1 <- trending::glm_model(count ~ date_index, "poisson")
  model2 <- trending::glm_nb_model(count ~ date_index)
  models <- list(
    lm_trend = model1,
    glm_nb_trend = model2
  )

  ## ungrouped incidence
  x <- incidence2::incidence(dat,
                             groups = hospital,
                             date_index = date_of_onset)
  res <- asmodee(x, models, k = 7)

  expect_identical(class(res), class(res[1]))
  expect_identical(names(res)[c(1,3)],
                   names(res[c(1,3)]))

})
