#' search_collection
#'
#' [Search TMDB Collections database](https://developer.themoviedb.org/reference/search-collection)
#'
#'
#' @param query Required search parameter
#' @param ... Other optional search parameters
#'
#' @return
#' @export
#'
#' @examples
search_collection <- function(query, ...) {
  args <- list(
    query = query,
    ...
  )

  combine_page_results(
    search_collection_response,
    args
  )
}



search_collection_response <- function(...) {
  get_tmdb_response(
    path_args = c(
      "search",
      "collection"
    ),
    ...
  )
}
