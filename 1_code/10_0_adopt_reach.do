********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 - Calculating Reach of Adoption 
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/adopt_reach" /s /q
mkdir "${tmp}/adopt_reach"

shell rmdir "${tmp}/adopt_reach/figures" /s /q
mkdir "${tmp}/adopt_reach/figures"

/* programs for tables: ----------------------------------------------------- */

do "${code}/programs/descr_tab.do"


/* Run ---------------------------------------------------------------------- */

do "${code}/10_1_adopt_reach_data.do"
// Source "${code}/10_2_adopt_reach_innovs_w4.R" from RStudio
// Source "${code}/10_3_adopt_reach_innovs_w5.R" from RStudio
// Source "${code}/10_4_adopt_reach_table.R" from RStudio
// Source "${code}/10_5_adopt_reach_figure.R" from RStudio