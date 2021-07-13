##' Tally of how often each title appeared
##'
##' 
##'
##' @title
##' @param subset
count_appearances <- function(subset) {
  
  total_days <- subset %>% 
    summarize(days=n_distinct(date)) %>% 
    pull()
  
  hist <- subset %>% 
    group_by(title) %>% 
    summarize(days=n_distinct(date)) %>% 
    mutate(days_pct=days / total_days) %>% 
    ggplot(aes(days_pct)) + 
    geom_histogram()

  return(hist)
}
