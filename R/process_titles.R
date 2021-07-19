##' .. content for \description{} (no empty lines) ..
##'
##' .. content for \details{} ..
##'
##' @title
##' @param data_all
process_titles <- function(data_all) {
  data_titles <- data_all %>% 
    mutate(title=tolower(title),
         # Remove leading "the"
         title=gsub("^the", "", title),
         # Remove non-alphanumeric characters
         title=gsub("[^[:alnum:]]", " ", title),
         # Remove extra whitespace
         title=str_squish(title))
  
  return(data_titles)
}
