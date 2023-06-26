
# PSNP: Special edition ----


ess4_hh_psnp <- read_dta(file.path(root, w4_dir, "ess4_hh_psnp.dta"))

sect14_hh_w4 <- read_dta(file.path(root, 
                                   "supplemental/replication_files/2_raw_data/ESS4_2018-19/Data/sect14_hh_w4.dta"))

ess5_hh_psnp <- read_dta(file.path(root, w5_dir, "ess5_hh_psnp.dta")) %>% 
  mutate(wave = "Wave 5")

recode_all_regions <- function(tbl, var) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = case_match(
          {{var}}, 
          1 ~ "Tigray",
          2 ~ "Afar",
          3 ~ "Amhara",
          4 ~ "Oromia",
          5 ~ "Somali",
          6 ~ "Benishangul Gumuz",
          7 ~ "SNNP",
          12 ~ "Gambela",
          13 ~ "Harar",
          14 ~ "Addis Ababa",
          15 ~ "Dire Dawa"
        )
      )
  )
  
}

relevel_region <- function(tbl) {
  tbl %>% 
    mutate(    
      region = fct_relevel(
        region, 
        "Tigray", "Afar", "Amhara", "Oromia", "Somali", "Benishangul Gumuz", 
        "SNNP", "Gambela", "Harar", "Addis Ababa", "Dire Dawa", "National")
    ) %>% 
    suppressWarnings()
}

psnp_w4_dir <- sect14_hh_w4 %>% 
  filter(assistance_cd==1) %>% 
  mutate(hhd_psnp_dir = case_when(
    s14q01==2 ~ 0, s14q01==1 ~ 1
  )) %>% 
  select(household_id, hhd_psnp_dir)

psnp_w4 <- ess4_hh_psnp %>% 
  left_join(psnp_w4_dir, by = "household_id") %>% 
  mutate(
    wave = "Wave 4",
    locality = recode(saq14, `1` = "Rural", `2` = "Urban"),
    hhd_psnp_any = case_when(
      (hhd_psnp==1 | hhd_psnp_dir==1) ~ 1,
      TRUE ~ 0
    )
  ) %>% 
  recode_all_regions(saq01) %>% 
  select(household_id, ea_id, pw_w4, locality, hhd_psnp, hhd_psnp_dir, hhd_psnp_any, region, wave)

psnp_w5 <- ess5_hh_psnp %>% 
  mutate(
    wave = "Wave 5",
    locality = recode(saq14, `1` = "Rural", `2` = "Urban"),
    hhd_psnp_any = case_when(
      (hhd_psnp==1 | hhd_psnp_dir==1) ~ 1,
      TRUE ~ 0
    )
  ) %>% 
  recode_all_regions(saq01) %>% 
  select(household_id, ea_id, pw_w5, locality, hhd_psnp, hhd_psnp_dir, hhd_psnp_any, region, wave) 



summ_psnp <- function(tbl, locality, ...) {
  
  if (locality) {
    grp_vars_reg <- c("wave", "variable", "region", "locality")
    grp_vars_nat <- c("wave", "variable", "locality")
  } else {
    grp_vars_reg <- c("wave", "variable", "region")
    grp_vars_nat <- c("wave", "variable")
  }
  
  mean_bind_tbl <- bind_rows(
    
    mean_tbl(tbl, c("hhd_psnp", "hhd_psnp_dir", "hhd_psnp_any"), 
             group_vars = grp_vars_reg, pw = ...),
    
    mean_tbl(tbl, c("hhd_psnp", "hhd_psnp_dir", "hhd_psnp_any"), 
             group_vars = grp_vars_nat, pw = ...) %>% 
      mutate(region = "National")
    
  )
  
  return(mean_bind_tbl)
  
}

## Household level ----

### All households ----


psnp_all_agg <- bind_rows(
  summ_psnp(psnp_w4, locality = FALSE, pw_w4),
  summ_psnp(psnp_w5, locality = FALSE, pw_w5)
) %>% 
  relevel_region()

psnp_all_local <- bind_rows(
  summ_psnp(psnp_w4, locality = TRUE, pw_w4),
  summ_psnp(psnp_w5, locality = TRUE, pw_w5)
) %>% 
  relevel_region()


### Panel households ----


ess5_weights_hh <- read_dta(file.path(root, "2_raw_data/data/HH/ESS5_weights_hh.dta"))

