#!/bin/bash
cd Experiment_3
../R-3.4.0/bin/Rscript task_handler.R $algorithm $dataset $fold
#Rscript task_handler.R $1 $2 $3