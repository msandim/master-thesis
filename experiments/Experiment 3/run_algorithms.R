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

#datasets <- tail(datasets, 1)

algorithms <- c(
  "CART",
  "DBSCAN",
  "kmeans",
  "LOF",
  "naiveBayes",
  "neuralNetwork",
  "oneClassSVM_linear",
  "oneClassSVM_polynomial",
  "oneClassSVM_radial",
  "oneClassSVM_sigmoid",
  "randomForest",
  "SVM_linear",
  "SVM_polynomial",
  "SVM_radial",
  "SVM_sigmoid",
  "random"
)

unsupervisedAlgorithms <- c("DBSCAN", "kmeans", "LOF", "random")

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
                    " -o outputs/", jobName, "_o.txt",
                    " -e errors/", jobName, "_e.txt",
                    " run_task.sh")
}

#################### Script starts here #####################

# Delete all previous results
unlink("results_algorithms/*")
unlink("outputs/*")
unlink("errors/*")

for(dataset in datasets)
{
  for(algorithm in algorithms)
  {
    # If the algorithm is unsupervised:
    if (algorithm %in% unsupervisedAlgorithms)
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