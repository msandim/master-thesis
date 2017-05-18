random_apply <- function(data)
{
  returnData <- data %>% select(outlier)
  
  probabilityOutlier <- prop.table(table(returnData$outlier))["yes"]
  randomPredictions <- sample(c("yes", "no"), size = nrow(returnData), replace = TRUE, prob = c(probabilityOutlier, 1 - probabilityOutlier))
  
  returnData$random <- randomPredictions
  return(returnData)
}