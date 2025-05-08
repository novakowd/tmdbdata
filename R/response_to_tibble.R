response_to_tibble <- function(response_list){
  tibble(response = list(response_list)) %>%
    unnest_wider(response)
}

column_list_to_table <- function(list){
  tibble(data = list) %>%
    unnest_longer(data) %>%
    unnest_wider(data)
}
