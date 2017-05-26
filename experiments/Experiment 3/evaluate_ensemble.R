set.seed(20)

library(dplyr)
library(caret)
library(MLmetrics)

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

f1_precall <- function(data, lev = NULL, model = NULL) {
  f1 <- F1_Score(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  precision <- Precision(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  recall <- Recall(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  
  return(c(f1 = f1, precision = precision, recall = recall))
}

change_lof_to_binary <- function(dataset, columnName)
{
  outlierRatio <- prop.table(table(dataset$outlier))["yes"]
  dataset[[columnName]] <- ifelse(dataset[[columnName]] > quantile(dataset[[columnName]], prob = 1 - outlierRatio), "yes", "no")
  dataset[[columnName]] <- dataset[[columnName]] %>% factor(levels = c("yes", "no"))
  return(dataset)
}

####### Script starts here ###################################################

ensemble_results <- data.frame(dataset = character(),
                               ensemble = character(),
                               f1 = numeric(),
                               precision = numeric(),
                               recall = numeric())

for(dname in datasets)
{
  dataset <- dataset_heart <- read.csv(paste0("results_algorithms_joined/", dname, ".csv")) %>% select(-id, -random)
  dataset$dbscan_0.3 <- factor(dataset$dbscan_0.3, levels = c("yes", "no"))
  dataset$dbscan_0.5 <- factor(dataset$dbscan_0.5, levels = c("yes", "no"))
  dataset$dbscan_0.7 <- factor(dataset$dbscan_0.7, levels = c("yes", "no"))
  dataset$dbscan_0.9 <- factor(dataset$dbscan_0.9, levels = c("yes", "no"))
  dataset$dbscan_1.1 <- factor(dataset$dbscan_1.1, levels = c("yes", "no"))
  dataset$oneClassSVM <- factor(dataset$oneClassSVM, levels = c("yes", "no"))
  dataset$rf <- factor(dataset$rf, levels = c("yes", "no"))
  dataset$outlier <- factor(dataset$outlier, levels = c("yes", "no"))
  
  #print(names(dataset))
  
  # Stratified Cross Validation:
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  fitControl <- trainControl(index = cvIndex, method = 'cv', number = nFolds, summaryFunction = f1_precall)
  
  dataset <- dataset %>% select(outlier:rf)
  
  ########### Majority Voting
  dataset_majority_voting <- dataset
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_03")
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_05")
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_08")
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_14")
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_19")
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_25")
  dataset_majority_voting <- change_lof_to_binary(dataset_majority_voting, "lof_30")
  
  majority_predictions <- apply(dataset_majority_voting, 1, function(x) names(which.max(table(x))))
  confusion_majority <- caret::confusionMatrix(majority_predictions %>% factor(levels = c("yes", "no")),
                                               dataset_majority_voting$outlier %>% factor(levels = c("yes", "no")),
                                               mode = "prec_recall")
  
  ensemble_results <- rbind(ensemble_results, data.frame(
    dataset = dname,
    ensemble = "majority",
    f1 = confusion_majority$byClass[["F1"]],
    precision = confusion_majority$byClass[["Precision"]],
    recall = confusion_majority$byClass[["Recall"]]))
  
  #######$$$### GLM
  
  train_object <- train(outlier ~ .,
                        data = dataset,
                        method = "glm",
                        metric = "f1",
                        maximize = TRUE,
                        trControl = fitControl)
  
  ensemble_results <- rbind(ensemble_results, data.frame(
    dataset = dname,
    ensemble = "glm",
    f1 = train_object$results$f1,
    precision = train_object$results$precision,
    recall = train_object$results$recall))
  
  
  print(paste0("Trained ", dname))
}

# Save the dataset:
write.csv(ensemble_results,
          paste0("results_evaluation/ensemble_metrics.csv"),
          row.names = FALSE)