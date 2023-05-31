
# load packages -----
library(haven)
library(tidyverse)

# read data ------
root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"

synergies_hh_ess4 <- read_dta(file.path(root, "3_report_data/synergies_hh_ess4_new.dta"))

synergies_hh_ess5 <- read_dta(file.path(root, "3_report_data/synergies_hh_ess5_new.dta"))



innov_w4 <- synergies_hh_ess4 %>% 
  select(household_id, pw_w4, pw_panel, hh_status, all_of(innovs))

innov_w5 <- synergies_hh_ess5 %>% 
  select(household_id, pw_w5, pw_panel, hh_status, all_of(innovs))

make_innov_int <- function(tbl, pw) {
  
  innovs <- c("nrm", "ca", "crop", "tree", "animal", "breed", "breed2", "psnp",
              "psnp2", "rotlegume", "cresidue", "mintillage", "zerotill")
  
  innov_int_tbl <- expand_grid(var1 = innovs, var2 = innovs, 
                               .name_repair = "universal") %>% 
    mutate(
      mean_var1 = NA_real_, mean_var2 = NA_real_, mean_int = NA_real_ 
    )
    
  for (i in 1:nrow(innov_int_tbl)) {
    
    x <- innov_int_tbl$var1[i]
    y <- innov_int_tbl$var2[i]
    
    m1 <- weighted.mean(tbl[[x]], w = tbl[[pw]], na.rm = T)
    m2 <- weighted.mean(tbl[[y]], w = tbl[[pw]], na.rm = T)
    m3 <- weighted.mean(tbl[[x]]*tbl[[y]], w = tbl[[pw]], na.rm = T)
    
    innov_int_tbl$mean_var1[i] <- if_else(x!=y, m1, NA)
    innov_int_tbl$mean_var2[i] <- if_else(x!=y, m2, NA)
    innov_int_tbl$mean_int[i]  <- if_else(x!=y, m3, NA)
    
  }
  
  return(innov_int_tbl)
  
}

make_innov_int(innov_w4, "pw_w4")
make_innov_int(innov_w5, "pw_w5")

make_innov_int(filter(innov_w4, hh_status == 3), "pw_panel")
make_innov_int(filter(innov_w5, hh_status == 3), "pw_panel")


syn_int_w4 <- innov_int_tbl %>% 
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
  mutate(mean_int = case_when(
    !is.na(mean_int) ~ paste0(round(mean_int, 3) * 100, "%"),
    is.na(mean_int)  ~ "---"
    )) %>%
  pivot_wider(names_from = var2, values_from = mean_int)  

int_w4_piv <- int_w4_var1 %>% 
  select(-var1) %>% 
  as.list()

int_w4_col <- syn_int_w4 %>% 
  select(var1, var2, clr_var1) %>% 
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










