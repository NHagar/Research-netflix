##' Plots item rank trajectories
##'
##'
##'
##' @title
##' @param subset
rank_trajectories <- function(subset) {
  plt <- subset %>% 
    group_by(title) %>% 
    arrange(date) %>% 
    mutate(days=date - min(date)) %>% 
    ggplot(aes(days, rank, color=title)) + 
    geom_line() + 
    scale_y_reverse() + 
    theme(legend.position="none")
  
  return(plt)
}
