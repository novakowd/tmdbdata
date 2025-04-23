#' Discover_movies
#'
#' [Discover TMDB movies](https://developer.themoviedb.org/reference/discover-movie)
#' has a number of available optional parameters.
#'
#'
#' @param num_pages Max. number of pages to request from API server
#' (default = 5 pages x 20 results/page)
#' @param ... Search parameters as seen on documentation website
#'
#' @return
#' @export
#'
#' @examples
discover_movies <- function(num_pages = 5,
                            ...) {
  args <- list(
    num_pages = num_pages,
    ...
  )

  combine_page_results(
    discover_movies_response,
    args
  )
}



discover_movies_response <- function(...) {
  get_tmdb_response(
    path_args = c(
      "discover",
      "movie"
    ),
    ...
  )
}
