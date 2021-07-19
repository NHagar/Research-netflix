##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param data_all
resolve_titles <- function(data_all, resolutions) {
  resolved <- data_all %>% 
    left_join(resolutions, by=c("title"="X2")) %>% 
    mutate(title=ifelse(is.na(X1), title, X1)) %>% 
    select(-X1)
  
  return(resolved)
}
