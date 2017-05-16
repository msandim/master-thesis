set.seed(20)

library(caret)
library(dplyr)

random_forest_train <- function(data)
{
  model <- train(outlier ~ ., data = data %>% select(-outlier), method = "rf")
  
  return(model)
}

random_forest_test <- function(model, data)
{
  data$rf <- predict(model, newdata = data, type = "prob")
  return(data)
}