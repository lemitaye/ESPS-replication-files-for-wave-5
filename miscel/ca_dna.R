

# CA only among hhs with DNA data --------- #

# Depends on: 06_2_dynamics_adopt_rates.R

source("../1_code/06_2_dynamics_adopt_rates.R")


hh_panel_dna_w4 <- hh_panel_w4 %>% 
  semi_join(ess4_dna_hh_panel, by = "household_id") %>% 
  mutate(wave = paste("Wave", wave)) 

hh_panel_dna_w5 <- hh_panel_w5 %>% 
  semi_join(ess5_dna_hh_panel, by = "household_id") %>% 
  mutate(wave = paste("Wave", wave)) 

psnp_panel_dna_w4 <- psnp_w4_panel %>% 
  semi_join(ess4_dna_hh_panel, by = "household_id") 

psnp_panel_dna_w5 <- psnp_w5_panel %>% 
  semi_join(ess5_dna_hh_panel, by = "household_id")

national_hh_panel_dna <- bind_rows(
  mean_tbl(hh_panel_dna_w4, group_vars = c("wave", "variable"), pw = pw_panel),
  mean_tbl(hh_panel_dna_w5, group_vars = c("wave", "variable"), pw = pw_panel),
  mean_tbl(psnp_panel_dna_w4, vars = c("hhd_psnp", "hhd_psnp_dir", "hhd_psnp_any"), 
           group_vars = c("wave", "variable"), pw = pw_panel),
  mean_tbl(psnp_panel_dna_w5, vars = c("hhd_psnp", "hhd_psnp_dir", "hhd_psnp_any"), 
           group_vars = c("wave", "variable"), pw = pw_panel)
) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)  

regions_hh_panel_dna <- bind_rows(
  mean_tbl(hh_panel_dna_w4, group_vars = c("wave", "variable", "region"), pw = pw_panel),
  mean_tbl(hh_panel_dna_w5, group_vars = c("wave", "variable", "region"), pw = pw_panel),
  mean_tbl(psnp_panel_dna_w4, vars = c("hhd_psnp", "hhd_psnp_dir", "hhd_psnp_any"), 
           group_vars = c("wave", "variable", "region"), pw = pw_panel),
  mean_tbl(psnp_panel_dna_w5, vars = c("hhd_psnp", "hhd_psnp_dir", "hhd_psnp_any"), 
           group_vars = c("wave", "variable", "region"), pw = pw_panel)
) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)


adopt_rates_panel_hh_dna <- bind_rows(
  regions_hh_panel_dna, 
  national_hh_panel_dna %>% 
    mutate(region = "National")
) %>% 
  mutate(region = fct_relevel(
    region, 
    "Amhara", "Oromia", "SNNP", "Harar", "Dire Dawa", "National"
  ))


adopt_rates_panel_hh_dna %>% 
  filter(variable %in% c("hhd_consag1"), region != "Tigray") %>% 
  plot_waves() +
  expand_limits(y = .7) +
  labs(title = "Conservation Agriculture with Minimum Tillage",
       subtitle = "Panel DNA sample only")

adopt_rates_panel_hh_dna %>% 
  filter(variable %in% c("hhd_consag2"), region != "Tigray") %>% 
  plot_waves() +
  expand_limits(y = .025) +
  labs(title = "Conservation Agriculture with Zero Tillage",
       subtitle = "Panel DNA sample only")

adopt_rates_panel_hh_dna %>% 
  filter(variable %in% c("hhd_psnp_any"), region != "Tigray") %>% 
  plot_waves() +
  expand_limits(y = .025) +
  labs(title = "PSNP - both temporary labor and direct assistance",
       subtitle = "Panel DNA sample only")


