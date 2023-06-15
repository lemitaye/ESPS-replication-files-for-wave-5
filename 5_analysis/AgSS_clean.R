

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
    mutate(data = map(file, read_csv, show_col_types = FALSE, na = c("NA", "-", ""))) %>%
    extract(file, "name", paste0(year, "_(.*).csv")) %>%
    deframe()
  
  return(agss_year)
}


# read csv files to a list: -------------
agss_2013 <- read_csv_2list(2013)
agss_2014 <- read_csv_2list(2014)
agss_2015 <- read_csv_2list(2015)
agss_2016 <- read_csv_2list(2016)
agss_2017 <- read_csv_2list(2017)
agss_2018 <- read_csv_2list(2018)
agss_2019 <- read_csv_2list(2019)
agss_2020 <- read_csv_2list(2020)
agss_2021 <- read_csv_2list(2021)
agss_2022 <- read_csv_2list(2022)



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
    ) %>% 
    mutate(
      crop = str_remove(crop, ""),
      across(area:production_cv, as.numeric)
    )
  
  
  agss_2013_cleaned_lst <- rlist::list.append(agss_2013_cleaned_lst, tbl_cur)
  
}


clean_tbl_lst <- function(tbl_lst) {
  
  cleaned_tbl_lst <- list()
  
  
  for (i in seq_along(tbl_lst)) {
    
    # Find the row index containing "Grain"  
    grain_row <- which(str_detect(tbl_lst[[i]]$`Unnamed: 0`, "Grain"))
    
    # Subset the data frame from the grain_row to the end
    tbl_cur <- tbl_lst[[i]][(grain_row:nrow(tbl_lst[[i]])), ]
    
    
    tbl_cur <- tbl_cur %>% 
      select(where(~any(!is.na(.)))) %>% # remove columns with entire NAs
      select(-1) %>% 
      rename(
        crop = 1, area = 2, area_se = 3, area_cv = 4, production = 5,
        production_se = 6, production_cv = 7
      ) %>% 
      filter(!is.na(crop)) %>% 
      mutate(
        # crop = str_trim(str_remove(crop, "\\.+")),
        across(area:production_cv, ~as.numeric(str_remove(., ",")))
      )
    
    
    cleaned_tbl_lst <- rlist::list.append(cleaned_tbl_lst, tbl_cur)
    
  }
  

  
  return(cleaned_tbl_lst)
  
}

clean_tbl_lst(agss_2022)


agss_2013_cleaned <- bind_rows(agss_2013_cleaned_lst) 


grain_row <- which(str_detect(agss_2022$Afar$`Unnamed: 0`, "Grain"))

# Subset the data frame from the grain_row to the end
tbl_cur <- agss_2022$Afar[(grain_row:nrow(agss_2022$Afar)), ]

tbl_cur %>% 
  select(where(~any(!is.na(.)))) %>% # remove columns with entire NAs
  select(-1) %>% 
  rename(
    crop = 1, area = 2, area_se = 3, area_cv = 4, production = 5,
    production_se = 6, production_cv = 7
  ) %>% 
  filter(!is.na(crop)) %>% 
  mutate(
    crop = str_trim(str_remove(crop, "\\.+")),
    across(area:production_cv, ~as.numeric(str_remove(., ",")))
  )





















