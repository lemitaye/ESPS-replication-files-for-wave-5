********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/dynamics" /s /q
mkdir "${tmp}/dynamics"

shell rmdir "${tmp}/dynamics/tables" /s /q
shell rmdir "${tmp}/dynamics/figures" /s /q
mkdir "${tmp}/dynamics/tables"
mkdir "${tmp}/dynamics/figures"


/* Run -----------------------------------------------------------------------*/

do "${code}/06_1_dynamics_tracking.do"
// Source "${code}/06_2_dynamics_adopt_rates.R" from RStudio
do "${code}/06_3_dynamics_adopt_matrix.do"
do "${code}/06_4_dynamics_covars.do"
// Source "${code}/06_5_dynamics_maizeDNA.R" from RStudio
// Source "${code}/06_6_dynamics_new_innovs_w5.R" from RStudio
