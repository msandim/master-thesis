set.seed(20)

library(dbscan)
library(dplyr)

dbscan_apply <- function(data)
{
  data_matrix <- data %>% select(-outlier) %>% as.matrix
  
  data$dbscan_03 <- (dbscan(data_matrix, eps = 0.3, minPts = ncol(data) + 1)$cluster == 0)
  data$dbscan_05 <- (dbscan(data_matrix, eps = 0.5, minPts = ncol(data) + 1)$cluster == 0)
  data$dbscan_07 <- (dbscan(data_matrix, eps = 0.7, minPts = ncol(data) + 1)$cluster == 0)
  data$dbscan_09 <- (dbscan(data_matrix, eps = 0.9, minPts = ncol(data) + 1)$cluster == 0)
  data$dbscan_11 <- (dbscan(data_matrix, eps = 1.1, minPts = ncol(data) + 1)$cluster == 0)
  
  return(data)
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
