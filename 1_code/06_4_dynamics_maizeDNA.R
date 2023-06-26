

# Comparing crop-germplasm improvements -----

recode_region_dna <- function(tbl, region_var = region) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(
          {{region_var}}, 
          `1` = "Tigray",
          `3` = "Amhara",
          `4` = "Oromia",
          `7` = "SNNP",
          `13` = "Harar",
          `15` = "Dire Dawa"
        )
      )
  )
  
}

ess4_dna_hh_new <- read_dta(file.path(root, w4_dir, "ess4_dna_hh_new.dta")) %>% 
  filter(!is.na(maize_cg), !is.na(dtmz)) %>%  # retain only maize
  dplyr::select(-c(barley_cg, sorghum_cg)) %>% 
  recode_region_dna(saq01)


ess5_dna_hh_new <- read_dta(file.path(root, w5_dir, "03_5_ess5_dna_hh.dta")) %>% 
  recode_region_dna()

ess5_weights_hh <- read_dta(file.path(root, "2_raw_data/data/HH/ESS5_weights_hh.dta"))

summarize_dna_hh <- function(tbl, pw) {
  tbl %>% 
    summarise(
      hhd_maize_cg = weighted.mean(maize_cg, w = {{pw}}, na.rm = TRUE),
      hhd_dtmz = weighted.mean(dtmz, w = {{pw}}, na.rm = TRUE),
      nobs = sum(!is.na(maize_cg))
    )
}


dna_means_hh_all <- bind_rows(
  ess4_dna_hh_new %>% 
    group_by(region) %>% 
    summarize_dna_hh(pw = pw_w4) %>% 
    mutate(wave = "Wave 4"),
  
  ess4_dna_hh_new %>% 
    summarize_dna_hh(pw = pw_w4) %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  ess5_dna_hh_new %>% 
    group_by(region) %>% 
    summarize_dna_hh(pw = pw_w5) %>%
    mutate(wave = "Wave 5"),
  
  ess5_dna_hh_new %>% 
    summarize_dna_hh(pw = pw_w5) %>% 
    mutate(region = "National", wave = "Wave 5")
  
) %>% 
  pivot_longer(c("hhd_maize_cg", "hhd_dtmz"),
               names_to = "variable",
               values_to = "mean") %>% 
  mutate(region = fct_relevel(
    region, 
    "Tigray", "Amhara", "Oromia", "SNNP", "Harar", "Dire Dawa", "National"
  ))


# panel hhs only 

ess4_dna_hh_panel <- ess4_dna_hh_new %>% 
  semi_join(ess5_dna_hh_new,
            by = "household_id") %>% 
  left_join(dplyr::select(ess5_weights_hh, household_id, pw_panel),
            by = "household_id")

ess5_dna_hh_panel <- ess5_dna_hh_new %>% 
  semi_join(ess4_dna_hh_new,
            by = "household_id") %>% 
  left_join(dplyr::select(ess5_weights_hh, household_id, pw_panel),
            by = "household_id")

dna_means_hh_panel <- bind_rows(
  ess4_dna_hh_panel %>% 
    group_by(region) %>% 
    summarize_dna_hh(pw = pw_panel) %>% 
    mutate(wave = "Wave 4"),
  
  ess4_dna_hh_panel %>% 
    summarize_dna_hh(pw = pw_panel) %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  ess5_dna_hh_panel %>% 
    group_by(region) %>% 
    summarize_dna_hh(pw = pw_panel) %>%
    mutate(wave = "Wave 5"),
  
  ess5_dna_hh_panel %>% 
    summarize_dna_hh(pw = pw_panel) %>% 
    mutate(region = "National", wave = "Wave 5")
  
) %>% 
  pivot_longer(c("hhd_maize_cg", "hhd_dtmz"),
               names_to = "variable",
               values_to = "mean") %>% 
  mutate(region = fct_relevel(
    region, 
    "Amhara", "Oromia", "SNNP", "Harar", "Dire Dawa", "National"
  ))

