#' Calculates and plots daily list dropout
#'
#' 
#'
#' @title
##' @param subset
daily_drops <- function(subset) {

  plt <- subset %>% 
    arrange(Date) %>% 
    select(Title, Date, Rank) %>% 
    pivot_wider(names_from=Date, values_from=Rank) %>% 
    pivot_longer(-Title, names_to="date", values_to="rank") %>% 
    group_by(Title) %>% 
    mutate(drop=is.na(rank) & !is.na(lag(rank)),
           date=as_date(date)) %>% 
    group_by(date) %>% 
    summarize(drops=sum(drop)) %>% 
    ggplot(aes(date, drops)) + 
    geom_line()

  return(plt)
}
