  ********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Household covariates
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Paola Mallia]
* STATA Version: MP 17.0
********************************************************************************
 

* Years of schooling -----------------------------------------------------------

use "${rawdata}/HH/sect2_hh_w5.dta", clear

gen     yrseduc=.
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


merge 1:1 household_id individual_id using "${rawdata}/HH/sect1_hh_w5.dta"
keep if _m==3
drop _merge

keep if s1q01==1  // retain the head of the household

collapse (max) yrseduc, by(household_id)
lab var yrseduc "HH-head years of education completed"


replace yrseduc=0 if yrseduc==.

tempfile educ_w5
save `educ_w5'


* Demographic groups -----------------------------------------------------------

use "${rawdata}/HH/sect1_hh_w5.dta", clear

bysort household_id : egen hh_size=count(individual_id)

collapse (max)  hh_size, by(household_id)
label variable hh_size "Household size"

tempfile agegroup
save `agegroup'


* Female family farm Labor -----------------------------------------------------

// Land preparation, planting, fertilizer application etc. - PP survey
use "${rawdata}/PP/sect3_pp_w5.dta", clear

rename s3q29a s3q29_1
rename s3q29e s3q29_2
rename s3q29i s3q29_3
rename s3q29m s3q29_4


reshape long s3q29_, i(holder_id household_id parcel_id field_id) j(membernb)

drop if s3q29_==.a & (s3q28==. | s3q28==0 )

rename  s3q29_ s1q00
merge m:1 holder_id household_id s1q00 using  "${rawdata}/PP/sect1_pp_w5.dta"

drop if _m==2
drop _merge

bys household_id parcel_id field_id: egen fhhlab1=count(s1q00) if s1q03==2 & s1q02>=15

merge m:1 household_id using `agegroup', keepusing(hh_size)
drop if _m==2
drop _merge

gen sh_fhhlab1=fhhlab1/hh_size 
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

gen     hhd_flab=.
replace hhd_flab=0 if sh_fhhlabavg1<0.5
replace hhd_flab=1 if sh_fhhlabavg1>=0.5
lab var hhd_flab "Share of female family labor >50%"


tempfile  hhfamlab1
save     `hhfamlab1'

