
library(haven)
library(tidyverse)
library(thatssorandom)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)

# theme_set(theme_light())

setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

wave4_ea_new <- read_dta("replication_files/3_report_data/wave4_ea_new.dta")
wave5_ea_new <- read_dta("LSMS_W5/3_report_data/wave5_ea_new.dta")


select_hh_level <- function(tbl, pw) {
  
  tbl %>% 
    mutate_if(is.labelled, as.character, levels = "labels") %>% 
    select(
      household_id, region, {{pw}}, wave, ead_ofsp, ead_awassa83, ead_rdisp, 
      ead_motorpump, ead_swc, ead_consag1, ead_consag2, ead_affor, ead_mango, 
      ead_papaya, ead_avocado, ead_impcr13, ead_impcr19, ead_impcr11, 
      ead_impcr24, ead_impcr14, ead_impcr3, ead_impcr5, ead_impcr60, ead_impcr62
    ) %>% 
    mutate(region = recode(region, 
                           `0` = "Other regions",
                           `1` = "Tigray",
                           `3` = "Amhara",
                           `4` = "Oromia",
                           `7` = "SNNP"))
  
}

vars <- c(
  "ead_ofsp", "ead_awassa83", "ead_kabuli", "ead_rdisp", "ead_motorpump", 
        "ead_swc", "ead_consag1", "ead_consag2", "ead_affor", "ead_mango", 
          "ead_papaya", "ead_avocado", "ead_malt", "ead_durum", "ead_hotline", 
          "ead_seedv1", "ead_seedv2", "commirr", "comm_video", "comm_video_all", 
          "comm_2wt_own", "comm_2wt_use", "comm_psnp", "ead_impcr13", "ead_impcr19", 
          "ead_impcr11", "ead_impcr24", "ead_impcr14", "ead_impcr3", "ead_impcr5", 
          "ead_impcr60", "ead_impcr62"
  )

ea_level_w5 <- wave5_ea_new %>% 
  select(ea_id, wave, region, pw = pw_w5, all_of(vars))

ea_level_w4 <- wave4_ea_new %>% 
  select(ea_id, wave, region, pw_w4, any_of( all_of(vars) ) ) %>% 
  left_join(
    wave5_ea_new %>% 
      select(ea_id, pw = pw_w5),
    by = c("ea_id")
  ) %>% 
  mutate(pw = case_when(!is.na(pw) ~ pw, TRUE ~ pw_w4))


mean_tbl <- function(tbl, by_region = TRUE) {
  
  if (by_region) {
    
    tbl %>% 
      pivot_longer(ead_ofsp:hhd_impcr62, 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, region, variable) %>% 
      summarise(
        mean = weighted.mean(value, w = pw, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  } else {
    
    tbl %>% 
      pivot_longer(hhd_ofsp:hhd_impcr62, 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, variable) %>% 
      summarise(
        mean = weighted.mean(value, w = pw, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  }
  
}




wave5_ea_new %>% 
  select(

)

x <- c("ead_ofsp", "ead_awassa83")
wave5_ea_new %>% 
  select(ea_id, all_of(x))











