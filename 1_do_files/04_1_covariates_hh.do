*********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Household covariates
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Solomon Alemu & Paola Mallia]
* STATA Version: MP 17.0
********************************************************************************


* Section 1: Demographics ------------------------------------------------------


use "${rawdata}/HH/sect1_hh_w5.dta", clear

gen age_head= s1q03a if s1q01==1

bysort household_id : egen hh_size=count(individual_id)

collapse (max) age_head hh_size, by(household_id)

clonevar age_head_wiz = age_head
winsor2 age_head_wiz, replace cuts(1 99)

label variable age_head "Age of household head (in years)"
label variable hh_size "Household size"
label variable age_head_wiz "Age of household head (in years) - winsorized"

order age_head_wiz, after(age_head)

save "${tmp}/covariates/hh_demo.dta", replace


* Section 2: Education ---------------------------------------------------------

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
predict asset_prod
sum asset_prod
xtile prod_asset_index=asset, nq(5)
table prod_asset_index, stat(mean asset)

keep household_id asset_prod prod_asset_index

save "${tmp}/covariates/hh_prod_asset_index.dta", replace


* Non-farm enterprise and Other income- sections 12 & 13 -----------------------

use "${rawdata}/HH/sect13_hh_w5.dta", clear

sort s13q02
replace s13q02 = . if s13q02 >= 2000000

collapse (sum) s13q02, by (household_id)
label variable s13q02 "Off-farm income in the  last 12 months? (BIRR)"
winsor2 s13q02, replace cuts(1 99)

save "${tmp}/covariates/hh_offfarm_inc.dta", replace


* Merging ----------------------------------------------------------------------

use "${rawdata}/HH/sect_cover_hh_w5.dta", clear 

merge 1:1 household_id using "${tmp}/covariates/hh_demo.dta"
drop _m

*merge 1:1 household_id using `asset_index'
*drop _m

merge 1:1 household_id using "${tmp}/covariates/hh_prod_asset_index.dta"
drop _m

merge 1:1 household_id using "${tmp}/covariates/hh_offfarm_inc.dta"
drop _m


save "${tmp}/HH_LEVEL_DATA.dta", replace