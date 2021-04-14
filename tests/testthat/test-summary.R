test_that("asmodee works with data.frame", {

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

  # k = 7
  res <- asmodee(x, models, "date", k = 7)

  smry <- summary(res)
  expect_s3_class(smry, "data.frame")
  expect_identical(nrow(smry), 1L)
  expect_identical(ncol(smry), 10L)
  expected_names <- c("n_recent", "n_recent_increases", "n_recent_decreases",
                      "n_recent_outliers", "p_recent_outliers", "n_training",
                      "n_training_increases", "n_training_decreases",
                      "n_training_outliers", "p_training_outliers")
  expect_identical(names(smry), expected_names)
  expect_identical(smry$n_recent_outliers,
                   smry$n_recent_increases + smry$n_recent_decreases)
  expect_identical(smry$n_training_outliers,
                   smry$n_training_increases + smry$n_training_decreases)

})



test_that("asmodee works with incidence2 object", {

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
  smry <- summary(res)

  expect_equal(smry, summary(res$output[[1]]))

  ## grouped incidence
  x <- incidence2::incidence(dat, groups = hospital, date_index = date_of_onset)
  res <- asmodee(x, models, k = 7)
  smry <- summary(res)

  expect_s3_class(smry, "data.frame")
  expect_identical(nrow(smry), length(res$output))
  expect_identical(ncol(smry), 11L)
  expected_names <- c("group",
                      "n_recent", "n_recent_increases", "n_recent_decreases",
                      "n_recent_outliers", "p_recent_outliers", "n_training",
                      "n_training_increases", "n_training_decreases",
                      "n_training_outliers", "p_training_outliers")
  expect_identical(names(smry), expected_names)
  expect_identical(smry$n_recent_outliers,
                   smry$n_recent_increases + smry$n_recent_decreases)
  expect_identical(smry$n_training_outliers,
                   smry$n_training_increases + smry$n_training_decreases)

})
