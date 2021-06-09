##' Distribution of unique titles per rank
##'
##' 
##'
##' @title
##' @param subset
count_occupants <- function(subset) {

  occupants <- subset %>% 
    group_by(Rank) %>% 
    summarize(occupants=n_distinct(Title)) %>% 
    ggplot(aes(Rank, occupants)) + 
    geom_bar(stat='identity') + 
    expand_limits(y=0)

  return(occupants)
  
}
