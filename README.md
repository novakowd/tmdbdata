
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tmdbdata

<!-- badges: start -->
<!-- badges: end -->

The goal of `tmdbdata` is to serve as an API wrapper and access data
from [The Movie Database’s (TMDB) Application Programming Interface
(API)](https://developer.themoviedb.org/docs/getting-started)

## Installation

You can install the development version of tmdbdata from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("novakowd/tmdbdata")
```

## Authentication

This package must be supplied with an **API Read Access Token** for the
functions to interact with the API.  

Otherwise the API server will throw an error message:

``` r
search_movies(query = "Avengers",
              auth_token = invalid_auth_token)
#> Error in `httr2::req_perform()`:
#> ! HTTP 401 Unauthorized.
#> • Invalid API key: You must be granted a valid key.
```

To obtain an Access Token, follow the steps in the [***API’s
documentation***](https://developer.themoviedb.org/docs/authentication-application).  
Once you have `YOUR_AUTH_TOKEN`, store it in a [environment
variable](https://httr2.r-lib.org/articles/wrapping-apis.html#user-supplied-key)

- storing in the `.Renviron` file means the variable will be available
  in future R sessions

``` r
usethis::edit_r_environ() 
# type `TMDB_AUTH_TOKEN=YOUR_AUTH_TOKEN` in the `.Renviron` that opened,
# then save the file
```

> `set_auth_token()` will also set the `TMDB_AUTH_TOKEN` environment
> variable, but it is only specific to the session you’re working in

------------------------------------------------------------------------

# Examples

##### Search For Movies

``` r
avenger_movies <- search_movies(query = "Avengers", 
                                num_pages = 1) 

avenger_movies %>% dplyr::glimpse()
#> Rows: 20
#> Columns: 14
#> $ adult             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ backdrop_path     <chr> "/gHLs7Fy3DzLmLsD4lmfqL55KGcl.jpg", "/mDfJG3LC3Dqb67…
#> $ genre_ids         <list> [878, 28, 12], [12, 28, 878], [12, 878, 28], [28, 1…
#> $ id                <int> 24428, 299536, 299534, 99861, 1003596, 1003598, 1359…
#> $ original_language <chr> "en", "en", "en", "en", "en", "en", "en", "en", "ja"…
#> $ original_title    <chr> "The Avengers", "Avengers: Infinity War", "Avengers:…
#> $ overview          <chr> "When an unexpected enemy emerges and threatens glob…
#> $ popularity        <dbl> 36.6243, 34.6673, 24.3061, 19.8977, 18.3720, 8.4169,…
#> $ poster_path       <chr> "/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg", "/7WsyChQLEftFiDO…
#> $ release_date      <chr> "2012-04-25", "2018-04-25", "2019-04-24", "2015-04-2…
#> $ title             <chr> "The Avengers", "Avengers: Infinity War", "Avengers:…
#> $ video             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ vote_average      <dbl> 7.744, 8.200, 8.238, 7.271, 0.000, 0.000, 6.800, 4.3…
#> $ vote_count        <int> 31725, 30490, 26301, 23406, 0, 0, 95, 724, 275, 126,…
```

##### Get Movie Details

``` r
avenger_movie_details <- movie_details(
  movie_id = avenger_movies$id[1],
  append_to_response = "keywords"
)

avenger_movie_details %>% dplyr::glimpse()
#> Rows: 1
#> Columns: 27
#> $ release_date          <chr> "2012-04-25"
#> $ title                 <chr> "The Avengers"
#> $ vote_average          <dbl> 7.744
#> $ vote_count            <int> 31724
#> $ popularity            <dbl> 36.0784
#> $ runtime               <int> 143
#> $ overview              <chr> "When an unexpected enemy emerges and threatens …
#> $ id                    <int> 24428
#> $ imdb_id               <chr> "tt0848228"
#> $ adult                 <lgl> FALSE
#> $ backdrop_path         <chr> "/gHLs7Fy3DzLmLsD4lmfqL55KGcl.jpg"
#> $ belongs_to_collection <list> [86311, "The Avengers Collection", "/yFSIUVTCvgY…
#> $ budget                <int> 220000000
#> $ genres                <list> [[878, "Science Fiction"], [28, "Action"], [12, …
#> $ homepage              <chr> "https://www.marvel.com/movies/the-avengers"
#> $ origin_country        <list> ["US"]
#> $ original_language     <chr> "en"
#> $ original_title        <chr> "The Avengers"
#> $ poster_path           <chr> "/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg"
#> $ production_companies  <list> [[420, "/hUzeosd33nzE5MCNsZxCGEKTXaQ.png", "Marv…
#> $ production_countries  <list> [["US", "United States of America"]]
#> $ revenue               <int> 1518815515
#> $ spoken_languages      <list> [["English", "en", "English"], ["Hindi", "hi", "…
#> $ status                <chr> "Released"
#> $ tagline               <chr> "Some assembly required."
#> $ video                 <lgl> FALSE
#> $ keywords              <list> [[[242, "new york city"], [9715, "superhero"], […
```
