

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

adopt_rate_dna_w4 <- read_csv("dynamics_presentation/data/adopt_rate_dna_w4.csv")

adopt_rates_w5_hh <- read_csv("dynamics_presentation/data/adopt_rates_w5_hh.csv")


dna_means_hh <- read_csv("dynamics_presentation/data/dna_means_hh.csv")

wave5_hh_new <- read_dta(file.path(root, "3_report_data/wave5_hh_new.dta"))

psnp_hh <- read_csv("dynamics_presentation/data/psnp_hh.csv")

ubounds_w4 <- read_csv("dynamics_presentation/data/ubounds_w4.csv")

bd_mean_w5 <- read_csv("dynamics_presentation/data/bd_mean_w5.csv")

ess5_bounds <- read_dta(file.path(root, "tmp/dynamics/ess5_bounds.dta"))



track_hh <- read_dta(file.path(root, "tmp/dynamics/06_1_track_hh.dta")) 


# calculate no. of rural households by region for each wave

# Rural populations

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

# Urban populations

pop_urb_w4_all <- track_hh %>% 
  filter(wave4==1, locality == "Urban") %>%
  count(region, wt = pw_w4, name = "pop_w4_all") %>% 
  bind_rows(
    data.frame(region = "National", pop_w4_all = sum(.$pop_w4_all))
  )

pop_urb_w5_all <- track_hh %>% 
  filter(wave5==1, locality == "Urban") %>%
  count(region, wt = pw_w5, name = "pop_w5_all") %>% 
  bind_rows(
    data.frame(region = "National", pop_w5_all = sum(.$pop_w5_all))
  )

pop_urb_pnl <- track_hh %>% 
  filter(locality == "Urban", hh_status==3) %>%
  count(region, wt = pw_panel, name = "pop_w5_panel") %>% 
  bind_rows(
    data.frame(region = "National", pop_w5_panel = sum(.$pop_w5_panel))
  )


# DNA in wave 5

recode_region_dna <- function(tbl, region_var = region) {
  
  suppressWarnings(
    tbl %>% 
      mutate(
        region = recode(
          {{region_var}}, 
          `1` = "Tigray",
          `3` = "Amhara",
          `4` = "Oromia",
          `7` = "SNNP",
          `13` = "Harar",
          `15` = "Dire Dawa"
        )
      )
  )
  
}


maize_growing <- wave5_hh_new %>% 
  recode_region_dna(saq01) %>% 
  filter(!is.na(region)) %>% 
  group_by(region) %>% 
  summarise(growing_pct = weighted.mean(cr2, pw = pw_w5)) %>% 
  bind_rows(data.frame(
    region = "National",
    growing_pct = weighted.mean(wave5_hh_new$cr2, pw = pw_w5)
  ))

dna_w5 <- dna_means_hh %>% 
  filter(wave == "Wave 5", sample == "All households/EA") %>% 
  left_join(maize_growing, by = "region")


# Wave 4: cross-sectional weight

