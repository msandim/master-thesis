library(dplyr)
library(tidyr)

cmd <- paste0("java -jar elki-software/elki/elki-bundle-0.7.1.jar ",
              "KDDCLIApplication -dbc.in datasets_processed/KDDCup99.csv ",
              "-time -algorithm outlier.clustering.KMeansOutlierDetection -kmeans.k 7 -evaluator NoAutomaticEvaluation ",
              "-resulthandler ResultWriter -out elki-software/results/")

system(cmd)


result <- read.csv("elki-software/results/kmeans-outlier_order.txt", sep = " ", header = FALSE, stringsAsFactors = FALSE) %>%
  select(V1, V81) %>%
  separate(V81, sep = "=", into = c("delete", "score")) %>%
  separate(V1, se = "=", into = c("delete2", "id")) %>%
  mutate(score = as.numeric(score)) %>%
  select(-delete, -delete2)

result$score <- as.numeric(result$score)
