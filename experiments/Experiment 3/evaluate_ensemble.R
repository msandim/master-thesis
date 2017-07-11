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

#datasets <- "dataset_iono"

nFolds <- 10

f1_precall <- function(data, lev = NULL, model = NULL) {
  f1 <- F1_Score(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  
  if (is.na(f1))
    f1 <- 0.0
  
  precision <- Precision(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  
  if (is.na(precision))
    precision <- 0.0
  
  recall <- Recall(y_pred = data$pred, y_true = data$obs, positive = lev[1])
  
  if (is.na(recall))
    recall <- 0.0
  
  return(c(f1 = f1, precision = precision, recall = recall))
}

change_numeric_to_binary <- function(dataset, columnName)
{
  if(columnName %in% colnames(dataset))
  {
    outlierRatio <- prop.table(table(dataset$outlier))["yes"]
    dataset[[columnName]] <- ifelse(dataset[[columnName]] > quantile(dataset[[columnName]], prob = 1 - outlierRatio), "yes", "no")
    dataset[[columnName]] <- dataset[[columnName]] %>% factor(levels = c("yes", "no"))
  }
  
  return(dataset)
}

feature_selection <- function(dataset)
{
  X <- select(dataset, -outlier)
  Y <- dataset$outlier
  nzv <- nearZeroVar(X, freqCut = 0, uniqueCut = 0)
  
  # If the neither of our variables have 0 variance, or all of them // tbl_df to avoid dataframe being transformed into list
  if (length(nzv) != 0 && length(nzv) != ncol(X))
    dataset <- X[, -nzv] %>% tbl_df %>% mutate(outlier = Y) %>% select(outlier, everything())
  
  return(dataset)
}

update_ensemble_results <- function(dname, algorithm, f1, precision, recall)
{
  ensemble_results <<- rbind(ensemble_results, data.frame(
    dataset = dname,
    ensemble = algorithm,
    f1 = ifelse(is.na(f1), 0, f1),
    precision = ifelse(is.na(precision), 0, precision),
    recall = ifelse(is.na(recall), 0, recall)))
}

majority_voting <- function(dataset)
{
  dataset_majority_voting <- dataset
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "cart")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_03")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_05")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_08")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_14")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_19")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_25")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "kmeans_30")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_03")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_05")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_08")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_14")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_19")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_25")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "lof_30")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "nb")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "mlp")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "rf")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "SVM_linear")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "SVM_polynomial")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "SVM_radial")
  dataset_majority_voting <- change_numeric_to_binary(dataset_majority_voting, "SVM_sigmoid")
  
  majority_predictions <- apply(dataset_majority_voting, 1, function(x) names(which.max(table(x))))
  confusion_majority <- caret::confusionMatrix(majority_predictions %>% factor(levels = c("yes", "no")),
                                               dataset_majority_voting$outlier %>% factor(levels = c("yes", "no")),
                                               mode = "prec_recall")
  
  return(confusion_majority)
}

calc_majority_voting <- function(dataset, dname)
{
  confusion_majority <- majority_voting(dataset)
  update_ensemble_results(dname,
                          "majority",
                          confusion_majority$byClass[["F1"]],
                          confusion_majority$byClass[["Precision"]],
                          confusion_majority$byClass[["Recall"]])
}

calc_glm <- function(dataset, dname)
{
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  fitControl <- trainControl(index = cvIndex, method = 'cv', number = nFolds, summaryFunction = f1_precall, verboseIter = TRUE)
  
  train_object <- caret::train(outlier ~ .,
                               data = dataset,
                               method = "glm",
                               family="binomial",
                               control = list(maxit = 100),
                               metric = "f1",
                               maximize = TRUE,
                               preProcess = c("center", "scale"),
                               trControl = fitControl)
  
  update_ensemble_results(dname,
                          "glm",
                          train_object$results$f1,
                          train_object$results$precision,
                          train_object$results$recall)
}

calc_cart <- function(dataset, dname)
{
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  fitControl <- trainControl(index = cvIndex, method = 'cv', number = nFolds, summaryFunction = f1_precall, verboseIter = TRUE)
  
  train_object <- caret::train(outlier ~ .,
                               data = dataset,
                               method = "rpart",
                               metric = "f1",
                               maximize = TRUE,
                               preProcess = c("center", "scale"),
                               tuneGrid = data.frame(.cp = 0.01), 
                               trControl = fitControl)
  
  update_ensemble_results(dname,
                          "rpart",
                          train_object$results$f1,
                          train_object$results$precision,
                          train_object$results$recall)
}

calc_nb <- function(dataset, dname)
{
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  fitControl <- trainControl(index = cvIndex, method = 'cv', number = nFolds, summaryFunction = f1_precall, verboseIter = TRUE)
  
  train_object <- caret::train(outlier ~ .,
                               data = dataset,
                               method = "nb",
                               metric = "f1",
                               maximize = TRUE,
                               preProcess = c("center", "scale"),
                               trControl = fitControl)
  
  update_ensemble_results(dname,
                          "nb",
                          train_object$results$f1,
                          train_object$results$precision,
                          train_object$results$recall)
}

calc_mlp <- function(dataset, dname)
{
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  fitControl <- trainControl(index = cvIndex, method = 'cv', number = nFolds, summaryFunction = f1_precall, verboseIter = TRUE)
  
  train_object <- caret::train(outlier ~ .,
                               data = dataset,
                               method = "mlp",
                               metric = "f1",
                               maximize = TRUE,
                               preProcess = c("center", "scale"),
                               tuneGrid = data.frame(.size = 5),
                               trControl = fitControl)
  
  update_ensemble_results(dname,
                          "mlp",
                          train_object$results$f1,
                          train_object$results$precision,
                          train_object$results$recall)
}

