

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

adopt_rates_w4_hh <- read_csv("dynamics_presentation/data/adopt_rates_w4_hh.csv")

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


# filter and adjust innovations in wave 4
# adopt_rates_w4_all <- adopt_rates_all_hh %>% 
#   filter(wave=="Wave 4") %>% 
#   filter(!str_detect(variable, "hhd_impcr"))


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

# join with adoption rates data

ess4_all <- adopt_rates_w4_hh %>% 
  left_join(pop_rur_w4_all, by = "region") %>% 
  mutate(abs_num = mean * pop_w4_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)


ess4_pnl <- adopt_rates_w4_hh %>% 
  left_join(pop_rur_pnl, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_panel) %>% 
  filter(!region %in% c("Tigray", "National")) %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)


ess5_all <- adopt_rates_w4_all %>% 
  left_join(pop_rur_w5_all, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

df <- ess4_all %>% 
  rename(num = abs_num) %>% 
  pivot_wider(
    names_from = region,
    names_glue = "{region}_{.value}",
    values_from = c(mean, num)
  ) %>% 
  select(label, sort(colnames(.))) 

# Find the column indices that end with "_num"
num_cols <- grep("_num$", names(df))

# Create a new column that is the sum of the selected columns
df$Total <- rowSums(df[, num_cols], na.rm = TRUE)

# final rounding
df <- df %>% 
  mutate(
    across(c(ends_with("_num"), Total), ~round(.)),
    across(c(ends_with("_mean"), Total), ~round(., 3))
  )  


make_sheet <- function(tbl) {
  
  df <- tbl %>% 
    rename(num = abs_num) %>% 
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
  
  # final rounding
  df <- df %>% 
    mutate(
      across(c(ends_with("_num"), Total), ~round(.)),
      across(c(ends_with("_mean"), Total), ~round(., 3))
    )  
  
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

df_lst <- list(
  "ESS4 - all" = make_sheet(ess4_all)$df, 
  "ESS4 - panel" = make_sheet(ess4_pnl)$df, 
  "ESS5 - all" = make_sheet(ess5_all)$df
  )

reg_lst <- list(
  make_sheet(ess4_all)$region_nm, 
  make_sheet(ess4_pnl)$region_nm, 
  make_sheet(ess5_all)$region_nm
)

col_lst <- list(
  make_sheet(ess4_all)$col_hd, 
  make_sheet(ess4_pnl)$col_hd, 
  make_sheet(ess5_all)$col_hd
)

# Population frame:
pop_frm <- reduce(list(pop_rur_w4_all, pop_rur_w5_all, pop_rur_pnl), left_join, by = "region") %>% 
  rename("Region" = region, "Wave 4 weight" = pop_w4_all, 
         "Wave 5 weight" = pop_w5_all, "Panel weight" = pop_w5_panel) %>% 
  mutate_if(is.numeric, ~round(.))


# create a workbook
wb <- createWorkbook()

# set global options
options(openxlsx.borderColour = "#4F80BD")
options(openxlsx.borderStyle = "thin")
modifyBaseFont(wb, fontSize = 10, fontName = "Times New Roman")

# Add a worksheet
addWorksheet(wb, "Population Frame") 

# write data 
writeData(wb, sheet = "Population Frame", pop_frm, startCol = 2, startRow = 4)


for (i in seq_along(df_lst)) {
  
  # Add a worksheet
  addWorksheet(wb, names(df_lst)[[i]] ) 
  
  # write data 
  writeData(wb, sheet = names(df_lst)[[i]], df_lst[[i]], startCol = 1, startRow = 4, colNames = FALSE)
  
  # Write the region names
  writeData(wb, sheet = names(df_lst)[[i]], reg_lst[[i]], startCol = 2, startRow = 2, colNames = FALSE)
  
  # write column headers
  writeData(wb, sheet = names(df_lst)[[i]], col_lst[[i]], startCol = 2, startRow = 3, colNames = FALSE)
  
  # column width
  setColWidths(wb, sheet = names(df_lst)[[i]], cols = 1, widths = 30)
  
  # freeze panes
  freezePane(wb, sheet = names(df_lst)[[i]], firstActiveRow = 4, firstActiveCol = 2) 
  
  # styles (fine-tuning)
  addStyle(
    wb, sheet = names(df_lst)[[i]], cols = 2:ncol(df_lst[[i]]), rows = 2:31,
    style = createStyle(halign = "center"), gridExpand = TRUE
  )
  
}

# Set the column names with merged cells
for (i in seq_along(df_lst)) {
  
  for (j in seq(2, ncol(reg_lst[[i]]), by = 2)) {
    x <- c(j, j+1)
    mergeCells(wb, sheet = names(df_lst)[[i]], cols = x, rows = 2)
  }
  
}

# Save the workbook as an Excel file
saveWorkbook(wb, "writeXLSX2.xlsx", overwrite = TRUE)

openXL("writeXLSX2.xlsx")






