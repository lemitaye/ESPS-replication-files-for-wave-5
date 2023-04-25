
library(haven)
library(tidyverse)
# library(thatssorandom)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)
library(ggpubr)


# theme_set(theme_light())

root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"
w4_dir <- "supplemental/replication_files/3_report_data"
w5_dir <- "3_report_data"

wave4_hh <- read_dta(file.path(root, w4_dir, "wave4_hh_new.dta"))
wave5_hh <- read_dta(file.path(root, w5_dir, "wave5_hh_new.dta"))

ess4_hh_psnp <- read_dta(file.path(root, w4_dir, "ess4_hh_psnp.dta"))
hh_livestock <- read_dta(file.path(root, w5_dir, "01_6_hh_livestock.dta"))

wave4_hh_new <- wave4_hh %>% 
  mutate(hhd_grass = case_when(
    hhd_elepgrass==100 | hhd_sasbaniya==100 | hhd_alfa==100 ~ 1,
    hhd_elepgrass==0 & hhd_sasbaniya==0 & hhd_alfa==0 ~ 0 
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
  "hhd_livIA_priv", "hhd_grass", "hhd_mintillage", "hhd_zerotill", 
  "hhd_cresidue2", "hhd_rotlegume", "hhd_psnp", "hhd_impcr1", "hhd_impcr2", 
  "hhd_impcr6", "hhd_impcr8"
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


hh_level_w4_urb_hh <- wave4_hh_new %>% 
  select(household_id, ea_id, wave, region = saq01, pw_w4, all_of(vars_urban_hhs)) %>% 
  mutate(
    across(
      c(all_of(vars_urban_hhs)), ~recode(., `100` = 1))  # since w4 vars are mult. by 100
  ) %>% 
  recode_region()

hh_level_w5_urb_hh <- wave5_hh_new %>% 
  bind_rows(
    hh_livestock %>%
      # b/c of duplicates:
      anti_join(wave5_hh, by = "household_id") %>%
      mutate(wave = 5)
  ) %>% 
  select(household_id, ea_id, wave, region = saq01, pw_w5, pw_panel, all_of(vars_urban_hhs)) %>% 
  recode_region() 
  


mean_tbl <- function(tbl, vars = vars_both, group_vars, pw) {
  
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

var_label(wave5_hh$hhd_grass) <- "Feed and forages: Elephant grass, Sesbaniya, & Alfalfa"

labels <- wave5_hh %>% 
  select(all_of(vars_both), all_of(vars_urban_hhs)) %>% 
  var_label() %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
    ) 

national_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, group_vars = c("wave", "variable"), pw = pw_w4),
  mean_tbl(hh_level_w4_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable"), pw = pw_w4) ,
  mean_tbl(hh_level_w5, group_vars = c("wave", "variable"), pw = pw_w5),
  mean_tbl(hh_level_w5_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable"), pw = pw_w5) 
) %>% 
  mutate(wave = paste("Wave", wave)) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)  

regions_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, group_vars = c("wave", "variable", "region"), pw = pw_w4),
  mean_tbl(hh_level_w4_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable", "region"), pw = pw_w4),
  mean_tbl(hh_level_w5, group_vars = c("wave", "variable", "region"), pw = pw_w5),
  mean_tbl(hh_level_w5_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable", "region"), pw = pw_w5)
) %>% 
  mutate(wave = paste("Wave", wave)) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)

adopt_rates_all_hh <- bind_rows(
  regions_hh_level, 
  national_hh_level %>% 
    mutate(region = "National")
)

write_csv(adopt_rates_all_hh, file = "adoption_rates_ESS/data/adopt_rates_all_hh.csv")
write_csv(adopt_rates_all_hh, file = "dynamics_presentation/data/adopt_rates_all_hh.csv")


# ONLY FOR PANEL HOUSEHOLDS: ####

hh_panel_w4 <- hh_level_w4 %>% 
  semi_join(hh_level_w5, by = "household_id") %>% 
  inner_join(select(hh_level_w5, household_id, pw_panel),
            by = "household_id")

hh_panel_w5 <- hh_level_w5 %>% 
  semi_join(hh_level_w4, by = "household_id") 

hh_panel_w4_urb_hh <- hh_level_w4_urb_hh %>% 
  semi_join(hh_level_w5_urb_hh, by = "household_id") %>% 
  inner_join(select(hh_level_w5_urb_hh, household_id, pw_panel),
             by = "household_id")

