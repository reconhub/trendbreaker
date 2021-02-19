test_that("asmodee works with data.frame", {

  data(nhs_pathways_covid19)
  to_keep <- nhs_pathways_covid19$date >= as.Date("2020-05-01") &
    !is.na(nhs_pathways_covid19$nhs_region) & 
    nhs_pathways_covid19$nhs_region == "London"
  x <- nhs_pathways_covid19[to_keep, ]
  
  models <- list(
      cst_pois = trending::glm_model(count ~ 1, "poisson"),
      pois = trending::glm_model(count ~ date, "poisson"),
      pois_weekday = trending::glm_model(count ~ weekday + date, "poisson"),
      nb_weekday = trending::glm_nb_model(count ~ weekday + date),
      nb_weekday_region = trending::glm_nb_model(count ~ nhs_region + weekday + date)
  )

  ## fixed_k = 7
  res <- asmodee(x, models, "date",
                 method = trendeval::evaluate_aic,
                 fixed_k = 7)
  expect_true(res$k == 7)
  expect_true(is.logical(res$results$outlier))
  expect_true(!anyNA(res$results$outlier))

  ## optimize k
  expect_silent(
      res <- asmodee(x, models, "date",
                     method = trendeval::evaluate_aic,
                     max_k = 1)
  )
  
})



test_that("asmodee works with incidence2 object", {
  dat <- outbreaks::ebola_sim_clean$linelist
  dat <- dat[dat$date_of_onset > as.Date("2014-09-01"), ]

  model1 <- trending::glm_model(count ~ date_index, "poisson")
  model2 <- trending::glm_nb_model(count ~ date_index)
  models <- list(
    lm_trend = model1,
    glm_nb_trend = model2
  )

  ## ungrouped incidence
  x <- incidence2::incidence(dat, date_index = date_of_onset)
  res <- asmodee(x, models, method = trendeval::evaluate_aic, fixed_k = 7)

  expect_equal(res[[1]]$k, 7)
  expect_true(is.logical(res[[1]]$results$outlier))
  expect_true(!anyNA(res[[1]]$results$outlier))

  # grouped incidence
  x <- incidence2::incidence(dat, groups = hospital, date_index = date_of_onset)
  res <- asmodee(x, models, method = trendeval::evaluate_aic, fixed_k = 7)

  expect_equal(res[[2]]$k, 7)
  expect_true(is.logical(res[[2]]$results$outlier))
  expect_true(!anyNA(res[[2]]$results$outlier))

})
