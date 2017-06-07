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
  "CART",
  "DBSCAN",
  "kmeans",
  "LOF",
  "naiveBayes",
  "neuralNetwork",
  "oneClassSVM_linear",
  "oneClassSVM_polynomial",
  "oneClassSVM_radial",
  "oneClassSVM_sigmoid",
  "randomForest",
  "SVM_linear",
  "SVM_polynomial",
  "SVM_radial",
  "SVM_sigmoid",
  "random"
)

unsupervisedAlgorithms <- c("DBSCAN", "kmeans", "LOF", "random")

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
        }
        
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
      algorithm_variants <- read.csv(paste0("results_algorithms/", dname, "_", algname, "_01.csv"), stringsAsFactors = FALSE) %>%
        select(-outlier, -id) %>%
        names
        
      for(variant in algorithm_variants)
      {
        f1s <- numeric()
        precisions <- numeric()
        recalls <- numeric()
        
        for(fold in 1:10)
        {
          fileName <- paste0("results_algorithms/",
                             dname,
                             "_",
                             algname,
                             "_",
                             sprintf("%02d", fold),
                             ".csv")
          
          algorithm_fold <- read.csv(fileName, stringsAsFactors = FALSE)
          
          confusion <- caret::confusionMatrix(algorithm_fold[[variant]] %>% factor(levels = c("yes", "no")),
                                              algorithm_fold$outlier %>% factor(levels = c("yes", "no")),
                                              mode = "prec_recall")
          
          f1s <- c(f1s, confusion$byClass[["F1"]])
          precisions <- c(precisions, confusion$byClass[["Precision"]])
          recalls <- c(recalls, confusion$byClass[["Recall"]])
        }
        
        # All the NAs will be replaced by zero:
        f1s[is.na(f1s)] <- 0
        precisions[is.na(precisions)] <- 0
        recalls[is.na(recalls)] <- 0
        
        results_dataset <- rbind(results_dataset, data.frame(
          dataset = dname,
          algorithm = algname,
          variant = variant,
          f1 = mean(f1s, na.rm = TRUE),
          precision = mean(precisions, na.rm = TRUE),
          recall = mean(recalls, na.rm = TRUE)))
      }
    }
  }
}

# Save the dataset:
write.csv(results_dataset,
          paste0("results_evaluation/algorithms_metrics.csv"),
          row.names = FALSE)