hh_panel_w5_urb_hh <- hh_level_w5_urb_hh %>% 
  semi_join(hh_level_w4_urb_hh, by = "household_id") 

national_hh_panel <- bind_rows(
  mean_tbl(hh_panel_w4, group_vars = c("wave", "variable"), pw = pw_panel), 
  
  mean_tbl(hh_panel_w4_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable"), pw = pw_panel), 
  
  mean_tbl(hh_panel_w5, group_vars = c("wave", "variable"), pw = pw_panel), 
  
  mean_tbl(hh_panel_w5_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable"), pw = pw_panel) 
) %>% 
  mutate(wave = paste("Wave", wave)) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs) 


regions_hh_panel <- bind_rows(
  mean_tbl(hh_panel_w4, group_vars = c("wave", "variable", "region"), pw = pw_panel), 
  
  mean_tbl(hh_panel_w4_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable", "region"), pw = pw_panel), 
  
  mean_tbl(hh_panel_w5, group_vars = c("wave", "variable", "region"), pw = pw_panel), 
  
  mean_tbl(hh_panel_w5_urb_hh, vars = vars_urban_hhs, 
           group_vars = c("wave", "variable", "region"), pw = pw_panel) 
) %>% 
  mutate(wave = paste("Wave", wave)) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)


adopt_rates_panel_hh <- bind_rows(
  regions_hh_panel, 
  national_hh_panel %>% 
    mutate(region = "National")
)

write_csv(adopt_rates_panel_hh, file = "adoption_rates_ESS/data/adopt_rates_panel_hh.csv")
write_csv(adopt_rates_panel_hh, file = "dynamics_presentation/data/adopt_rates_panel_hh.csv")


# EA level ----

## All households ----

collapse_ea <- function(tbl, group_vars = c("variable", "region")) {
  
  tbl %>% 
    summarise(
      # n = n(),
      across(
        -any_of(c("household_id", "ea_id", "wave", "region", "pw_w4", "pw_w5", "pw_panel")), 
        ~max(.x, na.rm = TRUE) ),
      .groups = "drop"
    ) %>% 
    suppressWarnings() %>% 
    modify(~ifelse(is.infinite(.), 0, .)) %>% 
    rename_with(~str_replace(., "hhd_", "ead_"), starts_with("hhd_")) %>% 
    pivot_longer(
      -any_of(c("household_id", "ea_id", "wave", "region", "pw_w4", "pw_w5", "pw_panel")), 
      names_to = "variable", values_to = "value") %>% 
    group_by(pick(group_vars)) %>% 
    summarise(
      mean = mean(value, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    )
  
}




innov_ea_all <- bind_rows(
  hh_level_w4 %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  hh_level_w4_urb_hh %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  hh_level_w4 %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 4"),
  
  hh_level_w4_urb_hh %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 4"),
  
  hh_level_w5 %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 5"),
  
  hh_level_w5_urb_hh %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 5"),
  
  hh_level_w5 %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 5"),
  
  hh_level_w5_urb_hh %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 5")
) %>% 
  left_join(
    labels %>% 
      mutate( variable = str_replace(variable, "hhd_", "ead_") ), 
    by = "variable") 

write_csv(innov_ea_all, "adoption_rates_ESS/data/innov_ea_all.csv")
write_csv(innov_ea_all, "dynamics_presentation/data/innov_ea_all.csv")


## Panel hhs ----

innov_ea_panel <- bind_rows(
  hh_panel_w4 %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  hh_panel_w4_urb_hh %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 4"),
  
  hh_panel_w4 %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 4"),
  
  hh_panel_w4_urb_hh %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 4"),
  
  hh_panel_w5 %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 5"),
  
  hh_panel_w5_urb_hh %>% 
    group_by(ea_id) %>% 
    collapse_ea(group_vars = "variable") %>% 
    mutate(region = "National", wave = "Wave 5"),
  
  hh_panel_w5 %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 5"),
  
  hh_panel_w5_urb_hh %>% 
    group_by(ea_id, region) %>% 
    collapse_ea() %>% 
    mutate(wave = "Wave 5")
) %>% 
  left_join(
    labels %>% 
      mutate( variable = str_replace(variable, "hhd_", "ead_") ), 
    by = "variable") 


write_csv(innov_ea_panel, "adoption_rates_ESS/data/innov_ea_panel.csv")
write_csv(innov_ea_panel, "dynamics_presentation/data/innov_ea_panel.csv")




# Plots ----

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


