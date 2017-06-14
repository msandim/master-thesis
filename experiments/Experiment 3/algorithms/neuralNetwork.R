library(caret)

neural_net_train <- function(data)
{
  data_model <- data %>% select(-outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_model, method = c("center", "scale"))
  data_model <- predict(scaleObject, data_model)
  
  data_model$outlier <- data$outlier
  
  model <- caret::train(outlier ~ ., data = data_model, method = "mlp",
                        tuneGrid = data.frame(.size = 5), trControl = trainControl(method = "none"))
  
  return(list(model = model, scaleObject = scaleObject))
}

neural_net_test <- function(model, data)
{
  data_model <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  data_model <- predict(model[["scaleObject"]], data_model)
  
  returnData$mlp <- predict(model[["model"]], data_model, type = "prob")[, "yes"]
  
  return(returnData)
}