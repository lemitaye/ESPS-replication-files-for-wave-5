
# ----- #
# Purpose: to create figures comparing adoption of improved forages across waves
# Author: Lemi Daba (tayelemi@gmail.com)
# ----- #


library(scales)
library(haven)
library(tidyverse)

# 
recode_region <- function(tbl, region_var) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(
          {{region_var}}, 
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

mean_tbl <- function(tbl, vars = vars_both, group_vars, pw) {
  
  tbl %>% 
    pivot_longer(all_of(vars), 
                 names_to = "variable",
                 values_to = "value") %>% 
    group_by_at(group_vars) %>% 
    summarise(
      mean = weighted.mean(value, w = {{pw}}, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    )
  
}

plot_forage <- function(tbl) {
  tbl %>% 
    ggplot(aes(region, mean, fill = wave)) +
    geom_col(position = "dodge") +
    geom_text(aes(label = paste0( round(mean*100, 1), "%", "\n(", nobs, ")" ) ),
              position = position_dodge(width = 1),
              vjust = -.35, size = 3) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    scale_y_continuous(labels = percent_format()) +
    # expand_limits(y = maxGrid + .15) +
    # facet_wrap(~ level, nrow=2, scales = "free") +
    scale_fill_Publication() + 
    theme_Publication() +
    theme(
      legend.position = "top",
      legend.margin = margin(t = -0.4, unit = "cm"),
      axis.title = element_text(size = 12.5),
      plot.margin = unit(c(1, 1, 0.5, 1), units = "line") # top, right, bottom, & left
    )
}

# load data ----

wave4_hh <- read_dta("../supplemental/replication_files/3_report_data/wave4_hh_new.dta")
wave5_hh <- read_dta("../3_report_data/wave5_hh_new.dta")

track_hh <- read_dta("../tmp/dynamics/06_1_track_hh.dta")


# some cleaning ----
wave4_grass <- wave4_hh %>% 
  rename(hhd_sesbaniya = hhd_sasbaniya, hhd_alfalfa = hhd_alfa) %>% 
  mutate(hhd_grassII = case_when(
    hhd_elepgrass==100 | hhd_sesbaniya==100 | hhd_alfalfa==100 | hhd_gaya==100 ~ 1,
    hhd_elepgrass==0 & hhd_sesbaniya==0 & hhd_alfalfa==0 & hhd_gaya==0 ~ 0 
  )) %>% 
  select(household_id:saq01, hhd_grassII) %>% 
  mutate(wave = "Wave 4", region = as.numeric(saq01)) %>% 
  recode_region(region) %>% 
  left_join(select(track_hh, household_id, hh_status), by = "household_id")

wave5_grass <- wave5_hh %>% 
  select(household_id:saq01, hhd_grass, hhd_grassII) %>% 
  mutate(wave = "Wave 5", region = as.numeric(saq01)) %>% 
  recode_region(region) %>% 
  left_join(select(track_hh, household_id, hh_status), by = "household_id")


grass_hh_all <- bind_rows(
  mean_tbl(wave4_grass, vars = "hhd_grassII", group_vars = c("wave", "variable"), 
           pw = pw_w4),
  mean_tbl(wave4_grass, vars = "hhd_grassII", group_vars = c("wave", "variable", "region"), 
           pw = pw_w4),
  mean_tbl(wave5_grass, vars = c("hhd_grass", "hhd_grassII"), 
           group_vars = c("wave", "variable"), pw = pw_w5),
  mean_tbl(wave5_grass, vars = c("hhd_grass", "hhd_grassII"), 
           group_vars = c("wave", "variable", "region"), pw = pw_w5)
) %>% 
  replace_na(list(region = "National"))

grass_hh_pnl <- bind_rows(
  mean_tbl(filter(wave4_grass, hh_status==3), vars = "hhd_grassII", group_vars = c("wave", "variable"), 
           pw = pw_w4),
  mean_tbl(filter(wave4_grass, hh_status==3), vars = "hhd_grassII", group_vars = c("wave", "variable", "region"), 
           pw = pw_w4),
  mean_tbl(filter(wave5_grass, hh_status==3), vars = c("hhd_grass", "hhd_grassII"), 
           group_vars = c("wave", "variable"), pw = pw_w5),
  mean_tbl(filter(wave5_grass, hh_status==3), vars = c("hhd_grass", "hhd_grassII"), 
           group_vars = c("wave", "variable", "region"), pw = pw_w5)
) %>% 
  replace_na(list(region = "National"))



# EA level -----
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
      -any_of(c("household_id", "ea_id", "wave", "region", "pw_w4", "pw_w5", "pw_panel",
                "hh_status", "saq01", "saq14")), 
      names_to = "variable", values_to = "value") %>% 
    group_by_at(group_vars) %>% 
    summarise(
      mean = mean(value, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    )
  
}

summ_by_ea <- function(tbl, name) {
  
  bind_rows(
    
    tbl %>% 
      group_by(ea_id) %>% 
      collapse_ea(group_vars = "variable") %>% 
      mutate(region = "National", wave = name),
    
    tbl %>% 
      group_by(ea_id, region) %>% 
      collapse_ea() %>% 
      mutate(wave = name)
    
  )
}

grass_ea_all <- bind_rows(
  summ_by_ea(wave4_grass, "Wave 4"),
  summ_by_ea(wave5_grass, "Wave 5")
)

grass_ea_pnl <- bind_rows(
  summ_by_ea(filter(wave4_grass, hh_status==3), "Wave 4"),
  summ_by_ea(filter(wave5_grass, hh_status==3), "Wave 5")
)

# Save data
grass_means <- bind_rows(
  grass_hh_all %>% 
    mutate(sample = "All households/EA", level = "Household"),
  grass_hh_pnl %>% 
    mutate(sample = "Panel households/EA", level = "Household"),
  grass_ea_all %>% 
    mutate(sample = "All households/EA", level = "EA"),
  grass_ea_pnl %>% 
    mutate(sample = "Panel households/EA", level = "EA")
) 

write_csv(grass_means, "dynamics_presentation/data/grass_means.csv")


# All:
grass_means_all %>% 
  filter(variable == "hhd_grassII",
         region != "Tigray") %>% 
  plot_forage() +
  labs(
    x = "", y = "Percent",
    title = "Forages: ",
    fill = "",
    caption = "Percent at the household level are weighted sample means.
             Number of observations in parenthesis."
  )


grass_means_all %>% 
  filter(
    (wave == "Wave 4" & variable == "hhd_grassII") | variable=="hhd_grass",
    region != "Tigray"
  ) %>% 
  plot_forage() +
  labs(
    x = "", y = "Percent",
    # title = input$var,
    fill = "",
    caption = "Percent at the household level are weighted sample means.
             Number of observations in parenthesis."
  )


# Panel:
grass_means_all %>% 
  filter(variable == "hhd_grassII",
         region != "Tigray") %>% 
  plot_forage() +
  expand_limits(y = .4) +
  labs(
    x = "", y = "Percent",
    title = "Forage grasses",
    subtitle = "Panel households",
    fill = "",
    caption = "Includes only forages measured in the two waves. 
    Percent at the household level are weighted sample means. Number of observations in parenthesis."
  )

ggsave(
  filename = "../tmp/figures/forages_restricted_pnl.png",
  width = 300,
  height = 200,
  units = "mm"
)


grass_means_pnl %>% 
  filter(
    (wave == "Wave 4" & variable == "hhd_grassII") | variable=="hhd_grass",
    region != "Tigray"
  ) %>% 
  plot_forage() +
  expand_limits(y = .6) +
  labs(
    x = "", y = "Percent",
    title = "Forage grasses",
    subtitle = "Panel households",
    fill = "",
    caption = "Includes all forages measured in each wave.
    Percent at the household level are weighted sample means. Number of observations in parenthesis."
  )

ggsave(
  filename = "../tmp/figures/forages_all_pnl.png",
  width = 300,
  height = 200,
  units = "mm"
)
































