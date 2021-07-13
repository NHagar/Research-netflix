#' Generates distribution of items' first rank in list
#'
#' 
#'
#' @title
##' @param subset
first_distribution <- function(subset) {
  plt <- subset %>% 
    filter(date==min(date)) %>% 
    anti_join(subset, ., by="title") %>% 
    group_by(title) %>% 
    filter(date==min(date)) %>% 
    ggplot(aes(rank)) + 
    geom_density()
  
  return(plt)
}
