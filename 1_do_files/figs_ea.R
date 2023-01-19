
library(haven)
library(tidyverse)
library(thatssorandom)
library(labelled)
library(janitor)
library(kableExtra)
library(scales)

# theme_set(theme_light())

setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

wave4_ea_new <- read_dta("replication_files/3_report_data/wave4_ea_new.dta")
wave5_ea_new <- read_dta("LSMS_W5/3_report_data/wave5_ea_new.dta")


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
vars_all <- c(
  "ead_ofsp", "ead_awassa83", "ead_kabuli", "ead_rdisp", "ead_motorpump", 
  "ead_swc", "ead_consag1", "ead_consag2", "ead_affor", "ead_mango", 
  "ead_papaya", "ead_avocado", "ead_malt", "ead_durum", "ead_hotline", 
  "ead_seedv1", "ead_seedv2", "ead_livIA", "ead_livIA_publ", "ead_livIA_priv", 
  "ead_cross_largerum", "ead_cross_smallrum", "ead_cross_poultry", 
  "ead_agroind", "ead_cowpea", "ead_elepgrass", "ead_deshograss", 
  "ead_sesbaniya", "ead_sinar", "ead_lablab", "ead_alfalfa", "ead_vetch", 
  "ead_rhodesgrass", "commirr", "comm_video", "comm_video_all", 
  "comm_2wt_own", "comm_2wt_use", "comm_psnp", "ead_impcr13", 
  "ead_impcr19", "ead_impcr11", "ead_impcr24", "ead_impcr14", 
  "ead_impcr3", "ead_impcr5", "ead_impcr60", "ead_impcr62"
)

vars_both <- wave4_ea_new %>% 
  select(any_of(vars_all)) %>% 
  colnames()

vars_w5 <- setdiff(vars_all, vars_both) # vars only in wave 5


ea_level_w5 <- wave5_ea_new %>% 
  select(ea_id, wave, region, pw = pw_w5, all_of(vars_both)) %>% 
  recode_region()

ea_level_w4 <- wave4_ea_new %>% 
  select(ea_id, wave, region, pw_w4, all_of( vars_both ) ) %>% 
  mutate(across(all_of(vars_both), ~recode(., `100` = 1))) %>% 
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

labels <- var_label(ea_level_w5) %>% 
  .[-c(1:4)] %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  ) 

national_ea_level <- bind_rows(
  mean_tbl(ea_level_w4, vars_both, by_region = FALSE) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(ea_level_w5, vars_both, by_region = FALSE) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, variable, label, mean, nobs)

regions_ea_level <- bind_rows(
  mean_tbl(ea_level_w4, vars_both) %>% 
    mutate(wave = "Wave 4"),
  mean_tbl(ea_level_w5, vars_both) %>% 
    mutate(wave = "Wave 5")
) %>% 
  mutate(wave = fct_relevel(wave, "Wave 5", "Wave 4")) %>% 
  left_join(labels, by = "variable") %>% 
  select(wave, region, variable, label, mean, nobs)


national_ea_level %>% 
  ggplot(aes(mean, label, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 2), " %", "(", nobs, ")" )),
            position = position_dodge(width = 1),
            size = 1.5) +
  scale_x_continuous(labels = percent_format()) +
  labs(x = "Percent of EAs", 
       y = "", 
       fill = "Wave",
       title = "Percent of Rural EAs Adopting Innovations - Waves 4 and 5")

regions_ea_level %>% 
  filter(region == "Amhara") %>% 
  ggplot(aes(mean, label, fill = wave)) +
  geom_col(position = "dodge") +
  geom_text(aes(label = paste0( round(mean*100, 2), " %", "(", nobs, ")" )),
            position = position_dodge(width = 1),
            size = 1.5) +
  scale_x_continuous(labels = percent_format()) +
  labs(x = "Percent of EAs", 
       y = "", 
       fill = "Wave",
       title = "Percent of Rural EAs Adopting Innovations - Waves 4 and 5")


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




