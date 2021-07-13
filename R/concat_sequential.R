#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

concat_sequential <- function(dfs) {
  dates <- gen_dates()
  concat <- vector("list", length(dfs))
  i <- 1
  for (df in dfs) {
    result <- dataframe_step(df, dates)
    concat[[i]] <- result$df
    dates <- result$dates
    i <- i + 1
  }
  df_all <- bind_rows(concat)
  
  return(df_all)
}

gen_dates <- function() {
  dates <- seq(date("2021-01-01"), Sys.Date()-1, by="days")
  datecheck <- as_tibble(dates) %>% 
    mutate(l1="movie", l2="tv") %>% 
    rename(c("date"=value)) %>% 
    pivot_longer(c(l1, l2), names_to="d", values_to="list") %>% 
    select(-d)
  
  return(datecheck)
}

dataframe_step <- function(df, dates) {
  df_sub <- df %>% 
    filter(date %in% dates$date)
  good <- df_sub %>% 
    filter(list!="overall") %>% 
    group_by(date, list) %>% 
    summarize(ten_items=n_distinct(title)==10) %>% 
    filter(ten_items) %>% 
    select(-ten_items) %>% 
    ungroup()
  df_good <- left_join(
    good,
    df_sub,
    by=c("date", "list")
  )
  remaining_dates <- anti_join(
    dates,
    good,
    by=c("date", "list")
  )
  output <- list(df=df_good, dates=remaining_dates)
  
  return(output)
}