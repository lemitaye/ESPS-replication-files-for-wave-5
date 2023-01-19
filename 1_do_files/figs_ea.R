
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

# this list need to retain only vars that are common across the 
# two waves (for comparison)
# can do a separate analysis for new innovations (see figs_hh)
vars_both <- c(
  "ead_ofsp", "ead_awassa83", "ead_rdisp", "ead_motorpump", 
  "ead_swc", "ead_consag1", "ead_consag2", "ead_affor", "ead_mango", 
  "ead_papaya", "ead_avocado", "commirr", "ead_impcr13", "ead_impcr19", 
  "ead_impcr11", "ead_impcr24", "ead_impcr14", "ead_impcr3", "ead_impcr5", 
  "ead_impcr60", "ead_impcr62"
  )

vars_w5 <- c(
  "ead_kabuli", "ead_malt", "ead_durum", "ead_hotline", "ead_seedv1", 
  "ead_seedv2", "comm_video", "comm_video_all", "comm_2wt_own", "comm_2wt_use", 
  "comm_psnp"
)

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





# Table
track_ea_dropped <- read_dta("LSMS_W5/tmp/track_ea_dropped.dta") %>% 
  mutate(
    region_w4 = recode(region_w4,
                    `1` = "Tigray",
                    `2` = "Afar",
                    `3` = "Amhara",
                    `4` = "Oromia",
                    `5` = "Somali",
                    `6` = "Benishangul Gumuz",
                    `7` = "SNNP",
                    `12` = "Gambela",
                    `13` = "Harar",
                    `15` = "Dire Dawa" )
  ) 

bind_rows(
  track_ea_dropped %>% 
    count(region_w4, ea_missing), 
  
  track_ea_dropped %>% 
    count(ea_missing) %>% 
    mutate(region_w4 = "National")
) %>% 
  complete(region_w4, ea_missing, fill = list(n = 0)) %>% 
  mutate(ea_missing = recode(ea_missing, `1` = "ea_missing", `0` = "ea_not_missing")) %>% 
  pivot_wider(names_from = "ea_missing", values_from = "n") %>% 
  mutate(total = ea_missing + ea_not_missing,
         region_w4 = fct_relevel(
           factor(region_w4), "Tigray", "Afar", "Amhara", "Oromia", "Somali", 
           "Benishangul Gumuz", "SNNP", "Gambela", "Harar", "Dire Dawa", "National"
         )) %>% 
  arrange(region_w4)




