#' search_movies
#'
#' [Search TMDB movie database](https://developer.themoviedb.org/reference/search-movie)
#' Search for movies by their original, translated and alternative titles.
#' This function uses [search_movies_response()] to get the data from one page of results,
#' then uses [call_tmdb_fn()] and [loop_through_pages()] to combine data from remaining
#' pages
#'
#' @param query Required search parameter
#' @param ... Other optional search parameters
#' @seealso [search_movies_response()], [get_tmdb_response()], [call_tmdb_fn()], [unique()]
#'
#' @return
#' @export
#'
#' @examples
search_movies <- function(query, ...){

  args <- list(query = query,
               ...)

  call_tmdb_fn(search_movies_response,
               args) %>%
    dplyr::arrange(dplyr::desc(popularity))

}



#' search_movies_response
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
search_movies_response <- function(...){

  get_tmdb_response(path_args = c("search",
                                  "movie"),
                    ...)

}