calc_rf <- function(dataset, dname)
{
  cvIndex <- createFolds(dataset$outlier, k = nFolds, returnTrain = TRUE)
  fitControl <- trainControl(index = cvIndex, method = 'cv', number = nFolds, summaryFunction = f1_precall, verboseIter = TRUE)
  
  train_object <- caret::train(outlier ~ .,
                               data = dataset,
                               method = "rf",
                               ntree = 200,
                               metric = "f1",
                               maximize = TRUE,
                               preProcess = c("center", "scale"),
                               tuneGrid = data.frame(.mtry = floor(sqrt(ncol(dataset %>% select(-outlier))))),
                               trControl = fitControl)
  
  update_ensemble_results(dname,
                          "rf",
                          train_object$results$f1,
                          train_object$results$precision,
                          train_object$results$recall)
}

####### Script starts here ###################################################

ensemble_results <- data.frame(dataset = character(),
                               ensemble = character(),
                               f1 = numeric(),
                               precision = numeric(),
                               recall = numeric())

for(dname in datasets)
{
  dataset <- read.csv(paste0("results_algorithms_joined/", dname, ".csv")) %>% select(-id, -random)
  dataset$dbscan_0.3 <- factor(dataset$dbscan_0.3, levels = c("yes", "no"))
  dataset$dbscan_0.5 <- factor(dataset$dbscan_0.5, levels = c("yes", "no"))
  dataset$dbscan_0.7 <- factor(dataset$dbscan_0.7, levels = c("yes", "no"))
  dataset$dbscan_0.9 <- factor(dataset$dbscan_0.9, levels = c("yes", "no"))
  dataset$dbscan_1.1 <- factor(dataset$dbscan_1.1, levels = c("yes", "no"))
  dataset$oneClassSVM_linear <- factor(dataset$oneClassSVM_linear, levels = c("yes", "no"))
  dataset$oneClassSVM_polynomial <- factor(dataset$oneClassSVM_polynomial, levels = c("yes", "no"))
  dataset$oneClassSVM_radial <- factor(dataset$oneClassSVM_radial, levels = c("yes", "no"))
  dataset$oneClassSVM_sigmoid <- factor(dataset$oneClassSVM_sigmoid, levels = c("yes", "no"))
  dataset$outlier <- factor(dataset$outlier, levels = c("yes", "no"))
  
  dataset <- dataset %>% select(outlier:SVM_sigmoid)
  
  # Ensemble of supervised/unsupervised:
  # Supervised
  #dataset <- dataset %>% select(-starts_with("dbscan"),
  #                               -starts_with("kmeans"),
  #                               -starts_with("lof"),
  #                               -starts_with("oneClassSVM"))
  # Unsupervised without One-class
  #dataset <- dataset %>% select(-cart,
  #                              -nb,
  #                              -mlp,
  #                              -rf,
  #                              -starts_with("SVM"),
  #                              -starts_with("oneClassSVM"))
  # Unsupervised w/ One-class
  #dataset <- dataset %>% select(-cart,
  #                              -nb,
  #                              -mlp,
  #                              -rf,
  #                              -starts_with("SVM"))
  
  # LOFs
  #dataset <- dataset %>% select(outlier,
  #                              starts_with("lof"))
  # SVMs
  #dataset <- dataset %>% select(outlier,
  #                              starts_with("SVM"))
  # One-Class
  #dataset <- dataset %>% select(outlier,
  #                              starts_with("oneClassSVM"))
  # SVMs + One-Class
  #dataset <- dataset %>% select(outlier,
  #                              starts_with("SVM"),
  #                              starts_with("oneClassSVM"))
  # DBSCANs
  dataset <- dataset %>% select(outlier,
                                starts_with("dbscan"))
  # kmeans
  #dataset <- dataset %>% select(outlier,
  #                              starts_with("kmeans"))
  # DBSCANs + kmeans
  #dataset <- dataset %>% select(outlier,
  #                              starts_with("dbscan"),
  #                              starts_with("kmeans"))
  # Tree-based
  #dataset <- dataset %>% select(outlier,
  #                              cart,
  #                              rf)
  
  ############### Feature selection
  dataset <- feature_selection(dataset)
  
  print(names(dataset))
  
  print("mv")
  calc_majority_voting(dataset, dname)
  
  print("glm")
  calc_glm(dataset, dname)
  
  print("rpart")
  calc_cart(dataset, dname)
  
  #calc_nb(dataset, dname)
  #print("nb")
  
  print("mlp")
  calc_mlp(dataset, dname)
  
  print("rf")
  if (dname != "dataset_waveform" && dname != "dataset_wdbc" && dname != "dataset_wpbc" && dname != "dataset_arr" && dname != "dataset_cardio" && dname != "dataset_heart" && dname != "dataset_hepatitis" && dname != "dataset_ads" && dname != "dataset_parkinson") # This dataset takes a lot in random forests
    calc_rf(dataset, dname)
  else
    update_ensemble_results(dname, "rf", NA, NA, NA)
  
  
  print(paste0("******** Trained ", dname, "********"))
}

# Save the dataset:
write.csv(ensemble_results,
          paste0("results_evaluation/ensemble_metrics.csv"),
          row.names = FALSE)