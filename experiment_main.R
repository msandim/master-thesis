set.seed(2)

# Divides the dataset into 3 parts: train for the Ensemble, test of the Ensemble and train of algorithms
divideDataset <- function(dataset)
{
  # The final test dataset is made out of 20% of the data:
  testFinalIndex <- createDataPartition(dataset$truth, p = 0.2, list = FALSE)
  testFinal <- dataset[testFinalIndex, ]
  train <- dataset[-testFinalIndex, ]
  
  trainFinalIndex <- createDataPartition(train$truth, p = 0.5, list = FALSE)
  
  # The training for the final phase is made out of 40% of the data:
  trainFinal <- dataset[trainFinalIndex, ]
  
  # The training for the first phase is made out of 40% of the data:
  trainAlgorithms <- dataset[-trainFinalIndex, ]
  
  list(trainAlgorithms = trainAlgorithms, trainFinal = trainFinal, testFinal = testFinal)
}

aggregatePredictions <- function(algorithmResults)
{
  trainFinal <- bind_rows(lapply(algorithmResults, function(x) x$trainFinal))
  testFinal <- bind_rows(lapply(algorithmResults, function(x) x$testFinal))
  
  list(trainFinal = trainFinal, testFinal = testFinal)
}

evaluateDatasets <- function(supervisedAlgs, semiSupervisedAlgs, unsupervisedAlgs, datasets)
{
  sapply(datasets, function(dataset)
  {
    # Divide dataset according to the proportions defined:
    datasetSplit <- divideDataset(dataset)
    
    #resultsSupervised <- lapply(supervisedAlgs, evaluateDatasetSupervised, datasetSplit)
    resultsSemi <- lapply(semiSupervisedAlgs, evaluateDatasetSemi, datasetSplit)
    resultsUnsupervised <- lapply(unsupervisedAlgs, evaluateDatasetUnsupervised, datasetSplit)
    
    #aggregatePredictions(resultsSupervised)
    aggregatePredictions(resultsSemi)
    aggregatePredictions(resultsUnsupervised)
    
    # Combine results:
    resultsAlgorithmsTrain <- bind_cols(#resultsSupervised$trainFinal %>% select(-truth), 
                                        resultsSemi$trainFinal %>% select(-truth),
                                        resultsUnsupervised$trainFinal %>% select(-truth))
    
    resultsAlgorithmsTest <- bind_cols(#resultsSupervised$testFinal %>% select(-truth), 
                                       resultsSemi$testFinal %>% select(-truth),
                                       resultsUnsupervised$testFinal %>% select(-truth))
    
    # Add ground truth again:
    #resultsAlgorithmsTrain$truth <- dataset$trainAlgorithms
    #resultsAlgorithmsTest$truth <- resultsSupervised$testFinal$truth
    
    # Evaluate algorithms individually:
    evaluateDataset(resultsAlgorithmsTrain)
    
    # Evaluate the ensemble of algorithms:
    evaluateDatasetEnsembleRF(resultsAlgorithmsTrain, resultsAlgorithmsTest)
  })
}

# I assume the algorithm here is a name to use in caret
evaluateDatasetSupervised <- function(algorithmName, dataset)
{
  model <- train(truth ~ ., data = dataset$trainAlgorithms, method = algorithmName)
  dataset$trainFinal[[paste0("alg_", algorithmName)]] <- predict(model, dataset$trainFinal)
  dataset$testFinal[[paste0("alg_", algorithmName)]] <- predict(model, dataset$testFinal)
  
  list(trainFinal = dataset$trainFinal, testFinal = dataset$testFinal)
}

evaluateDatasetSemi <- function(algorithm, dataset)
{
  # ver isto melhor ########## falta meter o name e assim
  model <- algorithm$train(truth ~ ., data = dataset$trainAlgorithms %>% filter(truth == TRUE))
  dataset$trainFinal[[paste0("alg_", algorithmName)]] <- predict(model, dataset$trainFinal)
  dataset$testFinal[[paste0("alg_", algorithmName)]] <- predict(model, dataset$testFinal)
  
  list(trainFinal = dataset$trainFinal, testFinal = dataset$testFinal)
}

evaluateDatasetUnsupervised <- function(algorithm, dataset)
{
  #### Fazer ainda
  model <- algorithm(dataset$trainAlgorithms %>% filter(truth == TRUE))
  dataset$trainFinal[[paste0("alg_", algorithmName)]] <- predict(model, dataset$trainFinal)
  dataset$testFinal[[paste0("alg_", algorithmName)]] <- predict(model, dataset$testFinal)
  
  list(trainFinal = dataset$trainFinal, testFinal = dataset$testFinal)
}

evaluateDatasetEnsembleRF <- function(resultsAlgorithms)
{
  # Train on 50% of the data (which is 40% of the total), test on the other 50%
  
  
  combinerModel <- train(truth ~ ., data = dataset$train, method = "rf")
  predictionEnsemble <- predict(combinerModel, test)
  
  test$prediction_ensemble_rf <- predictionEnsemble
  
  # Eventually get the results of the test set (to calculate precision and recall and f1)
  test
}


main <- function(x)
{
  sapply()
}