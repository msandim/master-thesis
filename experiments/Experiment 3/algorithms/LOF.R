set.seed(20)

library(dbscan)
library(dplyr)

lof_apply <- function(data)
{
  data_matrix <- data %>% select(-outlier) %>% as.matrix
  
  data$lof_03 <- lof(data_matrix, k = 3)
  data$lof_05 <- lof(data_matrix, k = 5)
  data$lof_08 <- lof(data_matrix, k = 8)
  data$lof_14 <- lof(data_matrix, k = 14)
  data$lof_19 <- lof(data_matrix, k = 19)
  data$lof_25 <- lof(data_matrix, k = 25)
  data$lof_30 <- lof(data_matrix, k = 30)
  
  return(data)
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
