##' Loads and cleans netflix ranking data
##'
##' 
##'
##' @title
##' @param fpath
load_and_clean_data <- function(fpath) {

  df <- read_csv(fpath) %>% 
    select(-`Total Seasons on Netflix`,-`New Season`,-`Run Time`) %>% 
    filter(!is.na(Title)) %>% 
    mutate(Date=as_date(Date, format="%m/%d"))
  
  # Mark each collection period
  df <- df %>% 
    group_by(Date) %>% 
    arrange(Time) %>% 
    mutate(delta=as.integer(Time-lag(Time)),
           delta=ifelse(is.na(delta), 0, delta)) %>% 
    mutate(collection=cumsum(delta>500)) %>% 
    ungroup() %>% 
    select(-delta)
  
  # Clean genre pages
  df <- df %>% 
    mutate(genre_trunk=sapply(str_split(Page, "/"), tail, 1),
           list=ifelse(genre_trunk=="browse", "overall", ifelse(str_length(genre_trunk)==2, "tv", "movie"))) %>% 
    select(-genre_trunk)
  
  df <- df %>% 
    rename(c("date"=Date, "rank"=Rank, "title"=Title)) %>% 
    filter(collection==0) %>% 
    select(-Time, -Page, -collection)
  
  return(df)

}
