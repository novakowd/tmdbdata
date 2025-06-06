% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auth_token.R
\name{decrypt_auth_token}
\alias{decrypt_auth_token}
\title{decrypt_auth_token}
\usage{
decrypt_auth_token()
}
\value{
Character vector of Authorization Token
}
\description{
Token Obtained from \href{https://developer.themoviedb.org/docs/getting-started}{TMDB api} Decript the
Authorization Token using \href{https://httr2.r-lib.org/articles/wrapping-apis.html#basics}{httr2's secret encription}
}
