********************************************************************************
*                           Ethiopia Synthesis Report - v2
*    DO: ESS4-ESS5 dynamics - analyzing chickpea
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
* STATA Version: MP 17.0
********************************************************************************

* Crop roster data in ESS4

use "${raw4}/sect4_pp_w4.dta", clear

gen grow_cpea_w4 = (s4q01b==11)

preserve
    collapse (max) grow_cpea_w4, by(household_id)
    save "${tmp}/dynamics/06_4_cpea_hh_w4.dta", replace
restore


* Crop roster in ESS5

use "${rawdata}/PP/sect4_pp_w5.dta", clear

gen grow_cpea_w5 = (s4q01b==11)

preserve
    collapse (max) grow_cpea_w5, by(household_id)
    save "${tmp}/dynamics/06_4_cpea_hh_w5.dta", replace
restore

* Merge 
use "${tmp}/dynamics/06_4_cpea_hh_w4.dta", clear

merge 1:1 household_id using "${tmp}/dynamics/06_4_cpea_hh_w5.dta"
keep if _merge==3
drop _merge

save "${tmp}/dynamics/06_4_cpea_hh.dta", replace 


// Crops for households in wave 4
use "${raw4}/sect4_pp_w4.dta", clear

merge m:1 household_id using  "${tmp}/dynamics/06_4_cpea_hh.dta"