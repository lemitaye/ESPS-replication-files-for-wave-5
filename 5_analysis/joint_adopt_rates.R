


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


