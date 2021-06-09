##' Fit and format markov transition probabilities
##'
##' 
##'
##' @title
##' @param subset
fitmk <- function(subset) {
  transitions <- markovchainFit(subset %>% select(-Title))
  df_transitions <- as_tibble(transitions$estimate@transitionMatrix)
  
  df_transitions$rank <- df_transitions %>% 
    colnames() %>% 
    as.integer()
  
  df_transitions <- df_transitions %>% 
    pivot_longer(-rank, names_to="dest", values_to="proba") %>% 
    mutate(dest=as.integer(dest))
  
  return(df_transitions)

}
