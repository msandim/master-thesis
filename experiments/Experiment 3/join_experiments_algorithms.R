set.seed(20)

library(dplyr)

datasets <- c(
  "dataset_aloi",
  "dataset_glass",
  "dataset_iono",
  "dataset_kdd",
  "dataset_lym",
  "dataset_pen",
  "dataset_shuttle",
  "dataset_waveform",
  "dataset_wbc",
  "dataset_wdbc",
  "dataset_wpbc",
  "dataset_ann",
  "dataset_arr",
  "dataset_cardio", 
  "dataset_heart",
  "dataset_hepatitis",
  "dataset_ads",
  "dataset_blocks",
  "dataset_parkinson",
  "dataset_pima",
  "dataset_spam",
  "dataset_stamps",
  "dataset_wilt")

algorithms <- c(
  #"CART",
  "DBSCAN",
  #"kmeans",
  #"kNN",
  #"kNNDistance",
  #"linearSVM",
  "LOF",
  #"naiveBayes",
  #"neuralNetwork",
  "oneClassSVM",
  "randomForest",
  "random"
)

unsupervisedAlgorithms <- c("DBSCAN", "kmeans", "kNNDistance", "LOF", "random")

for(dname in datasets)
{
  dataset_original <- read.csv(paste0("datasets_processed/", dname, ".csv"))
  
  for(algname in algorithms)
  {
    if (algname %in% unsupervisedAlgorithms)
    {
      fileName <- paste0("results_algorithms/",
                         dname,
                         "_",
                         algname,
                         "_00.csv")
      
      dataset_original <- bind_cols(dataset_original, read.csv(fileName) %>% select(-outlier))
    }
    else
    {
      dataset_folds <- list()
      
      for(fold in 1:10)
      {
        
        
        fileName <- paste0("results_algorithms/",
                           dname,
                           "_",
                           algname,
                           "_",
                           sprintf("%02d", fold),
                           ".csv")
        
        read.csv(fileName) %>% select(-outlier)
      }
    }
  }
}