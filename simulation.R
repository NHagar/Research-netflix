library(tidyverse)

n_movies <- 100
movies <- seq(1, n_movies)
users <- 100000
days <- 21

# ----Random----
results <- matrix(nrow=days, ncol=users)

for (i in seq(1, days)) {
  s <- sample(movies, users, replace=T)
  results[i,] <- s
}

df <- as_tibble(results)
df %>% 
  mutate(iter=row_number()) %>% 
  pivot_longer(-iter, names_to="index", values_to="movie") %>% 
  select(-index) %>% 
  group_by(iter, movie) %>% 
  summarize(picks=n()) %>% 
  mutate(rank=dense_rank(desc(picks))) %>% 
  arrange(iter, rank)

# ----Popularity, fixed----



# ----Popularity, variable----




results[1,]
