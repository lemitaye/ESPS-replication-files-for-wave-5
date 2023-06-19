
# created on: July 17, 2023
# purpose: to produce some figures for chickpea from AgSS

# 
# root directory
root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"


# load libraries ------
library(tidyverse)
library(readxl)
library(scales)

source("dynamics_presentation/helpers/ggplot_theme_Publication-2.R")



wb_path <- file.path(root, "2_raw_data/auxiliary/chickpea_agss_area_prod.xlsx")

# read excel sheets
cpea_wb_list <- map(
  set_names(excel_sheets(wb_path)),
  read_excel, 
  skip = 1,
  na = c("", "NA", "-"),
  path = wb_path
  )


# cleaning

cpea_wb_rnm <- cpea_wb_list %>% 
  map(
    ~rename(
      .,
      region = 1,
      area_red_cp = 2,
      prod_red_cp = 3,
      area_wht_cp = 4,
      prod_wht_cp = 5,
      area_any_cp = 6,
      prod_any_cp = 7
    )
  )

# create year column
for (i in seq_along(cpea_wb_rnm)) {
  
  year <- names(cpea_wb_rnm)[[i]] %>% str_replace("-", "/")
  
  cpea_wb_rnm[[i]]$year <- year
  
}


cpea_agss <- bind_rows(cpea_wb_rnm) %>% 
  select(year, region, everything()) %>% 
  pivot_longer(
    cols = area_red_cp:prod_any_cp,
    names_to = c("measure", "cpea_type"),
    names_pattern = "(.*)_(.*)_cp",
    values_to = "value"
  ) %>% 
  mutate(
    measure = recode(measure, "prod" = "production"),
    cpea_type = recode(cpea_type, "wht" = "White"),
    across(measure:cpea_type, str_to_title),
    region = fct_collapse(
      region,
      "SNNP" =  c("SNNP", "Sidama")
    )
  ) %>% 
  group_by(year, region, measure, cpea_type) %>% 
  summarise(value = sum(value, na.rm = T), .groups = "drop")


# plots

cpea_agss %>% 
  filter(region == "Ethiopia") %>% 
  ggplot(aes(year, value, fill = cpea_type)) +
  geom_col(position = "dodge") +
  facet_wrap(~measure, scales = "free_y", nrow = 2) +
  scale_y_continuous(labels = comma_format()) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(legend.position = "top") +
  labs(
    x = "Year", y = "", fill = "Chickpea type"
  )




cpea_agss %>% 
  filter(region != "Ethiopia", measure == "Area") %>% 
  ggplot(aes(year, value, fill = cpea_type)) +
  geom_col(position = "dodge") +
  facet_wrap(~region, scales = "free_y") +
  scale_y_continuous(labels = comma_format()) +
  theme_Publication() +
  scale_fill_Publication() +
  theme(legend.position = "top")

cpea_agss %>% 
  filter(region == "Ethiopia", measure == "Area") %>% 
  ggplot(aes(year, value, color = cpea_type, group = cpea_type)) +
  geom_line() 


cpea_agss %>% 
  filter(region != "Ethiopia", cpea_type == "Any",
         year != "2011/12") %>% 
  ggplot(aes(year, value, color = region, group = region)) +
  geom_line() +
  facet_wrap(~ measure, scales = "free_y")







