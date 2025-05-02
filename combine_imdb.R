library(tidyverse)
load_all()

imdb_data <- load_imdb_data(use_cached_data = T)


movies <- imdb_data$all_other_media %>%
  filter(!grepl("Game", titleType),
         !grepl("Series", titleType))


# top 10 by year
movies_votes <- movies %>%
  group_by(startYear) %>%
  mutate(rank_in_year = rank(-numVotes)) %>%
  filter(rank_in_year <= 10) %>%
  arrange(desc(startYear),rank_in_year) %>%
  mutate(numVotes = numVotes %>%
           prettyNum(big.mark = ",")) %>%
  select(startYear,
         rank_in_year,
         title,
         numVotes,
         averageRating,
         everything())

movies_ranks <- movies %>%
  mutate(min_votes = case_when(startYear == 2025 ~
                                 20000,
                               T ~ 100000)) %>%
  filter(numVotes > min_votes) %>%
  group_by(startYear) %>%
  mutate(rank_in_year = rank(-averageRating,
                             ties.method = "first")) %>%
  filter(rank_in_year <= 10) %>%
  arrange(desc(startYear),rank_in_year) %>%
  mutate(numVotes = numVotes %>%
           prettyNum(big.mark = ",")) %>%
  select(startYear,
         rank_in_year,
         title,
         averageRating,
         numVotes,
         everything())

test <- movies %>%
  filter(startYear == 2025)
