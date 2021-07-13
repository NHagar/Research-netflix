##' Count frequency of rank swaps
##'
##' 
##'
##' @title
##' @param subset
count_swaps <- function(subset) {

  swaps <- subset %>% 
    group_by(rank) %>% 
    arrange(date) %>% 
    mutate(next_title=lead(title),
           was_swap=title!=next_title) %>% 
    summarize(swaps=sum(was_swap, na.rm=T)) %>% 
    ggplot(aes(rank, swaps)) + 
    geom_bar(stat='identity') + 
    expand_limits(y=0)
  
  return(swaps)

}
