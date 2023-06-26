

# Depends on: fig_hh.R

###############################################################################*
# New innovations incorporated in ESPS5 ####
###############################################################################*

w5_hh_new <- wave5_hh_new %>% 
  select(
    household_id, region, pw_w5, all_of(vars_w5)
  ) %>% 
  recode_region() %>% 
  pivot_longer(all_of(vars_w5), 
               names_to = "variable",
               values_to = "value") 

w5_means_new <- left_join(
  x = bind_rows(
    w5_hh_new %>% 
      group_by(region, variable) %>% 
      summarise(
        mean = weighted.mean(value, w = pw_w5, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      ),
    w5_hh_new %>% 
      group_by(variable) %>% 
      summarise(
        mean = weighted.mean(value, w = pw_w5, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      ) %>% 
      mutate(region = "National")
  ),
  
  y = var_label(select(wave5_hh_new, all_of(vars_w5))) %>% 
    as_tibble() %>% 
    pivot_longer(
      cols = everything(), 
      names_to = "variable", 
      values_to = "label"
    ),
  by = "variable"
)


new_innov <- w5_means_new %>% 
  filter(variable != "hhd_kabuli",
         !str_detect(label, "Feed and Forage")) %>% 
  mutate(region = fct_relevel(region, "Amhara", "Oromia", "SNNP", "Other regions", "National")) %>% 
  ggplot(aes(region, mean, fill = region)) +
  geom_col() +
  geom_text(aes(label = paste0(round(mean*100, 2), " %")),
            vjust = -.5, size = 2.5) +
  facet_wrap(~ label, scales = "free", nrow = 4) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  theme(legend.position = "none") +
  labs(y = "Percent of households adopting", 
       x = "",
       title = "Adoption of innovations incorporated only in ESPS5")

ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/new_innov.pdf"),
  plot = new_innov,
  device = cairo_pdf,
  width = 200,
  height = 285,
  units = "mm"
)  



# panel dna households:
inner_join(
  ess4_dna_hh_new,
  ess5_dna_hh_new,
  by = "household_id",
  suffix = c("_w4", "_w5")
)


# Synergies: comparing joint adoption rates

synergies_hh_ess5_new <- read_dta(file.path(root, w5_dir, "synergies_hh_ess5_new.dta"))

synergies_hh_ess4_new <- read_dta(file.path(root, w4_dir, "synergies_hh_ess4_new.dta"))

# Maize - DNA data

synergies_dna_hh_ess4 <- read_dta(file.path(root, w4_dir, "synergies_dna_hh_ess4.dta")) %>% 
  filter(!is.na(maize_cg))   # filter maize only

synergies_dna_hh_ess5 <- read_dta(file.path(root, w5_dir, "synergies_dna_hh_ess5.dta"))


vars <- unique(c(
  "nrm", "ca", "nrm_ca", "nrm", "ca1", "nrm_ca1", "nrm", "ca2", "nrm_ca2", "nrm", "ca3", 
  "nrm_ca3", "nrm", "ca4", "nrm_ca4", "nrm", "ca5", "nrm_ca5", "nrm", "crop", "nrm_crop", 
  "nrm", "tree", "nrm_tree", "nrm", "animal", "nrm_animal", "nrm", "breed", "nrm_breed", 
  "nrm", "breed2", "nrm_breed2", "nrm", "psnp", "nrm_psnp", "nrm", "rotlegume", "nrm_rotlegume", 
  "nrm", "cresidue", "nrm_cresidue", "nrm", "mintillage", "nrm_mintillage", "nrm", "zerotill", 
  "nrm_zerotill", "ca", "crop", "ca_crop", "ca", "tree", "ca_tree", "ca", "animal", "ca_animal", 
  "ca", "breed", "ca_breed", "ca", "breed2", "ca_breed2", "ca", "psnp", "ca_psnp", "crop", "tree", 
  "crop_tree", "crop", "animal", "crop_animal", "crop", "breed", "crop_breed", "crop", "breed2", 
  "crop_breed2", "crop", "psnp", "crop_psnp", "crop", "rotlegume", "crop_rotlegume", "crop", "cresidue", 
  "crop_cresidue", "crop", "mintillage", "crop_mintillage", "crop", "zerotill", "crop_zerotill", 
  "crop", "ca1", "crop_ca1", "crop", "ca2", "crop_ca2", "crop", "ca3", "crop_ca3", "crop", "ca4", 
  "crop_ca4", "crop", "ca5", "crop_ca5", "tree", "animal", "tree_animal", "tree", "breed", "tree_breed", 
  "tree", "breed2", "tree_breed2", "tree", "psnp", "tree_psnp", "tree", "rotlegume", "tree_rotlegume", 
  "tree", "cresidue", "tree_cresidue", "tree", "mintillage", "tree_mintillage", "tree", "zerotill", 
  "tree_zerotill", "tree", "ca1", "tree_ca1", "tree", "ca2", "tree_ca2", "tree", "ca3", "tree_ca3", 
  "tree", "ca4", "tree_ca4", "tree", "ca5", "tree_ca5", "animal", "breed", "animal_breed", "animal", 
  "breed2", "animal_breed2", "animal", "psnp", "animal_psnp", "animal", "rotlegume", "animal_rotlegume", 
  "animal", "cresidue", "animal_cresidue", "animal", "mintillage", "animal_mintillage", "animal", "zerotill", 
  "animal_zerotill", "animal", "ca1", "animal_ca1", "animal", "ca2", "animal_ca2", "animal", "ca3", "animal_ca3", 
  "animal", "ca4", "animal_ca4", "animal", "ca5", "animal_ca5", "breed", "psnp", "breed_psnp", "breed", "rotlegume", 
  "breed_rotlegume", "breed", "cresidue", "breed_cresidue", "breed", "mintillage", "breed_mintillage", "breed", 
  "zerotill", "breed_zerotill", "breed", "ca1", "breed_ca1", "breed", "ca2", "breed_ca2", "breed", "ca3", "breed_ca3", 
  "breed", "ca4", "breed_ca4", "breed", "ca5", "breed_ca5", "breed2", "psnp", "breed2_psnp", "breed2", "rotlegume", 
  "breed2_rotlegume", "breed2", "cresidue", "breed2_cresidue", "breed2", "mintillage", "breed2_mintillage", "breed2", 
  "zerotill", "breed2_zerotill", "breed2", "ca1", "breed2_ca1", "breed2", "ca2", "breed2_ca2", "breed2", "ca3", 
  "breed2_ca3", "breed2", "ca4", "breed2_ca4", "breed2", "ca5", "breed2_ca5", "psnp", "rotlegume", "psnp_rotlegume", 
  "psnp", "cresidue", "psnp_cresidue", "psnp", "mintillage", "psnp_mintillage", "psnp", "zerotill", "psnp_zerotill", 
  "psnp", "ca1", "psnp_ca1", "psnp", "ca2", "psnp_ca2", "psnp", "ca3", "psnp_ca3", "psnp", "ca4", "psnp_ca4", "psnp", 
  "ca5", "psnp_ca5", "rotlegume", "cresidue", "rotlegume_cresidue", "rotlegume", "mintillage", "rotlegume_mintillage", 
  "rotlegume", "zerotill", "rotlegume_zerotill", "cresidue", "mintillage", "cresidue_mintillage", "cresidue", "zerotill", 
  "cresidue_zerotill"
))


vars_joint <- vars[str_detect(vars, "_")]

vars_maize <- c(
  "nrm_maize", "ca_maize", "crop_maize", "tree_maize", "animal_maize", "breed_maize", "breed2_maize",
  "psnp_maize", "rotlegume_maize", "cresidue_maize", "mintillage_maize", "zerotill_maize"
)

lbl_vars <- c(
  var_label(select(synergies_hh_ess5_new, all_of(vars_joint))), 
  var_label(select(synergies_dna_hh_ess5, all_of(vars_maize)))
) %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  ) %>% 
  mutate(label = str_replace(label, " - ", " & "))