dna_means_hh <- bind_rows(
  dna_means_hh_all %>% 
    mutate(sample = "All households/EA", level = "Household"),
  dna_means_hh_panel %>% 
    mutate(sample = "Panel households/EA", level = "Household")
) %>% 
  mutate(label = case_when(
    variable == "hhd_maize_cg" ~ "Maize - CG germplasm (DNA data)",
    variable == "hhd_dtmz" ~ "Drought tolerant maize (DNA data)"
  )
  )

write_csv(dna_means_hh, "dynamics_presentation/data/dna_means_hh.csv")



# EA level

ess4_dna_ea_all <- ess4_dna_hh_new %>% 
  group_by(region, ea_id) %>% 
  summarise(
    ead_maize_cg = max(maize_cg, na.rm = T),
    ead_dtmz = max(dtmz, na.rm = T),
    .groups = "drop"
    )

ess5_dna_ea_all <- ess5_dna_hh_new %>% 
  group_by(region, ea_id) %>% 
  summarise(
    ead_maize_cg = max(maize_cg, na.rm = T),
    ead_dtmz = max(dtmz, na.rm = T),
    .groups = "drop"
  )

summarize_dna_ea <- function(tbl) {
  tbl %>% 
    summarise(
      ead_maize_cg = mean(ead_maize_cg, na.rm = TRUE),
      ead_dtmz = mean(ead_dtmz, na.rm = TRUE),
      nobs = n()
    )
}
  
dna_means_ea_all <- bind_rows(
  ess4_dna_ea_all %>% 
    group_by(region) %>% 
    summarize_dna_ea() %>% 
    mutate(wave = "Wave 4"),
  
  ess4_dna_ea_all %>% 
    summarize_dna_ea() %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  ess5_dna_ea_all %>% 
    group_by(region) %>% 
    summarize_dna_ea() %>%
    mutate(wave = "Wave 5"),
  
  ess5_dna_ea_all %>% 
    summarize_dna_ea() %>% 
    mutate(region = "National", wave = "Wave 5")
  
) %>% 
  pivot_longer(c("ead_maize_cg", "ead_dtmz"),
               names_to = "variable",
               values_to = "mean")


ess4_dna_ea_panel <- ess4_dna_hh_panel %>% 
  group_by(region, ea_id) %>% 
  summarise(
    ead_maize_cg = max(maize_cg, na.rm = T),
    ead_dtmz = max(dtmz, na.rm = T),
    .groups = "drop"
  )

ess5_dna_ea_panel <- ess5_dna_hh_panel %>% 
  group_by(region, ea_id) %>% 
  summarise(
    ead_maize_cg = max(maize_cg, na.rm = T),
    ead_dtmz = max(dtmz, na.rm = T),
    .groups = "drop"
  )

dna_means_ea_panel <- bind_rows(
  ess4_dna_ea_panel %>% 
    group_by(region) %>% 
    summarize_dna_ea() %>% 
    mutate(wave = "Wave 4"),
  
  ess4_dna_ea_panel %>% 
    summarize_dna_ea() %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  ess5_dna_ea_panel %>% 
    group_by(region) %>% 
    summarize_dna_ea() %>%
    mutate(wave = "Wave 5"),
  
  ess5_dna_ea_panel %>% 
    summarize_dna_ea() %>% 
    mutate(region = "National", wave = "Wave 5")
  
) %>% 
  pivot_longer(c("ead_maize_cg", "ead_dtmz"),
               names_to = "variable",
               values_to = "mean")

dna_means_ea <- bind_rows(
  dna_means_ea_all %>% 
    mutate(sample = "All households/EA", level = "EA"),
  dna_means_ea_panel %>% 
    mutate(sample = "Panel households/EA", level = "EA")
) %>% 
  mutate(label = case_when(
    variable == "ead_maize_cg" ~ "Maize - CG germplasm (DNA data)",
    variable == "ead_dtmz" ~ "Drought tolerant maize (DNA data)"
  )
  )


write_csv(dna_means_ea, "dynamics_presentation/data/dna_means_ea.csv")