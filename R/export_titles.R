##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param data_all
export_titles <- function(data_all) {
  titles <- data_all %>%
    group_by(list) %>%
    select(title) %>% 
    distinct() %>% 
    arrange(list, title)
  
  return(titles)
}
