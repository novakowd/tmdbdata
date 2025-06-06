library(tidyverse)
library(httr2)


load_all()

avengers_response <- base_tmdb_request() %>%
  req_url_path_append("search", "movie") %>%
  req_url_query(query = "Avengers") %>%
  req_perform()

avengers_json <- avengers_response %>%
  resp_body_json()

avengers_json %>%
  tibble("reponse" = .) %>%
  slice(2) %>%
  unnest_longer(reponse) %>%
  unnest_wider(reponse)



infwar_response <- base_tmdb_request() %>%
  req_url_path_append("movie",
                      "299536") %>% #avenger:infinity war movie id
  req_perform()

infwar_json <- infwar_response %>%
  resp_body_json()

infwars_df <- infwar_json %>%
  list() %>%
  tibble(response = .) %>%
  unnest_wider(response)


test <- movie_details(299536)
