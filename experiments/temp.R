results <- readRDS("experiments/results_27Apr_experiment_2_processed.rds")

results_processed <- lapply(results, function(dataset)
{
  dataset <- dataset %>% mutate(vote_lof = (rowMeans(select(dataset, starts_with("lof"))) >= 0.5)) %>%
    mutate(vote_dbscan = (rowMeans(select(dataset, starts_with("dbscan"))) >= 0.5)) %>%
    select(-starts_with("lof"), -starts_with("dbscan"))
})

lapply(names(results_processed), function(dname)
{
  results_processed[[dname]] <<- results_processed[[dname]] %>% mutate(dataset = dname)  
})