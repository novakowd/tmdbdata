movie_details_summary <- function(movie_ids) {
  movie_ids %>%
    purrr::map(\(x) movie_details(x) %>% movie_summary_info()) %>%
    purrr::list_rbind()
}

#' movie_details
#'
#' [Get TMDB movie details](https://developer.themoviedb.org/reference/movie-details)
#'
#'
#' @param movie_id Required search parameter, internal TMDB identifier for a movie
#' @param append_to_response [Optional,](https://developer.themoviedb.org/docs/append-to-response) comma separated list of endpoints within this namespace, 20 items max (ex: `"videos,images"`)
#'
#' @return JSON response for the movie details of specified movie
#' @export
#'
#' @examples
movie_details <- function(movie_id,
                          append_to_response = NULL) {
  get_tmdb_response(
    path_args = c(
      "movie",
      movie_id
    ),
    append_to_response = append_to_response
  )
}


movie_summary_info <- function(response) {
  data.frame(response$id,
    response$original_title,
    response$title,
    response$release_date,
    response$popularity,
    response$vote_average,
    response$vote_count,
    genres = response$genres$name %>%
      paste(collapse = ", "),
    collection = ifelse(!is.null(response$belongs_to_collection),
      response$belongs_to_collection$name,
      NA
    ),
    response$overview,
    response$budget,
    response$revenue
  ) %>%
    dplyr::rename_with(~ stringr::str_remove(
      .x,
      "^response."
    ))
}
