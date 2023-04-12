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


/* ---------------------------------------------------------------------------*/

* do 