

# ================ MASTER R SCRIPT ===================== #
# 
# Project: ETHIOPIA SYNTHESIS REPORT - v 2.0
# Author: Lemi Taye Daba (tayelemi@gmail.com)
# 
# ====================================================== #

# preparations ------
rm(list = ls())

## packages ---------
library(tidyverse)
library(haven)
library(labelled)
library(scales)
library(readxl)


# Call R scripts ----------

## Household -------
source("01_2_hh_psnp_II.R",             echo=TRUE, max=1000) 

## Community -------
source("02_2_community_psnp.R",         echo=TRUE, max=1000) 

## Dynamics -------
source("06_2_dynamics_adopt_rates.R",   echo=TRUE, max=1000) 
source("06_5_dynamics_maizeDNA.R",      echo=TRUE, max=1000) 
source("06_6_dynamics_new_innovs_w5.R", echo=TRUE, max=1000) 

## Chickpea -------
source("07_1_chickpea_compare.R",       echo=TRUE, max=1000) 
source("07_2_chickpea_AgSS.R",          echo=TRUE, max=1000) 

## Adoption reach -------
source("10_2_adopt_reach_innovs_w4.R",  echo=TRUE, max=1000) 
source("10_3_adopt_reach_innovs_w5.R",  echo=TRUE, max=1000) 
source("10_4_adopt_reach_table.R",      echo=TRUE, max=1000) 
source("10_5_adopt_reach_figure.R",     echo=TRUE, max=1000) 


# -------------------------------- END ----------------------------------- #

