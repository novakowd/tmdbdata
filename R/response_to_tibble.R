response_to_tibble <- function(response_list){
  tibble::tibble(response = list(response_list)) %>%
    tidyr::unnest_wider(response)
}

column_list_to_table <- function(list){
  tibble::tibble(data = list) %>%
    tidyr::unnest_longer(data) %>%
    tidyr::unnest_wider(data)
}
