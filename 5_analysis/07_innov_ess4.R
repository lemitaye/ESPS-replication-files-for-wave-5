
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


# some cleaning ----
wave4_hh_new <- wave4_hh %>% 
  rename(hhd_sesbaniya = hhd_sasbaniya, hhd_alfalfa = hhd_alfa) %>% 
  mutate(hhd_grass = case_when(
    hhd_elepgrass==100 | hhd_sesbaniya==100 | hhd_alfalfa==100 ~ 1,
    hhd_elepgrass==0 & hhd_sesbaniya==0 & hhd_alfalfa==0 ~ 0 
  )) %>% 
  left_join(select(ess4_hh_psnp, household_id, hhd_psnp), by = "household_id")

wave5_hh_new <- wave5_hh %>% 
  mutate(hhd_grass = case_when(
    hhd_elepgrass==1 | hhd_sesbaniya==1 | hhd_alfalfa==1 ~ 1,
    hhd_elepgrass==0 & hhd_sesbaniya==0 & hhd_alfalfa==0 ~ 0 
  )) 


vars_all <- c(
  "hhd_ofsp", "hhd_awassa83", "hhd_kabuli", "hhd_desi", "hhd_rdisp", "hhd_motorpump", 
  "hhd_swc", "hhd_consag1", "hhd_consag2", "hhd_affor", "hhd_mango", 
  "hhd_papaya", "hhd_avocado", "hotline", "hhd_malt", "hhd_durum", 
  "hhd_seedv1", "hhd_seedv2", "hhd_livIA", "hhd_livIA_publ", 
  "hhd_livIA_priv", "hhd_grass", "hhd_elepgrass", "hhd_sesbaniya", "hhd_alfalfa",
  "hhd_mintillage", "hhd_zerotill", "hhd_cresidue2", "hhd_rotlegume", "hhd_psnp", 
  "hhd_impcr1", "hhd_impcr2", "hhd_impcr6", "hhd_impcr8"
)


vars_both <- wave4_hh_new %>% 
  select(any_of(vars_all)) %>% 
  colnames()

vars_w5 <- setdiff(vars_all, vars_both)

vars_urban_hhs <- c("hhd_cross_largerum", "hhd_cross_smallrum", "hhd_cross_poultry")



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


# ALL HOUSEHOLDS ----

hh_level_w4 <- wave4_hh_new %>% 
  select(household_id, ea_id, wave, region = saq01, pw_w4, all_of(vars_both)) %>% 
  mutate(
    across(
      c(all_of(vars_both)), ~recode(., `100` = 1))  # since w4 vars are mult. by 100
  ) %>% 
  recode_region()

hh_level_w5 <- wave5_hh_new %>% 
  select(household_id, ea_id, wave, region = saq01, pw_w5, pw_panel, all_of(vars_both)) %>% 
  recode_region()