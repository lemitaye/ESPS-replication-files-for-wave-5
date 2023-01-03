
library(haven)
library(tidyverse)
library(thatssorandom)
library(labelled)


setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

wave4_hh_new <- read_dta("replication_files/3_report_data/wave4_hh_new.dta")
wave5_hh_new <- read_dta("LSMS_W5/3_report_data/wave5_hh_new.dta")

glimpse(wave4_hh_new) 

select_hh_level <- function(tbl, pw) {
  
  tbl %>% 
    mutate_if(is.labelled, as.character, levels = "labels") %>% 
    select(
      household_id, region, {{pw}}, wave, hhd_ofsp, hhd_awassa83, hhd_rdisp, 
      hhd_motorpump, hhd_swc, hhd_consag1, hhd_consag2, hhd_affor, hhd_mango, 
      hhd_papaya, hhd_avocado, hhd_impcr13, hhd_impcr19, hhd_impcr11, 
      hhd_impcr24, hhd_impcr14, hhd_impcr3, hhd_impcr5, hhd_impcr60, hhd_impcr62
    ) %>% 
    mutate(region = recode(region, 
                           `0` = "Other regions",
                           `1` = "Tigray",
                           `3` = "Amhara",
                           `4` = "Oromia",
                           `7` = "SNNP"))
  
}

hh_level_w5 <- select_hh_level(wave5_hh_new, pw_w5) %>% 
  rename(pw = "pw_w5")

hh_level_w4 <- select_hh_level(wave4_hh_new, pw_w4) %>% 
  left_join(
    hh_level_w5 %>% 
      select(household_id, pw),
    by = c("household_id")
  ) %>% 
  mutate(pw = case_when(!is.na(pw) ~ pw, TRUE ~ pw_w4))



mean_tbl <- function(tbl, by_region = TRUE) {
  
  if (by_region) {
    
    tbl %>% 
      pivot_longer(hhd_ofsp:hhd_impcr62, 
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


labels <- var_label(hh_level_w5) %>% 
  .[-c(1:4)] %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
    ) 

national_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, by_region = FALSE) %>% 
    mutate(wave = "wave 4"),
  mean_tbl(hh_level_w5, by_region = FALSE) %>% 
    mutate(wave = "wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "wave 5", "wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)  

regions_hh_level <- bind_rows(
  mean_tbl(hh_level_w4),
  mean_tbl(hh_level_w5)
  ) %>% 
  mutate(wave = paste("wave", wave) %>% 
           fct_relevel("wave 5", "wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)

# save as csv
write_csv(national_hh_level, "LSMS_W5/3_report_data/national_hh_level.csv")
write_csv(regions_hh_level, "LSMS_W5/3_report_data/regions_hh_level.csv")


national_hh_level %>% 
  ggplot(aes(mean, label, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = round(mean, 2)),
            position = position_dodge(width = 1),
            size = 1.5) +
  labs(x = "Percent of households", 
       y = "", 
       fill = "Wave",
       title = "Percent of Rural Households Adopting Innovations - Waves 4 and 5")

regions_hh_level %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(mean, label, fill = wave)) +
  geom_col(position = "dodge") +
  facet_wrap(~ region, scales = "free_y")


national_hh_level %>% 
  filter(wave == "wave 5")

# Add no. of obs

# Next: EA level (replicate first in stata)




























































































