set.seed(20)

library(dplyr)

# Include data utils
source("utils/data_IO.R")

# Include algorithms
source("algorithms/CART.R")
source("algorithms/DBSCAN.R")
source("algorithms/kmeans.R")
source("algorithms/kNN.R")
source("algorithms/kNNDistance.R")
source("algorithms/linearSVM.R")
source("algorithms/LOF.R")
source("algorithms/naiveBayes.R")
source("algorithms/neuralNetwork.R")
source("algorithms/oneClassSVM.R")
source("algorithms/randomForest.R")
source("algorithms/random.R")

unsupervisedAlgorithms <- c("DBSCAN", "kmeans", "kNNDistance", "LOF", "random")
semiSupervisedAlgorithms <- c("oneClassSVM")

train_functions <- list(
  #CART = cart_train,
  #kNN = knn_train,
  #linearSVM = linear_svm_train,
  #naiveBayes = naive_bayes_train,
  #neuralNetwork = neural_network_train,
  oneClassSVM = one_class_svm_train,
  randomForest = random_forest_train
)

test_functions <- list(
  #CART = cart_test,
  #kNN = knn_test,
  #linearSVM = linear_svm_test,
  #naiveBayes = naive_bayes_test,
  #neuralNetwork = neural_network_test,
  oneClassSVM = one_class_svm_test,
  randomForest = random_forest_test
)

apply_functions <- list(
  DBSCAN = dbscan_apply,
  #kmeans = kmeans_apply,
  #kNNDistance = kNNDistance_apply,
  LOF = lof_apply,
  random = random_apply
)

#save_functions <- list(
  #CART = cart_save,
  #kNN = knn_save,
  #linearSVM = linear_svm_save,
  #naiveBayes = naive_bayes_save,
  #neuralNetwork = neural_network_save,
  #oneClassSVM = one_class_svm_save,
  #randomForest = random_forest_save,
  #DBSCAN = dbscan_save,
  #kmeans = kmeans_save,
  #kNNDistance = kNNDistance_save,
  #LOF = lof_save
#)

# Recebi 3 argumentos:
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3)
  stop("task_handler.R: The arguments are not present!")

algorithm <- args[1]
dataset <- args[2]
fold <- as.numeric(args[3])

print(algorithm)
print(dataset)
print(fold)

# Unsupervised
if (algorithm %in% unsupervisedAlgorithms)
{
  # Load dataset and train
  data <- loadDataset(dataset)
  
  # Save the predictions by the algorithm
  final_data <- apply_functions[[algorithm]](data)
  
} else if (algorithm %in% semiSupervisedAlgorithms) # Semi-supervised
{
  print("semi-supervised")
  
  # Load dataset (only inliers)
  train_data <- loadDatasetTrain(dataset, fold) %>% filter(outlier == "no")
  test_data <- loadDatasetTest(dataset, fold)
  
  # Give dataset to algorithm
  model <- train_functions[[algorithm]](train_data)
  
  # Save the final predictions
  final_data <- test_functions[[algorithm]](model, test_data)
  
} else # Supervised Learning Algorithms
{
  # Load dataset
  train_data <- loadDatasetTrain(dataset, fold)
  test_data <- loadDatasetTest(dataset, fold)
  
  # Give dataset to algorithm
  model <- train_functions[[algorithm]](train_data)
  
  # Save the final predictions
  final_data <- test_functions[[algorithm]](model, test_data)
}

writePredictions(final_data,
                 algorithm,
                 dataset,
                 fold)

#save_functions[[algorithm]](final_data, algorithm, dataset, fold)
