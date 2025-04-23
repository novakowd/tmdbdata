#' get_tmdb_response
#'
#' @param path_args Additional arguments appended to the base API url
#' @param ... Other arguments passed as named query parameters
#'
#' @return The response in JSON format
#' @export
#'
#' @examples
get_tmdb_response <- function(path_args,
                              ...){
  base_tmdb_request() %>%
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
base_tmdb_request <- function(auth_token = get_auth_token()){
  httr2::request("https://api.themoviedb.org/3/") %>%
    httr2::req_headers(accept = "application/json",
                       Authorization = paste("Bearer",
                                             auth_token),
                       .redact = "Authorization"
    ) %>%
    httr2::req_throttle(rate = 40)
}
