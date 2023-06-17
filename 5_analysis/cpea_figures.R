
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
  path = wb_path
  )
