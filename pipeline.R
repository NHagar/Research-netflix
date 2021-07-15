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
  # External data check
  data_ext = load_and_clean_external(),
  # Patch any missing data
  data_all=concat_sequential(list(data, data_json_cleaned, data_ext)),  
  # Break data into lists
  subset = target(
    data_all %>% filter(list==type),
    transform=map(type=c("tv", "movie"), .names=c("tv", "movie"))
  ),
  # EDA
  total_items = target(
    n_distinct(subset$title),
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
    transform=map(mk_df, .names=c("mk_tv", "mk_movie"))
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