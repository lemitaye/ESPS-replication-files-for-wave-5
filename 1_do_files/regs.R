

library(haven)
library(tidyverse)
library(thatssorandom)
library(labelled)
library(janitor)
library(scales)

# theme_set(theme_light())

setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

ess5_cov <- read_dta("LSMS_W5/3_report_data/ess5_pp_cov_new.dta")
