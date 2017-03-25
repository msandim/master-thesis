library(dplyr)

##
dataset <- read.arff("datasets/literature/KDDCUP99/KDDCup99_withoutdupl_1ofn.arff")
dataset <- dataset %>% select(-outlier, -id)
write.csv(dataset, "datasets_processed/KDDCup99.csv", row.names = FALSE)

## Experiments
dataset3 <- read.arff("datasets/literature/KDDCUP99/KDDCup99_idf.arff")
