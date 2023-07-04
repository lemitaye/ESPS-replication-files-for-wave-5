********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                   DO: Analyzing chickpea - ESS3, ESS4, and ESS5
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
* STATA Version: MP 17.0
********************************************************************************


* Crop roster data in ESS3
use "${raw3}/Post-Planting/sect4_pp_w3.dta", clear

keep if rural==1

gen grow_cpea_w3 = (pp_s4q01_b==11)
gen cpea_kabuli = (pp_s4q12c==2)

preserve
    collapse (firstnm) saq01 (max) grow_cpea_w3 cpea_kabuli, by(household_id)
    save "${tmp}/chickpea/06_4_cpea_hh_w3.dta", replace
restore

* Crop roster data in ESS4

use "${raw4}/sect4_pp_w4.dta", clear

gen grow_cpea_w4 = (s4q01b==11)

preserve
    collapse (firstnm) saq01 (max) grow_cpea_w4, by(household_id)
    save "${tmp}/chickpea/06_4_cpea_hh_w4.dta", replace
restore


* Crop roster in ESS5

use "${rawdata}/PP/sect4_pp_w5.dta", clear

gen grow_cpea_w5 = (s4q01b==11)
gen cpea_kabuli = (s4q14b==2)

preserve
    collapse (firstnm) saq01 (max) grow_cpea_w5 cpea_kabuli, by(household_id)
    save "${tmp}/chickpea/06_4_cpea_hh_w5.dta", replace
restore

* Merge 
use "${tmp}/chickpea/06_4_cpea_hh_w4.dta", clear

merge 1:1 household_id using "${tmp}/chickpea/06_4_cpea_hh_w5.dta"
keep if _merge==3
drop _merge

// matrix:
tab grow_cpea_w4 grow_cpea_w5

// at hh level:
preserve
    collapse (max) grow_cpea_w4 grow_cpea_w5, by(household_id)
    tab grow_cpea_w4 grow_cpea_w5
restore

// save
save "${tmp}/chickpea/06_4_cpea_hh.dta", replace 


// Crops for households in wave 4
use "${raw4}/sect4_pp_w4.dta", clear

merge m:1 household_id using  "${tmp}/chickpea/06_4_cpea_hh.dta"
keep if _merge==3


// Grow cp in wave 4 but stopped in wave 5
tab s4q01b if grow_cpea_w4==1 & grow_cpea_w5==0, sort

// Grow cp in wave 4 and continued to grow in wave 5
tab s4q01b if grow_cpea_w4==1 & grow_cpea_w5==1, sort


// Crops for households in wave 5
use "${rawdata}/PP/sect4_pp_w5.dta", clear

merge m:1 household_id using  "${tmp}/chickpea/06_4_cpea_hh.dta"
keep if _merge==3


// Grow cp in wave 4 but stopped in wave 5
tab s4q01b if grow_cpea_w4==1 & grow_cpea_w5==0, sort

// Grow cp in wave 4 and continued to grow in wave 5
tab s4q01b if grow_cpea_w4==1 & grow_cpea_w5==1, sort


* Number of hhs with chickpea in each wave (by region):

// ESS3:
use "${tmp}/chickpea/06_4_cpea_hh_w3.dta", clear

tab saq01 if grow_cpea_w3==1
tab saq01 if cpea_kabuli==1
tab saq01

// ESS4:
use "${tmp}/chickpea/06_4_cpea_hh_w4.dta", clear

tab saq01 if grow_cpea_w4==1
tab saq01


// ESS5:
use "${tmp}/chickpea/06_4_cpea_hh_w5.dta", clear

tab saq01 if grow_cpea_w5==1
tab saq01 if cpea_kabuli==1
tab saq01