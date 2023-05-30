
library(haven)
library(tidyverse)

synergies_hh_ess4 <- read_dta("C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5/3_report_data/synergies_hh_ess4_new.dta")


innov_w4 <- synergies_hh_ess4 %>% 
  select(household_id, pw_w4, pw_panel, hh_status, nrm:zerotill)

innov_w4_means <- innov_w4 %>% 
  summarise(
    across(nrm:zerotill, ~weighted.mean(., w = pw_w4, na.rm = T))
  ) %>% 
  pivot_longer(everything()) 

int_w4 <- synergies_hh_ess4 %>% 
  select(household_id, pw_w4, pw_panel, hh_status, nrm_ca:ca5_psnp2) %>% 
  summarise(across(nrm_ca:ca5_psnp2, ~weighted.mean(., w = pw_w4, na.rm = T))) %>% 
  pivot_longer(everything()) %>% 
  filter(str_detect(name, "_")) %>% 
  filter(name != "hhd_psnp_dir") %>% 
  separate(name, into = c("var1", "var2"), sep = "_", extra = "merge", remove = F) %>% 
  filter(var1 != var2) %>% 
  left_join(rename(innov_w4_means, mean_var1 = value), by = c("var1" = "name")) %>% 
  left_join(rename(innov_w4_means, mean_var2 = value), by = c("var2" = "name")) %>% 
  rename(mean_int = value)

syn_int_w4 <- int_w4 %>% 
  mutate(
    syn_var1 = (mean_int / mean_var2) - mean_var1,
    syn_var2 = (mean_int / mean_var1) - mean_var2
    ) %>% 
  mutate(
    clr_var1 = case_when(
      syn_var1 >= .1                        ~ "#008B45",
      (syn_var1 >= .01) & (syn_var1 < .1)   ~ "#90EE90",
      syn_var1 <= -.1                       ~ "#CD0000",
      (syn_var1 <= -.01) & (syn_var1 > -.1) ~ "#FF6A6A"
    ),
    
    clr_var2 = case_when(
      syn_var2 >= .1                        ~ "#008B45",
      (syn_var2 >= .01) & (syn_var2 < .1)   ~ "#90EE90",
      syn_var2 <= -.1                       ~ "#CD0000",
      (syn_var2 <= -.01) & (syn_var2 > -.1) ~ "#FF6A6A"
    )
  )

int_w4_var1 <- syn_int_w4 %>% 
  select(var1, var2, mean_int) %>% 
  filter(!str_detect(var1, "ca\\d+")) %>% 
  filter(!str_detect(var2, "ca\\d+")) %>% 
  mutate(mean_int = paste0(round(mean_int, 3) * 100, "%")) %>%
  pivot_wider(names_from = var2, values_from = mean_int)  

int_w4_piv <- int_w4_var1 %>% 
  select(-var1) %>% 
  as.list()

int_w4_col <- syn_int_w4 %>% 
  select(var1, var2, clr_var1) %>% 
  filter(!str_detect(var1, "ca\\d+")) %>% 
  filter(!str_detect(var2, "ca\\d+")) %>% 
  pivot_wider(names_from = var2, values_from = clr_var1) %>% 
  select(-var1) %>%
  as.list()


int_w4_celspc <- list()
int_w4_celspc_html <- list()

for (i in seq_along(int_w4_piv)) {
  
  x <- int_w4_piv[[i]]
  
  col <- int_w4_col[[i]]
  
  y <- cell_spec(
    x,
    format = "latex",
    background = if_else(is.na(col), "#FFFFFF", col)
  )
  
  z <- cell_spec(
    x,
    format = "html",
    background = if_else(is.na(col), "#FFFFFF", col)
  )
  
  int_w4_celspc <- rlist::list.append(int_w4_celspc, y)
  int_w4_celspc_html <- rlist::list.append(int_w4_celspc_html, z)
}

names(int_w4_celspc) <- names(int_w4_piv)
names(int_w4_celspc_html) <- names(int_w4_piv)

data <- bind_cols(select(int_w4_var1, var1), bind_rows(int_w4_celspc))
data_html <- bind_cols(select(int_w4_var1, var1), bind_rows(int_w4_celspc_html))


data %>% 
  kable("latex", escape = F, align = "c") %>%
  kable_styling(full_width = FALSE) %>%
  landscape() %>% 
  save_kable("color_col.tex")

data_html %>% 
  kable(escape = F, align = "c") %>%
  kable_styling(full_width = FALSE) 




# Or dplyr ver
iris[1:10, ] %>%
  mutate(Species = cell_spec(
    Species, color = "white", bold = T,
    background = spec_color(1:10, end = 0.9, option = "A", direction = -1)
  )) %>%
  kable(escape = F, align = "c") %>%
  kable_styling(c("striped", "condensed"), full_width = F)



c(, "#FFFFFF", "#FFFFFF")