joint_rate <- function(tbl, pw, vars, wave_no) {
  tbl %>% 
    summarise(
      across(all_of(vars), ~weighted.mean(., w={{pw}}, na.rm = TRUE))
    ) %>% 
    mutate(wave = wave_no) %>% 
    pivot_longer(cols = -wave, names_to = "variable", values_to = "joint_rate")
  
}

joint_rate_tbl <- bind_rows(
  joint_rate(synergies_hh_ess5_new, pw_w5, vars_joint, "Wave 5"),
  joint_rate(synergies_hh_ess4_new, pw_w4, vars_joint, "Wave 4"),
  joint_rate(synergies_dna_hh_ess5, pw_w5, vars_maize, "Wave 5"),
  joint_rate(synergies_dna_hh_ess4, pw_w4, vars_maize, "Wave 4")
) %>%
  left_join(lbl_vars, by = "variable") %>%
  filter(complete.cases(.)) %>%
  filter(!str_detect(label, "CA1|CA2|CA3|CA4|CA5")) %>%
  mutate(
    label = str_replace(label, "Maize - CG germplasm", "Maize-CG"),
    label = str_replace(label, "Feed and Forages", "Forages"),
    label = str_trim(label)
  )


# only panel households

synergies_hh_ess5_panel <- semi_join(
  x = synergies_hh_ess5_new,
  y = synergies_hh_ess4_new,
  by = "household_id"
)

synergies_hh_ess4_panel <- semi_join(
  x = synergies_hh_ess4_new,
  y = synergies_hh_ess5_new,
  by = "household_id"
)

synergies_dna_hh_ess5_panel <- semi_join(
  x = synergies_dna_hh_ess5,
  y = synergies_dna_hh_ess4,
  by = "household_id"
)

synergies_dna_hh_ess4_panel <- semi_join(
  x = synergies_dna_hh_ess4,
  y = synergies_dna_hh_ess5,
  by = "household_id"
)


joint_rate_tbl_panel <- bind_rows(
  joint_rate(synergies_hh_ess5_panel, pw_w5, vars_joint, "Wave 5"),
  joint_rate(synergies_hh_ess4_panel, pw_w4, vars_joint, "Wave 4"),
  joint_rate(synergies_dna_hh_ess5_panel, pw_w5, vars_maize, "Wave 5"),
  joint_rate(synergies_dna_hh_ess4_panel, pw_w4, vars_maize, "Wave 4")
) %>%
  left_join(lbl_vars, by = "variable") %>%
  filter(complete.cases(.)) %>%
  filter(!str_detect(label, "CA1|CA2|CA3|CA4|CA5")) %>%
  mutate(
    label = str_replace(label, "Maize - CG germplasm", "Maize-CG"),
    label = str_replace(label, "Feed and Forages", "Forages"),
    label = str_trim(label)
  )



# CA only among hhs with DNA data ----------


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








