get_auth_token <- function() {
  token <- Sys.getenv("TMDB_AUTH_TOKEN")
  if (!identical(token, "")) {
    return(token)
  }

  if (is_testing()) {
    return(decrypt_auth_token())
   } else {
    stop("No Authorization Token found, please supply with `auth_token` argument or with TMDB_AUTH_TOKEN env var")
  }
}

is_testing <- function() {
  identical(Sys.getenv("TESTTHAT"), "true")
}


#' decrypt_auth_token
#'
#' Token Obtained from [TMDB
#' api](https://developer.themoviedb.org/docs/getting-started) Decript the
#' Authorization Token using [httr2's secret
#' encription](https://httr2.r-lib.org/articles/wrapping-apis.html#basics)
#'
#' @return Character vector of Authorization Token
#' @export
decrypt_auth_token <- function() {
  httr2::secret_decrypt(
    "GlRPWG8E9U6bxKRX3DI9v8kt1Z1UOY2QFBhKwQxeqVmNZUxsDMH0r4u2ahyr_G6ru8uTwrs1lGO-jtWQJbpnSWm4zPvCsf_L6ZUx7zKK1d6t5-Svm5mf2hM16jUY6StzTjMEHf7_BM-U9IYOGdRtvRv_noeKovRUcmtnjIg-c2QXwCKILUsKzaTvZysUe8OIAgQI7-QkZw8awUe2kDw4nVHfKE_A2IRhPk8Nmv-_S3ENkjaWnC1AhbbR3NtFpXTXmqg9ZPZPgrIBHsrbiI7m1nRyMBCCerdWBybFkRQLjKV0UwGG29DfaeVdD5rsrXmMj05YmpovWFKhdEFGx0NQ",
    "HTTR2_KEY"
  )
}
set_auth_token <- function(token = NULL) {
  if (is.null(token)) {
    key <- askpass::askpass("Please enter your API Read Access Token from \"https://www.themoviedb.org/settings/api\"")
  }
  Sys.setenv("TMDB_AUTH_TOKEN" = key)
}
