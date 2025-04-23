#' search_movies
#'
#' [Search TMDB movie
#' database](https://developer.themoviedb.org/reference/search-movie) movies by
#' their original, translated and alternative titles.
#'
#' @description
#'
#' **`search_movies()`** is a wrapper function, which uses [combine_page_results()] to:
#' \itemize{
#'   \item run `search_movies_response(query)` to get the response of the first
#'   page and determine how many total pages/results the `query` returned
#'   \itemize{
#'     \item takes the `$total_pages` from the response,
#'     \item Compares with the *optional* argument `num_pages`
#'   }
#'   \item if more pages are desired, uses [loop_through_pages()] to combine
#'   rows from all pages, then returns one `data.frame` object
#' }
#'
#' **`search_movies_response()`** returns a named list from one page of the JSON
#' response (default `page = 1`). The response contains:
#' \itemize{
#'   \item `$page` - (an `integer` value)
#'   \item `$results` - (a `data.frame` object representing one page of results,
#'   typically 20 entries per page)
#'   \item `$total_pages` - (an `integer` value)
#'   \item `$total_results` - (an `integer` value)
#' }
#'
#' @param query Required. A character vector with one element
#' @param ... Other Optional Query Parameters passed to the [search/movies/
#'   resource](https://developer.themoviedb.org/reference/search-movie). The
#'   only required parameter is `query`
#' @seealso [get_tmdb_response()], [call_tmdb_fn()], [unique()]
#'
#' @return
#' @export
#'
#' @examples
search_movies <- function(query, ...) {
  args <- list(
    query = query,
    ...
  )

  combine_page_results(
    search_movies_response,
    args = args
  ) %>%
    dplyr::arrange(dplyr::desc(popularity))
}


#' @rdname search_movies
search_movies_response <- function(query,
                                   ...,
                                   auth_token = get_auth_token()) {
  args <- list(
    query = query,
    ...
  )

  get_tmdb_response(
    path_args = c(
      "search",
      "movie"
    ),
    !!!args,
    auth_token = auth_token
  )
}
