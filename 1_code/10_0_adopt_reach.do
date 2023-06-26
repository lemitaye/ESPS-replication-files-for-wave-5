********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 - Calculating Reach of Adoption 
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************

shell rmdir "${tmp}/adopt_reach" /s /q
mkdir "${tmp}/adopt_reach"

shell rmdir "${tmp}/adopt_reach/figures" /s /q
mkdir "${tmp}/adopt_reach/figures"

* Program for tables
do "${code}/programs/descr_tab.do"


// Run do files:
// do 
