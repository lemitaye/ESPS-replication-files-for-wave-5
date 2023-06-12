
# ----- #
# Purpose: to create data on adoption rates of innovations only in wave 5
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

wave5_hh <- read_dta(file.path(root, "3_report_data/wave5_hh_new.dta"))

ess5_bounds <- read_dta(file.path(root, "tmp/dynamics/ess5_bounds.dta"))

dna_means_hh <- read_csv("dynamics_presentation/data/dna_means_hh.csv")




# psnp data (generated in 03_new_innov_ess5.R)
psnp_hh <- read_csv("dynamics_presentation/data/psnp_hh.csv")


recode_region <- function(tbl, region_var = region) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(
          {{region_var}}, 
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

innovs_w5 <- c(
  # animal agriculture:
  "hhd_livIA", "hhd_cross_largerum", "hhd_cross_smallrum", "hhd_cross_poultry",
  
  # forages:
  "hhd_agroind", "hhd_elepgrass", "hhd_deshograss", "hhd_sesbaniya", "hhd_sinar", 
  "hhd_lablab", "hhd_alfalfa", "hhd_vetch", "hhd_rhodesgrass", "hhd_grass",
  
  # crop-germplasm improvment:
  "maize_cg", "dtmz", "hhd_ofsp", "hhd_awassa83", "hhd_kabuli", 
  
  # Natural resoruce management:
  "hhd_rdisp", "hhd_motorpump", "hhd_swc", "hhd_consag1", "hhd_consag2", "hhd_affor", 
  "hhd_mango", "hhd_papaya", "hhd_avocado"
  )



# ALL HOUSEHOLDS ----

hh_level_w5 <- wave5_hh %>% 
  select(
    household_id, ea_id, wave, region = saq01, starts_with("pw_"), all_of(innovs_w5)
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

means_hh_w5 <- bind_rows(
  mean_tbl(hh_level_w5, innovs_w5, group_vars = c("wave", "variable", "region"), pw = pw_w5),
  mean_tbl(hh_level_w5, innovs_w5, group_vars = c("wave", "variable"), pw = pw_w5) %>% 
    mutate(region = "National")
) %>% 
  mutate(wave = paste("Wave", wave))


# 
labs <- wave5_hh %>% 
  select(all_of(innovs_w5)) %>% 
  var_label() %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  )

# modify PSNP
psnp_w5_rur <- psnp_hh %>% 
  filter(
    wave == "Wave 5", locality == "Rural",
    sample == "All", region != "Addis Ababa"
  ) %>% 
  select(wave, variable, region, mean, nobs, label)


# create final tibble:
adopt_rates_w5_hh <- means_hh_w5  %>% 
  left_join(labs, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs) %>% 
  bind_rows(psnp_w5_rur)

write_csv(adopt_rates_w5_hh, file = "dynamics_presentation/data/adopt_rates_w5_hh.csv")



# DNA in wave 5 -------

maize_growing <- wave5_hh_new %>% 
  recode_region(saq01) %>% 
  filter(!is.na(region)) %>% 
  group_by(region) %>% 
  summarise(growing_pct = weighted.mean(cr2, pw = pw_w5)) %>% 
  bind_rows(data.frame(
    region = "National",
    growing_pct = weighted.mean(wave5_hh_new$cr2, pw = pw_w5)
  ))

adopt_rate_dna_w5 <- dna_means_hh %>% 
  filter(wave == "Wave 5", sample == "All households/EA") %>% 
  left_join(maize_growing, by = "region")


write_csv(adopt_rate_dna_w5, file = "dynamics_presentation/data/adopt_rate_dna_w5.csv")



# Upper and lower bound estimates -----------

## Wave 4 ---------

no_dna_reg <- c("Afar", "Benishangul Gumuz", "Gambela", "Somali")

bounds_w5 <- ess5_bounds %>% 
  recode_region(saq01) %>% 
  group_by(region) %>% 
  summarise(
    across(c(starts_with(c("ubound", "lbound")), cr2), ~weighted.mean(., w = pw_w5, na.rm = T))
  ) %>% 
  mutate(across(-region, ~replace_na(., 0))) %>% 
  rename(maize_pct = cr2)

# calculate means
bd_mean_w5 <- bounds_w5 %>% 
  mutate(
    maize_pct = if_else(region %in% no_dna_reg, 0, maize_pct)
  ) %>% 
  mutate(
    mean_ub1 = ( ubound1a * maize_pct ) + ( ubound1b * (1 - maize_pct) ),
    mean_ub2 = ( ubound2a * maize_pct ) + ( ubound2b * (1 - maize_pct) ),
    mean_lb = ( lbound1a * maize_pct ) + ( lbound1b * (1 - maize_pct) ),
  ) %>% 
  select(region, starts_with("mean")) 


# save
write_csv(bd_mean_w5, file = "dynamics_presentation/data/bd_mean_w5.csv")


