set.seed(20)

loadDataset <- function(dataset)
{
  fileName <- paste0("datasets_processed/",
                     dataset,
                     ".csv")
  
  file <- read.csv(fileName)
  file$outlier <- factor(file$outlier, levels = c("yes", "no"))
  
  return(file)
}

loadDatasetTrain <- function(dataset, fold)
{
  fileName <- paste0("datasets_processed/",
                     dataset,
                     "_",
                     sprintf("%02d", fold),
                     "_train.csv")
  
  file <- read.csv(fileName)
  file$outlier <- factor(file$outlier, levels = c("yes", "no"))
  
  return(file)
}

loadDatasetTest <- function(dataset, fold)
{
  fileName <- paste0("datasets_processed/",
                     dataset,
                     "_",
                     sprintf("%02d", fold),
                     "_test.csv")
  
  file <- read.csv(fileName)
  file$outlier <- factor(file$outlier, levels = c("yes", "no"))
  
  return(file)
}

writePredictions <- function(data, algorithm, dataset, fold)
{
  fileName <- paste0("results_algorithms/",
                     dataset,
                     "_",
                     algorithm,
                     "_",
                     sprintf("%02d", fold),
                     ".csv")
  
  write.csv(data, fileName, row.names = FALSE)
}