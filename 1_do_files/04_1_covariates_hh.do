*********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Household covariates
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Solomon Alemu & Paola Mallia]
* STATA Version: MP 17.0
********************************************************************************


* Section 1: Demographics - household head -------------------------------------

use "${rawdata}/HH/sect1_hh_w5.dta", clear

// Age:
gen age_head= s1q03a if s1q01==1
winsor2 age_head, cuts(1 99) suffix(_wiz) 

// Sex = female:
gen fem_head= s1q02 if s1q01==1
recode fem_head (1=0) (2=1)

// Marital status:
gen marr_head=s1q09 if s1q01==1
recode marr_head (2=1) (3=1) (1=0) (4=0) (5=0) (6=0) (7=0)

// Main occupation = Agriculture:
gen agr_head=1 if s1q01==3 & s1q21==1  // s1q21 is the occupation of biological father
replace agr_head=0 if s1q01==3 & s1q21>1 & s1q21!=.

// household size:
bysort household_id : egen hh_size=count(individual_id)

// collapse:
collapse (firstnm) ea_id saq01 saq14 (max) age_head age_head_wiz fem_head ///
    marr_head agr_head hh_size, by(household_id)

// label:
label var age_head      "Age of household head (in years)"
label var age_head_wiz  "Age of household head (in years) - winsorized"
label var fem_head      "HH-head is female"
label var marr_head     "HH-head is married"
label var agr_head      "HH-head main occupation is agriculture"
label var hh_size       "Household size"


save "${tmp}/covariates/hh_demo_head.dta", replace


* Section 2: Education ---------------------------------------------------------

use "${rawdata}/HH/sect2_hh_w5.dta", clear

merge 1:1 household_id individual_id using "${rawdata}/HH/sect1_hh_w5.dta", keepusing(s1q01)
keep if _m==3
drop _merge

gen     yrseduc=.
replace yrseduc=0  if s2q06==0 & s1q01==1
replace yrseduc=1  if s2q06==1 & s1q01==1
replace yrseduc=2  if s2q06==2 & s1q01==1
replace yrseduc=3  if s2q06==3 & s1q01==1
replace yrseduc=4  if s2q06==4 & s1q01==1
replace yrseduc=5  if s2q06==5 & s1q01==1
replace yrseduc=6  if s2q06==6 & s1q01==1
replace yrseduc=7  if s2q06==7 & s1q01==1
replace yrseduc=8  if s2q06==8 & s1q01==1
replace yrseduc=9  if s2q06==9 & s1q01==1
replace yrseduc=10 if s2q06==10 & s1q01==1
replace yrseduc=11 if s2q06==11 & s1q01==1
replace yrseduc=12 if s2q06==12 & s1q01==1
replace yrseduc=13 if s2q06==13 & s1q01==1
replace yrseduc=13 if s2q06==14 & s1q01==1
replace yrseduc=13 if s2q06==15 & s1q01==1
replace yrseduc=14 if s2q06==16 & s1q01==1
replace yrseduc=13 if s2q06==17 & s1q01==1
replace yrseduc=15 if s2q06==18 & s1q01==1
replace yrseduc=13 if s2q06==19 & s1q01==1
replace yrseduc=17 if s2q06==20 & s1q01==1
replace yrseduc=9  if s2q06==21 & s1q01==1
replace yrseduc=10 if s2q06==22 & s1q01==1
replace yrseduc=11 if s2q06==23 & s1q01==1
replace yrseduc=12 if s2q06==24 & s1q01==1
replace yrseduc=11 if s2q06==25 & s1q01==1
replace yrseduc=12 if s2q06==26 & s1q01==1
replace yrseduc=12 if s2q06==27 & s1q01==1
replace yrseduc=13 if s2q06==28 & s1q01==1
replace yrseduc=13 if s2q06==29 & s1q01==1
replace yrseduc=13 if s2q06==30 & s1q01==1
replace yrseduc=13 if s2q06==31 & s1q01==1
replace yrseduc=14 if s2q06==32 & s1q01==1
replace yrseduc=15 if s2q06==33 & s1q01==1
replace yrseduc=16 if s2q06==34 & s1q01==1
replace yrseduc=17 if s2q06==35 & s1q01==1
replace yrseduc=0  if s2q06==93 & s1q01==1
replace yrseduc=0  if s2q06==94 & s1q01==1
replace yrseduc=0  if s2q06==95 & s1q01==1
replace yrseduc=0  if s2q06==96 & s1q01==1
replace yrseduc=0  if s2q06==98 & s1q01==1

gen educ_head_att=(s2q04==1)

gen educ_head_fr=1 if s2q06<93
replace educ_head_fr=0 if s2q06>=93 & s2q06!=.

