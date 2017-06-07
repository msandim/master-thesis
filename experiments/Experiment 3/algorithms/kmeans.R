kmeans_dist <- function(data, k)
{
  model <- kmeans(data, centers = k)
  data$cluster <- model$cluster
  
  sapply(1:nrow(data), function(i)
  {
    data_instance <- data[i, ]
    
    centroid <- model$centers[data_instance$cluster, ]
    
    data_instance %>% select(-cluster)

    return(dist(rbind(centroid, data_instance))[[1]])
  })
}

kmeans_apply <- function(data)
{
  data_X <- data %>% select(-outlier)
  returnData <- data %>% select(outlier)
  
  # Scale the data:
  scaleObject <- preProcess(data_X, method = c("center", "scale"))
  data_X <- predict(scaleObject, data_X)
  
  returnData$kmeans_03 <- kmeans_dist(data_X, k = 3)
  #returnData$kmeans_05 <- kmeans_dist(data_X, k = 5)
  #returnData$kmeans_08 <- kmeans_dist(data_X, k = 8)
  #returnData$kmeans_14 <- kmeans_dist(data_X, k = 14)
  #returnData$kmeans_19 <- kmeans_dist(data_X, k = 19)
  #returnData$kmeans_25 <- kmeans_dist(data_X, k = 25)
  #returnData$kmeans_30 <- kmeans_dist(data_X, k = 30)
  
  return(returnData)
}