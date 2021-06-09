#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
##' @param fpath
clean_transitions <- function(fpath) {

  df <- read_csv(fpath) %>% 
    select(-`Season # Release`, -`Total Seasons`,
           -Runtime, -`Season #`, -`Movie Runtime`)
  
  arrivals <- df %>% 
    select(c(1:2)) %>% 
    arrival_departure()
  
  departures <- df %>% 
    select(c(3:4)) %>% 
    arrival_departure()

  
  all_events <- bind_rows(arrivals, departures) %>% 
    mutate(month=sapply(strsplit(date, "/"), "[", 1),
           month=as.integer(month),
           date_event=ifelse(month > month(today()), 
                             paste(date, "2020", sep="/"), 
                             paste(date, "2021", sep="/")),
           date_event=as_date(date_event, format="%m/%d/%Y")) %>% 
    select(-date)
  
  return(all_events)
    
}