ess4_innov <- adopt_rates_w4_hh %>% 
  left_join(pop_rur_w4_all, by = "region") %>% 
  mutate(abs_num = mean * pop_w4_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess4_dna <- adopt_rate_dna_w4 %>% 
  left_join(pop_rur_w4_all, by = "region") %>% 
  mutate(abs_num = mean * growing_pct * pop_w4_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess4_cs <- bind_rows(ess4_innov, ess4_dna)


# Wave 4: panel weight

ess4_innov_pnl <- adopt_rates_w4_hh %>% 
  left_join(pop_rur_pnl, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_panel) %>% 
  filter(!region %in% c("Tigray", "National")) %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess4_dna_pnl <- adopt_rate_dna_w4 %>% 
  left_join(pop_rur_pnl, by = "region") %>% 
  mutate(abs_num = mean * growing_pct * pop_w5_panel) %>% 
  filter(!region %in% c("Tigray", "National")) %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess4_pnl <- bind_rows(ess4_innov_pnl, ess4_dna_pnl)


# Wave 5: cross-sectional weights

ess5_innov <- adopt_rates_w5_hh %>% 
  filter(!variable %in% c("dtmz", "maize_cg")) %>% 
  left_join(pop_rur_w5_all, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess5_dna <- dna_w5 %>% 
  left_join(pop_rur_w5_all, by = "region") %>% 
  mutate(abs_num = mean * growing_pct * pop_w5_all) %>% 
  filter(region != "National") %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess5_cs <- bind_rows(ess5_innov, ess5_dna)


# Wave 5: panel weights

ess5_innov_pnl <- adopt_rates_w5_hh %>% 
  left_join(pop_rur_pnl, by = "region") %>% 
  mutate(abs_num = mean * pop_w5_panel) %>% 
  filter(!region %in% c("Tigray", "National")) %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess5_dna_pnl <- dna_w5 %>% 
  left_join(pop_rur_pnl, by = "region") %>% 
  mutate(abs_num = mean * growing_pct * pop_w5_panel) %>% 
  filter(!region %in% c("Tigray", "National")) %>% 
  select(region, label, mean, abs_num) %>% 
  arrange(region, label)

ess5_pnl <- bind_rows(ess5_innov_pnl, ess5_dna_pnl)




# function to construct list of data frames:
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
  df$Total <- rowSums(df[, num_cols], na.rm = TRUE)
  
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
  "ESS4 - wave 4 CS weight" = make_sheet(ess4_cs)$df, 
  "ESS4 - panel weight" = make_sheet(ess4_pnl)$df, 
  "ESS5 - wave 5 CS weight" = make_sheet(ess5_cs)$df,
  "ESS5 - panel weight" = make_sheet(ess5_pnl)$df
  )

reg_lst <- list(
  make_sheet(ess4_cs)$region_nm, 
  make_sheet(ess4_pnl)$region_nm, 
  make_sheet(ess5_cs)$region_nm, 
  make_sheet(ess5_pnl)$region_nm
)

col_lst <- list(
  make_sheet(ess4_cs)$col_hd, 
  make_sheet(ess4_pnl)$col_hd, 
  make_sheet(ess5_cs)$col_hd, 
  make_sheet(ess5_pnl)$col_hd
)

# Population frame:
pop_frm_rur <- reduce(
  list(pop_rur_w4_all, pop_rur_w5_all, pop_rur_pnl), left_join, by = "region"
  ) %>% 
  rename("Region" = region, "Wave 4 CS weight" = pop_w4_all, 
         "Wave 5 CS weight" = pop_w5_all, "Panel weight" = pop_w5_panel) %>% 
  mutate_if(is.numeric, ~round(.))

pop_frm_urb <- reduce(
  list(pop_urb_w4_all, pop_urb_w5_all, pop_urb_pnl), left_join, by = "region"
  ) %>% 
  rename("Region" = region, "Wave 4 CS weight" = pop_w4_all, 
         "Wave 5 CS weight" = pop_w5_all, "Panel weight" = pop_w5_panel) %>% 
  mutate_if(is.numeric, ~round(.))


# Upper and lower bounds

# Wave 4

ub_w4 <- ubounds_w4 %>% 
  left_join(pop_rur_w4_all, by = "region") %>% 
  mutate(abs_num = mean * pct * pop_w4_all, mean_pct = mean * pct) %>% 
  group_by(region) %>% 
  summarise(abs_num = sum(abs_num), mean = sum(mean_pct)) %>% 
  mutate(label = "Upper Bound") 

lb_w4 <- ess4_dna %>% 
  filter(label == "Maize DNA-fingerprinting") %>% 
  mutate(label = "Lower Bound")

bd_w4 <- bind_rows(ub_w4, lb_w4) %>% 
  expand(region, label) %>% 
  left_join(bind_rows(ub_w4, lb_w4), by = c("region", "label")) %>% 
  replace_na(list(abs_num = 0, mean = 0))

# panel hhs

# ub_w4_pnl <- ubounds_w4 %>% 
#   left_join(pop_rur_pnl, by = "region") %>% 
#   filter(region != "Tigray") %>% 
#   mutate(abs_num = mean * pct * pop_w5_panel, mean_pct = mean*pct) %>% 
#   group_by(region) %>% 
#   summarise(abs_num = sum(abs_num), mean = sum(mean_pct)) %>% 
#   mutate(label = "Upper Bound") 
# 
# lb_w4_pnl <- ess4_dna_pnl %>% 
#   filter(label == "Maize DNA-fingerprinting") %>% 
#   mutate(label = "Lower Bound")
# 
# bd_w4_pnl <- bind_rows(ub_w4_pnl, lb_w4_pnl) %>% 
#   expand(region, label) %>% 
#   left_join(bind_rows(ub_w4_pnl, lb_w4_pnl), by = c("region", "label")) %>% 
#   replace_na(list(abs_num = 0, mean = 0))


bd_w4 <- bd_means_w4 %>%
  left_join(pop_rur_w4_all, by = "region") %>%
  mutate(
    num_ub = mean_ub * pop_w4_all,
    num_lb1 = mean_lb1 * pop_w4_all,
    num_lb2 = mean_lb2 * pop_w4_all
  ) %>%
  select(-pop_w4_all) %>%
  pivot_longer(
    cols = -region,
    names_to = c("stat", "type"),
    names_sep = "_",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = "stat", values_from = "value"
  ) %>%
  mutate(
    label = case_match(
      type,
      "ub" ~ "Upper Bound",
      "lb1" ~ "Lower Bound-1",
      "lb2" ~ "Lower Bound-2"
    )
  ) %>%
  select(region, label, mean, abs_num = num)

bd_w4_pnl <- bd_means_w4 %>%
  left_join(pop_rur_pnl, by = "region") %>%
  filter(region != "Tigray") %>% 
  mutate(
    num_ub = mean_ub * pop_w5_panel,
    num_lb1 = mean_lb1 * pop_w5_panel,
    num_lb2 = mean_lb2 * pop_w5_panel
  ) %>%
  select(-pop_w5_panel) %>%
  pivot_longer(
    cols = -region,
    names_to = c("stat", "type"),
    names_sep = "_",
    values_to = "value"
  ) %>%
  pivot_wider(
    names_from = "stat", values_from = "value"
  ) %>%
  mutate(
    label = case_match(
      type,
      "ub" ~ "Upper Bound",
      "lb1" ~ "Lower Bound-1",
      "lb2" ~ "Lower Bound-2"
    )
  ) %>%
  select(region, label, mean, abs_num = num)


# Wave 5

bd_w5 <- bd_mean_w5 %>% 
  left_join(pop_rur_w5_all, by = "region") %>%
  mutate(
    num_ub1 = mean_ub1 * pop_w5_all,
    num_ub2 = mean_ub2 * pop_w5_all,
    num_lb  = mean_lb * pop_w5_all
  ) %>% 
  select(-pop_w5_all) %>% 
  pivot_longer(
    cols = -region,
    names_to = c("stat", "type"),
    names_sep = "_",
    values_to = "value"
  ) %>% 
  pivot_wider(
    names_from = "stat", values_from = "value"
    ) %>% 
  mutate(
    label = case_match(
      type, 
      "ub1" ~ "Upper Bound-1", 
      "ub2" ~ "Upper Bound-2", 
      "lb" ~ "Lower Bound"
    )
  ) %>% 
  select(region, label, mean, abs_num = num)


bd_w5_pnl <- bd_mean_w5 %>% 
  left_join(pop_rur_pnl, by = "region") %>%
  mutate(
    num_ub1 = mean_ub1 * pop_w5_panel,
    num_ub2 = mean_ub2 * pop_w5_panel,
    num_lb  = mean_lb * pop_w5_panel
  ) %>% 
  select(-pop_w5_panel) %>% 
  pivot_longer(
    cols = -region,
    names_to = c("stat", "type"),
    names_sep = "_",
    values_to = "value"
  ) %>% 
  pivot_wider(
    names_from = "stat", values_from = "value"
  ) %>% 
  mutate(
    label = case_match(
      type, 
      "ub1" ~ "Upper Bound-1", 
      "ub2" ~ "Upper Bound-2", 
      "lb" ~ "Lower Bound"
    )
  ) %>% 
  select(region, label, mean, abs_num = num)


  


# create a workbook
wb <- createWorkbook()

# set global options
options(openxlsx.borderColour = "#4F80BD")
options(openxlsx.borderStyle = "thin")
modifyBaseFont(wb, fontSize = 10, fontName = "Times New Roman")

# Add a worksheet
addWorksheet(wb, "Population Frame") 

# write data 
writeData(wb, sheet = "Population Frame", pop_frm_rur, startCol = 2, startRow = 4)

writeData(wb, sheet = "Population Frame", pop_frm_urb, startCol = 7, startRow = 4)



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

# add bound numbers
writeData(wb, sheet = names(df_lst)[[1]], make_sheet(bd_w4)$df, startCol = 1, startRow = 33, colNames = FALSE)
writeData(wb, sheet = names(df_lst)[[2]], make_sheet(bd_w4_pnl)$df, startCol = 1, startRow = 33, colNames = FALSE)

writeData(wb, sheet = names(df_lst)[[3]], make_sheet(bd_w5)$df, startCol = 1, startRow = 33, colNames = FALSE)
writeData(wb, sheet = names(df_lst)[[4]], make_sheet(bd_w5_pnl)$df, startCol = 1, startRow = 33, colNames = FALSE)


# Save the workbook as an Excel file
saveWorkbook(wb, file.path(root, "4_table/absolute_numbers.xlsx"), overwrite = TRUE)

openXL(file.path(root, "4_table/absolute_numbers.xlsx"))






