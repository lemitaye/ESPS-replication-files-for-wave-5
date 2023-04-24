

# Depends on: fig_hh.R

###############################################################################*
# New innovations incorporated in ESPS5 ####
###############################################################################*

w5_hh_new <- wave5_8hh_new %>% 
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


###############################################################################*
# Comparison for Chickpea Kabuli only (against wave 3) ####
###############################################################################*

wave3_hh <- read_dta(file.path(root, w4_dir, "wave3_hh.dta"))
wave3_ea <- read_dta(file.path(root, w4_dir, "wave3_ea.dta"))

wave5_ea_new <- read_dta(file.path(root, w5_dir, "wave5_ea_new.dta"))


chickpea_tbl <- function(tbl, kab_var, desi_var, pw, hh = TRUE) {
  
  if (hh) {
    bind_rows(
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        group_by(region) %>% 
        summarise(
          mean_kabuli = weighted.mean({{kab_var}}, w = {{pw}}, na.rm = TRUE),
          mean_desi = weighted.mean({{desi_var}}, w = {{pw}}, na.rm = TRUE),
          mean_chickpea = weighted.mean(chickpea, w = {{pw}}, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ),
      
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        summarise(
          mean_kabuli = weighted.mean({{kab_var}}, w = {{pw}}, na.rm = TRUE),
          mean_desi = weighted.mean({{desi_var}}, w = {{pw}}, na.rm = TRUE),
          mean_chickpea = weighted.mean(chickpea, w = {{pw}}, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ) %>% 
        mutate(region = "National")
    )
  } else {
    bind_rows(
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        group_by(region) %>% 
        summarise(
          mean_kabuli = mean({{kab_var}}, na.rm = TRUE),
          mean_desi = mean({{desi_var}}, na.rm = TRUE),
          mean_chickpea = mean(chickpea, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ),
      
      tbl %>% 
        mutate(chickpea = pmax({{kab_var}}, {{desi_var}}, na.rm = TRUE)) %>% 
        summarise(
          mean_kabuli = mean({{kab_var}}, na.rm = TRUE),
          mean_desi = mean({{desi_var}}, na.rm = TRUE),
          mean_chickpea = mean(chickpea, na.rm = TRUE),
          nobs = sum(!is.na(chickpea)),
          .groups = "drop"
        ) %>% 
        mutate(region = "National")
    )
  }
  
}




mean_kabuli_w3_hh <- wave3_hh %>% 
  recode_region() %>% 
  chickpea_tbl(hhd_kabuli_r, hhd_desi_r, pw_w3) %>% 
  mutate(across(c(mean_kabuli, mean_desi, mean_chickpea), ~ . / 100 ) ) %>%
  mutate(wave = "Wave 3", level = "Household-level")

mean_kabuli_w3_ea <- wave3_ea %>% 
  recode_region() %>% 
  chickpea_tbl(ead_kabuli_r, ead_desi_r, hh = FALSE) %>% 
  mutate(across(c(mean_kabuli, mean_desi, mean_chickpea), ~ . / 100 ) ) %>%
  mutate(wave = "Wave 3", level = "EA-level")

mean_kabuli_w5_hh <- wave5_hh_new %>% 
  recode_region() %>% 
  chickpea_tbl(hhd_kabuli, hhd_desi, pw_w5) %>% 
  mutate(wave = "Wave 5", level = "Household-level")

mean_kabuli_w5_ea <- wave5_ea_new %>% 
  recode_region() %>% 
  chickpea_tbl(ead_kabuli, ead_desi, hh = FALSE) %>% 
  mutate(wave = "Wave 5", level = "EA-level")


kabuli_bind <- bind_rows(
  mean_kabuli_w3_hh,
  mean_kabuli_w3_ea,
  mean_kabuli_w5_hh,
  mean_kabuli_w5_ea
) %>% 
  mutate(region = fct_relevel(region, "Amhara", "Oromia", "SNNP", "Other regions", "National")) 


kabuli_plot <- kabuli_bind %>% 
  filter(level == "Household-level", region != "Tigray") %>% 
  ggplot(aes(region, mean_chickpea, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean_chickpea*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  facet_wrap(~ level, scales = "free") +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .15) +
  theme(legend.position = "top") +
  labs(x = "", y = "Percent",
       title = "Comparision of Adoption of Chickpea Kabuli Variety b/n Waves 3 and 5",
       fill = "",
       caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/kabuli_plot.pdf"),
  plot = kabuli_plot,
  device = cairo_pdf,
  width = 180,
  height = 135,
  units = "mm"
)  



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
  select(-barley_cg, -sorghum_cg) %>% 
  recode_region_dna(saq01)


ess5_dna_hh_new <- read_dta(file.path(root, "ESPS_DNA/3_output", "01_3_ess5_dna_hh.dta")) %>% 
  recode_region_dna()

ess5_weights_hh <- read_dta(file.path(root, "LSMS_W5/2_raw_data/data/HH/ESS5_weights_hh.dta"))

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
  left_join(select(ess5_weights_hh, household_id, pw_panel),
            by = "household_id")

ess5_dna_hh_panel <- ess5_dna_hh_new %>% 
  semi_join(ess4_dna_hh_new,
            by = "household_id") %>% 
  left_join(select(ess5_weights_hh, household_id, pw_panel),
            by = "household_id")

dna_means_hh_panel <- bind_rows(
  ess4_dna_hh_panel %>% 
    group_by(region) %>% 
    summarize_dna(pw = pw_panel) %>% 
    mutate(wave = "Wave 4"),
  
  ess4_dna_hh_panel %>% 
    summarize_dna(pw = pw_panel) %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  ess5_dna_hh_panel %>% 
    group_by(region) %>% 
    summarize_dna(pw = pw_panel) %>%
    mutate(wave = "Wave 5"),
  
  ess5_dna_hh_panel %>% 
    summarize_dna(pw = pw_panel) %>% 
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

write_csv(dna_means_hh, "adoption_rates_ESS/data/dna_means_hh.csv")



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


write_csv(dna_means_ea, "adoption_rates_ESS/data/dna_means_ea.csv")



plot_dna <- function(tbl, ylim) {
  tbl %>% 
    filter(region != "Tigray") %>% 
    ggplot(aes(region, mean, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(mean*100, 2), "%", "\n(", nobs, ")" ) ),
              position = position_dodge(width = 1),
              vjust = -.35, size = 2.5) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    scale_y_continuous(labels = percent_format()) +
    expand_limits(y = ylim) +
    labs(x = "", y = "Percent", fill = "")
}

maize_plot <- dna_means %>% 
  filter(improvment == "hhd_maize_cg") %>% 
  plot_dna(ylim = 1) +
  labs(title = "Maize - CG germplasm")

dtmz_plot <- dna_means %>% 
  filter(improvment == "hhd_dtmz") %>% 
  plot_dna(ylim = .6) +
  labs(title = "Drought tolerant maize",
       caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")


maize_dna <- ggarrange(
  maize_plot, dtmz_plot, 
  nrow = 2,
  common.legend = TRUE
) 

ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/maize_dna_plot.pdf"),
  plot = maize_dna,
  device = cairo_pdf,
  width = 185,
  height = 285,
  scale = .8,
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


# PSNP: Special edition ----


ess4_hh_psnp <- read_dta(file.path(root, w4_dir, "ess4_hh_psnp.dta")) 

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

psnp_w4 <- ess4_hh_psnp %>% 
  mutate(
    wave = "Wave 4",
    locality = recode(saq14, `1` = "Rural", `2` = "Urban")
    ) %>% 
  recode_all_regions(saq01) %>% 
  select(household_id, pw_w4, locality, hhd_psnp, region, wave)

psnp_w5 <- ess5_hh_psnp %>% 
  mutate(
    wave = "Wave 5",
    locality = recode(saq14, `1` = "Rural", `2` = "Urban")
  ) %>% 
  recode_all_regions(saq01) %>% 
  select(household_id, pw_w5, locality, hhd_psnp, region, wave) 


psnp_all <- bind_rows(
  mean_tbl(psnp_w4, "hhd_psnp", group_vars = c("wave", "region"), pw = pw_w4),
  mean_tbl(psnp_w4, "hhd_psnp", group_vars = c("wave"), pw = pw_w4) %>% 
    mutate(region = "National"),
  
  mean_tbl(psnp_w5, "hhd_psnp", group_vars = c("wave", "region"), pw = pw_w5),
  mean_tbl(psnp_w5, "hhd_psnp", group_vars = c("wave"), pw = pw_w5) %>% 
    mutate(region = "National")
) %>% 
  mutate(
    region = fct_relevel(
      region, 
      "Tigray", "Afar", "Amhara", "Oromia", "Somali", "Benishangul Gumuz", 
      "SNNP", "Gambela", "Harar", "Addis Ababa", "Dire Dawa", "National")
  )

psnp_local <- bind_rows(
  mean_tbl(psnp_w4, "hhd_psnp", group_vars = c("wave", "region", "locality"), pw = pw_w4),
  mean_tbl(psnp_w4, "hhd_psnp", group_vars = c("wave", "locality"), pw = pw_w4) %>% 
    mutate(region = "National"),
  
  mean_tbl(psnp_w5, "hhd_psnp", group_vars = c("wave", "region", "locality"), pw = pw_w5),
  mean_tbl(psnp_w5, "hhd_psnp", group_vars = c("wave", "locality"), pw = pw_w5) %>% 
    mutate(region = "National")
) %>% 
  mutate(
    region = fct_relevel(
      region, 
      "Tigray", "Afar", "Amhara", "Oromia", "Somali", "Benishangul Gumuz", 
      "SNNP", "Gambela", "Harar", "Addis Ababa", "Dire Dawa", "National")
  )


psnp_all %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .35) +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - all households in each wave")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_all.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 127,
  units = "mm"
)  


psnp_local %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .4) +
  facet_wrap(~ locality, nrow = 2, scales = "free_y") +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - all households in each wave by locality")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_all_local.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 200,
  units = "mm"
)  


## PSNP: Only panel hhs ----


ess5_weights_hh <- read_dta(file.path(root, "LSMS_W5/2_raw_data/data/HH/ESS5_weights_hh.dta"))

psnp_w4_panel <- psnp_w4 %>% 
  semi_join(psnp_w5, by = "household_id") %>% 
  left_join(select(ess5_weights_hh, household_id, pw_panel), 
            by = "household_id")

psnp_w5_panel <- psnp_w5 %>% 
  semi_join(psnp_w4, by = "household_id") %>% 
  left_join(select(ess5_weights_hh, household_id, pw_panel), 
            by = "household_id")


psnp_all_panel <- bind_rows(
  mean_tbl(psnp_w4_panel, "hhd_psnp", group_vars = c("wave", "region"), pw = pw_panel),
  mean_tbl(psnp_w4_panel, "hhd_psnp", group_vars = c("wave"), pw = pw_panel) %>% 
    mutate(region = "National"),
  
  mean_tbl(psnp_w5_panel, "hhd_psnp", group_vars = c("wave", "region"), pw = pw_panel),
  mean_tbl(psnp_w5_panel, "hhd_psnp", group_vars = c("wave"), pw = pw_panel) %>% 
    mutate(region = "National")
) %>% 
  mutate(
    region = fct_relevel(
      region, 
      "Afar", "Amhara", "Oromia", "Somali", "Benishangul Gumuz", 
      "SNNP", "Gambela", "Harar", "Addis Ababa", "Dire Dawa", "National")
  )


psnp_local_panel <- bind_rows(
  mean_tbl(psnp_w4_panel, "hhd_psnp", group_vars = c("wave", "region", "locality"), pw = pw_panel),
  mean_tbl(psnp_w4_panel, "hhd_psnp", group_vars = c("wave", "locality"), pw = pw_panel) %>% 
    mutate(region = "National"),
  
  mean_tbl(psnp_w5_panel, "hhd_psnp", group_vars = c("wave", "region", "locality"), pw = pw_panel),
  mean_tbl(psnp_w5_panel, "hhd_psnp", group_vars = c("wave", "locality"), pw = pw_panel) %>% 
    mutate(region = "National")
) %>% 
  mutate(
    region = fct_relevel(
      region, 
      "Afar", "Amhara", "Oromia", "Somali", "Benishangul Gumuz", 
      "SNNP", "Gambela", "Harar", "Addis Ababa", "Dire Dawa", "National")
  )


psnp_all_panel %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .35) +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - only panel households")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_all_panel.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 127,
  units = "mm"
)  



psnp_local_panel %>% 
  filter(region != "Tigray") %>% 
  ggplot(aes(region, mean, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .4) +
  facet_wrap(~ locality, nrow = 2, scales = "free_y") +
  theme(
    legend.position = "top"#,
    # legend.margin = margin(t = -0.4, unit = "cm"),
    # axis.title = element_text(size = 12.5),
    # plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
  ) +
  labs(x = "", y = "Percent", fill = "",
       title = "PSNP - panel households by locality")


ggsave(
  filename = file.path(root, "LSMS_W5/tmp/figures/psnp_local_panel.pdf"),
  device = cairo_pdf,
  width = 180,
  height = 200,
  units = "mm"
)  



