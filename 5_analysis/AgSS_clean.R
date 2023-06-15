

# created on: July 15, 2023
# purpose: to clean scraped AgSS tables


# root directory
root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"


# load libraries ------
library(tidyverse)



# function to read csv files to list 
read_csv_2list <- function(year) {
  
  year_pr <- year-1
  folder_nm <- paste0(year_pr, "_", year-2000)
  
  agss_year <- tibble(
    file = dir(file.path(root, paste0("2_raw_data/auxiliary/AgSS_extracted/", folder_nm)), 
               full.names = TRUE)
  ) %>%
    mutate(data = map(file, read_csv, show_col_types = FALSE)) %>%
    extract(file, "name", paste0(year, "_(.*).csv")) %>%
    deframe()
  
  return(agss_year)
}

# 2012/13 -------------

# read csv files to a list:
agss_2013 <- read_csv_2list(2013)


agss_2013 <- tibble(
  file = dir(file.path(root, "2_raw_data/auxiliary/AgSS_extracted/2012_13"), 
             full.names = TRUE)
  ) %>%
  mutate(data = map(file, read_csv, show_col_types = FALSE)) %>%
  extract(file, "name", "2013_(.*).csv") %>%
  deframe()

agss_2013$Ethiopia %>% 
  select(-1) 

# Find the row index containing "Grain"  
grain_row <- which(agss_2013$Ethiopia$`Unnamed: 0` == "Grain")
# Subset the data frame from the grain_row to the end
agss_2013$Ethiopia <- agss_2013$Ethiopia[(grain_row:nrow(agss_2013$Ethiopia)), ]

agss_2013$SNNP %>% 
  filter(`...1` >= 3) %>% 
  select_if(~ !any(is.na(.))) %>% 
  select(-1) %>% 
  rename(
    crop = 1, area = 2, area_se = 3, area_cv = 4, production = 5,
    production_se = 6, production_cv = 7
  )


agss_2013_cleaned_lst <- list()


for (i in seq_along(agss_2013)) {
  
  # Find the row index containing "Grain"  
  grain_row <- which(agss_2013[[i]]$`Unnamed: 0` == "Grain")
  
  # Subset the data frame from the grain_row to the end
  tbl_cur <- agss_2013[[i]][(grain_row:nrow(agss_2013[[i]])), ]
  
  
  tbl_cur <- tbl_cur %>% 
    select_if(~ !any(is.na(.))) %>% # remove columns with entire NAs
    select(-1) %>% 
    rename(
      crop = 1, area = 2, area_se = 3, area_cv = 4, production = 5,
      production_se = 6, production_cv = 7
    )
  
  
  agss_2013_cleaned_lst <- rlist::list.append(agss_2013_cleaned_lst, tbl_cur)
  
}


agss_2013_cleaned <- bind_rows(agss_2013_cleaned_lst) 



# 2013/14 -------------

# read csv files to a list:
agss_2014 <- tibble(
  file = dir(file.path(root, "2_raw_data/auxiliary/AgSS_extracted/2013_14"), 
             full.names = TRUE)
) %>%
  mutate(data = map(file, read_csv)) %>%
  extract(file, "name", "2014_(.*).csv") %>%
  deframe()







# 2014/15 -------------

# read csv files to a list:
agss_2015 <- tibble(
  file = dir(file.path(root, "2_raw_data/auxiliary/AgSS_extracted/2014_15"), 
             full.names = TRUE)
) %>%
  mutate(data = map(file, read_csv)) %>%
  extract(file, "name", "2015_(.*).csv") %>%
  deframe()






# 2015/16 -------------

# read csv files to a list:
agss_2016 <- tibble(
  file = dir(file.path(root, "2_raw_data/auxiliary/AgSS_extracted/2015_16"), 
             full.names = TRUE)
) %>%
  mutate(data = map(file, read_csv)) %>%
  extract(file, "name", "2016_(.*).csv") %>%
  deframe()




# 2016/17 -------------

# read csv files to a list:
agss_2017 <- tibble(
  file = dir(file.path(root, "2_raw_data/auxiliary/AgSS_extracted/2016_17"), 
             full.names = TRUE)
) %>%
  mutate(data = map(file, read_csv)) %>%
  extract(file, "name", "2017_(.*).csv") %>%
  deframe()





















