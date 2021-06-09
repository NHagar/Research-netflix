##' Get distribution of sequential list tenures
##'
##' 
##'
##' @title
##' @param subset
count_tenure <- function(subset) {

  total_days <- subset %>% 
    summarize(days=n_distinct(Date)) %>% 
    pull()
  
  hist <- subset %>% 
    group_by(Title) %>% 
    arrange(Date) %>% 
    mutate(last_day=lag(Date),
           delta=as.integer(Date-last_day),
           delta=replace_na(delta, 1),
           sequence=cumsum(delta!=1)) %>% 
    group_by(Title, sequence) %>% 
    summarize(length=n()) %>% 
    mutate(length_pct=length / total_days) %>% 
    ggplot(aes(length_pct)) + 
    geom_histogram()

}
