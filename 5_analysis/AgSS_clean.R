

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
    mutate(data = map(
      file, read_csv, show_col_types = FALSE, na = c("", "NA", "-"))
      ) %>%
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



# function to clean list of raw csv ----------
clean_tbl_lst <- function(tbl_lst) {
  
  cleaned_tbl_lst <- list()
  
  
  for (i in seq_along(tbl_lst)) {
    
    # Find the row index containing "Grain"  
    grain_row <- which(str_detect(tbl_lst[[i]] %>% pull(2), "Grain"))
    
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
        # convert to numeric type
        across(area:production_cv, ~as.numeric(str_replace(., ",", ""))),
        
        # use regex to remove trailing dots
        crop = str_replace(crop, "\\.+\\s*\\.+\\s*$", "") %>% str_trim()
      ) %>% 
      suppressWarnings()
    
    
    cleaned_tbl_lst <- rlist::list.append(cleaned_tbl_lst, tbl_cur)
    
  }
  
  # cleaned_tbl_bind <- bind_rows(cleaned_tbl_lst)

  return(cleaned_tbl_lst)  
  # return(cleaned_tbl_bind)
  
}


# Fine tuning --------

## 2012/13 -------

clean_tbl_lst(agss_2013) %>% 
  map(dim)  

## 2013/14 -------

clean_tbl_lst(agss_2014) %>% 
  map(dim)

## 2014/15

clean_tbl_lst(agss_2015) %>% 
  map(dim)


# apply cleaning function -------

agss_2013_bind <- clean_tbl_lst(agss_2013) %>% 
  mutate(year = "2012/13")

agss_2014_bind <- clean_tbl_lst(agss_2014) %>% 
  mutate(year = "2013/14")

agss_2015_bind <- clean_tbl_lst(agss_2015) %>% 
  mutate(year = "2014/15")

agss_2016_bind <- clean_tbl_lst(agss_2016) %>% 
  mutate(year = "2015/16")

agss_2017_bind <- clean_tbl_lst(agss_2017) %>% 
  mutate(year = "2016/17")

agss_2018_bind <- clean_tbl_lst(agss_2018) %>% 
  mutate(year = "2017/18")

agss_2019_bind <- clean_tbl_lst(agss_2019) %>% 
  mutate(year = "2018/19")

agss_2020_bind <- clean_tbl_lst(agss_2020) %>% 
  mutate(year = "2019/20")

agss_2021_bind <- clean_tbl_lst(agss_2021) %>% 
  mutate(year = "2020/21")

agss_2022_bind <- clean_tbl_lst(agss_2022) %>% 
  mutate(year = "2021/22")


# bind all years to one tibble --------

agss_all <- bind_rows(
  agss_2013_bind,
  agss_2014_bind,
  agss_2015_bind,
  agss_2016_bind,
  agss_2017_bind,
  agss_2018_bind,
  agss_2019_bind,
  agss_2020_bind,
  agss_2021_bind,
  agss_2022_bind
)


















