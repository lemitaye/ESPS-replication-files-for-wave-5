********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - appending ESS4 and ESS5 data
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
* STATA Version: MP 17.0
********************************************************************************


use "${supp}/replication_files/3_report_data/wave4_hh_new.dta", clear

drop sh_*

// recode 100 to 1 for dummies for consistency:
for var hhd_treadle-hhd_ploc hhd_cross-hhd_grass lr_livIA-sr_grass ///
    hhd_ofsp-hhd_fieldp hhd_impcr1-ead_impccr: recode X (100=1)

preserve
    use "${data}/wave5_hh_new.dta", clear
    drop sh_*

    tempfile wave5_hh_new 
    save `wave5_hh_new'
restore

// append with ESS5:
append using `wave5_hh_new', force

// merge with tracking file:
merge m:1 household_id using "${tmp}/dynamics/05_1_track_hh.dta", keepusing(hh_status) nogenerate

* Merging ---------------------------------------------------------------------

use "${supp}/replication_files/3_report_data/wave4_hh_new.dta", clear

drop sh_*

// recode 100 to 1 for dummies for consistency:
for var hhd_treadle-hhd_ploc hhd_cross-hhd_grass lr_livIA-sr_grass ///
    hhd_ofsp-hhd_fieldp hhd_impcr1-ead_impccr: recode X (100=1)

for var hh_ea-othregion: rename X X_w4
/*
foreach var of varlist hh_ea-othregion {
    local lbl : variable label `var'
    label var `"`lbl'"' + "wave 4" 	
}
*/
preserve
    use "${data}/wave5_hh_new.dta", clear
    drop sh_*

    for var hh_ea-maize_cg: rename X X_w5

    tempfile wave5_hh_new 
    save `wave5_hh_new'
restore

merge 1:1 household_id using `wave5_hh_new', force
keep if _merge==3
drop _merge



































