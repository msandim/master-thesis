library(caret)

cart_train <- function(data)
{
  data_model <- data %>% select(-outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_model, method = c("center", "scale"))
  data_model <- predict(scaleObject, data_model)
  
  data_model$outlier <- data$outlier
  
  model <- caret::train(outlier ~ ., data = data_model, method = "rpart", trControl = trainControl(method = "none"))
  
  return(list(model = model, scaleObject = scaleObject))
}

cart_test <- function(model, data)
{
  data_model <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  data_model <- predict(model[["scaleObject"]], data_model)
  
  returnData$cart <- predict(model[["model"]], data_model, type = "prob")[, "yes"]
  
  return(returnData)
}