##' Distribution of unique titles per rank
##'
##' 
##'
##' @title
##' @param subset
count_occupants <- function(subset) {

  occupants <- subset %>% 
    group_by(rank) %>% 
    summarize(occupants=n_distinct(title)) %>% 
    ggplot(aes(rank, occupants)) + 
    geom_bar(stat='identity') + 
    expand_limits(y=0)

  return(occupants)
  
}
