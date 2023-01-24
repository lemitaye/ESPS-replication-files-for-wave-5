c("dtmz", "maize_cg")
library(haven)
library(tidyverse)
library(thatssorandom)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)

# theme_set(theme_light())

setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

wave3_hh <- read_dta("replication_files/3_report_data/wave3_hh.dta")
wave4_hh_new <- read_dta("replication_files/3_report_data/wave4_hh_new.dta")
wave5_hh_new <- read_dta("LSMS_W5/3_report_data/wave5_hh_new.dta")

vars_all <- c(
  "hhd_ofsp", "hhd_awassa83", "hhd_kabuli", "hhd_rdisp", "hhd_motorpump", 
  "hhd_swc", "hhd_consag1", "hhd_consag2", "hhd_affor", "hhd_mango", 
  "hhd_papaya", "hhd_avocado", "hotline", "hhd_malt", "hhd_durum", 
  "hhd_seedv1", "hhd_seedv2", "hhd_livIA", "hhd_livIA_publ", 
  "hhd_livIA_priv", "hhd_cross_largerum", "hhd_cross_smallrum", 
  "hhd_cross_poultry", "hhd_agroind", "hhd_cowpea", "hhd_elepgrass", 
  "hhd_deshograss", "hhd_sesbaniya", "hhd_sinar", "hhd_lablab", 
  "hhd_alfalfa", "hhd_vetch", "hhd_rhodesgrass", "hhd_impcr13", "hhd_impcr19", 
  "hhd_impcr11", "hhd_impcr24", "hhd_impcr14", "hhd_impcr3", "hhd_impcr5", 
  "hhd_impcr60", "hhd_impcr62"
  )

vars_both <- wave4_hh_new %>% 
  select(any_of(vars_all)) %>% 
  colnames()

vars_w5 <- setdiff(vars_all, vars_both)



recode_region <- function(tbl) {
  
  tbl %>% 
    mutate(
      region = recode(region, 
                      `0` = "Other regions",
                      `1` = "Tigray",
                      `3` = "Amhara",
                      `4` = "Oromia",
                      `7` = "SNNP")
    )
  
}

hh_level_w5 <- wave5_hh_new %>% 
  select(household_id, wave, region, pw = pw_w5, all_of(vars_both)) %>% 
  recode_region()

hh_level_w4 <- wave4_hh_new %>% 
  select(household_id, wave, region, pw_w4, all_of(vars_both)) %>% 
  left_join(
    hh_level_w5 %>% 
      select(household_id, pw),
    by = c("household_id")
  ) %>% 
  mutate(
    pw = case_when(!is.na(pw) ~ pw, TRUE ~ pw_w4),
    across(all_of(vars_both), ~recode(., `100` = 1))  # since w4 vars are mult. by 100
    ) %>% 
  recode_region()



