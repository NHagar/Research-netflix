##' Get distribution of sequential list tenures
##'
##' 
##'
##' @title
##' @param subset
count_tenure <- function(subset) {

  total_days <- subset %>% 
    summarize(days=n_distinct(date)) %>% 
    pull()
  
  hist <- subset %>% 
    group_by(title) %>% 
    arrange(date) %>% 
    mutate(last_day=lag(date),
           delta=as.integer(date-last_day),
           delta=replace_na(delta, 1),
           sequence=cumsum(delta!=1)) %>% 
    group_by(title, sequence) %>% 
    summarize(length=n()) %>% 
    mutate(length_pct=length / total_days) %>% 
    ggplot(aes(length_pct)) + 
    geom_histogram()

}
