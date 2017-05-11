setwd("~/master-thesis")
set.seed(20)
library(MASS)
library(dplyr)
library(foreign)

dataset_aloi <- read.arff("datasets/literature/ALOI/ALOI_withoutdupl.arff") %>% select(-id)
dataset_glass <- read.arff("datasets/literature/Glass/Glass_withoutdupl_norm.arff") %>% select(-id)
dataset_iono <- read.arff("datasets/literature/Ionosphere/Ionosphere_withoutdupl_norm.arff") %>% select(-id)
dataset_kdd <- read.arff("datasets/literature/KDDCup99/KDDCup99_withoutdupl_idf.arff") %>% select(-id)
dataset_lym <- read.arff("datasets/literature/Lymphography/Lymphography_withoutdupl_idf.arff") %>% select(-id)
dataset_pen <- read.arff("datasets/literature/PenDigits/PenDigits_withoutdupl_norm_v01.arff") %>% select(-id)
dataset_shuttle <- read.arff("datasets/literature/Shuttle/Shuttle_withoutdupl_v01.arff") %>% select(-id)
dataset_waveform <- read.arff("datasets/literature/Waveform/Waveform_withoutdupl_v01.arff") %>% select(-id)
dataset_wbc <- read.arff("datasets/literature/WBC/WBC_withoutdupl_v01.arff") %>% select(-id)
dataset_wdbc <- read.arff("datasets/literature/WDBC/WDBC_withoutdupl_v01.arff") %>% select(-id)
dataset_wpbc <- read.arff("datasets/literature/WPBC/WPBC_withoutdupl_norm.arff") %>% select(-id)

dataset_ann <- read.arff("datasets/semantic/Annthyroid/Annthyroid_withoutdupl_07.arff") %>% select(-id)
dataset_arr <- read.arff("datasets/semantic/Arrhythmia/Arrhythmia_withoutdupl_10_v01.arff") %>% select(-id)
dataset_cardio <- read.arff("datasets/semantic/Cardiotocography/Cardiotocography_withoutdupl_20_v01.arff") %>% select(-id)
dataset_heart <- read.arff("datasets/semantic/HeartDisease/HeartDisease_withoutdupl_20_v01.arff") %>% select(-id)
dataset_hepatitis <- read.arff("datasets/semantic/Hepatitis/Hepatitis_withoutdupl_16.arff") %>% select(-id)
dataset_ads <- read.arff("datasets/semantic/InternetAds/InternetAds_withoutdupl_norm_19.arff") %>% select(-id)
dataset_blocks <- read.arff("datasets/semantic/PageBlocks/PageBlocks_withoutdupl_09.arff") %>% select(-id)
dataset_parkinson <- read.arff("datasets/semantic/Parkinson/Parkinson_withoutdupl_20_v01.arff") %>% select(-id)
dataset_pima <- read.arff("datasets/semantic/Pima/Pima_withoutdupl_20_v01.arff") %>% select(-id)
dataset_spam <- read.arff("datasets/semantic/SpamBase/SpamBase_withoutdupl_20_v01.arff") %>% select(-id)
dataset_stamps <- read.arff("datasets/semantic/Stamps/Stamps_withoutdupl_09.arff") %>% select(-id)
dataset_wilt <- read.arff("datasets/semantic/Wilt/Wilt_withoutdupl_05.arff") %>% select(-id)

datasets <- list(
  dataset_aloi = dataset_aloi,
  dataset_glass = dataset_glass,
  dataset_iono = dataset_iono,
  dataset_kdd = dataset_kdd,
  dataset_lym = dataset_lym,
  dataset_pen = dataset_pen,
  dataset_shuttle = dataset_shuttle,
  dataset_waveform = dataset_waveform,
  dataset_wbc = dataset_wbc,
  dataset_wdbc = dataset_wdbc,
  dataset_wpbc = dataset_wpbc,
  dataset_ann = dataset_ann,
  dataset_arr = dataset_arr,
  dataset_cardio = dataset_cardio,
  dataset_heart = dataset_heart,
  dataset_hepatitis = dataset_hepatitis,
  dataset_ads = dataset_ads,
  dataset_blocks = dataset_blocks,
  dataset_parkinson = dataset_parkinson,
  dataset_pima = dataset_pima,
  dataset_spam = dataset_spam,
  dataset_stamps = dataset_stamps,
  dataset_wilt = dataset_wilt
)

experiment_dbscan <- function(dataset)
{
  dbscan(dataset %>% select(-outlier) %>% as.matrix, eps = 0.5, minPts = ncol(dataset))
}

calculate_second_derivative <- function(x)
{
  sapply(seq(1, length(x)), function(i)
  {
    if (i == 1 || i == length(x))
      return(0)
    else
      return(x[i+1] + x[i-1] - 2 * x[i])
  })
}

# test with derivative
y <- kNNdist(dataset_hepatitis %>% select(-outlier) %>% as.matrix, k = 4) %>% sort
kNNdistplot(dataset_hepatitis %>% select(-outlier) %>% as.matrix, k = 4)
elbow <- calculate_second_derivative(y) # 317
y[317]
dataset_hepatitis_copy <- dataset_hepatitis
dataset_hepatitis_copy$cluster <- dbscan(dataset_hepatitis_copy %>% select(-outlier) %>% as.matrix, eps = y[317], minPts = ncol(dataset_hepatitis_copy))$cluster
table(dataset_hepatitis_copy$cluster)
dataset_hepatitis_copy %>% filter(cluster == 0) %>% .$outlier %>% table

# test with code from stack overflow
y <- kNNdist(dataset_hepatitis %>% select(-outlier) %>% as.matrix, k = 4) %>% sort
kNNdistplot(dataset_hepatitis %>% select(-outlier) %>% as.matrix, k = 4)
elbow <- calculate_second_derivative(y)

x <- c(1,2,3,4,5,7,14)
kNNdist(x)