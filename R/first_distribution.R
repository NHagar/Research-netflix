#' Generates distribution of items' first rank in list
#'
#' 
#'
#' @title
##' @param subset
first_distribution <- function(subset) {
  plt <- subset %>% 
    filter(Date==min(Date)) %>% 
    anti_join(subset, ., by="Title") %>% 
    group_by(Title) %>% 
    filter(Date==min(Date)) %>% 
    ggplot(aes(Rank)) + 
    geom_density()
  
  return(plt)
}
