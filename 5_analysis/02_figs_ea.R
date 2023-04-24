
library(haven)
library(tidyverse)
# library(thatssorandom)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)

# theme_set(theme_light())

setwd("C:/Users/l.daba/OneDrive/SPIA/Ethiopia")

wave4_ea_new <- read_dta("replication_files/3_report_data/wave4_ea_new.dta")
wave5_ea_new <- read_dta("LSMS_W5/3_report_data/wave5_ea_new.dta")

ess4_ea_psnp <- read_dta("replication_files/3_report_data/ess4_ea_psnp.dta") %>% 
  select(ea_id, ead_psnp, sh_ea_psnp)

wave4_ea_new <- wave4_ea_new %>% 
  mutate(ead_grass = case_when(
    ead_elepgrass==100 | ead_sasbaniya==100 | ead_alfa==100 ~ 1,
    ead_elepgrass==0 & ead_sasbaniya==0 & ead_alfa==0 ~ 0 
  )) %>% 
  left_join(ess4_ea_psnp, by = "ea_id")

wave5_ea_new <- wave5_ea_new %>% 
  mutate(ead_grass = case_when(
    ead_elepgrass==1 | ead_sesbaniya==1 | ead_alfalfa==1 ~ 1,
    ead_elepgrass==0 & ead_sesbaniya==0 & ead_alfalfa==0 ~ 0 
  )) 


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

# variable lists
vars_all_ea <- c(
  "ead_ofsp", "ead_awassa83", "ead_kabuli", "ead_rdisp", "ead_motorpump", 
  "ead_swc", "ead_consag1", "ead_consag2", "ead_affor", "ead_mango", 
  "ead_papaya", "ead_avocado", "ead_malt", "ead_durum", "ead_hotline", 
  "ead_seedv1", "ead_seedv2", "ead_livIA", "ead_livIA_publ", "ead_livIA_priv", 
  "ead_cross_largerum", "ead_cross_smallrum", "ead_cross_poultry", 
  "ead_agroind", "ead_cowpea", "ead_elepgrass", "ead_deshograss", 
  "ead_sesbaniya", "ead_sinar", "ead_lablab", "ead_alfalfa", "ead_vetch", 
  "ead_rhodesgrass", "ead_grass", "commirr", "comm_video", "comm_video_all", 
  "comm_2wt_own", "comm_2wt_use", "comm_psnp", "ead_mintillage", 
  "ead_zerotill", "ead_cresidue2", "ead_rotlegume", "ead_psnp"
)

vars_both_ea <- wave4_ea_new %>% 
  select(any_of(vars_all_ea)) %>% 
  colnames()

vars_w5_ea <- setdiff(vars_all_ea, vars_both_ea) # vars only in wave 5


ea_level_w5 <- wave5_ea_new %>% 
  select(ea_id, wave, region, pw = pw_w5, all_of(vars_both_ea)) %>% 
  recode_region()

ea_level_w4 <- wave4_ea_new %>% 
  select(ea_id, wave, region, pw_w4, all_of( vars_both_ea ) ) %>% 
  mutate(across(all_of(vars_both_ea), ~recode(., `100` = 1))) %>% 
  recode_region()


