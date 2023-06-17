
# created on: July 17, 2023
# purpose: to produce some figures for chickpea from AgSS

# 
# root directory
root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"


# load libraries ------
library(tidyverse)
library(readxl)



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
    ~select(., 1:5) %>% 
      rename(
        region = 1,
        area_red_cp = 2,
        prod_red_cp = 3,
        area_wht_cp = 4,
        prod_wht_cp = 5
      )
  )

for (i in seq_along(cpea_wb_rnm)) {
  
  year <- names(cpea_wb_rnm)[[i]] %>% str_replace("-", "/")
  
  cpea_wb_rnm[[i]]$year <- year
  
}


cpea_agss <- bind_rows(cpea_wb_rnm) %>% 
  select(year, region, everything())



