psnp_w4_panel <- psnp_w4 %>% 
  semi_join(psnp_w5, by = "household_id") %>% 
  left_join(select(ess5_weights_hh, household_id, pw_panel), 
            by = "household_id")

psnp_w5_panel <- psnp_w5 %>% 
  semi_join(psnp_w4, by = "household_id") %>% 
  left_join(select(ess5_weights_hh, household_id, pw_panel), 
            by = "household_id")


psnp_panel_agg <- bind_rows(
  summ_psnp(psnp_w4_panel, locality = FALSE, pw_w4),
  summ_psnp(psnp_w5_panel, locality = FALSE, pw_w5)
) %>% 
  relevel_region()


psnp_panel_local <- bind_rows(
  summ_psnp(psnp_w4_panel, locality = TRUE, pw_w4),
  summ_psnp(psnp_w5_panel, locality = TRUE, pw_w5)
) %>% 
  relevel_region()


psnp_hh <- bind_rows(
  psnp_all_agg %>% 
    mutate(locality = "Aggregate", sample = "All"), 
  psnp_all_local %>% 
    mutate(sample = "All"),
  psnp_panel_agg %>% 
    mutate(locality = "Aggregate", sample = "Panel"), 
  psnp_panel_local %>% 
    mutate(sample = "Panel")
) %>% 
  mutate(
    label = case_when(
      variable == "hhd_psnp"     ~ "PSNP (Temporary labor)",
      variable == "hhd_psnp_dir" ~ "PSNP (Direct support)",
      variable == "hhd_psnp_any" ~ "PSNP (Direct support + Temporary labor)"
    )
  )

write_csv(psnp_hh, file = "dynamics_presentation/data/psnp_hh.csv")


## EA level ----

collapse_ea_psnp <- function(tbl, group_vars = c("variable", "region")) {
  
  tbl %>% 
    summarise(
      # n = n(),
      across(
        -any_of(c("household_id", "ea_id", "wave", "region", "locality", "pw_w4", "pw_w5", "pw_panel")), 
        ~max(.x, na.rm = TRUE) ),
      .groups = "drop"
    ) %>% 
    suppressWarnings() %>% 
    modify(~ifelse(is.infinite(.), 0, .)) %>% 
    rename_with(~str_replace(., "hhd_", "ead_"), starts_with("hhd_")) %>% 
    pivot_longer(
      -any_of(c("household_id", "ea_id", "wave", "region", "locality", "pw_w4", "pw_w5", "pw_panel")), 
      names_to = "variable", values_to = "value") %>% 
    group_by(pick(group_vars)) %>% 
    summarise(
      mean = mean(value, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    )
  
}

psnp_w4 %>% 
  group_by(ea_id, loca) %>% 
  collapse_ea_psnp(group_vars = c("variable", "locality"))

nsumm_by_ea_psnp <- function(tbl, name, ...) {
  
  bind_rows(
    
    tbl %>% 
      group_by(ea_id) %>% 
      collapse_ea(group_vars = c("variable", "locality")) %>% 
      mutate(region = "National", wave = name),
    
    tbl %>% 
      group_by(ea_id, region) %>% 
      collapse_ea(group_vars = c("variable", "region", "locality")) %>% 
      mutate(wave = name)
    
  )
}

### All EAs ----

wave_lab <- c("Wave 4", "Wave 5")

psnp_all_rural <- map(list(psnp_w4, psnp_w5), 
                      ~filter(., locality=="Rural") %>% select(-locality))

psnp_ea_all_rural <- map2(psnp_all_rural, wave_lab, summ_by_ea) %>% 
  bind_rows()



### Panel EAs ----


psnp_panel_rural <- map(list(psnp_w4_panel, psnp_w5_panel), 
                        ~filter(., locality=="Rural") %>% select(-locality))

psnp_ea_panel_rural <- map2(psnp_panel_rural, wave_lab, summ_by_ea) %>% 
  bind_rows()


psnp_ea_rural <- bind_rows(
  psnp_ea_all_rural %>% 
    mutate(locality = "Rural", sample = "All"), 
  psnp_ea_panel_rural %>% 
    mutate(locality = "Rural", sample = "Panel")
) %>% 
  mutate(label = "PSNP (Direct support + Temporary labor)")

write_csv(psnp_ea_rural, file = "dynamics_presentation/data/psnp_ea_rural.csv")


