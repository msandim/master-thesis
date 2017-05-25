set.seed(20)

library(dplyr)
library(caret)

datasets <- c(
  "dataset_aloi",
  #"dataset_glass",
  "dataset_iono",
  "dataset_kdd",
  #"dataset_lym",
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

results_dataset <- data.frame(dataset = character(),
                              algorithm = character(),
                              variant = character(),
                              f1 = numeric(),
                              precision = numeric(),
                              recall = numeric())

for(dname in datasets)
{
  dataset_original <- read.csv(paste0("datasets_processed/", dname, ".csv"))
  
  for(algname in algorithms)
  {
    algorithm_variants <- c()
    
    if (algname %in% unsupervisedAlgorithms)
    {
      fileName <- paste0("results_algorithms/",
                         dname,
                         "_",
                         algname,
                         "_00.csv")
      
      dataset_unsupervised <- read.csv(fileName, stringsAsFactors = FALSE) %>% select(-outlier, -id)
      dataset_original <- bind_cols(dataset_original, dataset_unsupervised)
      
      algorithm_variants <- names(dataset_unsupervised)
      
      for(variant in algorithm_variants)
      {
        # If the algorithm is LOF, we will mark the k higher scores as anomalous:
        if (algname == "LOF")
        {
          outlierRatio <- prop.table(table(dataset_original$outlier))["yes"]
          dataset_original[[variant]] <- ifelse(dataset_original[[variant]] > quantile(dataset_original[[variant]], prob = 1 - outlierRatio),
                                                "yes",
                                                "no")
        } else if (algname == "DBSCAN")
          dataset_original[[variant]] <- ifelse(dataset_original[[variant]], "yes", "no")
        
        # Compute performance metric:
        confusion <- caret::confusionMatrix(dataset_original[[variant]] %>% factor(levels = c("yes", "no")),
                                            dataset_original$outlier %>% factor(levels = c("yes", "no")),
                                            mode = "prec_recall")
        
        # Add entry to dataset of results:
        results_dataset <- rbind(results_dataset, data.frame(
          dataset = dname,
          algorithm = algname,
          variant = variant,
          f1 = confusion$byClass[["F1"]],
          precision = confusion$byClass[["Precision"]],
          recall = confusion$byClass[["Recall"]]))
      }
    }
    else
    {
      algorithm_folds <- list()
      
      for(fold in 1:10)
      {
        fileName <- paste0("results_algorithms/",
                           dname,
                           "_",
                           algname,
                           "_",
                           sprintf("%02d", fold),
                           ".csv")
        
        algorithm_folds <- c(algorithm_folds, list(read.csv(fileName, stringsAsFactors = FALSE) %>% select(-outlier)))
      }
      
      algorithm_folds <- bind_rows(algorithm_folds) %>% arrange(id) %>% select(-id)
      dataset_original <- bind_cols(dataset_original, algorithm_folds)
      algorithm_variants <- names(algorithm_folds)
      
      for(variant in algorithm_variants)
      {
        # Compute performance metric:
        confusion <- caret::confusionMatrix(dataset_original[[variant]] %>% factor(levels = c("yes", "no")),
                                            dataset_original$outlier %>% factor(levels = c("yes", "no")),
                                            mode = "prec_recall")
        
        # Add entry to dataset of results:
        results_dataset <- rbind(results_dataset, data.frame(
          dataset = dname,
          algorithm = algname,
          variant = variant,
          f1 = confusion$byClass[["F1"]],
          precision = confusion$byClass[["Precision"]],
          recall = confusion$byClass[["Recall"]]))
      }
      
    }
  }
}

# Save the dataset:
write.csv(results_dataset,
          paste0("results_evaluation/algorithms_metrics.csv"),
          row.names = FALSE)