library(dbscan)
library(caret)

lof_apply <- function(data)
{
  data_X <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_X, method = c("center", "scale"))
  data_X <- predict(scaleObject, data_X) %>% as.matrix
  
  returnData$lof_03 <- lof(data_X, k = 3)
  returnData$lof_05 <- lof(data_X, k = 5)
  returnData$lof_08 <- lof(data_X, k = 8)
  returnData$lof_14 <- lof(data_X, k = 14)
  returnData$lof_19 <- lof(data_X, k = 19)
  returnData$lof_25 <- lof(data_X, k = 25)
  returnData$lof_30 <- lof(data_X, k = 30)
  
  return(returnData)
}

#lof_save <- function(data, algorithm, dataset, fold)
#{
#  for(parameter in names(data))
#  {
#    writePredictions(data[[name]],
#                     paste0(algorithm,":",parameter),
#                     dataset,
#                     fold)
#  }
#}
