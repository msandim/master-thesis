set.seed(20)

library(e1071)
library(dplyr)

one_class_svm_train <- function(data)
{
  data_model <- data %>% select(-outlier)
  model <- svm(data_model, type='one-classification', scale = FALSE)
  
  return(model)
}

one_class_svm_test <- function(model, data)
{
  data$oneClassSVM <- !predict(svm_model, data %>% select(-outlier))
  return(data)
}

#one_class_svm_save <- function(data, algorithm, dataset, fold)
#{
#  writePredictions(data,
#                   algorithm,
#                   dataset,
#                   fold)
#}