library(e1071)

one_class_svm_polynomial_train <- function(data)
{
  data_X <- data %>% select(-outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_X, method = c("center", "scale"))
  data_X <- predict(scaleObject, data_X)
  
  model <- svm(data_X, kernel = "polynomial", type='one-classification', scale = FALSE)
  
  return(list(model = model, scaleObject = scaleObject))
}

one_class_svm_polynomial_test <- function(model, data)
{
  data_X <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  data_X <- predict(model[["scaleObject"]], data_X)
  
  predictions <- predict(model[["model"]], data_X)
  
  returnData$oneClassSVM_polynomial <- ifelse(predictions, "no", "yes")
  
  return(returnData)
}

#one_class_svm_save <- function(data, algorithm, dataset, fold)
#{
#  writePredictions(data,
#                   algorithm,
#                   dataset,
#                   fold)
#}