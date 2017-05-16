set.seed(20)

library(dplyr)

# Include data utils
source("experiments/Experiment 3/utils/read_data_utils.R")

# Include algorithms
source("experiments/Experiment 3/algorithms/CART.R")
source("experiments/Experiment 3/algorithms/DBSCAN.R")
source("experiments/Experiment 3/algorithms/kmeans.R")
source("experiments/Experiment 3/algorithms/kNN.R")
source("experiments/Experiment 3/algorithms/kNNDistance.R")
source("experiments/Experiment 3/algorithms/linearSVM.R")
source("experiments/Experiment 3/algorithms/LOF.R")
source("experiments/Experiment 3/algorithms/naiveBayes.R")
source("experiments/Experiment 3/algorithms/neuralNetwork.R")
source("experiments/Experiment 3/algorithms/oneClassSVM.R")
source("experiments/Experiment 3/algorithms/randomForest.R")

unsupervisedAlgorithms <- c("DBSCAN", "kmeans", "kNNDistance", "LOF")
semiSupervisedAlgorithms <- c("oneClassSVM")

train_functions <- list(
  CART = CART$train,
  kNN = kNN$train,
  linearSVM = linearSVM$train,
  naiveBayes = naiveBayes$train,
  neuralNetwork = neuralNetwork$train,
  oneClassSVM$train,
  randomForest = randomForest$train
)

test_functions <- list(
  CART = CART$test,
  kNN = kNN$test,
  linearSVM = linearSVM$test,
  naiveBayes = naiveBayes$test,
  neuralNetwork = neuralNetwork$test,
  oneClassSVM = oneClassSVM$test,
  randomForest = randomForest$test
)

apply_functions <- list(
  DBSCAN = DBSCAN$apply,
  kmeans = kmeans$apply,
  kNNDistance = kNNDistance$apply,
  LOF = LOF$apply
)

# Recebi 3 argumentos:
datasetName <- paste0()

dataset <- x
algorithm <- x
fold <- x

# Unsupervised
if (algorithm %in% unsupervisedAlgorithms)
{
  # Load dataset and train
  data <- loadDataset(dataset)
  
  # Save the predictions by the algorithm
  final_data <- apply_functions[[algorithm]](data)
}
# Semi-supervised
else if (algorithm %in% semiSupervisedAlgorithms)
{
  # Load dataset (only inliers)
  train_data <- loadDatasetTrain(dataset, fold) %>% filter(outlier = "no")
  test_data <- loadDatasetTest(dataset, fold)
  
  # Give dataset to algorithm
  model <- train_functions[[algorithm]](train_data)
  
  # Save the final predictions
  final_data <- test_functions[[algorithm]](model, test_data)
}
# Supervised Learning Algorithms
else
{
  # Load dataset
  train_data <- loadDatasetTrain(dataset, fold)
  test_data <- loadDatasetTest(dataset, fold)
  
  # Give dataset to algorithm
  model <- train_functions[[algorithm]](train_data)
  
  # Save the final predictions
  final_data <- test_functions[[algorithm]](model, test_data)
}

final_data
