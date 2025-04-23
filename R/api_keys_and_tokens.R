get_api_key <- function() {
  key <- Sys.getenv("TMDB_API_KEY")
  if (identical(key, "")) {
    stop("No API key found, please supply with `api_key` argument or with TMDB_API_KEY env var")
  }
  key
}


get_auth_token <- function() {
  token <- Sys.getenv("TMDB_AUTH_TOKEN")
  if (identical(token, "")) {
    stop("No Authorization Token found, please supply with `auth_token` argument or with TMDB_AUTH_TOKEN env var")
  }
  token
}


#' decrypt_api_key
#'
#' Key Obtained from
#' [TMDB api](https://developer.themoviedb.org/docs/getting-started)
#' Decript the API key using
#' [httr2's secret encription](https://httr2.r-lib.org/articles/wrapping-apis.html#basics)
#'
#' @return Character vector of API key
#' @export
decrypt_api_key <- function(){
  httr2::secret_decrypt(
    glue::glue("fnC3UhwIky2l9BPU
               tlmGOJ-WwMoufzJPA
               aRrKkWXRFCvgAw30T
               DPiKlzOlOhpnAByX2
               8qdGeQmQ2fFLBwQMK
               yeL8ctTNF5Y6cZTm8
               5f3i_o"),
    "TMDBDATA_KEY"
    )
}


#' decrypt_auth_token
#'
#' Token Obtained from
#' [TMDB api](https://developer.themoviedb.org/docs/getting-started)
#' Decript the Authorization Token using
#' [httr2's secret encription](https://httr2.r-lib.org/articles/wrapping-apis.html#basics)
#'
#' @return Character vector of Authorization Token
#' @export
decrypt_auth_token <- function(){
  httr2::secret_decrypt(
    glue::glue("NvjamemVlmt303Jf5
               m6OTZzzCRCOVDpPwWT
               jo4UX2rMfgQ39con-X
               AVPk_VfhJ1NSXL_FP9
               E1VVyQy7Op5mYqgLUx
               Uo6OSR6Vvx8u1V9gZ5
               rvA0BfPkE5LtoVvWne
               GXgSD0olkfUeQGQ_ue
               UXsaRcrb-GrzKA_m9J
               G9PqMzvHeK230NtNkj
               Kx7p0JJO7EPEBfFL60
               WjTgIYrzb19xKGVWjk
               1t7rfN58VBrPcoJ56J
               B_U-pJaC5SWufde9QW
               Swg7McWvmHfIc9u6Kp
               SszIW60m3ND-jzXyPh
               dVQefc0BxKoIO2tJAp
               vH63F_ohqQX8iCayhU
               GrjDKcyBq7nmp2tw1"),
    "TMDBDATA_KEY"
    )
}