mean_tbl <- function(tbl, by_region = TRUE) {
  
  if (by_region) {
    
    tbl %>% 
      pivot_longer(all_of(vars_both), 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, region, variable) %>% 
      summarise(
        mean = weighted.mean(value, w = pw, na.rm = TRUE),
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
        mean = weighted.mean(value, w = pw, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  }
  
}


labels <- var_label(hh_level_w5) %>% 
  .[-c(1:4)] %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
    ) 

national_hh_level <- bind_rows(
  mean_tbl(hh_level_w4, by_region = FALSE) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(hh_level_w5, by_region = FALSE) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)  

regions_hh_level <- bind_rows(
  mean_tbl(hh_level_w4),
  mean_tbl(hh_level_w5)
  ) %>% 
  mutate(wave = paste("Wave", wave) %>% 
           fct_relevel("Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)


# ONLY FOR PANEL HOUSEHOLDS:
hh_level_panel <- inner_join(
  x = hh_level_w4 %>% select(-wave, -pw_w4, -pw, -region),
  y = hh_level_w5 %>% select(-wave), 
  by = "household_id",
  suffix = c(".w4", ".w5")
) %>% 
  select(household_id, region, pw, everything()) %>% 
  pivot_longer(hhd_ofsp.w4:hhd_impcr62.w5, 
               names_to = "variable",
               values_to = "value") %>% 
  separate(variable, into = c("variable", "wave"), sep = "\\.") %>% 
  mutate(wave = recode(wave, "w4" = "Wave 4", "w5" = "Wave 5")) %>% 
  left_join(labels, by = "variable")  

regions_hh_panel <- hh_level_panel %>% 
  group_by(wave, region, label) %>% 
  summarise(
    mean = weighted.mean(value, w = pw, na.rm = TRUE),
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
    mean = weighted.mean(value, w = pw, na.rm = TRUE),
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
         caption = "Percent are weighted sample means using the latest (wave 5) weights.
         Number of households responding in parenthesis")
  
}


nat_hh <- national_hh_level %>% 
  plot_compar("National", xlim = .85)

amhara_hh <- regions_hh_level %>% 
  filter(region == "Amhara") %>% 
  plot_compar("Amhara", xlim = 1.05)

oromia_hh <- regions_hh_level %>% 
  filter(region == "Oromia") %>% 
  plot_compar("Oromia")

snnp_hh <- regions_hh_level %>% 
  filter(region == "SNNP") %>% 
  plot_compar("SNNP")

other_hh <- regions_hh_level %>% 
  filter(region == "Other regions") %>% 
  plot_compar("Other regions")



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
  
  file <- paste0("LSMS_W5/tmp/figures/", names(plots)[[i]], ".pdf")
  
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
  filename = "LSMS_W5/tmp/figures/new_innov.pdf",
  plot = new_innov,
  device = cairo_pdf,
  width = 200,
  height = 285,
  units = "mm"
)  


###############################################################################*
# Comparison for Chickpea Kabuli only (against wave 3) ####
###############################################################################*

kabuli_w3 <- wave3_hh %>% 
  select(region, hhd_kabuli_r, pw_w3) %>% 
  recode_region()

mean_kabuli_w3 <- bind_rows(
  kabuli_w3 %>% 
    group_by(region) %>% 
    summarise(
      mean_kabuli_w3 = weighted.mean(hhd_kabuli_r, w = pw_w3, na.rm = TRUE),
      nobs = sum(!is.na(hhd_kabuli_r)),
      .groups = "drop"
    ),
  
  wave3_hh %>% 
    summarise(
      mean_kabuli_w3 = weighted.mean(hhd_kabuli_r, w = pw_w3, na.rm = TRUE),
      nobs = sum(!is.na(hhd_kabuli_r))
    ) %>% 
    mutate(region = "National")
)


kabuli_bind <- bind_rows(
  w5_means_new %>% 
    filter(variable == "hhd_kabuli") %>% 
    select(-variable) %>% 
    mutate(mean = mean*100, wave = "Wave 5"), 
  
  mean_kabuli_w3 %>% 
    filter(region!= "Tigray") %>% 
    rename(mean = mean_kabuli_w3) %>% 
    mutate(label = "Chickpea Kabuli variety", wave = "Wave 3") 
) %>% 
  mutate(region = fct_relevel(region, "Amhara", "Oromia", "SNNP", "Other regions", "National")) 


kabuli_plot <- kabuli_bind %>% 
  ggplot(aes(region, mean/100, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean, 2), "%", "\n(", nobs, ")" ) ),
            position = position_dodge(width = 1),
            vjust = -.35, size = 2.5) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  expand_limits(y = .08) +
  labs(x = "", y = "Percent",
       title = "Comparision of Adoption of Chickpea Kabuli Variety b/n Waves 3 and 5",
       fill = "Wave",
       caption = "Percent are weighted sample means.
       Number of responding households in parenthesis")


ggsave(
  filename = "LSMS_W5/tmp/figures/kabuli_plot.pdf",
  plot = kabuli_plot,
  device = cairo_pdf,
  width = 180,
  height = 135,
  units = "mm"
)  



# Comparing crop-germplasm improvements

ess4_dna_hh_new <- read_dta("replication_files/3_report_data/ess4_dna_hh_new.dta") %>% 
  filter(!is.na(maize_cg), !is.na(dtmz)) %>%  # retain only maize
  select(-barley_cg, -sorghum_cg)

ess5_dna_hh_new <- read_dta("LSMS_W5/3_report_data/ess5_dna_hh_new.dta")


















































