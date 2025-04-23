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
{
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
      glue::glue("NvjamemVlmt303Jf5m6OTZzzCRCOVDpPwWTjo4UX2rMfgQ39con
                  -XAVPk_VfhJ1NSXL_FP9E1VVyQy7Op5mYqgLUxUo6OSR6Vvx8u1
                  V9gZ5rvA0BfPkE5LtoVvWneGXgSD0olkfUeQGQ_ueUXsaRcrb-G
                  rzKA_m9JG9PqMzvHeK230NtNkjKx7p0JJO7EPEBfFL60WjTgIYr
                  zb19xKGVWjk1t7rfN58VBrPcoJ56JB_U-pJaC5SWufde9QWSwg7
                  McWvmHfIc9u6KpSszIW60m3ND-jzXyPhdVQefc0BxKoIO2tJApv
                  H63F_ohqQX8iCayhUGrjDKcyBq7nmp2tw1"),
      "HTTR2_KEY"
    )
  }
}

set_auth_token <- function(token = NULL) {
  if (is.null(token)) {
    key <- askpass::askpass("Please enter your API Read Access Token from \"https://www.themoviedb.org/settings/api\"")
  }
  Sys.setenv("TMDB_AUTH_TOKEN" = key)
}
