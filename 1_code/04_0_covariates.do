*********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Household covariates
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Solomon Alemu & Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************

/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/covariates" /s /q
mkdir "${tmp}/covariates"

shell rmdir "${tmp}/covariates/tables" /s /q
shell rmdir "${tmp}/covariates/figures" /s /q
mkdir "${tmp}/covariates/tables"
mkdir "${tmp}/covariates/figures"

/* Run -----------------------------------------------------------------------*/

do "${code}/04_1_covariates_hh.do"
do "${code}/04_2_covariates_pp.do"
do "${code}/04_3_covariates_ea.do"
