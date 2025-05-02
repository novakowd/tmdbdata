load_imdb_data <- function(use_cached_data = T,
                           cache_results = T,
                           cache_dir = "cache_imdb/"){

  check_for_imdb_suggested_packages()

  args <- list(use_cached_data = use_cached_data,
               cache_results = cache_results,
               cache_dir = cache_dir)

  if(use_cached_data == T){
    cache_paths <- sapply(c("imdb_tv_episodes",
                            "imdb_all_other_media"),
                          fst_path,
                          cache_dir)

    if(all(file.exists(cache_paths))){
      tv_episodes <- get_cached_data(cache_paths[1])

      all_other_media <- get_cached_data(cache_paths[2])

      return(list(tv_episodes = tv_episodes,
                  all_other_media = all_other_media))
    } else {
      rlang::inject(combine_imdb_data(!!!args))
    }
  } else {
    rlang::inject(combine_imdb_data(!!!args))
  }
}

check_for_imdb_suggested_packages <- function(){
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop(paste0(
      "This function needs Package \"cli\" ",
      "to display function updates."
    ),
    call. = FALSE
    )
  }
  if (!requireNamespace("fst", quietly = TRUE)) {
    stop(paste0(
      "This function needs Package \"fst\" ",
      "to cache the IMDB tables."
    ),
    call. = FALSE
    )
  }
  if (!requireNamespace("withr", quietly = TRUE)) {
    stop(paste0(
      "This function needs Package \"withr\" ",
      "for download time limits."
    ),
    call. = FALSE
    )
  }
  if (!requireNamespace("utils", quietly = TRUE)) {
    stop(paste0(
      "This function needs Package \"utils\" ",
      "to download .gz files."
    ),
    call. = FALSE
    )
  }
  if (!requireNamespace("R.utils", quietly = TRUE)) {
    stop(paste0(
      "This function needs Package \"R.utils\" ",
      "to unzip the .gz files."
    ),
    call. = FALSE
    )
  }
  if (!requireNamespace("data.table", quietly = TRUE)) {
    stop(paste0(
      "This function needs Package \"data.table\" ",
      "to read the .tsv files."
    ),
    call. = FALSE
    )
  }
}

combine_imdb_data <- function(cache_results,
                              cache_dir,
                              ...){

  args <- list(cache_results = cache_results,
               cache_dir = cache_dir,
               ...)

  imdb_tables <- rlang::inject(load_relevant_imdb_tables(!!!args))
  # imdb_tables contains .$all_media .$ratings and .$episodes

  cli::cli_alert_info("Combining data from IMDB tables...")

  imdb_data <- format_episode_movie_data(imdb_tables)
  # imdb_data contains .$tv_episodes and .$all_other_media

  cli::cli_li("TV Episodes: {dim(imdb_data$tv_episodes)[1] %>%
              prettyNum(big.mark = ',')} rows x
              {dim(imdb_data$tv_episodes)[2]} columns")
  cli::cli_li("Other Media: {dim(imdb_data$all_other_media)[1] %>%
              prettyNum(big.mark = ',')} rows x
              {dim(imdb_data$all_other_media)[2]} columns")

  if(cache_results){
    cache_imdb_table(imdb_data$tv_episodes,
                     cache_path = fst_path("imdb_tv_episodes",
                                           cache_dir))
    cache_imdb_table(imdb_data$all_other_media,
                     cache_path = fst_path("imdb_all_other_media",
                                           cache_dir))
  }

  return(imdb_data)
}

{
  load_relevant_imdb_tables <- function(...){
    all_media <- load_imdb_table("title_basics",
                                 ...)
    ratings   <- load_imdb_table("title_ratings",
                                 ...)
    episodes  <- load_imdb_table("title_episode",
                                 ...)

    return(list(all_media = all_media,
                ratings = ratings,
                episodes = episodes))
  }

  format_episode_movie_data <- function(imdb_tables){

    rated_media <- filter_to_relevant_media(imdb_tables)

    all_other_media <- rated_media %>%
      dplyr::filter(titleType != "tvEpisode")


    tv_episodes <- rated_media %>%
      get_episode_and_series_data(
        imdb_tables$episodes)


    return(list(tv_episodes = tv_episodes,
                all_other_media = all_other_media))
  }

  {
    filter_to_relevant_media <- function(imdb_tables){

      imdb_tables$all_media %>%
        # Only show media with Ratings
        dplyr::right_join(imdb_tables$ratings,
                          by = 'tconst') %>%
        # Format & filter Year > 1930
        dplyr::mutate(dplyr::across(
          dplyr::contains("Year"), as.integer)) %>%
        suppressWarnings() %>%
        dplyr::filter(startYear > 1930 | is.na(startYear)) %>%
        # Organize columns
        dplyr::select(titleType,
                      title = primaryTitle,
                      averageRating,
                      numVotes,
                      genres,
                      runtimeMinutes,
                      startYear,
                      endYear,
                      tconst) %>%
        dplyr::arrange(dplyr::desc(numVotes))
    }

    get_episode_and_series_data <- function(media_data,
                                            episode_numbers){
      media_data %>%
        dplyr::inner_join(episode_numbers, by = "tconst") %>%
        combine_series_episode_data(media_data) %>%
        format_tv_episode_output()
    }

    combine_series_episode_data <- function(episode_data,
                                            series_data){
      episode_data %>%
        dplyr::select(-endYear) %>%
        dplyr::left_join(series_data %>%
                           dplyr::select(tconst,
                                         series_name = title,
                                         endYear),
                         by = join_by(parentTconst == tconst)) %>%
        dplyr::mutate(dplyr::across(
          dplyr::contains("Number"), as.integer)) %>%
        suppressWarnings()
    }

    format_tv_episode_output <- function(episode_data){
      episode_data %>%
        dplyr::select(series_name,
                      seasonNumber,
                      episodeNumber,
                      episode_name = title,
                      episode_rating = averageRating,
                      dplyr::everything(),
                      episode_year = startYear,
                      series_end_year = endYear,
                      -dplyr::contains("tconst"),
                      tconst_episode = tconst,
                      tconst_series = parentTconst,
                      -titleType)
    }
  }


}

