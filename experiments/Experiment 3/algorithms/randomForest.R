library(randomForest)

random_forest_train <- function(data)
{
  data_model <- data %>% select(-outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_model, method = c("center", "scale"))
  data_model <- predict(scaleObject, data_model)
  
  data_model$outlier <- data$outlier
  
  model <- randomForest(outlier ~ ., data_model, ntree = 200)
  
  return(list(model = model, scaleObject = scaleObject))
}

random_forest_test <- function(model, data)
{
  data_model <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  data_model <- predict(model[["scaleObject"]], data_model)
  
  returnData$rf <- predict(model[["model"]], data_model)
  
  return(returnData)
}