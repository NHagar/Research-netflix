##' Plots item rank trajectories
##'
##'
##'
##' @title
##' @param subset
rank_trajectories <- function(subset) {
  plt <- subset %>% 
    group_by(Title) %>% 
    arrange(Date) %>% 
    mutate(days=Date - min(Date)) %>% 
    ggplot(aes(days, Rank, color=Title)) + 
    geom_line() + 
    scale_y_reverse() + 
    theme(legend.position="none")
  
  return(plt)
}
