test_that("asmodee works with data.frame", {

  data(nhs_pathways_covid19)
  to_keep <- nhs_pathways_covid19$date >= as.Date("2020-05-01")
  x <- nhs_pathways_covid19[to_keep, ]
  
  models <- list(
      cst_pois = trending::glm_model(count ~ 1, "poisson"),
      pois = trending::glm_model(count ~ date, "poisson"),
      pois_weekday = trending::glm_model(count ~ weekday + date, "poisson"),
      nb_weekday = trending::glm_nb_model(count ~ weekday + date),
      nb_weekday_region = trending::glm_nb_model(count ~ nhs_region + weekday + date)
  )

  # fixed_k = 7
  res <- asmodee(x, models, "date",
                 method = trendeval::evaluate_aic,
                 fixed_k = 7)
  expect_true(res2$k == 7)
  expect_true(is.logical(res2$results$outlier))
  expect_true(!anyNA(res2$results$outlier))
  
  ## # fixed_k = NULL
  ## expect_silent(
  ##   res <- asmodee(mtcars, models, method = trendeval::evaluate_aic)
  ## )
  expect_true(res$k >= 0)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))

  # fixed_k not proper input
  expect_error(
    asmodee(mtcars, models, method = trendeval::evaluate_aic, fixed_k = "bob"),
    "`fixed_k` must be a finite number"
  )

  
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
  res <- asmodee(x, models, method = trendeval::evaluate_aic)

  expect_true(res[[1]]$k >= 0)
  expect_true(is.logical(res[[1]]$results$outlier))
  expect_true(!anyNA(res[[1]]$results$outlier))

  # grouped incidence
  x <- incidence2::incidence(dat, date_index = date_of_onset, groups = gender)
  res <- asmodee(x, models, method = trendeval::evaluate_aic)

  expect_true(res[[2]]$k >= 0)
  expect_true(is.logical(res[[2]]$results$outlier))
  expect_true(!anyNA(res[[2]]$results$outlier))


})

