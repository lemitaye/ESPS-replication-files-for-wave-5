
# Tables for replication file
# Date created: July 21, 2022
# Author: Lemi Daba (tayelemi@gmail.com)


# preparation -------

## load packages ------
library(tidyverse)
library(kableExtra)

## declare path to export- -----
tabpath <- "C:/Users/l.daba/SPIA Dropbox/Lemi Daba/Apps/Overleaf/README/tables"


# Table as a data frame
main_tab_df <- data.frame(
  script = c("09$_$1$_$tables_adopt$_$rates.do"),
  datasets = c(""),
  int_table = c("09_1_ess5_adoption_rates.xml"),
  supp_table = c(""),
  report_table = c("")
) %>% 
  as_tibble()


# Export table
kbl(
  main_tab_df,
  format = "latex",
  caption = "Put caption here",
  booktabs = TRUE,
  linesep = "",
  align = c("l", "l", "l", "l", "l"),
  col.names = c(
    "Script", "Data set(s)", "Intermediary table (in scripts)", "Table in supp. material", "Table/Figure in report"
    ),
  escape = FALSE
) %>% 
  column_spec(1:5, width = "7em", latex_valign = "b") %>%
  kable_styling(latex_options = c("striped", "hold_position")) %>% 
  save_kable(file.path(tabpath, "rep_tab_main.tex"))











