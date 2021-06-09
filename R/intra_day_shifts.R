##' Checks for items that inhabit multiple ranks on the same day
##'
##' 
##'
##' @title
##' @param data
intra_day_shifts <- function(data) {

  ids <- data %>% 
    group_by(Date, cat, Title) %>% 
    summarize(ranks=n_distinct(Rank)) %>% 
    filter(ranks>1)
  
  return(ids)

}
