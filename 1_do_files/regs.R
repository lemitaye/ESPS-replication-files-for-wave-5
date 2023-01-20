

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


# Declare innovations and covariates:
innov <- c(
  "hhd_rdisp", "hhd_motorpump", "hhd_rotlegume", "hhd_cresidue1", "hhd_cresidue2", 
  "hhd_mintillage", "hhd_zerotill", "hhd_consag1", "hhd_consag2", "hhd_swc", "hhd_terr", 
  "hhd_wcatch", "hhd_affor", "hhd_ploc", "hhd_ofsp", "hhd_awassa83", "hhd_avocado", 
  "hhd_papaya", "hhd_mango", "hhd_fieldp", "hhd_sweetpotato", "hhd_impcr2", "hhd_impcr1",
  "hhd_kabuli", "hhd_malt", "hhd_durum", "hhd_livIA", 
  "hhd_cross", "hhd_cross_largerum", "hhd_cross_smallrum", "hhd_cross_poultry"
)

covar <- c(
  "hhd_flab", "flivman", "parcesizeHA", "asset_index", "pssetindex", 
  "income_offfarm", "total_cons_ann", "total_cons_ann_win", "nom_totcons_aeq", "consq1", 
  "consq2", "adulteq" 
)


panel_selected <- inner_join(
  x = ess5_cov,
  y = sect_cover_pp_w4 %>% distinct(household_id),
  by = "household_id"
) %>% 
  select(household_id, all_of(covar), all_of(innov))


# start running regressions
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


# create empty lists to store regression results
coef_list <- list()
se_list <- list()
p_list <- list()

ninnov <- length(innov)  # no. of rows

for (i in seq_along(covar)) {
  
  coef_list <- list.append(coef_list, double(ninnov))
  se_list <- list.append(se_list, double(ninnov))
  p_list <- list.append(p_list, double(ninnov))
  
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

df <- data.frame(matrix(data = rnorm(1500*ninnov), ncol = ninnov))

fm <- lm(X1 ~ 0 + ., data = df)


labels_covar <- panel_selected %>% 
  select(all_of(covar)) %>% 
  var_label() 

labels_innov <- panel_selected %>% 
  select(all_of(innov)) %>% 
  var_label()

names(labels_covar) <- NULL
names(labels_innov) <- NULL

col_labels <- unlist(labels_covar)
row_labels <- unlist(labels_innov)


stargazer(
  fm, fm, fm, fm, fm, fm, fm, fm, fm, fm, fm, fm,
  coef = coef_list,
  se = se_list,
  p = p_list,
  type = "html",
  report = "vc*",
  omit.stat = "all",
  dep.var.caption  = "",
  covariate.labels = row_labels,
  column.labels = col_labels,
  # column.separate = c(1, 3, 1, 3),
  dep.var.labels.include = FALSE,
  model.names = FALSE,
  out.header = TRUE,
  out = "LSMS_W5/4_table/Table_14.html"
  # # star.cutoffs = c(0.05, 0.01, 0.001),
  # add.lines = last_lines,
  # title = "OLS and 2SLS Estimates of The Effect of The Number of Children",
  # label = "tab:main-res"
)





































