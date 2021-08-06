library(tidyverse)
source("./R/sim_functions.R")

set.seed(20210721)

# ----Parameters----
n_movies <- 500
movies <- seq(1, n_movies)
users <- 500000
days <- 21

alpha <- 0.1
beta <- 3

# ----Random----
results <- matrix(nrow=days, ncol=users)

for (i in seq(1, days)) {
  s <- sample(movies, users, replace=T)
  results[i,] <- s
}

df <- transform_results(results)
plots <- plot_results(df)

# ----Popularity, fixed----
results <- matrix(nrow=days, ncol=users)

for (i in seq(1, days)) {
  # Generate skewed draw probabilities
  p <- sort(rbeta(n_movies, alpha, beta), decreasing=T)
  
  if (i==1) {
    # Shuffle movie order to start
    movies_sorted <- sample(movies)
  }
  
  # Weighted user draw
  s <- sample(movies_sorted, users, replace=T, prob=p)
  # Stash in results matrix
  results[i,] <- s
  # Get new order based on choices
  movies_sorted <- as_tibble(choices) %>% 
    group_by(value) %>% 
    summarize(count=n()) %>% 
    arrange(desc(count)) %>% 
    pull(value)
  movies_sorted <- c(movies_sorted, movies[!movies %in% movies_sorted])
}

df <- transform_results(results)
plots <- plot_results(df)

# ----Popularity, variable----



# ----Results evaluation----
df <- read_csv("./data/sim_test.csv")

# Occupants
df %>% 
  arrange(iteration) %>% 
  group_by(iteration) %>% 
  mutate(rank=dense_rank(desc(selections))) %>% 
  filter(rank<=10) %>% 
  group_by(rank) %>% 
  summarize(movies=n_distinct(movie)) %>% 
  ggplot(aes(rank, movies)) + 
  geom_bar(stat="identity")
  
# Swaps
df %>% 
  group_by(iteration) %>% 
  mutate(rank=dense_rank(desc(selections))) %>% 
  filter(rank<=10) %>% 
  ungroup() %>% 
  arrange(iteration) %>% 
  group_by(rank) %>% 
  mutate(last=lag(movie)) %>% 
  ungroup() %>% 
  mutate(swap=rank==last) %>% 
  group_by(rank) %>% 
  summarize(swaps=sum(swap, na.rm=T)) %>% 
  ggplot(aes(rank, swaps)) + 
  geom_bar(stat='identity')

# Churn
df %>% 
  group_by(iteration) %>% 
  mutate(rank=dense_rank(desc(selections))) %>% 
  filter(rank<=10) %>% 
  group_by(movie) %>% 
  arrange(iteration) %>% 
  mutate(delta=iteration-lag(iteration),
         dropped=delta!=1 | is.na(delta)) %>% 
  group_by(iteration) %>% 
  summarize(turnover=sum(dropped)) %>% 
  ggplot(aes(iteration, turnover)) + 
  geom_line()
