test_that("asmodee and accessors works with data.frame", {

  # create a toy data set which should be fit by a linear model
  x <- 1:10
  y <- 2 * x + 3
  k <- 2           # this will exclude two dates (x = 9 and x = 10) for fitting
  y[10] <- 100     # This should be the only outlier
  dat <- data.frame(x, y)

  # Define models for fitting
  model1 <- trending::lm_model(y ~ 1)
  model2 <- trending::lm_model(y ~ x) # This should be the chosen model
  models <- list(constant = model1, lm_trend = model2)

  # we expect model2 to be the chosen one (fit to x = 1:8 as k = 2)
  expected_model <- trending::fit(model2, dat[1:8,])$fitted_model

  # calculate the result
  res <- asmodee(dat, models, x, method = trendeval::evaluate_aic, k = k)

  # asmodee expectations
  expect_identical(get_model(res), expected_model)
  expect_identical(get_formula(res), formula(expected_model))
  expect_identical(get_response(res), "y")
  expect_equal(get_k(res), 2)

  nms <- c(colnames(dat), ".training", "estimate", "lower_ci", "upper_ci",
           "lower_pi", "upper_pi", "outlier", "classification")
  expect_equal(names(get_results(res)), nms)

  outliers <- get_outliers(res)
  expect_equal(nrow(outliers), 1)
  expect_equal(ncol(outliers), 10)

  # asmodee fitting expectations
  y2 <- 2 * x + 3  # This is the trend we expect to be fit
  pred <- predict(res, dat)
  nms <- c(colnames(dat), "estimate", "lower_ci", "upper_ci", "lower_pi", "upper_pi")
  expect_equal(pred$estimate, y2)
  expect_equal(names(pred), nms)
})


test_that("basic sanity checks for data.frame on realistic data", {

  data(nhs_pathways_covid19)
  x <- dplyr::filter(nhs_pathways_covid19,
                     date >= as.Date("2020-04-01"),
                     nhs_region == "London")
  x <- dplyr::group_by(x, date, weekday, nhs_region)
  x <- dplyr::summarise(x, n = sum(count))

  models <- list(
      cst_pois = trending::glm_model(n ~ 1, "poisson"),
      pois = trending::glm_model(n ~ date, "poisson"),
      pois_weekday = trending::glm_model(n ~ weekday + date, "poisson"),
      nb_weekday = trending::glm_nb_model(n ~ weekday + date)
  )

  ## fixed_k = 7
  res <- asmodee(x, models, "date",
                 k = 7)
  expect_equal(res$k, 7)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))

  ## fixed_k, different pi estimation
  res <- asmodee(x, models, "date",
                 k = 3,
                 simulate_pi = FALSE,
                 uncertain = TRUE
                 )
  expect_equal(res$k, 3)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))

  ## using 4-fold  cross validation
  res <- asmodee(x, models,
                 "date",
                 k = 0,
                 method = trendeval::evaluate_resampling,
                 method_args = list(v = 4))
  expect_equal(res$k, 0)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))

})


test_that("basic sanity checks for incidence2 object on realistic data", {
  dat <- outbreaks::ebola_sim_clean$linelist
  dat <- dat[dat$date_of_onset > as.Date("2014-10-01"), ]

  model1 <- trending::glm_model(count ~ date_index, "poisson")
  model2 <- trending::glm_nb_model(count ~ date_index)
  models <- list(
    lm_trend = model1,
    glm_nb_trend = model2
  )

  ## ungrouped incidence
  x <- incidence2::incidence(dat, date_index = date_of_onset)
  res <- asmodee(x, models, k = 7)

  expect_equal(res$output[[1]]$k, 7)
  expect_true(is.logical(res$output[[1]]$results$outlier))
  expect_true(!anyNA(res$output[[1]]$results$outlier))

  ## grouped incidence
  x <- incidence2::incidence(dat, groups = hospital, date_index = date_of_onset)
  res <- asmodee(x, models, k = 7)

  expect_equal(res$output[[2]]$k, 7)
  expect_true(is.logical(res$output[[2]]$results$outlier))
  expect_true(!anyNA(res$output[[2]]$results$outlier))


  ## grouped incidence, weekly data
  x <- incidence2::incidence(dat, "monday week",
                             groups = hospital,
                             date_index = date_of_onset)
  res <- asmodee(x, models, k = 3)

  expect_equal(res$output[[2]]$k, 3)
  expect_true(is.logical(res$output[[2]]$results$outlier))
  expect_true(!anyNA(res$output[[2]]$results$outlier))

})
