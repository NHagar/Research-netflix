#' Calculates and plots daily list dropout
#'
#' 
#'
#' @title
##' @param subset
daily_drops <- function(subset) {

  plt <- subset %>% 
    group_by(title) %>% 
    arrange(date) %>% 
    mutate(delta=as.integer(date-lag(date))) %>% 
    filter(!is.na(delta)) %>% 
    mutate(drop=delta!=1) %>% 
    group_by(date) %>% 
    summarize(drops=sum(drop)) %>% 
    ggplot(aes(date, drops)) + 
    geom_line()

  return(plt)
}
