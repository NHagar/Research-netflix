##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param json_files
load_and_clean_json <- function(json_files) {
  alldf <- bind_rows(dfs) %>% 
    mutate(date=date(date)) %>% 
    as_tibble() %>% 
    select(-collected)
  
  return(alldf)

}


json_to_df <- function(fname) {
  df <- fromJSON(fname) %>% as.data.frame %>% 
    mutate(date=date(as.POSIXct(collected / 1000, origin = "1970-01-01", tz="America/Chicago")),
           rank=as.integer(rank),
           url=gsub("\\?.*", "", url),
           list=case_when(
             grepl("homepage", fname, ignore.case = T) ~ "overall",
             grepl("movie", fname, ignore.case = T) ~ "movie",
             grepl("tv", fname, ignore.case = T) ~ "tv"
           )
    ) %>% 
    distinct(url, .keep_all=T) %>% 
    select(-url)
  
  return(df)
}