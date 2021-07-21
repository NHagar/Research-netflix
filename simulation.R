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