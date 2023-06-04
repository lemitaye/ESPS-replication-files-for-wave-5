

library(haven)
library(kableExtra)
library(fuzzyjoin)
library(openxlsx)

root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"

sect_cover_hh_w4 <- read_dta(
  file.path(root, "/supplemental/replication_files/2_raw_data/ESS4_2018-19/Data/sect_cover_hh_w4.dta")
  
  ) %>% 
  mutate_if(is.labelled, as_factor)

tabpath <- "C:/Users/l.daba/SPIA Dropbox/Lemi Daba/Apps/Overleaf/ESS_adoption_matrices/tables"

adopt_rates_all_hh <- read_csv("dynamics_presentation/adoption_rates_ESS/data/adopt_rates_all_hh.csv")
adopt_rates_panel_hh <- read_csv("dynamics_presentation/adoption_rates_ESS/data/adopt_rates_panel_hh.csv")

track_hh <- read_dta(file.path(root, "tmp/dynamics/06_1_track_hh.dta")) 


# calculate no. of rural households by region for each wave

pop_rur_w4_all <- track_hh %>% 
  filter(wave4==1, locality == "Rural") %>%
  count(region, wt = pw_w4, name = "pop_w4_all") %>% 
  bind_rows(
    data.frame(region = "National", pop_w4_all = sum(.$pop_w4_all))
  )

pop_rur_w5_all <- track_hh %>% 
  filter(wave5==1, locality == "Rural") %>%
  count(region, wt = pw_w5, name = "pop_w5_all") %>% 
  bind_rows(
    data.frame(region = "National", pop_w5_all = sum(.$pop_w5_all))
  )

pop_rur_pnl <- track_hh %>% 
  filter(locality == "Rural", hh_status==3) %>%
  count(region, wt = pw_panel, name = "pop_w5_panel") %>% 
  bind_rows(
    data.frame(region = "National", pop_w5_panel = sum(.$pop_w5_panel))
  )


# Do the same for wave 5
sect_cover_pp_w5 <- read_dta(
  "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5/2_raw_data/data/PP/sect_cover_pp_w5.dta"
  )  %>% 
  mutate_if(is.labelled, as_factor)

ESS5_weights_hh <- read_dta(
  "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5/2_raw_data/data/HH/ESS5_weights_hh.dta"
  ) %>% 
  mutate_if(is.labelled, as_factor)

ESS5_weights_hh %>% 
  count(region, rururb, wt = pw_w5) 

pop_rur_w5 <- ESS5_weights_hh %>% 
  filter(rururb == "Rural") %>% 
  count(region, wt = pw_w5) %>% 
  mutate(region = str_to_title(region),
         region = recode(region, "Snnp" = "SNNP"))  %>% 
  rename(wave5_n = n) %>% 
  bind_rows(data.frame(region = "National", wave5_n = sum(.$wave5_n)))


pop_rur_w4_all  %>% 
  kable(
    format = "latex",
    booktabs = TRUE,
    align = c("l", "c"), 
    col.names = c("Region", "No. of hhs"),
    caption = "Number of rural households, ESPS - 2018/19",
    linesep = ""
  ) %>%
  # column_spec(1, width_min = "4cm") %>% 
  # column_spec(2:row_n, width_min = "2cm", width = "2cm") %>% 
  kable_styling(latex_options = c("hold_position", "repeat_header")) %>% 
  save_kable(file.path(tabpath, "pop_rur_w4_all.tex"))

pop_rur_w5  %>% 
  kable(
    format = "latex",
    booktabs = TRUE,
    align = c("l", "c"), 
    col.names = c("Region", "No. of hhs"),
    caption = "Number of rural households, ESPS - 2021/22",
    linesep = ""
  ) %>%
  # column_spec(1, width_min = "4cm") %>% 
  # column_spec(2:row_n, width_min = "2cm", width = "2cm") %>% 
  kable_styling(latex_options = c("hold_position", "repeat_header")) %>% 
  save_kable(file.path(tabpath, "pop_rur_w5.tex")) 



