test_that("get_auth_token() returns a character object", {
  expect_type(get_auth_token(), "character")
})

test_that("get_auth_token() returns a value at least 10 characters long", {
  expect_gte(nchar(get_auth_token()), 10)
})
