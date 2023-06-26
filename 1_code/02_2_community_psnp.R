
## Community psnp ----

sect09_com_w4 <- read_dta(file.path(
  root, 
  "supplemental/replication_files/2_raw_data/ESS4_2018-19/Data/sect09_com_w4.dta"
)) 

ess5_community_new <- read_dta(file.path(root, w5_dir, "ess5_community_new.dta")) 

ess5_comm_psnp <- ess5_community_new %>% 
  mutate_if(is.labelled, as_factor) %>% 
  mutate(
    across(c(saq01, saq14), ~ str_trim(str_to_title(str_remove(., "\\d+\\."))) ),
    wave = "Wave 5",
    region = recode(saq01, "Snnp" = "SNNP")
  ) %>% 
  select(ea_id, wave, region, locality = saq14, comm_psnp) 


ess4_comm_psnp <- sect09_com_w4 %>% 
  mutate(comm_psnp = case_when(
    cs9q01==1 ~ 1,
    cs9q01==2 ~ 0
  )) %>% 
  mutate_if(is.labelled, as_factor) %>% 
  mutate(
    across(c(saq01, saq14), ~ str_trim( str_to_title(str_remove(., "\\d+\\.")) ) ),
    wave = "Wave 4",
    region = recode(saq01, "Snnp" = "SNNP")
  ) %>% 
  select(ea_id, wave, region, locality = saq14, comm_psnp)

mean_tbl_nowt <- function(tbl, vars = vars_both, group_vars) {
  
  tbl %>% 
    pivot_longer(all_of(vars), 
                 names_to = "variable",
                 values_to = "value") %>% 
    group_by(pick(group_vars)) %>% 
    summarise(
      mean = mean(value, na.rm = TRUE),
      nobs = sum(!is.na(value)),
      .groups = "drop"
    )
  
}

summ_comm_psnp <- function(tbl, locality) {
  
  if (locality) {
    grp_vars_reg <- c("wave", "region", "locality")
    grp_vars_nat <- c("wave", "locality")
  } else {
    grp_vars_reg <- c("wave", "region")
    grp_vars_nat <- c("wave")
  }
  
  mean_bind_tbl <- bind_rows(
    
    mean_tbl_nowt(tbl, "comm_psnp", 
                  group_vars = grp_vars_reg),
    
    mean_tbl_nowt(tbl, "comm_psnp", 
                  group_vars = grp_vars_nat) %>% 
      mutate(region = "National")
    
  )
  
  return(mean_bind_tbl)
  
}


comm_psnp_all_agg <- bind_rows(
  summ_comm_psnp(ess4_comm_psnp, locality = FALSE),
  summ_comm_psnp(ess5_comm_psnp, locality = FALSE)
) %>% 
  relevel_region()


comm_psnp_all_local <- bind_rows(
  summ_comm_psnp(ess4_comm_psnp, locality = TRUE),
  summ_comm_psnp(ess5_comm_psnp, locality = TRUE)
) %>% 
  relevel_region()


# panel EAs:

ess5_comm_psnp_panel <- ess5_comm_psnp %>% 
  semi_join(ess4_comm_psnp, by = "ea_id")

ess4_comm_psnp_panel <- ess4_comm_psnp %>% 
  semi_join(ess5_comm_psnp, by = "ea_id")


comm_psnp_panel_agg <- bind_rows(
  summ_comm_psnp(ess4_comm_psnp_panel, locality = FALSE),
  summ_comm_psnp(ess5_comm_psnp_panel, locality = FALSE)
) %>% 
  relevel_region()


comm_psnp_panel_local <- bind_rows(
  summ_comm_psnp(ess4_comm_psnp_panel, locality = TRUE),
  summ_comm_psnp(ess5_comm_psnp_panel, locality = TRUE)
) %>% 
  relevel_region()


comm_psnp <- bind_rows(
  comm_psnp_all_agg %>% 
    mutate(locality = "Aggregate", sample = "All"), 
  comm_psnp_all_local %>% 
    mutate(sample = "All"),
  comm_psnp_panel_agg %>% 
    mutate(locality = "Aggregate", sample = "Panel"), 
  comm_psnp_panel_local %>% 
    mutate(sample = "Panel")
) %>% 
  mutate(variable = "comm_psnp")

write_csv(comm_psnp, file = "dynamics_presentation/data/comm_psnp.csv")

