
# New innovations incorporated in ESPS5 ----#


# ----- #
# Purpose: to create data sets on adoption rates of new innovations in wave 5
# Author: Lemi Daba (tayelemi@gmail.com)
# ----- #


# load packages ----
library(haven)
library(tidyverse)
library(labelled)
library(scales)


# load data ----

wave5_hh_new <- read_dta("../3_report_data/wave5_hh_new.dta")


# functions ----
recode_region <- function(tbl) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(
          region, 
          `1` = "Tigray",
          `3` = "Amhara",
          `4` = "Oromia",
          `7` = "SNNP",
          `0` = "Other regions"
        )
      )
  )
  
}


# Household level -----

# vector of new innovations
vars_w5 <- c(
  "hhd_kabuli", "hhd_desi", "hotline", "hhd_malt", "hhd_durum", "hhd_seedv1", 
  "hhd_seedv2", "hhd_livIA_publ", "hhd_livIA_priv", "hhd_deshograss", "hhd_sinar", 
  "hhd_lablab", "hhd_vetch", "hhd_rhodesgrass"
)

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

# Figure
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
  filename = "../tmp/dynamics/figures/w5_new_innovs_hh.pdf",
  plot = new_innov,
  device = cairo_pdf,
  width = 200,
  height = 285,
  units = "mm"
)  

# save
write_csv(w5_means_new, "../tmp/dynamics/w5_new_innovs_hh.csv")



# EA level ----


wave5_ea_new <- read_dta("../3_report_data/wave5_ea_new.dta")


vars_w5_ea <- c(
  "ead_kabuli", "ead_malt", "ead_durum", "ead_hotline", "ead_seedv1", "ead_seedv2", 
  "ead_livIA_publ", "ead_livIA_priv", "ead_deshograss", "ead_sinar", "ead_lablab", 
  "ead_vetch", "ead_rhodesgrass", "comm_video", "comm_video_all", "comm_2wt_own", 
  "comm_2wt_use"
)


w5_ea_new <- wave5_ea_new %>% 
  select(ea_id, wave, region, pw_w5, all_of(vars_w5_ea)) %>% 
  recode_region() %>% 
  pivot_longer(all_of(vars_w5_ea), 
               names_to = "variable",
               values_to = "value") 


w5_means_ea <- bind_rows(
  w5_ea_new %>% 
    group_by(region, variable) %>% 
    summarise(
      mean = weighted.mean(value, w = pw_w5, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    ),
  w5_ea_new %>% 
    group_by(variable) %>% 
    summarise(
      mean = weighted.mean(value, w = pw_w5, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    ) %>% 
    mutate(region = "National")
)


var_labs_ea <- var_label(select(wave5_ea_new, all_of(vars_w5_ea))) %>% 
  as_tibble() %>% 
  pivot_longer(
    cols = everything(), 
    names_to = "variable", 
    values_to = "label"
  )


w5_means_new_ea <- left_join(
  x = w5_means_ea,
  y = var_labs_ea,
  by = "variable"
)



# Figure
new_innov_ea <- w5_means_new_ea %>% 
  filter(variable != "ead_kabuli",
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
  labs(y = "Percent of EAs with at least 1 hh adopting", 
       x = "",
       title = "Adoption of innovations incorporated only in ESPS5")


ggsave(
  filename = "../tmp/dynamics/figures/w5_new_innovs_ea.pdf",
  plot = new_innov_ea,
  device = cairo_pdf,
  width = 200,
  height = 285,
  units = "mm"
)  

# save
write_csv(w5_means_new_ea, "../tmp/dynamics/w5_new_innovs_ea.csv")
