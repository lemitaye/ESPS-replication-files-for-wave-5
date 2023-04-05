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

shell rmdir "${tmp}/dynaimcs" /s /q
mkdir "${tmp}/dynamics"

shell rmdir "${tmp}/dynaimcs/tables" /s /q
shell rmdir "${tmp}/dynaimcs/figures" /s /q
mkdir "${tmp}/dynaimcs/tables"
mkdir "${tmp}/dynaimcs/figures"


global tables "${tmp}/dynaimcs/tables"
global figures "${tmp}/dynaimcs/figures"

/* ---------------------------------------------------------------------------*/

* do 