transform_results <- function(results) {
  df <- as_tibble(results)
  df <- df %>% 
    mutate(iter=row_number()) %>% 
    pivot_longer(-iter, names_to="index", values_to="movie") %>% 
    select(-index) %>% 
    group_by(iter, movie) %>% 
    summarize(picks=n()) %>% 
    mutate(rank=dense_rank(desc(picks))) %>% 
    arrange(iter, rank)
  
  return(df)
}

plot_results <- function(results_df) {
  output = list()
  output$occupants <- df %>% 
    filter(rank<=10) %>% 
    group_by(rank) %>% 
    summarize(occupants=n_distinct(movie)) %>% 
    ggplot(aes(rank, occupants)) + 
    geom_bar(stat="identity")
  
  output$swaps <- df %>%
    filter(rank<=10) %>% 
    arrange(iter) %>% 
    group_by(rank) %>% 
    mutate(swap=movie!=lag(movie)) %>% 
    filter(!is.na(swap)) %>% 
    summarize(swaps=sum(swap)) %>% 
    ggplot(aes(rank, swaps)) + 
    geom_bar(stat="identity")
  
  output$churn <- df %>% 
    filter(rank<=10) %>% 
    group_by(movie) %>% 
    arrange(iter) %>% 
    mutate(delta=iter-lag(iter),
           dropped=delta!=1 | is.na(delta)) %>% 
    group_by(iter) %>% 
    summarize(turnover=sum(dropped)) %>% 
    ggplot(aes(iter, turnover)) + 
    geom_line()
  
  return(output)
}