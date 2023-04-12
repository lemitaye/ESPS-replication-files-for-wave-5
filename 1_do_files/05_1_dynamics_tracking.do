********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - tracking
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${supp}/replication_files/2_raw_data/ESS4_2018-19/Data/sect_cover_pp_w4.dta", clear

duplicates drop household_id, force
keep household_id ea_id saq01
gen wave=4

save "${tmp}/dynamics/cover_pp_w4.dta", replace


use "${rawdata}/PP/sect_cover_pp_w5.dta", clear

duplicates drop household_id, force
keep household_id ea_id saq01
gen wave=5

save "${tmp}/dynamics/cover_pp_w5.dta", replace


merge 1:1 household_id using "${tmp}/dynamics/cover_pp_w4.dta", force

rename _merge hh_status

label define _merge 1 "1. Newly added in ESPS5", modify
label define _merge 2 "2. Dropped in ESPS5", modify
label define _merge 3 "3. Matched ", modify

save "${tmp}/dynamics/05_1_track_hh.dta", replace


* are there new EAs added in ESS5?

use "${supp}/replication_files/2_raw_data/ESS4_2018-19/Data/sect_cover_pp_w4.dta", clear

destring household_id, replace
collapse (firstnm) saq14 pw_w4 saq01 (count) household_id, by(ea_id)
rename saq01 region_w4
rename saq14 location_w4
rename household_id nohh_per_ea_w4

tempfile cover_pp_ea_w4
save `cover_pp_ea_w4'

use "${rawdata}/PP/sect_cover_pp_w5", clear

destring household_id, replace
collapse (firstnm) saq14 pw_w5 saq01 (count) household_id, by(ea_id)
rename saq01 region_w5
rename saq14 location_w5
rename household_id nohh_per_ea_w5

merge 1:1 ea_id using `cover_pp_ea_w4', force

tab region_w5 _m  // # of EAs added
tab region_w4 _m  // # of EAs dropped (with 0 hhs)
sum nohh_per_ea_w5

save "${tmp}/dynamics/track_ea_w5.dta", replace


* ESPS4 households that were in EAs surveyed in ESPS5

use "${supp}/replication_files/2_raw_data/ESS4_2018-19/Data/sect_cover_pp_w4", clear

collapse (firstnm) ea_id saq14 saq01, by(household_id)
rename saq01 region_w4
rename saq14 location_w4

tempfile cover_pp_w4
save `cover_pp_w4'

use "${rawdata}/PP/sect_cover_pp_w5", clear

destring household_id, replace
collapse (firstnm) saq14 saq01 (count) household_id, by(ea_id)
rename saq01 region_w5
rename saq14 location_w5
rename household_id nohh_per_ea_w5

merge 1:m ea_id using `cover_pp_w4'

generate ea_missing=.
replace ea_missing=1 if _merge==2  // hhs in ESPS4 whose EAs cannot be found in ESPS5 (b/c EAs are dropped)
replace ea_missing=0 if _merge==1 | _merge==3 // _merge==1: new EAs added in ESPS5

tab region_w4 ea_missing
drop if household_id==""   // 28 obs. (all from wave 5)
drop _merge

tempfile ea_merged_w5
save `ea_merged_w5'

use "${rawdata}/PP/sect_cover_pp_w5", clear

collapse (firstnm) ea_id saq14 pw_w5 saq01, by(household_id)
rename saq01 region_w5
rename saq14 location_w5
rename ea_id ea_id_w5

merge 1:1 household_id using `ea_merged_w5'

keep if _merge==2  // keep only hhs dropped from ESPS5 (i.e., only in ESPS4)
drop _merge

save "${tmp}/dynamics/05_1_track_ea_dropped.dta", replace

