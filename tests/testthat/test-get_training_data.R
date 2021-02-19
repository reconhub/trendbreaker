test_that("get_training_data works", {

  x <- 1:10
  y <- letters[1:10]
  dat <- data.frame(x, y)
  dat_rnd <- dat[sample(1:10), ]

  expect_identical(set_training_data(dat, "x", 1)$training,
                   rep(c(TRUE, FALSE), c(9, 1)))
  expect_identical(get_training_data(dat, "x", 7), dat[1:3, ])
  expect_identical(get_training_data(dat, "x", 7)$y,
                   sort(get_training_data(dat_rnd, "x", 7)$y))
  expect_identical(get_training_data(dat, "x", 0),
                   dat)

})





test_that("get_training_data throws appropriate errors", {

  x <- 1:10
  y <- letters[1:10]
  dat <- data.frame(x, y)
  dat_rnd <- dat[sample(1:10), ]

  expect_error(get_training_data(dat, "x", 10), msg)
})
