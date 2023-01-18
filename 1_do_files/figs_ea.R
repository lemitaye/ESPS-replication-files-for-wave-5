
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


recode_region <- function(tbl) {
  
  tbl %>% 
    mutate(
      region = recode(region, 
                           `0` = "Other regions",
                           `1` = "Tigray",
                           `3` = "Amhara",
                           `4` = "Oromia",
                           `7` = "SNNP")
      )
  
}

# this list need to retain only vars that are common across the 
# two waves (for comparison)
# can do a separate analysis for new innovations (see figs_hh)
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
  select(ea_id, wave, region, pw = pw_w5, all_of(vars)) %>% 
  recode_region()

ea_level_w4 <- wave4_ea_new %>% 
  select(ea_id, wave, region, pw_w4, any_of( all_of(vars) ) ) %>% 
  left_join(
    wave5_ea_new %>% 
      select(ea_id, pw = pw_w5),
    by = c("ea_id")
  ) %>% 
  mutate(pw = case_when(!is.na(pw) ~ pw, TRUE ~ pw_w4)) %>% 
  recode_region()


mean_tbl <- function(tbl, by_region = TRUE) {
  
  if (by_region) {
    
    tbl %>% 
      pivot_longer(all_of(vars), 
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
      pivot_longer(all_of(vars), 
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


mean_tbl(ea_level_w5, by_region = FALSE) %>% 
  mutate(wave = "wave 4")


ea_level_w5 %>% 
  pivot_longer(all_of(vars), 
               names_to = "variable",
               values_to = "value")




x <- c("ead_ofsp", "ead_awassa83")
wave5_ea_new %>% 
  select(ea_id, all_of(x))











