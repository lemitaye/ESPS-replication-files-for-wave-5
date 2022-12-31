
library(haven)
library(tidyverse)

setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

wave4_hh_new <- read_dta("replication_files/3_report_data/wave4_hh_new.dta")
wave5_hh_new <- read_dta("LSMS_W5/3_report_data/wave5_hh_new.dta")

glimpse(wave4_hh_new) 

select_hh_level <- function(tbl, pw) {
  
  tbl %>% 
    mutate_if(is.labelled, as.character, levels = "labels") %>% 
    select(
      region, {{pw}}, wave, hhd_ofsp, hhd_awassa83, hhd_rdisp, hhd_motorpump, hhd_swc, hhd_consag1, hhd_consag2, 
      hhd_affor, hhd_mango, hhd_papaya, hhd_avocado, hhd_impcr13, hhd_impcr19, hhd_impcr11, 
      hhd_impcr24, hhd_impcr14, hhd_impcr3, hhd_impcr5, hhd_impcr60, hhd_impcr62
    ) %>% 
    mutate(region = recode(region, 
                           `0` = "Other regions",
                           `1` = "Tigray",
                           `3` = "Amhara",
                           `4` = "Oromia",
                           `7` = "SNNP"))
  
}

hh_level_w4 <- select_hh_level(wave4_hh_new, pw_w4)
hh_level_w5 <- select_hh_level(wave5_hh_new, pw_w5)

mean_tbl <- function(tbl, pw) {
  
  tbl %>% 
    group_by(wave, region) %>% 
    summarise(
      across(hhd_ofsp:hhd_impcr62, 
             ~ weighted.mean(., w = {{pw}}, na.rm = TRUE)),
      .groups = "drop"
    ) %>% 
    pivot_longer(hhd_ofsp:hhd_impcr62, 
                 names_to = "variable",
                 values_to = "mean")
  
}

mean_tbl(hh_level_w4, pw_w4)
mean_tbl(hh_level_w5, pw_w5)

# values in hh_level_w4 have been multiplied by 100 somewhere (?)






























































