# join with adoption rates data

ess4_all <- adopt_rates_all_hh %>% 
  filter(wave=="Wave 4") %>% 
  left_join(pop_rur_w4_all, by = "region") %>% 
  mutate(abs_num = mean * pop_w4_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)


ess4_pnl <- adopt_rates_all_hh %>% 
  filter(wave=="Wave 4") %>% 
  left_join(pop_rur_pnl, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_panel) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)


ess5_all <- adopt_rates_all_hh %>% 
  filter(wave=="Wave 5") %>% 
  left_join(pop_rur_w5_all, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)


make_sheet <- function(tbl) {
  
  df <- tbl %>% 
    rename(num = abs_num) %>% 
    mutate(mean = round(mean, 3), num = round(num)) %>% 
    pivot_wider(
      names_from = region,
      names_glue = "{region}_{.value}",
      values_from = c(mean, num)
    ) %>% 
    select(label, sort(colnames(.))) 
  
  # Find the column indices that end with "_num"
  num_cols <- grep("_num$", names(df))
  
  # Create a new column that is the sum of the selected columns
  df$Total <- rowSums(df[, num_cols])
  
  
  region_nm <- str_remove(colnames(df)[-1], "_mean|_num") %>% 
    as_tibble() %>% 
    mutate(name = paste0("X", 1:nrow(.))) %>% 
    pivot_wider(names_from = name, values_from = value)
  
  col_hd <- rep(c("Mean", "No. of hhs"), (ncol(df)-1)/2) %>% 
    as_tibble() %>% 
    mutate(name = paste0("X", 1:nrow(.))) %>% 
    pivot_wider(names_from = name, values_from = value)
  
  return(list(df = df, region_nm = region_nm, col_hd = col_hd))
  
}

make_sheet(ess4_all)
make_sheet(ess4_pnl)
make_sheet(ess5_all)$df

l <- list(make_sheet(ess4_all)$df, make_sheet(ess4_pnl)$df, make_sheet(ess5_all)$df)
wb <- write.xlsx(l, file = "writeXLSX2.xlsx", startCol = 1, startRow = 4)


# Create a workbook
wb <- createWorkbook()

options(openxlsx.borderColour = "#4F80BD")
options(openxlsx.borderStyle = "thin")
modifyBaseFont(wb, fontSize = 10, fontName = "Times New Roman")

# Add a worksheet
addWorksheet(wb, "Data")

# Write the region names
writeData(wb, "Data", region_nm, startCol = 2, startRow = 2, colNames = FALSE)


# Set the column names with merged cells
for (i in seq(2, ncol(region_nm), by = 2)) {
  x <- c(i, i+1)
  mergeCells(wb, "Data", cols = x, rows = 2)
}

# write column headers
writeData(wb, "Data", col_hd, startCol = 2, startRow = 3, colNames = FALSE)

# write data 
writeData(wb, "Data", df, startCol = 1, startRow = 4, colNames = FALSE)

# width
setColWidths(wb, sheet = 1, cols = 1, widths = 30)

# styles (fine-tuning)
addStyle(
  wb, sheet = 1, 
  cols = 2:ncol(df), 
  rows = 2,
  style = createStyle(textDecoration = "bold"),
  gridExpand = TRUE
)

addStyle(
  wb, sheet = 1, cols = 2:ncol(df), 
  rows = 2:31,
  style = createStyle(halign = "center"),
  gridExpand = TRUE
  )

# Save the workbook as an Excel file
saveWorkbook(wb, "output.xlsx", overwrite = TRUE)



library(openxlsx)
write.xlsx(iris, file = "writeXLSX1.xlsx", startCol = 2, startRow = 2)
write.xlsx(iris, file = "writeXLSXTable1.xlsx", asTable = TRUE)






































