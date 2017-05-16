set.seed(20)

loadDataset <- function(dataset)
{
  fileName <- paste0("experiments/Experiment 3/datasets_processed/",
                     dname,
                     ".csv")
  
  return(read.csv(fileName))
}

loadDatasetTrain <- function(dataset, fold)
{
  fileName <- paste0("experiments/Experiment 3/datasets_processed/",
                     dname,
                     "_",
                     sprintf("%02d", fold),
                     "_train.csv")
  
  return(read.csv(fileName))
}

loadDatasetTest <- function(dataset, fold)
{
  fileName <- paste0("experiments/Experiment 3/datasets_processed/",
                     dname,
                     "_",
                     sprintf("%02d", fold),
                     "_test.csv")
  
  return(read.csv(fileName))
}


