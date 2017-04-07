library(dplyr)
library(foreign)

## Glass
dataset <- read.arff("datasets/literature/Glass/Glass_withoutdupl_norm.arff")

## KDDCUP99
dataset <- read.arff("datasets/literature/KDDCup99/KDDCup99_withoutdupl_1ofn.arff")
#dataset <- dataset %>% select(-outlier, -id)
write.csv(dataset, "datasets_processed/KDDCup99.csv", row.names = FALSE)

## ALOI
dataset <- read.arff("datasets/literature/ALOI/ALOI_withoutdupl.arff")
#dataset <- dataset %>% select(-outlier, -id)
write.csv(dataset, "datasets_processed/ALOI.csv", row.names = FALSE)

## 
