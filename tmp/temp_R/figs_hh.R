
library(haven)
library(tidyverse)
# library(thatssorandom)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)
library(ggpubr)


# theme_set(theme_light())

root <- "C:/Users/l.daba/OneDrive/SPIA/Ethiopia"
w4_dir <- "replication_files/3_report_data"
w5_dir <- "LSMS_W5/3_report_data"

wave4_hh_new <- read_dta(file.path(root, w4_dir, "wave4_hh_new.dta"))
wave5_hh_new <- read_dta(file.path(root, w5_dir, "wave5_hh_new.dta"))

wave4_hh_new <- wave4_hh_new %>% 
  mutate(hhd_grass = case_when(
    hhd_elepgrass==100 | hhd_sasbaniya==100 | hhd_alfa==100 ~ 1,
    hhd_elepgrass==0 & hhd_sasbaniya==0 & hhd_alfa==0 ~ 0 
  )) 

wave5_hh_new <- wave5_hh_new %>% 
  mutate(hhd_grass = case_when(
    hhd_elepgrass==1 | hhd_sesbaniya==1 | hhd_alfalfa==1 ~ 1,
    hhd_elepgrass==0 & hhd_sesbaniya==0 & hhd_alfalfa==0 ~ 0 
  )) 


vars_all <- c(
  "hhd_ofsp", "hhd_awassa83", "hhd_kabuli", "hhd_desi", "hhd_rdisp", "hhd_motorpump", 
  "hhd_swc", "hhd_consag1", "hhd_consag2", "hhd_affor", "hhd_mango", 
  "hhd_papaya", "hhd_avocado", "hotline", "hhd_malt", "hhd_durum", 
  "hhd_seedv1", "hhd_seedv2", "hhd_livIA", "hhd_livIA_publ", 
  "hhd_livIA_priv", "hhd_cross_largerum", "hhd_cross_smallrum", 
  "hhd_cross_poultry", "hhd_grass", "hhd_mintillage", "hhd_zerotill", 
  "hhd_cresidue2", "hhd_rotlegume"
  )

vars_both <- wave4_hh_new %>% 
  select(any_of(vars_all)) %>% 
  colnames()

vars_w5 <- setdiff(vars_all, vars_both)



recode_region <- function(tbl) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(region, 
                        `0` = "Other regions",
                        `1` = "Tigray",
                        `3` = "Amhara",
                        `4` = "Oromia",
                        `7` = "SNNP")
      )
  )
  
}


hh_level_w4 <- wave4_hh_new %>% 
  select(household_id, wave, region, pw_w4, all_of(vars_both)) %>% 
  mutate(
    across(
      c(all_of(vars_both)), ~recode(., `100` = 1))  # since w4 vars are mult. by 100
  ) %>% 
  recode_region()

hh_level_w5 <- wave5_hh_new %>% 
  select(household_id, wave, region, pw_w5, pw_panel, all_of(vars_both)) %>% 
  recode_region()


