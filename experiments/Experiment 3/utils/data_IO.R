set.seed(20)

loadDataset <- function(dataset)
{
  fileName <- paste0("datasets_processed/",
                     dname,
                     ".csv")
  
  return(read.csv(fileName))
}

loadDatasetTrain <- function(dataset, fold)
{
  fileName <- paste0("datasets_processed/",
                     dname,
                     "_",
                     sprintf("%02d", fold),
                     "_train.csv")
  
  return(read.csv(fileName))
}

loadDatasetTest <- function(dataset, fold)
{
  fileName <- paste0("datasets_processed/",
                     dname,
                     "_",
                     sprintf("%02d", fold),
                     "_test.csv")
  
  return(read.csv(fileName))
}

writePredictions <- function(data, algorithm, dataset, fold)
{
  fileName <- paste0("datasets_processed/",
                     dataset,
                     "_",
                     sprintf("%02d", fold),
                     "_",
                     algorithm,
                     ".csv")
  
  write.csv(data, fileName, row.names = FALSE)
}