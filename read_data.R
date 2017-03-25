x <- read.csv("datasets/literature/KDDCUP99/KDDCUP99_1ofn.arff", header=F, comment.char="@", blank.lines.skip=T, stringsAsFactors=F, quote="\'")

library(foreign)
y <- read.arff("datasets/literature/KDDCUP99/KDDCUP99_1ofn.arff")

y_2 <- read.arff("datasets/literature/ALOI/ALOI.arff")
