library(e1071)

naive_bayes_train <- function(data)
{
  data_model <- data %>% select(-outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_model, method = c("center", "scale"))
  data_model <- predict(scaleObject, data_model)
  
  data_model$outlier <- data$outlier
  
  model <- naiveBayes(outlier ~ ., data = data_model)
  
  return(list(model = model, scaleObject = scaleObject))
}

naive_bayes_test <- function(model, data)
{
  data_model <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  data_model <- predict(model[["scaleObject"]], data_model)
  
  returnData$nb <- predict(model[["model"]], data_model, type = "raw")[, "yes"]
  
  return(returnData)
}