set.seed(20)

library(dplyr)

# Include data utils
source("utils/data_IO.R")

# Include algorithms
source("algorithms/CART.R")
source("algorithms/DBSCAN.R")
source("algorithms/kmeans.R")
source("algorithms/LOF.R")
source("algorithms/naiveBayes.R")
source("algorithms/neuralNetwork.R")
source("algorithms/oneClassSVM_linear.R")
source("algorithms/oneClassSVM_polynomial.R")
source("algorithms/oneClassSVM_radial.R")
source("algorithms/oneClassSVM_sigmoid.R")
source("algorithms/randomForest.R")
source("algorithms/random.R")
source("algorithms/SVM_linear.R")
source("algorithms/SVM_polynomial.R")
source("algorithms/SVM_radial.R")
source("algorithms/SVM_sigmoid.R")

unsupervisedAlgorithms <- c("DBSCAN", "kmeans", "LOF", "random")
semiSupervisedAlgorithms <- c("oneClassSVM_linear",
                              "oneClassSVM_polynomial",
                              "oneClassSVM_radial",
                              "oneClassSVM_sigmoid")

train_functions <- list(
  CART = cart_train,
  naiveBayes = naive_bayes_train,
  neuralNetwork = neural_net_train,
  oneClassSVM_linear = one_class_svm_linear_train,
  oneClassSVM_polynomial = one_class_svm_polynomial_train,
  oneClassSVM_radial = one_class_svm_radial_train,
  oneClassSVM_sigmoid = one_class_svm_sigmoid_train,
  randomForest = random_forest_train,
  SVM_linear = svm_linear_train,
  SVM_polynomial = svm_polynomial_train,
  SVM_radial = svm_radial_train,
  SVM_sigmoid = svm_sigmoid_train
)

test_functions <- list(
  CART = cart_test,
  naiveBayes = naive_bayes_test,
  neuralNetwork = neural_net_test,
  oneClassSVM_linear = one_class_svm_linear_test,
  oneClassSVM_polynomial = one_class_svm_polynomial_test,
  oneClassSVM_radial = one_class_svm_radial_test,
  oneClassSVM_sigmoid = one_class_svm_sigmoid_test,
  randomForest = random_forest_test,
  SVM_linear = svm_linear_test,
  SVM_polynomial = svm_polynomial_test,
  SVM_radial = svm_radial_test,
  SVM_sigmoid = svm_sigmoid_test
)

apply_functions <- list(
  DBSCAN = dbscan_apply,
  kmeans = kmeans_apply,
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
  final_data <- apply_functions[[algorithm]](data %>% select(-id))
  final_data <- final_data %>% bind_cols(select(data, id)) %>% select(id, everything())
  
} else # Supervised and semi-supervised
{
  # Load dataset
  train_data <- loadDatasetTrain(dataset, fold)
  test_data <- loadDatasetTest(dataset, fold)
  
  if (algorithm %in% semiSupervisedAlgorithms)
  {
    print("semi-supervised")
    train_data <- train_data %>% filter(outlier == "no")
  }
  
  # Give dataset to algorithm
  model <- train_functions[[algorithm]](train_data %>% select(-id))
  
  # Save the final predictions
  final_data <- test_functions[[algorithm]](model, test_data %>% select(-id))
  final_data <- final_data %>% bind_cols(select(test_data, id)) %>% select(id, everything())
}

writePredictions(final_data,
                 algorithm,
                 dataset,
                 fold)

#save_functions[[algorithm]](final_data, algorithm, dataset, fold)
