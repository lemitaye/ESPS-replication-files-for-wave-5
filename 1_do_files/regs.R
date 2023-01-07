

library(haven)
library(tidyverse)
library(thatssorandom)
library(labelled)
library(rlist)
library(stargazer)
library(starpolishr)

# theme_set(theme_light())

setwd("C:/Users/tayel/Dropbox/Documents/SPIA/Ethiopia")

ess5_cov <- read_dta("LSMS_W5/3_report_data/ess5_pp_cov_new.dta")

sect_cover_pp_w4 <- read_dta("LSMS_W5/2_raw_data/data/sect_cover_pp_w4.dta")


panel_selected <- inner_join(
  x = ess5_cov,
  y = sect_cover_pp_w4 %>% distinct(household_id),
  by = "household_id"
) %>% 
  select(
    household_id, hhd_flab, flivman, parcesizeHA, asset_index, pssetindex, 
    income_offfarm, total_cons_ann, totconswin = total_cons_ann_win, nmtotcons = nom_totcons_aeq, 
    consq1, consq2, adulteq, hhd_rdisp, hhd_motorpump, hhd_rotlegume, hhd_cresidue1, hhd_cresidue2, 
    hhd_mintil = hhd_mintillage, hhd_zerotill, hhd_consag1, hhd_consag2, hhd_swc, hhd_terr, hhd_wcatch, 
    hhd_affor, hhd_ploc, hhd_ofsp, hhd_awassa83, hhd_avocado, hhd_papaya, 
    hhd_mango, hhd_fieldp, hhd_sp = hhd_sweetpotato, hhd_impcr2, hhd_impcr1
    )


innov <- c(
  "hhd_rdisp", "hhd_motorpump", "hhd_rotlegume", "hhd_cresidue1", "hhd_cresidue2", 
  "hhd_mintil", "hhd_zerotill", "hhd_consag1", "hhd_consag2", "hhd_swc", "hhd_terr", 
  "hhd_wcatch", "hhd_affor", "hhd_ploc", "hhd_ofsp", "hhd_awassa83", "hhd_avocado", 
  "hhd_papaya", "hhd_mango", "hhd_fieldp", "hhd_sp", "hhd_impcr2", "hhd_impcr1"
)

covar <- c(
  "hhd_flab", "flivman", "parcesizeHA", "asset_index", "pssetindex", 
  "income_offfarm", "total_cons_ann", "totconswin", "nmtotcons", "consq1", 
  "consq2", "adulteq" 
)


models <- list()

for (i in seq_along(covar)) {
  models <- list.append(models, list())
}

names(models) <- covar



for (i in covar) {
  for (j in innov) {
    mod <- lm(
      as.formula(paste(j, " ~ ", i)), 
      data = panel_selected
      )
    
    models[[i]] <- list.append(models[[i]], mod)
  }
}

for (i in seq_along(models)) {
  names(models[[i]]) <- innov
}



# Create empty lists
make_list <- function() {
  x <- list(
    ols_2 = double(4), iv_twins_2 = double(4), 
    iv_boy_girl_2 = double(4), iv_all_2 = double(4),
    ols_3 = double(4), iv_twins_3 = double(4), 
    iv_boy_girl_3 = double(4), iv_all_3 = double(4)
  ) 
  
  return(x)
}

coef_list <- list()
se_list <- list()
p_list <- list()

for (i in seq_along(covar)) {
  
  coef_list <- list.append(coef_list, double(23))
  se_list <- list.append(se_list, double(23))
  p_list <- list.append(p_list, double(23))
  
}

names(coef_list) <- covar
names(se_list) <- covar
names(p_list) <- covar

# Collect coefficients, standard errors, and p-values
for (i in seq_along(models)) {
  
  for (j in seq_along(models[[i]])) {
    
      coef_list[[i]][[j]] <- coef(summary(models[[i]][[j]]))[2, 1]
      se_list[[i]][[j]] <- coef(summary(models[[i]][[j]]))[2, 2]
      p_list[[i]][[j]] <- coef(summary(models[[i]][[j]]))[2, 4]
      
  }
  
}

df <- data.frame(matrix(data = rnorm(36000), ncol = 24))

fm <- lm(X1 ~ 0 + ., data = df)


star.out <- stargazer(
  fm, fm, fm, fm, fm, fm, fm, fm, fm, fm, fm, fm,
  coef = coef_list,
  se = se_list,
  p = p_list,
  # type = "html",
  omit.stat = "all",
  dep.var.caption  = "",
  # covariate.labels = labels,
  # # column.labels   = c("OLS", "2SLS", "OLS", "2SLS"),
  # column.separate = c(1, 3, 1, 3),
  dep.var.labels.include = FALSE,
  model.names = FALSE,
  out.header = TRUE
  # # star.cutoffs = c(0.05, 0.01, 0.001),
  # add.lines = last_lines,
  # title = "OLS and 2SLS Estimates of The Effect of The Number of Children",
  # label = "tab:main-res"
)


star.out <- star.out %>% 
  # star_insert_row(
  #   header_main,
  #   insert.after = c(9, 9, 10)
  # ) %>% star_notes_tex(
  #   note.type = "threeparttable", #Use the latex 'caption' package for notes
  #   note = long_note) %>% 
  star_sidewaystable()

star_tex_write(
  star.out, 
  headers = TRUE,
  file = "LSMS_W5/4_table/tex/Table_14.tex"
)






































