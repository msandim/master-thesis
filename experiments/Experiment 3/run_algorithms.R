set.seed(20)

datasets <- c(
  "dataset_aloi",
  "dataset_glass",
  "dataset_iono",
  "dataset_kdd",
  "dataset_lym",
  "dataset_pen",
  "dataset_shuttle",
  "dataset_waveform",
  "dataset_wbc",
  "dataset_wdbc",
  "dataset_wpbc",
  "dataset_ann",
  "dataset_arr",
  "dataset_cardio", 
  "dataset_heart",
  "dataset_hepatitis",
  "dataset_ads",
  "dataset_blocks",
  "dataset_parkinson",
  "dataset_pima",
  "dataset_spam",
  "dataset_stamps",
  "dataset_wilt")

datasets <- tail(datasets, 3)

algorithms <- c(
  "CART",
  #"DBSCAN",
  #"kmeans",
  #"kNN",
  #"kNNDistance",
  #"linearSVM",
  "LOF"
  #"naiveBayes",
  #"neuralNetwork",
  #"oneClassSVM",
  #"randomForest"
)

buildCommand <- function(algorithm, dataset, fold)
{
  jobName <- paste0(dataset, "_", algorithm, "_", fold)
  paste0("qsub -v dataset=\'",
                    dataset,
                    "\',algorithm=\'",
                    algorithm,
                    "\',fold=",
                    fold,
                    " -N ", jobName,
                    " run_task.sh")
}


for(dataset in datasets)
{
  for(algorithm in algorithms)
  {
    # If the algorithm is unsupervised:
    if (algorithm %in% c("DBSCAN", "kNNDistance", "LOF"))
    {
      fold <- 0
      command <- buildCommand(algorithm, dataset, fold)
      print(command)
      system(command)
    }
    else
    {
      for(fold in 1:10)
      {
        command <- buildCommand(algorithm, dataset, fold)
        print(command)
        system(command)
      }
    }
  }
}