library(dbscan)

dbscan_apply <- function(data)
{
  data_X <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_X, method = c("center", "scale"))
  data_X <- predict(scaleObject, data_X) %>% as.matrix
  
  returnData$dbscan_0.3 <- (dbscan(data_X, eps = 0.3, minPts = ncol(data) + 1)$cluster == 0)
  returnData$dbscan_0.5 <- (dbscan(data_X, eps = 0.5, minPts = ncol(data) + 1)$cluster == 0)
  returnData$dbscan_0.7 <- (dbscan(data_X, eps = 0.7, minPts = ncol(data) + 1)$cluster == 0)
  returnData$dbscan_0.9 <- (dbscan(data_X, eps = 0.9, minPts = ncol(data) + 1)$cluster == 0)
  returnData$dbscan_1.1 <- (dbscan(data_X, eps = 1.1, minPts = ncol(data) + 1)$cluster == 0)
  
  return(returnData)
}

#dbscan_save <- function(data, algorithm, dataset, fold)
#{
#  for(parameter in names(data))
#  {
#    writePredictions(data[[name]],
#                     paste0(algorithm,":",parameter),
#                     dataset,
#                     fold)
#  }
#}