collapse (max) yrseduc educ_head_att educ_head_fr, by(household_id)

lab var yrseduc       "HH-head years of education completed"
lab var educ_head_att "HH-head attended school"
lab var educ_head_fr  "HH-head had formal education"

replace yrseduc=0 if yrseduc==.

save "${tmp}/covariates/hh_educ_head.dta", replace



* Houssing - secttion 10a ------------------------------------------------------
/*
use "${rawdata}/HH/sect10a_hh_w5.dta", clear  // no data

order s10aq08 s10aq09 s10aq10 s10aq12  s10aq27 s10aq21 s10aq20 s10aq06 s10aq07, after(s10aq38)
order s10aq34 s10aq38, after(s10aq07)
for var s10aq08- s10aq38:replace X=. if X==.a
for var s10aq08 - s10aq38 : tabulate X, gen(X)
save "${tmp}/sect10a_hh_w4_houseing", replace

*merge 1:1 household_id using "C:\Users\SAlemu\Desktop\ESS_4_2018_May\ESS4_Analysis\sect11_hh_w4_asset.dta"
merge 1:1 household_id using "${tmp}/sect11_hh_w4_asset.dta"
*edit if _merge==1
keep if _merge==3
drop  s10aq271 - s10aq2716
save "${tmp}/asset_houseing", replace

drop s10aq081-s10aq3813
winsor2 s10aq06, replace cuts(1 99)
drop _merge
order s10aq06, after(HHown_item35)
pca HHown_item1- s10aq06, comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
table asset_index, c(mean asset)
keep household_id asset asset_index
compress
save "${tmp}/asset_index", replace
*/

* Productive asset - section 11 ------------------------------------------------

use "${rawdata}/HH/sect11_hh_w5.dta", clear 

rename s11q00 HHown_item

label define Yes_no 1 "Yes" 0 "No", replace
recode HHown_item (2=0)
label values HHown_item  Yes_no

keep if asset_cd>=29

keep household_id asset_cd HHown_item
replace HHown_item=0 if HHown_item==.
reshape wide HHown_item, i(household_id) j(asset_cd)

// employ principal component analysis (PCA)
pca HHown_item29-HHown_item35, comp(1)
predict pssetindex
sum pssetindex

xtile prodasset_quint=pssetindex, nq(5)
table prodasset_quint, stat(mean pssetindex)

lab var pssetindex      "Productive asset index"
lab var prodasset_quint "Productive asset index - quintiles"

keep household_id pssetindex prodasset_quint

save "${tmp}/covariates/hh_prod_asset_index.dta", replace


* Non-farm enterprise and Other income- sections 12 & 13 -----------------------

use "${rawdata}/HH/sect13_hh_w5.dta", clear

sort s13q02
replace s13q02 = . if s13q02 >= 2000000

collapse (max) s13q01 (sum) s13q02, by (household_id)

rename s13q02 income_offfarm
rename s13q01 offfarminc

winsor2 income_offfarm, cuts(1 99) suffix(_wiz) label

lab var offfarminc                "HH received off-farm income"
label variable income_offfarm     "Annual Off-farm income in BIRR"
label variable income_offfarm_wiz "Annual Off-farm income in BIRR - winsorized"

save "${tmp}/covariates/hh_income_off.dta", replace

/*
merge 1:1 household_id using "${data}\ess4_hh_psnp"
keep if _m==3
drop _m


*Add consumption aggregates *
merge 1:1 household_id using "${raw4}\HH\cons_agg_w4"

drop _merge


merge 1:1 household_id using "${data}\ess4_pp_hhlevel_parcel_new"
drop if _m==2
drop _m

g consq1=0 if cons_quint>1
replace consq1=1 if cons_quint==1

g consq2=0 if cons_quint>2
replace consq2=1 if cons_quint==1 | cons_quint==2
lab var consq1 "Bottom 1 consumption quintile" 
lab var consq2 "Bottom 1-2 (<40%) consumption quintiles"

*/


* Merging ----------------------------------------------------------------------

* use "${rawdata}/HH/sect_cover_hh_w5.dta", clear // don't have this for now
use "${tmp}/covariates/hh_demo_head.dta", clear

*merge 1:1 household_id using "${tmp}/covariates/hh_demo.dta"
*drop _m

merge 1:1 household_id using "${tmp}/covariates/hh_educ_head.dta"
drop _m

*merge 1:1 household_id using `asset_index'
*drop _m 

merge 1:1 household_id using "${tmp}/covariates/hh_prod_asset_index.dta"
drop _m

merge 1:1 household_id using "${tmp}/covariates/hh_income_off.dta"
drop _m


save "${tmp}/covariates/04_1_covars_hh.dta", replace