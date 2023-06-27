# Productive asset indices -------------

sect11_hh_w5 <- read_dta(file.path(root, "2_raw_data/data/HH", "sect11_hh_w5.dta"))

sect11_hh_w4 <- read_dta(file.path(root, "supplemental/replication_files/2_raw_data/ESS4_2018-19/Data", 
                                   "sect11_hh_w4.dta"))

track_hh <- read_dta(file.path(root, "tmp/dynamics/06_1_track_hh_pp.dta"))

tab_path <- "C:/Users/l.daba/SPIA Dropbox/Lemi Daba/Apps/Overleaf/ESS_adoption_matrices/tables"

prod_assets <- map(
  list(
    mutate(sect11_hh_w5, wave = "Wave 5"), 
    mutate(sect11_hh_w4, wave = "Wave 4")
  ),
  function (tbl) {
    tbl %>% 
      mutate(HHown_item = case_when(
        s11q00 == 2 ~ 0, is.na(s11q00) ~ 0, .default = as.numeric(s11q00))
      ) %>% 
      select(wave, household_id, asset_cd, HHown_item, starts_with("pw")) %>% 
      filter(asset_cd >= 29) %>% 
      mutate_if(is.labelled, as_factor)
    
  }
) %>% 
  bind_rows()

prod_assets_rural <- prod_assets %>% 
  # retain only rural households (vs. all hhs, i.e., urban included)
  inner_join( 
    select(track_hh, household_id, hh_status, pw_panel),
    by = "household_id"
  ) %>% 
  mutate(
    pw_wv = case_when(is.na(pw_w5) ~ pw_w4, is.na(pw_w4) ~ pw_w5),
    asset_cd = str_remove(asset_cd, "(^\\d+\\s+)")
  ) %>% 
  select(-pw_w4, -pw_w5) 

pset_tab_all <- prod_assets_rural %>% 
  group_by(wave, asset_cd) %>% 
  summarize(
    mean = weighted.mean(HHown_item, w = pw_wv, na.rm = T),
    n = sum(!is.na(HHown_item)),
    .groups = "drop"
  ) %>% 
  pivot_wider(names_from = wave, values_from = c(mean, n)) %>% 
  clean_names() %>% 
  select(asset_cd, mean_wave_4, n_wave_4, mean_wave_5, n_wave_5) %>% 
  mutate(across( starts_with("mean_wave"), ~round(. * 100, 2) ))

pset_tab_panel <- prod_assets_rural %>% 
  filter(hh_status==3) %>% 
  group_by(wave, asset_cd) %>% 
  summarize(
    mean = weighted.mean(HHown_item, w = pw_panel, na.rm = T),
    n = sum(!is.na(HHown_item)),
    .groups = "drop"
  ) %>% 
  pivot_wider(names_from = wave, values_from = c(mean, n)) %>% 
  clean_names() %>% 
  select(asset_cd, mean_wave_4, n_wave_4, mean_wave_5, n_wave_5) %>% 
  mutate(across( starts_with("mean_wave"), ~round(. * 100, 2) ))

kbl(
  pset_tab_all,
  format = "latex",
  caption = "Percentage of households with productive assets - all houesholds in both waves",
  booktabs = TRUE,
  linesep = "",
  align = c("l", "c", "c", "c"),
  col.names = c("Productive asset", "Mean (%)", "N", "Mean (%)", "N")
) %>% 
  add_header_above(c(" ", "Wave 4" = 2, "Wave 5" = 2)) %>% 
  # column_spec(2:7, width = "5em", latex_valign = "b") %>% 
  kable_styling(latex_options = c("striped", "hold_position")) %>% 
  save_kable(file.path(tab_path, "passet_tab_all.tex"))


kbl(
  pset_tab_panel,
  format = "latex",
  caption = "Percentage of households with productive assets - panel houesholds",
  booktabs = TRUE,
  linesep = "",
  align = c("l", "c", "c", "c"),
  col.names = c("Productive asset", "Mean (%)", "N", "Mean (%)", "N")
) %>% 
  add_header_above(c(" ", "Wave 4" = 2, "Wave 5" = 2)) %>% 
  # column_spec(2:7, width = "5em", latex_valign = "b") %>% 
  kable_styling(latex_options = c("striped", "hold_position")) %>% 
  save_kable(file.path(tab_path, "passet_tab_panel.tex"))