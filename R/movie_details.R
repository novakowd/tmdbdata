#' movie_details
#'
#' [Get TMDB movie
#' details](https://developer.themoviedb.org/reference/movie-details)
#'
#'
#' @param movie_id Required search parameter, internal TMDB identifier for a
#'   movie
#' @param append_to_response
#'   [Optional,](https://developer.themoviedb.org/docs/append-to-response) comma
#'   separated list of endpoints within this namespace, 20 items max (ex:
#'   `"videos,images"`)
#'
#' @return 1 row `tibble` containing JSON response details of specified
#'   movie in columns (25 columns by default, plus any `append_to_response`)
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
  ) %>%
    response_to_tibble() %>%
    reorganize_movie_detail_columns()
}

reorganize_movie_detail_columns <- function(movie_details){
  movie_details %>%
    dplyr::select(release_date,
                  title,
                  vote_average,
                  vote_count,
                  popularity,
                  runtime,
                  overview,
                  id,
                  imdb_id,
                  dplyr::everything())
}
