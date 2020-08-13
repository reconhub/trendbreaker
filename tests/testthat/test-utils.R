test_that("check_suggests works", {

  expect_null(check_suggests("base"))

  pkg <- "dkjgrndfkjgndlkfsjgndlskjfnglkdjfng"
  msg <- sprintf("Suggested package '%s' not present", pkg)
  expect_error(check_suggests(pkg))

})
