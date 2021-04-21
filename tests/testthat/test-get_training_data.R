test_that("get_training_data works", {

  x <- 1:10
  y <- letters[1:10]
  dat <- data.frame(x, y)
  dat_rnd <- dat[sample(1:10), ]

  dat0 <- set_training_data(dat, "x", 0)
  dat1 <- set_training_data(dat, "x", 1)
  dat7 <- set_training_data(dat, "x", 7)
  dat_rnd7 <- set_training_data(dat_rnd, "x", 7)

  expect_identical(dat1$.training, rep(c(TRUE, FALSE), c(9, 1)))
  expect_identical(get_training_data(dat7), dat[1:3, ])
  expect_identical(get_training_data(dat7)$y, sort(get_training_data(dat_rnd7)$y))
  expect_identical(get_training_data(dat0), dat)

})


