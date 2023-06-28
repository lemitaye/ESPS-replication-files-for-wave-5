********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Chickpea in ESS5 and ESS3
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
* STATA Version: MP 17.0
********************************************************************************


/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/chickpea" /s /q
mkdir "${tmp}/chickpea"

shell rmdir "${tmp}/chickpea/figures" /s /q
mkdir "${tmp}/chickpea/figures"


/* Run -----------------------------------------------------------------------*/

// Source "${code}/07_1_chickpea_compare.R" from RStudio
// Source "${code}/07_2_chickpea_AgSS.R" from RStudio
do "${code}/07_3_chickpea_crops.do"