load_imdb_table <- function(file_name = c("title_basics",
                                          "title_episode",
                                          "title_ratings",
                                          "title_akas",
                                          "name_basics",
                                          "title_crew",
                                          "title_principals"),
                            use_cached_data = T,
                            cache_results = T,
                            cache_dir = "cache_imdb/"){

  file_name <- match.arg(file_name) # error if not valid file_name

  ensure_directory_exists(cache_dir)

  args <- list(file_name = file_name,
               cache_dir = cache_dir,
               cache_results = cache_results)

  if(use_cached_data){
    rlang::inject(attempt_load_cache_data(!!!args))
  } else {
    rlang::inject(download_imdb_table(!!!args))
  }
}

{
  ensure_directory_exists <- function(cache_dir){
    if(!dir.exists(cache_dir)){
      cli::cli_text("creating ./{cache_dir} directory")
      dir.create(cache_dir)
    }
  }

  attempt_load_cache_data <- function(file_name,
                                      cache_dir,
                                      ...){

    cache_path <- fst_path(file_name, cache_dir)

    if(file.exists(cache_path)){
      get_cached_data(cache_path)
    } else {
      download_imdb_table(file_name,
                          cache_dir,
                          ...)
    }
  }


  {
    fst_path <- function(file_name,
                         cache_dir){
      path <- paste0(cache_dir,
                     file_name,
                     ".fst")
    }

    get_cached_data <- function(cache_path){

      display_cache_info_message(cache_path)

      start_time <- Sys.time()
      data <- fst::read_fst(cache_path)

      dl_time <- difftime(Sys.time(), start_time) %>% round(2)
      cli::cli_alert_success("Loaded in: {.emph
                             {difftime(Sys.time(), start_time) %>%
                             round(2)} {units(dl_time)}}")
      return(data)
    }

    {
      display_cache_info_message <- function(cache_path){
        fsize <- file.size(cache_path)

        cli::cli_alert_info(
          "Loading {.envvar {cache_path}}",
          wrap = T
        )
        cli::cli_li("Last updated:
                    {.emph {cache_date({cache_path})}}")
        cli::cli_li("Cached Size:
                    {.emph {round(fsize/1024/1024,1)} MB}.")
      }

      cache_date <- function(cache_path){
        file.mtime(cache_path) %>% as.Date()
      }
    }
  }

  download_imdb_table <- function(file_name,
                                  cache_dir,
                                  cache_results,
                                  destfile = tempfile(
                                    fileext = ".tsv.gz")){
    imdb_url <- generate_imdb_url(file_name)

    download_raw_gz_file(imdb_url, destfile)
    unzip_imdb_gz_file(file_path = destfile)

    data <- read_tsv_file(file_path = gsub(".gz", "", destfile))

    if(cache_results){
      cache_path <- fst_path(file_name,
                             cache_dir)
      cache_imdb_table(data, cache_path)
    }

    return(data)
  }

  {
    download_raw_gz_file <- function(url,
                                     destfile){
      withr::local_options(list(timeout = 4*60)) # increase timeout to 4 mins

      # DOWNLOAD FILE
      start_time <- Sys.time()
      utils::download.file(url,
                           destfile)

      dl_time <- difftime(Sys.time(), start_time) %>% round(2)
      cli::cli_alert_success("Downloaded in: {.emph {dl_time}
                             {units(dl_time)}}")

    }

    {
      generate_imdb_url <- function(file_name){
        paste0("https://datasets.imdbws.com/",
               gsub("_", ".", file_name),
               ".tsv.gz")
      }
    }

    unzip_imdb_gz_file <- function(file_path){
      cli::cli_text("Unzipping .gz file...")
      R.utils::gunzip(file_path, remove = F)
    }

    read_tsv_file <- function(file_path){
      cli::cli_text("Reading .tsv file...")
      data <- data.table::fread(file_path,
                                quote = "")

      object_size <- utils::object.size(data)

      cli::cli_li("R Object Size:
                  {.emph {round(object_size/1024/1024,1)} MB}. -
                  {dim(data)[1] %>% prettyNum(big.mark = ',')} rows x
                  {dim(data)[2]} columns")

      return(data)
    }

    cache_imdb_table <- function(data,
                                 cache_path){
      cli::cli_text("Storing ./{cache_path}")
      fst::write_fst(data, path = cache_path)

      fsize <- file.size(cache_path)

      cli::cli_alert_success("Cached Size: {.emph
                             {round(fsize/1024/1024,1)} MB}.")
    }

  }

}

