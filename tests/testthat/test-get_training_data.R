test_that("get_training_data works", {

  x <- 1:10
  y <- letters[1:10]
  dat <- data.frame(x, y)
  dat_rnd <- dat[sample(1:10), ]

  expect_identical(get_training_data(dat, "x", 7), dat[1:3, ])
  expect_identical(get_training_data(dat, "x", 7),
                   get_training_data(dat_rnd, "x", 7))

  expect_error(get_training_data(dat, "x", 10), msg)
})
