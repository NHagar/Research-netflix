#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
##' @param df
arrival_departure <- function(data) {
  
  if ("Arrival Date" %in% colnames(data)) {
    cleaned <- data %>% 
      rename("date"=`Arrival Date`) %>% 
      mutate(type="arrival")
  } else{
    cleaned <- data %>% 
      rename("date"=`Leave Date`, "Title"=Title_1) %>% 
      mutate(type="departure")
  }
  
  return(cleaned)
  
}