mean_tbl <- function(tbl, var_vec, by_region = TRUE) {
  
  if (by_region) {
    
    tbl %>% 
      pivot_longer(all_of(var_vec), 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, region, variable) %>% 
      summarise(
        mean = mean(value, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  } else {
    
    tbl %>% 
      pivot_longer(all_of(var_vec), 
                   names_to = "variable",
                   values_to = "value") %>% 
      group_by(wave, variable) %>% 
      summarise(
        mean = mean(value, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      )
    
  }
  
}

var_label(ea_level_w5$ead_grass) <- "Feed and forages: Elephant grass, Sesbaniya, & Alfalfa"


labels <- var_label(ea_level_w5) %>% 
  .[-c(1:4)] %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  ) 

national_ea_level <- bind_rows(
  mean_tbl(ea_level_w4, vars_both_ea, by_region = FALSE) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(ea_level_w5, vars_both_ea, by_region = FALSE) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)

regions_ea_level <- bind_rows(
  mean_tbl(ea_level_w4, vars_both_ea) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(ea_level_w5, vars_both_ea) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)

adopt_rates_all_ea <- bind_rows(
  regions_ea_level, 
  national_ea_level %>% 
    mutate(region = "National")
)

write_csv(adopt_rates_all_ea, 
          file = file.path("LSMS_W5/tmp/temp_R", "adopt_rates_all_ea.csv"))


panel_ea_w4 <- semi_join(
  x = ea_level_w4,
  y = ea_level_w5,
  by = "ea_id"
)

panel_ea_w5 <- semi_join(
  x = ea_level_w5,
  y = ea_level_w4,
  by = "ea_id"
)

regions_ea_panel <- bind_rows(
  mean_tbl(panel_ea_w4, vars_both_ea) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(panel_ea_w5, vars_both_ea) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)

national_ea_panel <- bind_rows(
  mean_tbl(panel_ea_w4, vars_both_ea, by_region = FALSE) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(panel_ea_w5, vars_both_ea, by_region = FALSE) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)

adopt_rates_panel_ea <- bind_rows(
  regions_ea_panel, 
  national_ea_panel %>% 
    mutate(region = "National")
)

write_csv(adopt_rates_panel_ea, 
          file = file.path("LSMS_W5/tmp/temp_R", "adopt_rates_panel_ea.csv"))



# plots ----

plot_compar_ea <- function(tbl, title, xlim = .8) {
  
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
    labs(x = "Percent of EAs", 
         y = "", 
         fill = "",
         title = paste0("Percent of Rural EAs Adopting Innovations - ", title),
         caption = "Number of EAs with at least 1 hhs responding in parenthesis")
  
}


nat_ea <- national_ea_level %>% 
  plot_compar_ea("National", xlim = .9)

amhara_ea <- regions_ea_level %>% 
  filter(region == "Amhara") %>% 
  plot_compar_ea("Amhara", xlim = 1.15)

oromia_ea <- regions_ea_level %>% 
  filter(region == "Oromia") %>% 
  plot_compar_ea("Oromia", xlim = 1)

snnp_ea <- regions_ea_level %>% 
  filter(region == "SNNP") %>% 
  plot_compar_ea("SNNP", xlim = 1)

other_ea <- regions_ea_level %>% 
  filter(region == "Other regions") %>% 
  plot_compar_ea("Other regions")

plots_ea <- list(nat_ea, amhara_ea, oromia_ea, snnp_ea, other_ea)

names(plots_ea) <- c("nat_ea", "amhara_ea", "oromia_ea", "snnp_ea", "other_ea")

for (i in seq_along(plots_ea)) {
  
  file <- paste0("LSMS_W5/tmp/figures/", names(plots_ea)[[i]], ".pdf")
  
  print(paste("saving to", file))
  
  ggsave(
    filename = file,
    plot = plots_ea[[i]],
    device = cairo_pdf,
    width = 200,
    height = 285,
    units = "mm"
  )
}


# for new innovations incorporated in ESPS5
w5_ea_new <- wave5_ea_new %>% 
  select(
    ea_id, region, all_of(vars_w5_ea)
  ) %>% 
  recode_region() %>% 
  pivot_longer(all_of(vars_w5_ea), 
               names_to = "variable",
               values_to = "value") 

w5_means_ea <- left_join(
  x = bind_rows(
    w5_ea_new %>% 
      group_by(region, variable) %>% 
      summarise(
        mean = mean(value, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      ),
    w5_ea_new %>% 
      group_by(variable) %>% 
      summarise(
        mean = mean(value, na.rm = TRUE),
        nobs = sum(!is.na(value)),
        .groups = "drop"
      ) %>% 
      mutate(region = "National")
  ),
  
  y = var_label(select(wave5_ea_new, all_of(vars_w5_ea))) %>% 
    as_tibble() %>% 
    pivot_longer(
      cols = everything(), 
      names_to = "variable", 
      values_to = "label"
    ),
  by = "variable"
)


new_innov_ea_1 <- w5_means_ea %>% 
  filter(variable != "ead_kabuli",
         !str_detect(label, "Feed and Forage")) %>% 
  filter(variable %in% c("comm_psnp", "comm_video", "comm_video_all", "comm_2wt_own", "comm_2wt_use", "ead_hotline")) %>% 
  mutate(region = fct_relevel(region, "Amhara", "Oromia", "SNNP", "Other regions", "National")) %>% 
  ggplot(aes(region, mean, fill = region)) +
  geom_col() +
  geom_text(aes(label = paste0(round(mean*100, 2), "%")),
            vjust = -.5, size = 2.5) +
  facet_wrap(~ label, scales = "free", nrow = 3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  theme(legend.position = "none") +
  labs(y = "Percent of EAs with at least one household adopting", 
       x = "",
       title = "Adoption of innovations incorporated only in ESPS5")

new_innov_ea_2 <- w5_means_ea %>% 
  filter(variable != "ead_kabuli",
         !str_detect(label, "Feed and Forage")) %>% 
  mutate(region = fct_relevel(region, "Amhara", "Oromia", "SNNP", "Other regions", "National")) %>% 
  filter(variable %in% c("ead_livIA_priv", "ead_livIA_publ", "ead_malt", "ead_durum", "ead_seedv1", "ead_seedv2")) %>% 
  ggplot(aes(region, mean, fill = region)) +
  geom_col() +
  geom_text(aes(label = paste0(round(mean*100, 2), "%")),
            vjust = -.5, size = 2.5) +
  facet_wrap(~ label, scales = "free", nrow = 3) +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_continuous(labels = percent_format()) +
  theme(legend.position = "none") +
  labs(y = "Percent of EAs with at least one household adopting", 
       x = "",
       title = "Adoption of innovations incorporated only in ESPS5")

ggsave(
  filename = "LSMS_W5/tmp/figures/new_innov_ea_1.pdf",
  plot = new_innov_ea_1,
  device = cairo_pdf,
  width = 200,
  height = 285,
  units = "mm"
)  

ggsave(
  filename = "LSMS_W5/tmp/figures/new_innov_ea_2.pdf",
  plot = new_innov_ea_2,
  device = cairo_pdf,
  width = 200,
  height = 285,
  units = "mm"
)  

