
cd "C:\Users\tayel\Dropbox\Documents\SPIA\Ethiopia"

use "replication_files\2_raw_data\ESS4_2018-19\Data\sect_cover_pp_w4", clear

collapse (firstnm) ea_id saq14 pw_w4 saq01, by(household_id)
rename saq01 region_w4
rename saq14 location_w4
rename ea_id ea_id_w4

tempfile cover_pp_w4
save `cover_pp_w4'

use "LSMS_W5\2_raw_data\data\PP\sect_cover_pp_w5", clear

collapse (firstnm) ea_id saq14 pw_w5 saq01, by(household_id)
rename saq01 region_w5
rename saq14 location_w5
rename ea_id ea_id_w5

merge 1:1 household_id using `cover_pp_w4', force

tab _m
tab region_w4 _m
tab region_w5 _m


save "LSMS_W5\tmp\track_hh_w5.dta", replace


* are there new EAs added in ESS5?

use "replication_files\2_raw_data\ESS4_2018-19\Data\sect_cover_pp_w4", clear

destring household_id, replace
collapse (firstnm) saq14 pw_w4 saq01 (count) household_id, by(ea_id)
rename saq01 region_w4
rename saq14 location_w4
rename household_id nohh_per_ea_w4

tempfile cover_pp_ea_w4
save `cover_pp_ea_w4'

use "LSMS_W5\2_raw_data\data\PP\sect_cover_pp_w5", clear

destring household_id, replace
collapse (firstnm) saq14 pw_w5 saq01 (count) household_id, by(ea_id)
rename saq01 region_w5
rename saq14 location_w5
rename household_id nohh_per_ea_w5

merge 1:1 ea_id using `cover_pp_ea_w4', force

tab region_w5 _m  // # of EAs added
tab region_w4 _m  // # of EAs dropped (with 0 hhs)
sum nohh_per_ea_w5

save "LSMS_W5\tmp\track_ea_w5.dta", replace


* ESPS4 households that were in EAs surveyed in ESPS5

use "replication_files\2_raw_data\ESS4_2018-19\Data\sect_cover_pp_w4", clear

collapse (firstnm) ea_id saq14 saq01, by(household_id)
rename saq01 region_w4
rename saq14 location_w4

tempfile cover_pp_w4
save `cover_pp_w4'

use "LSMS_W5\2_raw_data\data\PP\sect_cover_pp_w5", clear

destring household_id, replace
collapse (firstnm) saq14 saq01 (count) household_id, by(ea_id)
rename saq01 region_w5
rename saq14 location_w5
rename household_id nohh_per_ea_w5

merge 1:m ea_id using `cover_pp_w4'

generate ea_missing=.
replace ea_missing=1 if _merge==2
replace ea_missing=0 if _merge==1 | _merge==3

tab region_w4 ea_missing
drop if household_id==""   // 28 obs. (all from wave 5)
drop _merge

tempfile ea_merged_w5
save `ea_merged_w5'

use "replication_files\3_report_data\ess4_pp_cov_new", clear
merge 1:1 household_id using `ea_merged_w5'






















