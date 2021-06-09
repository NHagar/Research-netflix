##' Count frequency of rank swaps
##'
##' 
##'
##' @title
##' @param subset
count_swaps <- function(subset) {

  swaps <- subset %>% 
    group_by(Rank) %>% 
    arrange(Date) %>% 
    mutate(next_title=lead(Title),
           was_swap=Title!=next_title) %>% 
    summarize(swaps=sum(was_swap, na.rm=T)) %>% 
    ggplot(aes(Rank, swaps)) + 
    geom_bar(stat='identity') + 
    expand_limits(y=0)
  
  return(swaps)

}
