##' Transform rankings into sequence dataframe
##'
##' 
##'
##' @title
##' @param subset
rank_sequences <- function(subset) {

  rank_seq <- subset %>% 
    group_by(Title) %>% 
    arrange(Date) %>% 
    mutate(row=row_number()) %>% 
    select(Title, Rank, row) %>% 
    pivot_wider(names_from=row, values_from=Rank) %>% 
    replace(is.na(.), 0) %>% 
    ungroup()
  
  return(rank_seq)

}
