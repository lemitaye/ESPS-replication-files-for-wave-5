********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - Tables 
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* Date created: May 02, 2023
* STATA Version: MP 17.0
********************************************************************************


/* programs for tables: ----------------------------------------------------- */

do "${code}/programs/descr_tab.do"
do "${code}/programs/covar_regress.do"
do "${code}/programs/gen_synergy.do"


/* Run ---------------------------------------------------------------------- */

do "${code}/09_1_tables_adopt_rates.do"
do "${code}/09_2_tables_covar_dstats.do"
do "${code}/09_3_tables_covar_regs.do"
do "${code}/09_4a_tables_synergies.do"
do "${code}/09_4b_tables_synergies_dna.do"
