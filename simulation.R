library(tidyverse)
source("./R/sim_functions.R")

set.seed(20210721)

n_movies <- 500
movies <- seq(1, n_movies)
users <- 500000
days <- 21

# ----Random----
results <- matrix(nrow=days, ncol=users)

for (i in seq(1, days)) {
  s <- sample(movies, users, replace=T)
  results[i,] <- s
}

df <- transform_results(results)
plots <- plot_results(df)

# ----Popularity, fixed----



# ----Popularity, variable----
