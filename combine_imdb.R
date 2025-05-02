library(tidyverse)
load_all()

all_media <- load_imdb_table("title_basics",
                             use_cached_data = T)
ratings <- load_imdb_table("title_ratings",
                           use_cached_data = F)
episodes <- load_imdb_table("title_episode",
                            use_cached_data = T)

rated_media <- all_media %>%
  right_join(ratings,
             by = 'tconst') %>%
  mutate(across(contains("Year"), as.integer)) %>%
  suppressWarnings() %>%
  filter(startYear > 1930 | is.na(startYear)) %>%
  select(titleType,
         title = primaryTitle,
         averageRating,
         numVotes,
         genres,
         runtimeMinutes,
         startYear,
         endYear,
         tconst)


movies_tvseries <- rated_media %>%
  filter(titleType != "tvEpisode")


movies_tvseries %>%
  select(parentTconst = tconst,
         series_name = )


tv_episodes <- rated_media %>%
  filter(titleType == "tvEpisode")
  left_join(movies_tvseries %>%
              select(tconst,
                     series = title,
                     series_),
            by = join_by(parentTconst == tconst)) %>%
  mutate(across(contains("Number"), as.integer)) %>%
  suppressWarnings()
