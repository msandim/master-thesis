library(e1071)

svm_radial_train <- function(data)
{
  data_model <- data %>% select(-outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_model, method = c("center", "scale"))
  data_model <- predict(scaleObject, data_model)
  
  data_model$outlier <- data$outlier
  
  model <- svm(outlier ~ ., data = data_model, kernel = "radial", probability = TRUE, scale = FALSE)
  
  return(list(model = model, scaleObject = scaleObject))
}

svm_radial_test <- function(model, data)
{
  data_model <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  data_model <- predict(model[["scaleObject"]], data_model)
  
  returnData$SVM_radial <- attr(predict(model[["model"]], data_model, probability = TRUE), "probabilities")[, "yes"]
  
  return(returnData)
}