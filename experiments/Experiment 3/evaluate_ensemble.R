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

nFolds <- 10

datasets <- head(datasets)
for(dname in datasets)
{
  dataset <- read.csv(paste0("results_algorithms_joined/", dname, ".csv"))
  dataset$outlier <- factor(dataset$outlier, levels = c("yes", "no"))
  
  # Let's test 4 approaches: voting, voting with features, stacking, stacking with features
  
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  
  tc <- trainControl(index = cvIndex, method = 'cv',number = nFolds)
  
  train(outlier ~ .,
        data = dataset,
        method = "glm",
        trControl = fitControl)
}

# Save the dataset:
write.csv(results_dataset,
          paste0("results_evaluation/ensemble_metrics.csv"),
          row.names = FALSE)