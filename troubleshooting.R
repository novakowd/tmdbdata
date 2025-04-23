library(tidyverse)
library(httr2)
library(jsonlite)



dp_movies <- search_movies("deadpool")
dp_details <- movie_details_summary(dp_movies$id)


thor_movies <- search_movies("Thor")
ragnarok <- movie_details(284053, "videos,images,keywords")
thor_details <- movie_details_summary(thor_movies$id[1:5])

mrv_collections <- search_collection("Marvel")


marvel_company_id <- ragnarok$production_companies$id #420

marvel_movies <- discover_movies(with_companies = marvel_company_id,
                                 num_pages = 100)

marvel_details <- movie_details_summary(marvel_movies$id)

group_ratings <- marvel_details %>%
  group_by(collection) %>%
  summarize(max_rating = max(vote_average),
            avg_rating = mean(vote_average),
            num_movies = n())


response <- movie_details(758025)
