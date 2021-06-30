##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title

load_and_clean_external <- function() {
  movies <- read_csv("./data/batch_movies.csv")
  tv <- read_csv("./data/batch_tv.csv")
  both <- bind_rows(movies, tv)
  both <- both %>% 
    mutate(date=as_date(date, format="%m-%d-%Y")) %>% 
    rename("list"=type) %>% 
    select(-X1)
  
  return(both)
}
