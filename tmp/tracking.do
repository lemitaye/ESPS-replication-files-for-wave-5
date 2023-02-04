
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
replace ea_missing=1 if _merge==2  // hhs in ESPS4 whose EAs cannot be found in ESPS5 (b/c EAs are dropped)
replace ea_missing=0 if _merge==1 | _merge==3 // _merge==1: new EAs added in ESPS5

tab region_w4 ea_missing
drop if household_id==""   // 28 obs. (all from wave 5)
drop _merge

tempfile ea_merged_w5
save `ea_merged_w5'

use "LSMS_W5\2_raw_data\data\PP\sect_cover_pp_w5", clear

collapse (firstnm) ea_id saq14 pw_w5 saq01, by(household_id)
rename saq01 region_w5
rename saq14 location_w5
rename ea_id ea_id_w5

merge 1:1 household_id using `ea_merged_w5'

keep if _merge==2  // keep only hhs dropped from ESPS5 (i.e., only in ESPS4)

save "LSMS_W5\tmp\track_ea_dropped.dta", replace


** MAIZE-DNA TRACKING ***

** Household level

use "ESS5_DNA_Data\ESS_2022_DNA_Analysis\DNA_Report data\ESS4_dna_new_Mod", clear

keep if s4q01b==2   // retain only maize

collapse (firstnm) ea_id saq01, by(household_id)
rename saq01 region_w4
rename ea_id ea_id_w4

tempfile dna_hh_w4
save `dna_hh_w4'

use "LSMS_W5\3_report_data\ess5_dna_hh_new.dta", clear

rename saq01 region_w5
rename ea_id ea_id_w5
keep household_id ea_id_w5 region_w5

merge 1:1 household_id using `dna_hh_w4', force

tab _m
tab region_w4 _m
tab region_w5 _m


save "LSMS_W5\tmp\track_dna_hh.dta", replace


** EA level

use "ESS5_DNA_Data\ESS_2022_DNA_Analysis\DNA_Report data\ESS4_dna_new_Mod", clear

destring household_id, replace
collapse (firstnm) saq01 (count) household_id, by(ea_id)
rename saq01 region_w4
rename household_id nohh_per_ea_w4

tempfile dna_ea_w4
save `dna_ea_w4'

use "LSMS_W5\3_report_data\ess5_dna_hh_new.dta", clear

destring household_id, replace
collapse (firstnm) saq01 (count) household_id, by(ea_id)
rename saq01 region_w5
rename household_id nohh_per_ea_w5

merge 1:1 ea_id using `dna_ea_w4', force

tab region_w5 _m  // # of EAs added
tab region_w4 _m  // # of EAs dropped (with 0 hhs)
sum nohh_per_ea_w5

save "LSMS_W5\tmp\track_dna_ea.dta", replace


* comparing covaritates b/n dropped and matched hhs:

use "LSMS_W5\tmp\track_dna_hh.dta", replace

keep if _merge==2 | _merge==3  // retain matched & dropped hhs
rename _merge merge

merge 1:1 household_id using "LSMS_W5\3_report_data\ess4_pp_cov_new", keepusing(household_id hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann total_cons_ann_win nom_totcons_aeq consq1 consq2 adulteq )
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         2,680
        from master                         0  (_merge==1)
        from using                      2,680  (_merge==2)

    Matched                               219  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2   // drop non-DNA households
drop _merge

rename nom_totcons_aeq nmtotcons
rename total_cons_ann_win totconswin
rename ea_id_w4 ea_id
drop ea_id_w5 


save "LSMS_W5\tmp\track_dna_cov.dta", replace














