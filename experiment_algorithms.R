combineResultsByVote <- function(algorithm_results)
{
  rowMeans(algorithm_results) > 0.5
}

