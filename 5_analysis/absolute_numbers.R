

library(haven)
library(kableExtra)
library(fuzzyjoin)


sect_cover_hh_w4 <- read_dta(
  "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5/supplemental/replication_files/2_raw_data/ESS4_2018-19/Data/sect_cover_hh_w4.dta"
  ) %>% 
  mutate_if(is.labelled, as_factor)

tabpath <- "C:/Users/l.daba/SPIA Dropbox/Lemi Daba/Apps/Overleaf/ESS_adoption_matrices/tables"

adopt_rates_all_hh <- read_csv("dynamics_presentation/adoption_rates_ESS/data/adopt_rates_all_hh.csv")


sect_cover_hh_w4 %>% 
  count(saq01, saq14, wt = pw_w4) 

pop_rur_w4 <- sect_cover_hh_w4 %>% 
  filter(saq14 == "RURAL") %>%
  count(saq01, wt = pw_w4) %>% 
  mutate(region = str_to_title(saq01),
         region = recode(region, "Snnp" = "SNNP")) %>% 
  select(region, wave4_n = n) %>% 
  bind_rows(data.frame(region = "National", wave4_n = sum(.$wave4_n)))


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


pop_rur_w4  %>% 
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
  save_kable(file.path(tabpath, "pop_rur_w4.tex"))

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
adopt_rates_all_hh %>% 
  filter(wave=="Wave 4") %>% 
  left_join(pop_rur_w4, by = "region") %>% 
  mutate(abs_num = mean * wave4_n) %>% 
  filter(region != "National") %>% 
  select(label, region, abs_num) %>% 
  group_by(label) %>% 
  summarize(abs_num = round(sum(abs_num)))


adopt_rates_all_hh %>% 
  filter(wave=="Wave 4", region == "National")
















