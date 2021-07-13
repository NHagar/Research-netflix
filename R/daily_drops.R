#' Calculates and plots daily list dropout
#'
#' 
#'
#' @title
##' @param subset
daily_drops <- function(subset) {

  plt <- subset %>% 
    arrange(date) %>% 
    select(title, date, rank) %>% 
    pivot_wider(names_from=date, values_from=rank) %>% 
    pivot_longer(-title, names_to="date", values_to="rank") %>% 
    group_by(title) %>% 
    mutate(drop=is.na(rank) & !is.na(lag(rank)),
           date=as_date(date)) %>% 
    group_by(date) %>% 
    summarize(drops=sum(drop)) %>% 
    ggplot(aes(date, drops)) + 
    geom_line()

  return(plt)
}