mean_tbl <- function(tbl, pw, by_region = TRUE) {
  
  if (by_region) {
    
    tbl %>% 
      pivot_longer(all_of(vars_both), 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, region, variable) %>% 
      summarise(
        mean = weighted.mean(value, w = {{pw}}, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  } else {
    
    tbl %>% 
      pivot_longer(all_of(vars_both), 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, variable) %>% 
      summarise(
        mean = weighted.mean(value, w = {{pw}}, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  }
  
}

var_label(hh_level_w5$hhd_grass) <- "Feed and forages: Elephant grass, Sesbaniya, & Alfalfa"

labels <- var_label(hh_level_w5) %>% 
  .[-c(1:4)] %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
    ) 

national_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, pw = pw_w4, by_region = FALSE) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(hh_level_w5, pw = pw_w5, by_region = FALSE) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)  

regions_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, pw = pw_w4),
  mean_tbl(hh_level_w5, pw = pw_w5)
  ) %>% 
  mutate(wave = paste("Wave", wave) %>% 
           fct_relevel("Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)


# ONLY FOR PANEL HOUSEHOLDS: ####

hh_level_panel <- inner_join(
  x = hh_level_w4 %>% select(-wave, -region),
  y = hh_level_w5 %>% select(-wave), 
  by = "household_id",
  suffix = c(".w4", ".w5")
) %>% 
  select(household_id, region, pw_w4, pw_w5, pw_panel, everything()) %>% 
  pivot_longer(hhd_ofsp.w4:hhd_rotlegume.w5, 
               names_to = "variable",
               values_to = "value") %>% 
  separate(variable, into = c("variable", "wave"), sep = "\\.") %>% 
  mutate(wave = recode(wave, "w4" = "Wave 4", "w5" = "Wave 5")) %>% 
  left_join(labels, by = "variable")  

regions_hh_panel <- hh_level_panel %>% 
  group_by(wave, region, label) %>% 
  summarise(
    mean = weighted.mean(value, w = pw_panel, na.rm = TRUE),
    nobs = sum(!is.na(value)),
    .groups = "drop"
  ) %>% 
  mutate(improv = case_when(
    str_detect(label, "Improved") ~ 1,
    TRUE ~ 0
  ))

national_hh_panel <- hh_level_panel %>% 
  group_by(wave, label) %>% 
  summarise(
    mean = weighted.mean(value, w = pw_panel, na.rm = TRUE),
    nobs = sum(!is.na(value)),
    .groups = "drop"
  ) %>% 
  mutate(improv = case_when(
    str_detect(label, "Improved") ~ 1,
    TRUE ~ 0
  ))


plot_compar <- function(tbl, title, xlim = .8) {
  
  tbl %>% 
    mutate(
      improv = case_when(
        str_detect(label, "Improved") ~ 1,
        TRUE ~ 0
      ),
      wave = fct_relevel(wave, "Wave 5", "Wave 4"),
      label = fct_reorder(label, -improv)
    ) %>%
    ggplot(aes(mean, label, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(mean*100, 2), "%", " (", nobs, ")" ) ),
              position = position_dodge(width = 1),
              hjust = -.15, size = 2.5) +
    scale_y_discrete(labels = function(x) str_wrap(x, width = 35)) +
    scale_x_continuous(labels = percent_format()) +
    expand_limits(x = xlim) +
    theme(legend.position = "top") +
    labs(x = "Percent of households", 
         y = "", 
         fill = "",
         title = paste0("Percent of Rural Households Adopting Innovations - ", title),
         caption = "Percent are weighted sample means using panel weights.
         Number of households responding in parenthesis")
  
}


nat_hh <- national_hh_level %>% 
  plot_compar("National", xlim = .85) +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

amhara_hh <- regions_hh_level %>% 
  filter(region == "Amhara") %>% 
  plot_compar("Amhara", xlim = 1.05) +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

oromia_hh <- regions_hh_level %>% 
  filter(region == "Oromia") %>% 
  plot_compar("Oromia") +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

snnp_hh <- regions_hh_level %>% 
  filter(region == "SNNP") %>% 
  plot_compar("SNNP") +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")

other_hh <- regions_hh_level %>% 
  filter(region == "Other regions") %>% 
  plot_compar("Other regions") +
  labs(caption = "Percent are weighted sample means using each wave's respective weights.
         Number of households responding in parenthesis")



nat_panel <- national_hh_panel %>% 
  plot_compar("National") +
  labs(subtitle = "Only panel households included")
  
amhara_panel <- regions_hh_panel %>% 
  filter(region == "Amhara") %>% 
  plot_compar("Amhara", xlim = 1) +
  labs(subtitle = "Only panel households included")

oromia_panel <- regions_hh_panel %>% 
  filter(region == "Oromia") %>% 
  plot_compar("Oromia") +
  labs(subtitle = "Only panel households included")

snnp_panel <- regions_hh_panel %>% 
  filter(region == "SNNP") %>% 
  plot_compar("SNNP", xlim = .75) +
  labs(subtitle = "Only panel households included")

other_panel <- regions_hh_panel %>% 
  filter(region == "Other regions") %>% 
  plot_compar("Other Regions") +
  labs(subtitle = "Only panel households included")

plots <- list(nat_hh, amhara_hh, oromia_hh, snnp_hh, other_hh,
              nat_panel, amhara_panel, oromia_panel, snnp_panel, other_panel)

names(plots) <- c("nat_hh", "amhara_hh", "oromia_hh", "snnp_hh", "other_hh", "nat_panel", 
                  "amhara_panel", "oromia_panel", "snnp_panel", "other_panel")

for (i in seq_along(plots)) {
  
  file <- paste0(root, "/LSMS_W5/tmp/figures/", names(plots)[[i]], ".pdf")
  
  print(paste("saving to", file))
  
  ggsave(
    filename = file,
    plot = plots[[i]],
    device = cairo_pdf,
    width = 200,
    height = 285,
    units = "mm"
  )
}


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



# Comparing crop-germplasm improvements

ess4_dna_hh_new <- read_dta(file.path(root, w4_dir, "ess4_dna_hh_new.dta")) %>% 
  filter(!is.na(maize_cg), !is.na(dtmz)) %>%  # retain only maize
  select(-barley_cg, -sorghum_cg) %>% 
  recode_region()

ess5_dna_hh_new <- read_dta(file.path(root, w5_dir, "ess5_dna_hh_new.dta")) %>% 
  recode_region()

dna_means <- bind_rows(
  ess4_dna_hh_new %>% 
    group_by(region) %>% 
    summarise(
      mean_maize = weighted.mean(maize_cg, w = pw_w4, na.rm = TRUE),
      mean_dtmz = weighted.mean(dtmz, w = pw_w4, na.rm = TRUE),
      nobs = sum(!is.na(maize_cg))
    ) %>% 
    mutate(wave = "Wave 4"),
  
  ess4_dna_hh_new %>% 
    summarise(
      mean_maize = weighted.mean(maize_cg, w = pw_w4, na.rm = TRUE),
      mean_dtmz = weighted.mean(dtmz, w = pw_w4, na.rm = TRUE),
      nobs = sum(!is.na(maize_cg))
    ) %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  ess5_dna_hh_new %>% 
    group_by(region) %>% 
    summarise(
      mean_maize = weighted.mean(maize_cg, w = pw_w5, na.rm = TRUE),
      mean_dtmz = weighted.mean(dtmz, w = pw_w5, na.rm = TRUE),
      nobs = sum(!is.na(maize_cg))
    ) %>% 
    mutate(wave = "Wave 5"),
  
  ess5_dna_hh_new %>% 
    summarise(
      mean_maize = weighted.mean(maize_cg, w = pw_w5, na.rm = TRUE),
      mean_dtmz = weighted.mean(dtmz, w = pw_w5, na.rm = TRUE),
      nobs = sum(!is.na(maize_cg))
    ) %>% 
    mutate(region = "National", wave = "Wave 5")

) %>% 
  pivot_longer(c("mean_maize", "mean_dtmz"),
               names_to = "improvment",
               values_to = "mean") %>% 
  mutate(region = fct_relevel(
    region, 
    "Tigray", "Amhara", "Oromia", "SNNP", "Other regions", "National"
  ))

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
  filter(improvment == "mean_maize") %>% 
  plot_dna(ylim = 1) +
  labs(title = "Maize - CG germplasm")

dtmz_plot <- dna_means %>% 
  filter(improvment == "mean_dtmz") %>% 
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










