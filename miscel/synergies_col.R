
# load packages -----
library(haven)
library(tidyverse)

# read data ------
root <- "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"

synergies_hh_ess4 <- read_dta(file.path(root, "3_report_data/synergies_hh_ess4_new.dta"))

synergies_dna_ess4 <- read_dta(file.path(root, "3_report_data/synergies_dna_hh_ess4.dta"))


synergies_hh_ess5 <- read_dta(file.path(root, "3_report_data/synergies_hh_ess5_new.dta"))

synergies_dna_ess5 <- read_dta(file.path(root, "3_report_data/synergies_dna_hh_ess5.dta"))




innovs <- c("nrm", "ca", "tree", "animal", "breed",
            "psnp2", "maizedtmz", "maize", "dtmz")


innov_w4 <- left_join(
  synergies_hh_ess4 %>% 
    select(household_id, pw_w4, pw_panel, hh_status, all_of(innovs[-which(innovs %in% c("maizedtmz", "maize", "dtmz"))])),
  synergies_dna_ess4 %>% 
    select(household_id, hh_status_dna, maizedtmz, maize, dtmz),
  by = "household_id"
)

innov_w5 <- left_join(
  synergies_hh_ess5 %>% 
    select(household_id, pw_w5, pw_panel, hh_status, all_of(innovs[-which(innovs %in% c("maizedtmz", "maize", "dtmz"))])),
  synergies_dna_ess5 %>% 
    select(household_id, hh_status_dna, maizedtmz, maize, dtmz),
  by = "household_id"
)

