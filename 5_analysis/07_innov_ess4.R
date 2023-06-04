
# ----- #
# Purpose: to create data on adoption rates of innovations only in wave 4
# Author: Lemi Daba (tayelemi@gmail.com)
# ----- #


# load packages ----
library(haven)
library(tidyverse)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)
library(ggpubr)


# load data ----
root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"

ess4_hh_all <- read_dta(file.path(root, "tmp/dynamics/ess4_hh_all.dta"))

ess4_hh_psnp <- read_dta(file.path(root, w4_dir, "ess4_hh_psnp.dta"))

# psnp data (generated in 03_new_innov_ess5.R)
psnp_hh <- read_csv("dynamics_presentation/data/psnp_hh.csv")


recode_region <- function(tbl) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(
          region, 
          `1` = "Tigray",
          `2` = "Afar",
          `3` = "Amhara",
          `4` = "Oromia",
          `5` = "Somali",
          `6` = "Benishangul Gumuz",
          `7` = "SNNP",
          `12` = "Gambela",
          `13` = "Harar",
          `15` = "Dire Dawa"
        )
      )
  )
  
}

# some cleaning ----

innovs <- c(
  "hhd_livIA", "hhd_cross_largerum", "hhd_cross_smallrum", "hhd_cross_poultry", 
  "hhd_gaya", "hhd_sasbaniya", "hhd_alfa", "hhd_elepgrass",
  "hhd_grass", "hhd_ofsp", "hhd_awassa83", "hhd_rdisp", "hhd_motorpump", "hhd_swc", 
  "hhd_consag1", "hhd_consag2", "hhd_affor", "hhd_mango", "hhd_papaya", "hhd_avocado",
  "qpm", "dtmz", "maize_cg", "barley_cg", "sorghum_cg"
)


# ALL HOUSEHOLDS ----

hh_level_w4 <- ess4_hh_all %>% 
  select(
    household_id, ea_id, wave, region = saq01, starts_with("pw_"), all_of(innovs)
    ) %>% 
  mutate(
    across(
      c(all_of(innovs)), ~recode(., `100` = 1))  # since w4 vars are mult. by 100
  ) %>% 
  recode_region()


# calculate means
mean_tbl <- function(tbl, vars, group_vars, pw) {
  
  tbl %>% 
    pivot_longer(all_of(vars), 
                 names_to = "variable",
                 values_to = "value") %>% 
    group_by(pick(group_vars)) %>% 
    summarise(
      mean = weighted.mean(value, w = {{pw}}, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    )
  
}

national_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, innovs, group_vars = c("wave", "variable"), pw = pw_w4)
) %>% 
  mutate(wave = paste("Wave", wave))

regions_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, innovs, group_vars = c("wave", "variable", "region"), pw = pw_w4)
) %>% 
  mutate(wave = paste("Wave", wave)) 


# 
labs <- ess4_hh_all %>% 
  select(all_of(innovs)) %>% 
  var_label() %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  )

# modify PSNP
psnp_w4 <- psnp_hh %>% 
  filter(
    wave == "Wave 4", locality == "Aggregate",
    sample == "All", region != "Addis Ababa"
  ) %>% 
  select(wave, variable, region, mean, nobs, label)

adopt_rates_w4_hh <- bind_rows(
  regions_hh_level, 
  national_hh_level %>% 
    mutate(region = "National")
)  %>% 
  left_join(labs, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs) %>% 
  bind_rows(psnp_w4)

write_csv(adopt_rates_w4_hh, file = "dynamics_presentation/data/adopt_rates_w4_hh.csv")





























