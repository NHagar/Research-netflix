lapply(list.files("./R", full.names = TRUE), source)

plan <- drake_plan(
  # Data loading and formatting
  fpath = file_in("./data/Holly Netflix Data - Sheet1.csv"),
  data = load_and_clean_data(fpath),
  
  # Integrating JSON files
  json_files <- list.files("./data/Maddy Data", full.names = T),
  data_json <- load_and_clean_json(json_files),
  # JSON + CSV concatenation
  
  # Intra day sanity check
  ids = intra_day_shifts(data),
  # Break data into lists
  subset = target(
    data %>% filter(collection==0, cat==type),
    transform=map(type=c("overall", "tv", "movie"), .names=c("overall", "tv", "movie"))
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

readd(data) %>% 
  filter(Date==as_date("2021-04-05") & cat=="tv" & collection==0)

as_date("2021-03-11")
