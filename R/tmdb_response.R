#' get_tmdb_response
#'
#' @param path_args List or Character Vector - Additional arguments appended to the base API url
#' @param ... Other arguments passed as named query parameters
#'
#' @return The response in JSON format
#' @export
#'
#' @examples
get_tmdb_response <- function(path_args = NULL,
                              auth_token = get_auth_token(),
                              ...) {
  base_tmdb_request(auth_token = auth_token) %>%
    httr2::req_url_path_append(path_args) %>%
    httr2::req_url_query(...) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json(simplifyVector = T)
}


#' base_tmdb_request
#'
#' @param auth_token
#'
#' @return httr2 request object with base URL, Authentication, and Throttling
#'   parameters set
#' @export
#'
#' @examples
base_tmdb_request <- function(auth_token = get_auth_token()) {
  httr2::request("https://api.themoviedb.org/3/") %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = paste(
        "Bearer",
        auth_token
      ),
      .redact = "Authorization"
    ) %>%
    httr2::req_error(body = tmdb_error_body) %>%
    httr2::req_user_agent("tmdbdata (https://github.com/novakowd/tmdbdata)") %>%
    httr2::req_throttle(rate = 40, realm = "https://api.themoviedb.org/3/")
}
{
  tmdb_error_body <- function(resp) {
    resp %>%
      httr2::resp_body_json() %>%
      purrr::pluck("status_message")
  }
}
