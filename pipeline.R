lapply(list.files("./R", full.names = TRUE), source)

json_files <- list.files("./data/Maddy Data", full.names = T)

plan <- drake_plan(
  # Data loading and formatting
  fpath = file_in("./data/Holly Netflix Data - Sheet1.csv"),
  data = load_and_clean_data(fpath),
  
  # Integrating JSON files
  dataframes_json = target(json_to_df(file_in(file)),
                           transform=map(file=!!json_files)
  ),
  data_json=target(
    bind_rows(dataframes_json),
    transform = combine(dataframes_json)
  ),
  data_json_cleaned=data_json %>% 
    mutate(date=date(date)) %>% 
    as_tibble() %>% 
    select(-collected),
  # JSON + CSV concatenation
  data_all = bind_rows(data, data_json_cleaned) %>% 
    distinct(),
  # External data check
  data_ext = load_and_clean_external(),
  # Patch any missing data
  
  # Break data into lists
  subset = target(
    data_all %>% filter(cat==type),
    transform=map(type=c("list", "tv", "movie"), .names=c("overall", "tv", "movie"))
  ),
  # EDA
  total_items = target(
    n_distinct(subset$Title),
    transform=map(subset)
  ),
  appearances = target(
    count_appearances(subset),
    transform=map(subset)
  ),
  tenure = target(
    count_tenure(subset),
    transform=map(subset)
  ),
  occupants = target(
    count_occupants(subset),
    transform=map(subset)
  ),
  swaps = target(
    count_swaps(subset),
    transform=map(subset)
  ),
  # Dynamics analysis
  first_ranks = target(
    first_distribution(subset),
    transform=map(subset)
  ),
  trajectories = target(
    rank_trajectories(subset),
    transform=map(subset)
  ),
  seq = target(
    rank_sequences(subset),
    transform=map(subset)
  ),
  mk_df = target(
    fitmk(seq),
    transform=map(seq)
  ),
  mk_transitions = target(
    mk_df %>%
      filter(rank>0 & dest>0) %>%
      ggplot(aes(rank, dest, fill=proba)) +
      geom_tile() +
      scale_x_reverse() +
      scale_y_reverse(),
    transform=map(mk_df, .names=c("mk_overall", "mk_tv", "mk_movie"))
  ),
  churn = target(
    daily_drops(subset),
    transform=map(subset)
  ),
  descriptives = rmarkdown::render(
    knitr_in("./analysis/eda_descriptives.Rmd"),
    output_file = file_out("eda_descriptives.html"),
    quiet = T
  ),
  # Arrivals/departures analysis
  fpath_transitions = file_in("./data/Netflix Arriving_Leaving Data - Data.csv"),
  data_transitions = clean_transitions(fpath_transitions)
)

make(plan)

vis_drake_graph(plan)


loadd(data)
loadd(data_json)
loadd(data_ext)

dates <- seq(min(data$date), Sys.Date()-1, by="days")
datecheck <- as_tibble(dates) %>% 
  mutate(l1="movie", l2="tv") %>% 
  rename(c("date"=value)) %>% 
  pivot_longer(c(l1, l2), names_to="d", values_to="list") %>% 
  select(-d)


dataframe_step <- function(df, dates) {
  df_sub <- df %>% 
    filter(date %in% dates$date)
  good <- df_sub %>% 
    filter(list!="overall") %>% 
    group_by(date, list) %>% 
    summarize(ten_items=n_distinct(title)==10) %>% 
    filter(ten_items) %>% 
    select(-ten_items)
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

one <- dataframe_step(data, datecheck)
two <- dataframe_step(data_json, one$dates)
three <- dataframe_step(data_ext, two$dates)
