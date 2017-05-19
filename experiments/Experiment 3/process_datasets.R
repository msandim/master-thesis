library(dplyr)
library(caret)
library(foreign)

set.seed(20)

dataset_aloi <- read.arff("../../datasets/literature/ALOI/ALOI_withoutdupl.arff") %>% select(-id)
dataset_glass <- read.arff("../../datasets/literature/Glass/Glass_withoutdupl_norm.arff") %>% select(-id)
dataset_iono <- read.arff("../../datasets/literature/Ionosphere/Ionosphere_withoutdupl_norm.arff") %>% select(-id)
dataset_kdd <- read.arff("../../datasets/literature/KDDCup99/KDDCup99_withoutdupl_idf.arff") %>% select(-id)
dataset_lym <- read.arff("../../datasets/literature/Lymphography/Lymphography_withoutdupl_idf.arff") %>% select(-id)
dataset_pen <- read.arff("../../datasets/literature/PenDigits/PenDigits_withoutdupl_norm_v01.arff") %>% select(-id)
dataset_shuttle <- read.arff("../../datasets/literature/Shuttle/Shuttle_withoutdupl_v01.arff") %>% select(-id)
dataset_waveform <- read.arff("../../datasets/literature/Waveform/Waveform_withoutdupl_v01.arff") %>% select(-id)
dataset_wbc <- read.arff("../../datasets/literature/WBC/WBC_withoutdupl_v01.arff") %>% select(-id)
dataset_wdbc <- read.arff("../../datasets/literature/WDBC/WDBC_withoutdupl_v01.arff") %>% select(-id)
dataset_wpbc <- read.arff("../../datasets/literature/WPBC/WPBC_withoutdupl_norm.arff") %>% select(-id)

dataset_ann <- read.arff("../../datasets/semantic/Annthyroid/Annthyroid_withoutdupl_07.arff") %>% select(-id)
dataset_arr <- read.arff("../../datasets/semantic/Arrhythmia/Arrhythmia_withoutdupl_10_v01.arff") %>% select(-id)
dataset_cardio <- read.arff("../../datasets/semantic/Cardiotocography/Cardiotocography_withoutdupl_20_v01.arff") %>% select(-id)
dataset_heart <- read.arff("../../datasets/semantic/HeartDisease/HeartDisease_withoutdupl_20_v01.arff") %>% select(-id)
dataset_hepatitis <- read.arff("../../datasets/semantic/Hepatitis/Hepatitis_withoutdupl_16.arff") %>% select(-id)
dataset_ads <- read.arff("../../datasets/semantic/InternetAds/InternetAds_withoutdupl_norm_19.arff") %>% select(-id)
dataset_blocks <- read.arff("../../datasets/semantic/PageBlocks/PageBlocks_withoutdupl_09.arff") %>% select(-id)
dataset_parkinson <- read.arff("../../datasets/semantic/Parkinson/Parkinson_withoutdupl_20_v01.arff") %>% select(-id)
dataset_pima <- read.arff("../../datasets/semantic/Pima/Pima_withoutdupl_20_v01.arff") %>% select(-id)
dataset_spam <- read.arff("../../datasets/semantic/SpamBase/SpamBase_withoutdupl_20_v01.arff") %>% select(-id)
dataset_stamps <- read.arff("../../datasets/semantic/Stamps/Stamps_withoutdupl_09.arff") %>% select(-id)
dataset_wilt <- read.arff("../../datasets/semantic/Wilt/Wilt_withoutdupl_05.arff") %>% select(-id)

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
  dataset_wilt = dataset_wilt)

datasets <- lapply(datasets, function(dataset)
{
  dataset$id <- seq(1, nrow(dataset))
  dataset <- dataset %>% select(id, everything())
  return(dataset)
})

unlink("datasets_processed/*")

for(dname in names(datasets))
{
  dataset <- datasets[[dname]]
  folds <- createFolds(dataset$outlier, k = 10, list = TRUE, returnTrain = TRUE)
  
  write.csv(dataset,
            paste0("datasets_processed/", dname, ".csv"),
            row.names = FALSE)
  
  for(i in 1:10)
  {
    train <- folds[[i]]
    dataset_train <- dataset[train, ]
    dataset_test <- dataset[-train, ]
    
    write.csv(dataset_train,
              paste0("datasets_processed/", dname, "_", sprintf("%02d", i), "_train.csv"),
              row.names = FALSE)
    
    write.csv(dataset_test,
              paste0("datasets_processed/", dname, "_", sprintf("%02d", i), "_test.csv"),
              row.names = FALSE)
  }
}