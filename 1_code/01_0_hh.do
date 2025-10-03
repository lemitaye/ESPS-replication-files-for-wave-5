*********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Household roster
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/hh" /s /q
mkdir "${tmp}/hh"


/* Run -----------------------------------------------------------------------*/

do "${code}/01_1_hh_psnp_I.do"
// Source "${code}/01_2_hh_psnp_II.R" from RStudio
*do "${code}/01_3_hh_agg_field.do"
*do "${code}/01_4_hh_agg_crop.do"
do "${code}/01_5_hh_agg_livestock.do"