make_innov_int <- function(tbl, pw) {
  
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

int_w4_all <- make_innov_int(innov_w4, "pw_w4")
int_w5_all <- make_innov_int(innov_w5, "pw_w5")

int_w4_pnl <- bind_rows(
  make_innov_int(filter(innov_w4, hh_status == 3), "pw_panel") %>% 
    filter(var1 != "maize" & var2 != "maize"),
  make_innov_int(filter(innov_w4, hh_status_dna == 3), "pw_panel") %>% 
    filter(var1 == "maize" | var2 == "maize")
)

int_w5_pnl <- bind_rows(
  make_innov_int(filter(innov_w5, hh_status == 3), "pw_panel") %>% 
    filter(var1 != "maize" & var2 != "maize"),
  make_innov_int(filter(innov_w5, hh_status_dna == 3), "pw_panel") %>% 
    filter(var1 == "maize" | var2 == "maize")
)




make_syn_int <- function(tbl) {
  
  tbl %>% 
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
  
}

syn_w4_all <- make_syn_int(int_w4_all)
syn_w5_all <- make_syn_int(int_w5_all)

syn_w4_pnl <- make_syn_int(int_w4_pnl)
syn_w5_pnl <- make_syn_int(int_w5_pnl)

cell_spec_tbl <- function(tbl) {
  
  int_var1 <- tbl %>% 
    select(var1, var2, mean_int) %>% 
    mutate(mean_int = case_when(
      !is.na(mean_int) ~ paste0(round(mean_int, 3) * 100, "%"),
      is.na(mean_int)  ~ "---"
    )) %>%
    pivot_wider(names_from = var2, values_from = mean_int)  
  
  int_piv <- int_var1 %>% 
    select(-var1) %>% 
    as.list()
  
  int_col <- tbl %>% 
    select(var1, var2, clr_var1) %>% 
    pivot_wider(names_from = var2, values_from = clr_var1) %>% 
    select(-var1) %>%
    as.list()
  
  
  int_celspc_tex  <- list()
  int_celspc_html <- list()
  
  for (i in seq_along(int_piv)) {
    
    x <- int_piv[[i]]
    
    col <- int_col[[i]]
    
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
    
    int_celspc_tex <- rlist::list.append(int_celspc_tex, y)
    int_celspc_html <- rlist::list.append(int_celspc_html, z)
  }
  
  names(int_celspc_tex) <- names(int_piv)
  names(int_celspc_html) <- names(int_piv)
  
  data_tex <- bind_cols(select(int_var1, var1), bind_rows(int_celspc_tex))
  data_html <- bind_cols(select(int_var1, var1), bind_rows(int_celspc_html))
  
  return(list(tex = data_tex, html = data_html))
  
}

cell_ht_w4_all <- cell_spec_tbl(syn_w4_all)$html
cell_ht_w5_all <- cell_spec_tbl(syn_w5_all)$html

cell_ht_w4_pnl <- cell_spec_tbl(syn_w4_pnl)$html
cell_ht_w5_pnl <- cell_spec_tbl(syn_w5_pnl)$html


lbls <- as_tibble_col(innovs, column_name = "var1") %>%
  mutate(
    label = case_match(
      var1,
      "nrm" ~"AWM & SWC practices",
      "ca" ~"Conservation Agriculture",
      "tree" ~"Agroforestry practices",
      "animal" ~"Forages",
      "breed" ~"Animal crossbreeds",
      "breed2" ~"Animal crossbreeds (excl. poultry)",
      "psnp" ~"PSNP (temp. labor)",
      "psnp2" ~"PSNP (temp. labor & direct assist.)",
      "rotlegume" ~"Crop rotation with legume",
      "cresidue" ~"Crop residue cover",
      "mintillage" ~"Minimum tillage",
      "zerotill" ~"Zero tillage",
      "maize" ~ "Maize - CG germplasm",
      "crop" ~ "Crop varieties (OFSP, Awassa83, etc.)"
    )
  )

cell_ht_all <- inner_join(
  cell_ht_w4_all %>% 
    rename_with(~paste0(., "_w4"), -var1),
  
  cell_ht_w5_all %>% 
    rename_with(~paste0(., "_w5"), -var1),
  
  by = "var1"
) %>% 
  select(var1, sort(names(.))) %>% 
  arrange(var1) %>% 
  left_join(lbls, by = "var1") %>% 
  select(-1) %>% 
  select(label, everything())

cell_ht_pnl <- inner_join(
  cell_ht_w4_pnl %>% 
    rename_with(~paste0(., "_w4"), -var1),
  
  cell_ht_w5_pnl %>% 
    rename_with(~paste0(., "_w5"), -var1),
  
  by = "var1"
) %>% 
  select(var1, sort(names(.))) %>% 
  arrange(var1) %>% 
  left_join(lbls, by = "var1") %>% 
  select(-1) %>% 
  select(label, everything())

write_csv(cell_ht_all, "cell_ht_all.csv")
write_csv(cell_ht_pnl, "cell_ht_pnl.csv")


data %>% 
  kable("latex", escape = F, align = "c") %>%
  kable_styling(full_width = FALSE) %>%
  landscape() %>% 
  save_kable("color_col.tex")


col_n <- length(cell_ht_all$label)

row_n <- length(colnames(cell_ht_all))

x <- rep(2, col_n)

names(x) <- cell_ht_all$label

col_hd <- rep(c("Wave 4", "Wave 5"), length(cell_ht_all$label))

cell_ht_all  %>% 
  kable(
    escape = F, align = "c", col.names = c("", col_hd),
    caption = "Summary matrix of joint adoption rates, 2018/19 vs. 2021/22 --- All households"
    ) %>%
  add_header_above(c("", x)) %>%
  column_spec(seq(1, row_n, by = 2), border_right = T) %>% 
  column_spec(2:row_n, width_min = "2cm", width = "2cm") %>% 
  column_spec(1, width_min = "4cm") %>% 
  kable_styling(full_width = FALSE, fixed_thead = TRUE) 

cell_ht_pnl  %>% 
  kable(escape = F, align = "c", col.names = c("", col_hd),
        caption = "Summary matrix of joint adoption rates, 2018/19 vs. 2021/22 --- Panel households") %>%
  add_header_above(c("", x)) %>%
  column_spec(seq(1, row_n, by = 2), border_right = T) %>% 
  column_spec(2:row_n, width_min = "2cm", width = "2cm") %>% 
  column_spec(1, width_min = "4cm") %>% 
  kable_styling(full_width = FALSE, fixed_thead = TRUE) 




