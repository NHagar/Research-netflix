##' Transform rankings into sequence dataframe
##'
##' 
##'
##' @title
##' @param subset
rank_sequences <- function(subset) {

  rank_seq <- subset %>% 
    group_by(title) %>% 
    arrange(date) %>% 
    mutate(row=row_number()) %>% 
    select(title, rank, row) %>% 
    pivot_wider(names_from=row, values_from=rank) %>% 
    replace(is.na(.), 0) %>% 
    ungroup()
  
  return(rank_seq)

}
