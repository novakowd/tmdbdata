README for `tmdbdata` R Package
================

- [Installation](#installation)
  - [Authentication](#authentication)
    - [Option 1: `.Renviron`
      (RECOMMENDED)](#option-1-renviron-recommended)
    - [Option 2: `set_auth_token()` (Temporary
      Solution)](#option-2-set_auth_token-temporary-solution)
- [Examples](#examples)
- [TMDB data functions with
  `httr2::functions()`](#tmdb-data-functions-with-httr2functions)
  - [Create Basic Request](#create-basic-request)
  - [Append Request Details](#append-request-details)
  - [Perform Request](#perform-request)
    - [Response Structure](#response-structure)
  - [Response Body](#response-body)
    - [Missing Data](#missing-data)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# Installation

<!-- badges: start -->
<!-- badges: end -->

The goal of `tmdbdata` is to serve as an API wrapper and access data
from [The Movie Database’s (TMDB) Application Programming Interface
(API)](https://developer.themoviedb.org/docs/getting-started)

You can install the development version of tmdbdata from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
# devtools::install_github("novakowd/tmdbdata")
# library(tmdbdata)

devtools::load_all() # Development version of library(tmdbdata)
```

``` r
# Other packages used in this file
library(tidyverse)
library(httr2)
```

## Authentication

This package must be supplied with an **API Read Access Token** for the
functions to interact with the API.  

Otherwise the API server will throw an error message:

``` r
search_movies(query = "Avengers",
              auth_token = "invalid") # Example Only, never hardcode secrets (see below)
#> Error in `httr2::req_perform()`:
#> ! HTTP 401 Unauthorized.
#> • Invalid API key: You must be granted a valid key.
```

To obtain an Access Token, follow the steps in the [***API’s
documentation***](https://developer.themoviedb.org/docs/authentication-application).  
Once you have the access token, **DO NOT** hardcode it into a script

``` r
# ❗ NEVER DO THIS
auth_token <- "YOUR_AUTH_TOKEN"
```

❗ **DANGER**: Hardcoding secrets/passwords can pose [significant
security
risks](https://docs.github.com/en/get-started/learning-to-code/storing-your-secrets-safely)

Instead, it is better to store the Access Token as a
*`environment variable`*, which is retrieved automatically via the
[function
defaults](https://httr2.r-lib.org/articles/wrapping-apis.html#user-supplied-key)
**`auth_token = get_auth_token()`**

Here are **2** options that can help set the `TMBD_AUTH_TOKEN`
environment variable:

### Option 1: `.Renviron` (RECOMMENDED)

This is the preferred method because the token will be available in
future R sessions.

``` r
usethis::edit_r_environ() 
# type `TMDB_AUTH_TOKEN=YOUR_AUTH_TOKEN` in the `.Renviron` that opened,
# then save the file
```

### Option 2: `set_auth_token()` (Temporary Solution)

This needs to be run every time R is opened/restarted, so **Option 1**
is preferred.

``` r
set_auth_token() 
# type `YOUR_AUTH_TOKEN` in dialogue, Need to re-run every session
```

------------------------------------------------------------------------

# Examples

##### Search For Movies

``` r
avenger_movies <- search_movies(query = "Avengers", 
                                num_pages = 1) 

avenger_movies %>% glimpse()
#> Rows: 20
#> Columns: 14
#> $ adult             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ backdrop_path     <chr> "/mDfJG3LC3Dqb67AZ52x3Z0jU0uB.jpg", "/7RyHsO4yDXtBv1…
#> $ genre_ids         <list> <12, 28, 878>, <12, 878, 28>, <878, 28, 12>, <28, 1…
#> $ id                <int> 299536, 299534, 24428, 99861, 1003596, 1359227, 1003…
#> $ original_language <chr> "en", "en", "en", "en", "en", "en", "en", "en", "en"…
#> $ original_title    <chr> "Avengers: Infinity War", "Avengers: Endgame", "The …
#> $ overview          <chr> "As the Avengers and their allies have continued to …
#> $ popularity        <dbl> 87.9166, 47.7377, 38.6284, 23.2918, 14.2425, 8.4778,…
#> $ poster_path       <chr> "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", "/ulzhLuWrPK07P1…
#> $ release_date      <chr> "2018-04-25", "2019-04-24", "2012-04-25", "2015-04-2…
#> $ title             <chr> "Avengers: Infinity War", "Avengers: Endgame", "The …
#> $ video             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ vote_average      <dbl> 8.235, 8.237, 7.740, 7.271, 0.000, 6.782, 0.000, 4.3…
#> $ vote_count        <int> 30437, 26251, 31629, 23372, 0, 94, 0, 724, 125, 274,…
```

##### Get Movie Details

``` r
avenger_movie_details <- movie_details(
  movie_id = avenger_movies$id[1],
  append_to_response = "videos,images,keywords"
)

avenger_movie_details$belongs_to_collection
#> $id
#> [1] 86311
#> 
#> $name
#> [1] "The Avengers Collection"
#> 
#> $poster_path
#> [1] "/yFSIUVTCvgYrpalUktulvk3Gi5Y.jpg"
#> 
#> $backdrop_path
#> [1] "/zuW6fOiusv4X9nnW3paHGfXcSll.jpg"
avenger_movie_details$runtime %>% paste("minutes")
#> [1] "149 minutes"
avenger_movie_details$genres
#>    id            name
#> 1  12       Adventure
#> 2  28          Action
#> 3 878 Science Fiction
```

------------------------------------------------------------------------

# TMDB data functions with `httr2::functions()`

This Package uses [**`httr2`
package**](https://httr2.r-lib.org/articles/wrapping-apis.html)
functions to generate and perform requests then extract results from the
response body.

## Create Basic Request

A **`base_tmdb_request`** is constructed by looking at settings found in
the [**API
documentation**](https://developer.themoviedb.org/docs/rate-limiting).

For example:

- **`req_headers()`** info in the [**Response
  Format**](https://developer.themoviedb.org/docs/json-and-jsonp) and
  [**Authentication**](https://developer.themoviedb.org/docs/authentication-application)
  Documentation.  
- **`req_throttle()`** info in the [**Rate Limits
  Documentation**](https://developer.themoviedb.org/docs/rate-limiting)

``` r
base_tmdb_request
#> function(auth_token = get_auth_token()) {
#>   httr2::request("https://api.themoviedb.org/3/") %>%
#>     httr2::req_headers(
#>       accept = "application/json",
#>       Authorization = paste(
#>         "Bearer",
#>         auth_token
#>       ),
#>       .redact = "Authorization"
#>     ) %>%
#>     httr2::req_error(body = tmdb_error_body) %>%
#>     httr2::req_user_agent("tmdbdata (https://github.com/novakowd/tmdbdata)") %>%
#>     httr2::req_throttle(rate = 40, realm = "https://api.themoviedb.org/3/")
#> }
#> <environment: namespace:tmdbdata>
```

> | 📝 | default of `auth_token = get_auth_token()`, will **only** work with option 1 or 2 (environment variable) as mentioned [**above**](#authentication) |
> |----|:---|

The `Authorization` header info is also redacted in the following
objects.

------------------------------------------------------------------------

Running the above `base_tmdb_request()` function generates a basic
`<httr2_request>` object:

    #> <httr2_request>
    #> GET https://api.themoviedb.org/3/
    #> Headers:
    #> • accept       : "application/json"
    #> • Authorization: <REDACTED>
    #> Body: empty
    #> Options:
    #> • useragent: "tmdbdata (https://github.com/novakowd/tmdbdata)"
    #> Policies:
    #> • error_body    : <function>
    #> • throttle_realm: "https://api.themoviedb.org/3/"

> The functions `req_headers()`, `req_error()`, `req_user_agent()`, and
> `req_throttle()` do NOT change the URL
> `https://api.themoviedb.org/3/`, but they DO add other elements to the
> request such as `Headers`, `Options`, and `Policies`.

------------------------------------------------------------------------

## Append Request Details

The next step is to append a path to the base URL and add relevant
arguments to help with the request. Find appropriate arguments by
consulting the API Documentation.

The below example looks at the [**Search\>Movie
Documentation**](https://developer.themoviedb.org/reference/search-movie)
which states:

- there is a **required** parameter called **`query`** and,
- some other *optional* parameters, some of which have default values.

Let’s try putting together a request to **`search`** the **`movies`**
for **`Avengers`**:

``` r
base_tmdb_request() %>% 
  req_url_path_append("search","movie") %>% 
  req_url_query(query = "Avengers")
#> <httr2_request>
#> GET https://api.themoviedb.org/3/search/movie?query=Avengers
#> Headers:
#> • accept       : "application/json"
#> • Authorization: <REDACTED>
#> Body: empty
#> Options:
#> • useragent: "tmdbdata (https://github.com/novakowd/tmdbdata)"
#> Policies:
#> • error_body    : <function>
#> • throttle_realm: "https://api.themoviedb.org/3/"
```

> The functions `req_url_path_append()` and `req_url_query()` modified
> the url to
> **<https://api.themoviedb.org/3/search/movie?query=Avengers>**

------------------------------------------------------------------------

## Perform Request

Now that we have built a request, **`req_perform()`** allows us to get a
`response`.

- **`req_perform()`** submits the request to the server
  - assigning to a `variable` stores the response in-memory, as to not exceed the API's [Rate Limits](https://developer.themoviedb.org/docs/rate-limiting)

``` r
response <- base_tmdb_request() %>% 
  req_url_path_append("search", "movie") %>% 
  req_url_query(query = "Avengers") %>% 
  req_perform()

response
#> <httr2_response>
#> GET https://api.themoviedb.org/3/search/movie?query=Avengers
#> Status: 200 OK
#> Content-Type: application/json
#> Body: In memory (12038 bytes)
```

### Response Structure

Printing the `<httr2_response>` object above does not show much
information, though more information is available when inspecting
closer:

``` r
class(response)
#> [1] "httr2_response"
```

``` r
data.frame(class = unlist(lapply(response,class)),
           length = unlist(lapply(response,length)))
#>                     class length
#> method          character      1
#> url             character      1
#> status_code       integer      1
#> headers     httr2_headers     20
#> body                  raw  12038
#> request     httr2_request      8
#> cache         environment      0
```

``` r
names(response$headers)
#>  [1] "Content-Type"      "Transfer-Encoding" "Connection"       
#>  [4] "Date"              "Server"            "Cache-Control"    
#>  [7] "x-memc"            "x-memc-key"        "x-memc-age"       
#> [10] "x-memc-expires"    "ETag"              "Content-Encoding" 
#> [13] "Vary"              "X-Cache"           "Via"              
#> [16] "X-Amz-Cf-Pop"      "Alt-Svc"           "X-Amz-Cf-Id"      
#> [19] "Age"               "Vary"
```

The actual ‘Data’ that we’re looking for is in the `$body` element,
though it appears to be in a raw hexadecimal format:

``` r
cat(response$body[1:30], "...")
#> 7b 22 70 61 67 65 22 3a 31 2c 22 72 65 73 75 6c 74 73 22 3a 5b 7b 22 61 64 75 6c 74 22 3a ...
```

## Response Body

[**`httr2`**](https://httr2.r-lib.org/) provides many
[`resp_body_*()`](https://httr2.r-lib.org/reference/resp_body_raw.html)
functions to extract the `body` data, depending on the API response
format(s).  
The [**API
Documentation**](https://developer.themoviedb.org/docs/json-and-jsonp)
states the **only supported response format is `JSON`**, so we use the
**`resp_body_json()`** function and use the `simplifyVector = T` to make
the resulting lists easier to work with.

``` r
body <- response %>% 
  resp_body_json(simplifyVector = T)
```

Inspecting the body shows it is a list with 4 elements.

``` r
lapply(body, class)
#> $page
#> [1] "integer"
#> 
#> $results
#> [1] "data.frame"
#> 
#> $total_pages
#> [1] "integer"
#> 
#> $total_results
#> [1] "integer"
```

The `$page`, `$total_pages`, and `$total_results` elements are all
`integer` values:

``` r
body[c("page", "total_pages", "total_results")]
#> $page
#> [1] 1
#> 
#> $total_pages
#> [1] 7
#> 
#> $total_results
#> [1] 126
```

The `$results` element is a `data.frame`

``` r
body$results %>% 
  glimpse()
#> Rows: 20
#> Columns: 14
#> $ adult             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ backdrop_path     <chr> "/mDfJG3LC3Dqb67AZ52x3Z0jU0uB.jpg", "/Al127H6f1RXpES…
#> $ genre_ids         <list> <12, 28, 878>, <16, 35, 878>, <878, 28, 12>, <28, 1…
#> $ id                <int> 299536, 1359227, 24428, 40081, 257346, 1154598, 2995…
#> $ original_language <chr> "en", "en", "en", "zh", "ja", "en", "en", "en", "en"…
#> $ original_title    <chr> "Avengers: Infinity War", "LEGO Marvel Avengers: Mis…
#> $ overview          <chr> "As the Avengers and their allies have continued to …
#> $ popularity        <dbl> 87.9166, 8.4778, 38.6284, 1.7733, 2.7585, 4.1031, 47…
#> $ poster_path       <chr> "/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg", "/4KfgyzCgJeG0XJ…
#> $ release_date      <chr> "2018-04-25", "2024-10-17", "2012-04-25", "1978-12-2…
#> $ title             <chr> "Avengers: Infinity War", "LEGO Marvel Avengers: Mis…
#> $ video             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ vote_average      <dbl> 8.235, 6.782, 7.740, 6.837, 6.400, 6.556, 8.237, 7.2…
#> $ vote_count        <int> 30437, 94, 31629, 98, 274, 125, 26251, 23372, 724, 3…
```

### Missing Data

The `body$total_results` is 126, yet the `body$results` only contain 20
rows.  
This is because **body\$total_pages = 7** but each response only returns
**one** page.

To get the other pages, we need to specify an additional argument
**`page = n`** to the response, like so:

``` r
page2_response <- base_tmdb_request() %>% 
  req_url_path_append("search", "movie") %>% 
  req_url_query(query = "Avengers",
                page = 2) %>%                ### NEW ARGUMENT
  req_perform() %>% 
  resp_body_json(simplifyVector = T) 

page2_response %>% 
  pluck('results') %>% 
  glimpse()
#> Rows: 20
#> Columns: 14
#> $ adult             <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ backdrop_path     <chr> "/3aN6XMUfHmIsluhki7DRevM766D.jpg", "/eQiRPyEWhYnuqE…
#> $ genre_ids         <list> <28, 12>, <>, <35, 14, 28>, <35, 27>, <10751, 16, 2…
#> $ id                <int> 83876, 448368, 538153, 1353766, 940543, 385411, 4823…
#> $ original_language <chr> "zh", "en", "en", "xx", "en", "el", "ja", "zh", "en"…
#> $ original_title    <chr> "冷血十三鷹", "The Avengers: A Visual Journey", "Avengers…
#> $ overview          <chr> "Eagle Chief Yoh Xi-hung raises orphans to be his pe…
#> $ popularity        <dbl> 0.9892, 2.6584, 1.5184, 0.4081, 1.2433, 0.2987, 1.63…
#> $ poster_path       <chr> "/tpOVfLNNmWQFNJrfrAnLmdsx8pT.jpg", "/2kBT7KONKQTIhk…
#> $ release_date      <chr> "1978-09-13", "2012-09-25", "2018-07-20", "2024-09-2…
#> $ title             <chr> "The Avenging Eagle", "The Avengers: A Visual Journe…
#> $ video             <lgl> FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALS…
#> $ vote_average      <dbl> 7.40, 7.90, 5.30, 7.80, 6.80, 8.40, 7.10, 6.80, 5.10…
#> $ vote_count        <int> 34, 27, 28, 2, 14, 9, 14, 23, 64, 25, 33, 24, 6, 148…
```

This ‘second page’ table contains the *next* 20 rows.  
To get all rows we need to repeat this until page = 7
