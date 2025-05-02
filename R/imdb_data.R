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

  check_for_imdb_suggested_packages()

  file_name <- match.arg(file_name) # error if not valid file_name

  ensure_directory_exists(cache_dir)

  if(use_cached_data){
    attempt_load_cache_data(file_name,
                            cache_dir,
                            cache_results)
  } else {
    download_imdb_table(file_name,
                        cache_dir,
                        cache_results)
  }
}

{
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

  ensure_directory_exists <- function(cache_dir){
    if(!dir.exists(cache_dir)){
      cli::cli_text("creating ./{cache_dir} directory")
      dir.create(cache_dir)
    }
  }

  attempt_load_cache_data <- function(file_name,
                                      cache_dir,
                                      cache_results){
    cache_path <- fst_path(file_name, folder = cache_dir)

    if(file.exists(cache_path)){

      get_cached_data(cache_path)

    } else {
      download_imdb_table(file_name,
                          cache_dir,
                          cache_results)
    }
  }


  {
    fst_path <- function(file_name,
                         folder){
      path <- paste0(folder,
                     file_name,
                     ".fst")
    }

    get_cached_data <- function(cache_path){

      display_cache_info_message(cache_path)

      start_time <- Sys.time()
      data <- fst::read_fst(cache_path)

      dl_time <- difftime(Sys.time(), start_time) %>% round(2)
      cli::cli_li("Loaded in:
                  {.emph {difftime(Sys.time(), start_time) %>%
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
                                  destfile = tempfile(fileext = ".tsv.gz")){
    imdb_url <- generate_imdb_url(file_name)

    download_raw_gz_file(imdb_url, destfile)
    unzip_imdb_gz_file(file_path = destfile)

    data <- read_tsv_file(file_path = gsub(".gz", "", destfile))

    if(cache_results){
      cache_path <- fst_path(file_name,
                             folder = cache_dir)
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
      cli::cli_li("Downloaded in:
                {.emph {dl_time} {units(dl_time)}}")

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
                {.emph {round(object_size/1024/1024,1)}
                MB}.")

      return(data)
    }

    cache_imdb_table <- function(data,
                                 cache_path){
      cli::cli_text("Storing ./{cache_path}")
      fst::write_fst(data, path = cache_path)

      fsize <- file.size(cache_path)

      cli::cli_li("Cached Size: {.emph {round(fsize/1024/1024,1)} MB}.")
    }

  }

}

