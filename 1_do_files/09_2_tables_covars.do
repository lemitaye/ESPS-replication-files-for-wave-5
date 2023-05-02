********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - Tables on covariates
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* Date created: May 02, 2023
* STATA Version: MP 17.0
********************************************************************************

* Descriptive stats of covariates ----------------------------------------------

use "${tmp}/covariates/04_2_covars_hh_pp.dta", clear


#delimit;
global hhlevel   
parcesizeHA fem_head fowner flivman hhd_flab age_head nom_totcons_aeq consq1 
consq2 asset_index pssetindex income_offfarm
;
#delimit cr




descr_tab "$hhlevel"										

#delimit;
xml_tab C,  save("${tmp}/covariates/tables/04_4_1_descriptive_stats.xml") replace 
sheet("Table 13 - ESS5", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" 
"Other regions" "Other regions" "Other regions" "National" "National" "National" 
"National" "National" ) showeq 
title(Table 1: ESS5 - Household characteristics)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4D 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. These are multiplied by 100 for dummy variables to express them as percengages. 
Only rural sample included.) //Add your notes here
;
#delimit cr		



* Who are the adopters? --------------------------------------------------------

use "${data}/ess5_pp_hh_new.dta", clear 

merge 1:1 household_id using "${tmp}/covariates/04_2_covars_hh_pp.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             2,079  (_merge==3)
    -----------------------------------------
*/
drop _merge

rename hhd_cross_largerum crlargerum
rename hhd_cross_smallrum crsmallrum
rename hhd_cross_poultry crpoultry

rename total_cons_ann_win totconswin
rename nom_totcons_aeq nmtotcons


* HH level ----

#delimit;
global hhdemo      
hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann 
totconswin nmtotcons consq1 consq2 adulteq 
;
#delimit cr


#delimit;
global adopt     
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor 
hhd_ploc hhd_ofsp hhd_awassa83 hhd_kabuli hhd_seedv1 hhd_seedv2 hhd_malt hhd_durum 
hhd_avocado hhd_papaya hhd_mango hhd_fieldp hhd_psnp 
maize_cg dtmz hhd_agroind hhd_grass hhd_cross crlargerum crsmallrum crpoultry
;
#delimit cr



covar_regress "$adopt" "$hhdemo"

local cname ""
foreach var in $hhdemo {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $adopt {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "'		
}

#delimit ;
xml_tab D,  save("${tmp}/covariates/tables/04_4_2_adopters_chrxs.xml") replace 
sheet("Table 14 - ESS5", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESPS5 - Correlates of adoption)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the 
	column variable on the row variable.); 
# delimit cr


* EA level ----

use "${data}/ess5_pp_cov_ea_new.dta", clear

rename ead_sweetpotato ead_sp
rename ead_mintillage ead_mtill

#delimit;
global adopt5 ead_ofsp ead_awassa83 ead_avocado ead_papaya ead_mango ead_fieldp 
ead_sp ead_motorpump ead_rdisp ead_rotlegume ead_cresidue1 ead_cresidue2 ead_mtill 
ead_zerotill ead_consag1 ead_consag2 ead_swc ead_terr ead_wcatch ead_affor ead_ploc 
commirr ead_cross ead_crlr ead_crpo ead_livIA ead_agroind ead_grass ead_kabuli
ead_psnp maize_cg dtmz ead_impcr2 ead_impcr1
;
#delimit cr

#delimit;
global eacov5 cs9q01 cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 
cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 
cs6q15_13 cs4q01_11 cs4q01_12 cs4q01_13 cs4q01_14 cs4q03 cs4q08 cs4q11 cs4q14 
cs4q52 cs9q13 cs9q13_wiz cs9q14 cs6q01 cs6q10 cs4q02 cs4q02_wiz cs4q01 cs4q09 
cs4q09_wiz cs4q11 cs4q12b cs4q12b_wiz  cs4q15 cs4q15_wiz cs3q02 cs3q02_wiz cs4q52 
cs4q53 cs4q53_wiz 
;
#delimit cr

covar_regress "$adopt5" "$eacov5"

local cname ""
foreach var in $eacov5 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $adopt5 {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "'		
}

#delimit ;
xml_tab D,  save("${tmp}/covariates/tables/04_4_3_adopters_chrxs_ea.xml") replace 
sheet("Table 14 - ESS5 EA level", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESPS5 - Correlates of adoption)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the column 
	variable on the row variable.); 
# delimit cr


