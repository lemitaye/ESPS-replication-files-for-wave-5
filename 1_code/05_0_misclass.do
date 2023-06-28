********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Misclassification using maize DNA data
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/missclass" /s /q
mkdir "${tmp}/missclass"

shell rmdir "${tmp}/missclass/tables" /s /q
mkdir "${tmp}/missclass/tables"


/* Program for tables --------------------------------------------------------*/

do "${code}/programs/descr_tab.do"


/* Run -----------------------------------------------------------------------*/

do "${code}/05_1_misclass_purity.do"
do "${code}/05_2_misclass_year.do"
do "${code}/05_3_misclass_exotic.do"
do "${code}/05_4_misclass_dna.do"
do "${code}/05_5_misclass_source.do"