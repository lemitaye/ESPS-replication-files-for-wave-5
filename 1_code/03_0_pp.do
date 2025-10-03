*********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Post-Planting Roster
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


/* Paths ---------------------------------------------------------------------*/

shell rmdir "${tmp}/pp" /s /q
mkdir "${tmp}/pp"


/* Run -----------------------------------------------------------------------*/

do "${code}/03_1_pp_cover_sect2_parcel.do"
do "${code}/03_2_pp_sect3_field.do"
do "${code}/03_3_pp_sect4_crop.do"
do "${code}/03_4_pp_sect81_livestock.do"
do "${code}/03_5_pp_sect9a_cropcutDNA.do"
do "${code}/03_6_pp_merge.do"
do "${code}/03_7_pp_ea_level.do"
