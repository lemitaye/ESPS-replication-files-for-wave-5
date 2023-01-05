
********************************************************************************
*                           Ethiopia Synthesis Report 
*                                11_Covariates_ess4
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

********* Importing dashboard locations ****************************************
import excel "${rawdata}\Dashboard_distances_toimport.xlsx", sheet("ESS.Distances") firstrow allstring clear

foreach i in Dist_CG_LargeR N_20_CG_LargeR N_50_CG_LargeR N_100_CG_LargeR Dist_CG_SmallR N_20_CG_SmallR N_50_CG_SmallR N_100_CG_SmallR Dist_CG_chicken N_20_CG_chicken N_50_CG_chicken N_100_CG_chicken Dist_CG_Avocado N_20_CG_Avocado N_50_CG_Avocado N_100_CG_Avocado Dist_CG_DTMZ N_20_CG_DTMZ N_50_CG_DTMZ N_100_CG_DTMZ Dist_CG_CA N_20_CG_CA N_50_CG_CA N_100_CG_CA Dist_CG_OFSP N_20_CG_OFSP N_50_CG_OFSP N_100_CG_OFSP Dist_CG_NUME N_20_CG_NUME N_50_CG_NUME N_100_CG_NUME Dist_CG_SLM N_20_CG_SLM N_50_CG_SLM N_100_CG_SLM Dist_CG_Barley N_20_CG_Barley N_50_CG_Barley N_100_CG_Barley Dist_CG_Sorghum N_20_CG_Sorghum N_50_CG_Sorghum N_100_CG_Sorghum {
    
destring `i', force replace

}

lab var Dist_CG_chicken "Distance to closest area of CG activitiies - Poultry crossbred"
lab var Dist_CG_LargeR  "Distance to closest area of CG activitiies - Large ruminants crossbred"
lab var Dist_CG_SmallR  "Distance to closest area of CG activitiies - Small ruminants crossbred"
lab var Dist_CG_Barley  "Distance to closest area of CG activitiies - Public Private Partnership for barley seed dissemination"
lab var Dist_CG_Sorghum "Distance to closest area of CG activitiies - Improved sorghum varieties"
lab var Dist_CG_DTMZ    "Distance to closest area of CG activitiies - DTMZ varieties"
lab var Dist_CG_NUME    "Distance to closest area of CG activitiies - QPM varieties"
lab var Dist_CG_OFSP    "Distance to closest area of CG activitiies - OFSP"
lab var Dist_CG_Avocado "Distance to closest area of CG activitiies - Avocado trees"
lab var Dist_CG_CA      "Distance to closest area of CG activitiies - Conservation Agriculture"
lab var Dist_CG_SLM     "Distance to closest area of CG activitiies - Watershed level SLM"


drop saq01


save "${data}\dashboard_locations", replace

****************************
*ESS4 - years of education *
****************************

use "${rawdata}\sect2_hh_w4", clear

g       yrseduc=.
replace yrseduc=0  if s2q06==0
replace yrseduc=1  if s2q06==1
replace yrseduc=2  if s2q06==2
replace yrseduc=3  if s2q06==3
replace yrseduc=4  if s2q06==4
replace yrseduc=5  if s2q06==5
replace yrseduc=6  if s2q06==6
replace yrseduc=7  if s2q06==7
replace yrseduc=8  if s2q06==8
replace yrseduc=9  if s2q06==9
replace yrseduc=10 if s2q06==10
replace yrseduc=11 if s2q06==11
replace yrseduc=12 if s2q06==12
replace yrseduc=13 if s2q06==13
replace yrseduc=13 if s2q06==14
replace yrseduc=13 if s2q06==15
replace yrseduc=14 if s2q06==16
replace yrseduc=13 if s2q06==17
replace yrseduc=15 if s2q06==18
replace yrseduc=13 if s2q06==19
replace yrseduc=17 if s2q06==20
replace yrseduc=9  if s2q06==21
replace yrseduc=10 if s2q06==22
replace yrseduc=11 if s2q06==23
replace yrseduc=12 if s2q06==24
replace yrseduc=11 if s2q06==25
replace yrseduc=12 if s2q06==26
replace yrseduc=12 if s2q06==27
replace yrseduc=13 if s2q06==28
replace yrseduc=13 if s2q06==29
replace yrseduc=13 if s2q06==30
replace yrseduc=13 if s2q06==31
replace yrseduc=14 if s2q06==32
replace yrseduc=15 if s2q06==33
replace yrseduc=16 if s2q06==34
replace yrseduc=17 if s2q06==35
replace yrseduc=0  if s2q06==93
replace yrseduc=0  if s2q06==94
replace yrseduc=0  if s2q06==95
replace yrseduc=0  if s2q06==96
replace yrseduc=0  if s2q06==98
lab var yrseduc "HH-head years of education completed"


keep household_id individual_id yrseduc


merge 1:1 household_id individual_id using "${rawdata}\sect1_hh_w4"
keep if _m==3
drop _merge

keep if s1q01==1  // retain only household head

collapse (max) yrseduc, by(household_id)
lab var yrseduc "HH-head years of education completed"


replace yrseduc=0 if yrseduc==.

tempfile educ_w4
save `educ_w4'


*******************************************************************************
* HH Demographic groups
********************************************************************************
use "${rawdata}\sect1_hh_w4", clear
bys household_id : egen hh_size=count(individual_id)

collapse (max)   hh_size, by(household_id)

tempfile agegroup
save `agegroup'


****************************************
* Female family farm Labor             *
****************************************

* Land preparation, planting, fertilizer application etc. - PP survey
use "${rawdata}\PP\sect3_pp_w5", clear

rename s3q29a s3q29_1
rename s3q29e s3q29_2
rename s3q29i s3q29_3
rename s3q29m s3q29_4


reshape long s3q29_, i(holder_id household_id parcel_id field_id) j(membernb)

drop if s3q29_==.a & (s3q28==. | s3q28==0 )

rename  s3q29_ s1q00
merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5"

drop if _m==2
drop _merge

bys household_id parcel_id field_id: egen fhhlab1=count(s1q00) if s1q03==2 & s1q02>=15

merge m:1 household_id using `agegroup', keepusing(hh_size)
drop if _m==2
drop _merge

g  sh_fhhlab1=fhhlab1/hh_size 
bys household_id parcel_id field_id: egen sh_fhhlab2=max(sh_fhhlab1)

by household_id: egen sh_fhhlabmax=max(sh_fhhlab2)
by household_id: egen sh_fhhlabmin=min(sh_fhhlab2)
by household_id: egen sh_fhhlabavg=mean(sh_fhhlab2)

collapse (firstnm) sh_fhhlabmax sh_fhhlabmin sh_fhhlabavg, by(household_id)


rename sh_fhhlabmax sh_fhhlabmax1
rename sh_fhhlabmin sh_fhhlabmin1
rename sh_fhhlabavg sh_fhhlabavg1

lab var sh_fhhlabmax1 "Share of female family labor - Land prep., planting,etc - Max"
lab var sh_fhhlabmin1 "Share of female family labor - Land prep., planting,etc - Min"
lab var sh_fhhlabavg1 "Share of female family labor - Land prep., planting,etc - Avg"


foreach i in sh_fhhlabmax1 sh_fhhlabmin1 sh_fhhlabavg1 {
replace `i' =0 if `i' ==.
}

g       hhd_flab=.
replace hhd_flab=0 if sh_fhhlabavg1<0.5
replace hhd_flab=1 if sh_fhhlabavg1>=0.5
lab var hhd_flab "Share of female family labor >50%"



tempfile  hhfamlab1
save     `hhfamlab1'
*ex
****************************************
* FEMALE LIVESTOCK OWNERS AND MANAGERS *
****************************************


use "${rawdata}\sect8_1_ls_w4", clear
*Owner
preserve
reshape long  ls_s8_1q04_, i(holder_id household_id ls_code) j(membernb)

drop if ls_s8_1q04_==.
drop if ls_s8_1q04_==.a

rename  ls_s8_1q04_ s1q00
merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5", force
keep if _m==3
drop _merge

g flivown1=0 
replace flivown1=1 if s1q03==2
bys household_id: egen flivown=max(flivown1)
drop flivown1
lab var flivown "Female livestock owner"

rename   s1q00 ls_s8_1q04__
drop membernb
collapse (max) flivown (firstnm) ea_id  saq14, by(household_id)
lab var flivown "Female livestock owner"
tempfile flivown

save `flivown'
restore

*Manager
reshape long ls_s8_1q05_, i( holder_id household_id ls_code) j(membernb)

drop if ls_s8_1q05_==.
drop if ls_s8_1q05_==.a

rename  ls_s8_1q05_ s1q00
merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5", force

keep if _m==3
drop _merge

g       flivman1=.
replace flivman1=0 if s1q03==1
replace flivman1=1 if s1q03==2
bys household_id: egen flivman=max(flivman1)
drop flivman1




rename   s1q00 ls_s8_1q05_
drop membernb

collapse (max) flivman (firstnm) ea_id  saq14, by(household_id)

lab var flivman "At least 1 female livestock manager/keeper in the hh"
tempfile flivman
save `flivman'




********************************************************************************
* Covariates produced by Solomon
********************************************************************************
use "${rawdata}\HH_LEVEL_DATA_2018", clear

* Variable labelling
lab var sex_head      "HH-head is male"
lab var age_head      "HH-head age in years"
lab var educ_head_att "HH-head attended school"
lab var educ_head_fr  "HH-head formal education"
rename  Marital_head2 marr_head
lab var marr_head     "HH-head is married"
rename  mainoc_head2 agr_head 
lab var agr_head      "HH-head main occupation is agriculture"
*lab var adulteq  "HH size in adult equivalent"
rename  asset_index asset_quint
lab var asset_quint   "Asset index - quintiles"
rename  asset asset_index
lab var asset_index   "Asset index"
rename  asset_prod pssetindex
lab var pssetindex    "Productive asset index"
rename  prod_asset_index prodasset_quint
lab var prodasset_quint "Productive asset index - quintiles"
rename s12aq01__1 nonfarm_bus
lab var nonfarm_bus   "HH owns non-farm business"
rename s13q01 offfarminc
lab var offfarminc    "HH received off-farm income"
rename s13q02 income_offfarm
lab var income_offfarm "Annual Off-farm income in BIRR"
lab var parcesizeHA   "Total parcels size in HA per hh"

g       fem_head=.
replace fem_head=0 if sex_head==1
replace fem_head=1 if sex_head==0

lab var fem_head "HH-head is female"

*******Merge with vars produced in this do file *

merge 1:1 household_id using `educ_w4'
drop _merge


merge 1:1 household_id using `agegroup'
drop _merge

merge 1:1 household_id using "${data}\ess4_hh_psnp"
keep if _m==3
drop _m


*Add consumption aggregates *
merge 1:1 household_id using "${rawdata}\cons_agg_w4"

drop _merge


merge 1:1 household_id using "${data}\ess5_pp_hhlevel_parcel_new"
drop if _m==2
drop _m

g consq1=0 if cons_quint>1
replace consq1=1 if cons_quint==1

g consq2=0 if cons_quint>2
replace consq2=1 if cons_quint==1 | cons_quint==2
lab var consq1 "Bottom 1 consumption quintile" 
lab var consq2 "Bottom 1-2 (<40%) consumption quintiles"

save "${data}\HH_LEVEL_DATA_2018_relab", replace


********************************************************************************
*** Innovation dataset: produced in 3_PP_CG_innovation_ess4
********************************************************************************

use "${data}\ess5_pp_hh_new", clear //INNOVATIONS DATASET 
merge 1:1 household_id using `hhfamlab1'
drop if _m==2
drop _merge

merge 1:1 household_id using `flivown'
drop if _m==2
drop _merge

merge 1:1 household_id using `flivman'
drop if _m==2
drop _m

drop  saq13
merge 1:1 household_id using  "${data}\HH_LEVEL_DATA_2018_relab", force // Data created in : Do ESS4_2018_dofile__Public

keep if _m==3 | _m==1
drop _m
replace wave=5 if wave!=.
drop region
clonevar region=saq01

replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5
/*
rename hhd_cross_largerum hhd_crlr
rename hhd_cross_smallrum hhd_crsr
rename hhd_cross_poultry  hhd_crpo
g       hhd_feed=.
replace hhd_feed=0 if hhd_elepgrass==0 & hhd_gaya==0 & hhd_sasbaniya==0 & hhd_alfa==0
replace hhd_feed=100 if hhd_elepgrass==100 | hhd_gaya==100 | hhd_sasbaniya==100 | hhd_alfa==100
*/
merge 1:1 household_id using "${data}\ess4_dna_hh_new", force 
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         1,989
        from master                     1,988  (_merge==1)
        from using                          1  (_merge==2)

    matched                               787  (_merge==3)
    -----------------------------------------
*/
drop if _m==2
drop _m

*Winsorize
sum total_cons_ann, d
g total_cons_ann_win=total_cons_ann
sum total_cons_ann, d
replace total_cons_ann_win=r(p99) if total_cons_ann_win>r(p99)

lab var total_cons_ann_win "Total annual consumption - winsorize"

save "${data}\ess5_pp_cov_new", replace // HH-level 