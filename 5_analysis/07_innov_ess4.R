
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
  "hhd_consag1", "hhd_consag2", "hhd_affor", "hhd_mango", "hhd_papaya", "hhd_avocado"
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
psnp_w4_rur <- psnp_hh %>% 
  filter(
    wave == "Wave 4", locality == "Rural",
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
  bind_rows(psnp_w4_rur)

write_csv(adopt_rates_w4_hh, file = "dynamics_presentation/data/adopt_rates_w4_hh.csv")



# DNA -------

dna_vars <- c("qpm", "dtmz", "maize_cg", "barley_cg", "sorghum_cg",
              "cr1", "cr2", "cr6")

hh_dna_w4 <- ess4_hh_all %>% 
  select(
    household_id, ea_id, wave, region = saq01, starts_with("pw_"), all_of(dna_vars),
    cr1, cr2, cr6
  ) %>% 
  mutate(
    across(
      c(all_of(dna)), ~recode(., `100` = 1))  # since w4 vars are mult. by 100
  ) %>% 
  recode_region() %>% 
  filter(region %in% c("Amhara", "Dire Dawa", "Harar", "Oromia", "SNNP", "Tigray"))


labs_dna <- ess4_hh_all %>% 
  select(all_of(dna_vars)) %>% 
  var_label() %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  )


dna_w4 <- bind_rows(
  mean_tbl(hh_dna_w4, dna_vars, group_vars = c("wave", "variable"), pw = pw_w4) %>% 
    mutate(region = "National"),
  mean_tbl(hh_dna_w4, dna_vars, group_vars = c("wave", "variable", "region"), pw = pw_w4) 
 ) %>% 
  filter(!variable %in% c("cr1", "cr2", "cr6")) %>% 
  left_join(labs_dna, by = "variable") %>% 
  mutate(wave = paste("Wave", wave)) %>% 
  select(wave, region, variable, label, mean, nobs) %>% 
  mutate(crop = case_match(
    variable,
    c("maize_cg", "dtmz", "qpm") ~ "Maize",
    "sorghum_cg" ~ "Sorghum", 
    "barley_cg" ~ "Barley"
  ))


crop_growing <- adopt_rate_dna_w4 %>% 
  filter(variable %in% c("cr1", "cr2", "cr6")) %>% 
  mutate(crop = case_match(
    variable,
    "cr2" ~ "Maize",
    "cr6" ~ "Sorghum", 
    "cr1" ~ "Barley"
  )) %>% 
  select(region, crop, growing_pct = mean) 

adopt_rate_dna_w4 <- dna_w4 %>% 
  left_join(crop_growing, by = c("region", "crop"))



write_csv(adopt_rate_dna_w4, file = "dynamics_presentation/data/adopt_rate_dna_w4.csv")






















