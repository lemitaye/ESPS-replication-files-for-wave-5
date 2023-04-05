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

global tables "${tmp}/missclass/tables"


/* ---------------------------------------------------------------------------*/

* do 