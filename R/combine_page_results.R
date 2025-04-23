combine_page_results <- function(.f,
                                 args = list()) {
  first_page_response <- do.call(.f, args = args)

  total_pages <- ifelse("num_pages" %in% names(args),
    min(
      args$num_pages,
      first_page_response$total_pages
    ),
    first_page_response$total_pages
  )

  # Extract First Page Results
  data <- first_page_response$results

  # Results from other Pages (if applicable)
  if (total_pages > 1) {
    more_data <- loop_through_pages(.f,
      page_range = 2:total_pages,
      args
    )

    data <- rbind(data, more_data)
  }

  return(data)
}


loop_through_pages <- function(.f,
                               page_range,
                               args = list()) {
  purrr::map(
    page_range,
    \(x) {
      args$page <- x
      do.call(.f, args) %>%
        purrr::pluck("results")
    }
  ) %>%
    purrr::list_rbind()
}
