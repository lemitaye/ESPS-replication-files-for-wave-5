  ********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Household covariates - Part I
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Solomon Alemu]
* STATA Version: MP 17.0
********************************************************************************

** Demographics and Education - sect 1 & 2 hh_w5


use "${rawdata}/HH/sect1_hh_w5.dta", clear

gen age_head= s1q03a if s1q01==1

collapse (max) age_head, by ( household_id )
label variable age_head "Age of household head (in years)"

clonevar age_head_wiz = age_head
winsor2 age_head_wiz, replace cuts(1 99)
label variable age_head_wiz "Age of household head (in years) - winsorized"

order age_head_wiz, after (age_head)

tempfile age_head
save `age_head'


* Houssing - secttion 10a ------------------------------------------------------
/*
use "${rawdata}/HH/sect10a_hh_w5.dta", clear  // no data

order s10aq08 s10aq09 s10aq10 s10aq12  s10aq27 s10aq21 s10aq20 s10aq06 s10aq07, after ( s10aq38 )
order s10aq34 s10aq38,after ( s10aq07 )
for var s10aq08- s10aq38:replace X=. if X==.a
for var s10aq08 - s10aq38 : tabulate X , gen(X )
save "$temp\sect10a_hh_w4_houseing", replace

*merge 1:1 household_id using "C:\Users\SAlemu\Desktop\ESS_4_2018_May\ESS4_Analysis\sect11_hh_w4_asset.dta"
merge 1:1 household_id using "$temp\sect11_hh_w4_asset.dta"
*edit if _merge==1
keep if _merge==3
drop  s10aq271 - s10aq2716
save "$temp\asset_houseing", replace

drop s10aq081-s10aq3813
winsor2 s10aq06 , replace cuts(1 99)
drop _merge
order s10aq06,after (HHown_item35)
pca HHown_item1- s10aq06 , comp(1)
predict asset
sum asset
xtile asset_index=asset, nq(5)
table asset_index, c(mean asset)
keep household_id asset asset_index
compress
save "$temp\asset_index", replace
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
reshape wide HHown_item, i(household_id) j( asset_cd)

// employ principal component analysis (PCA)
pca HHown_item29-HHown_item35, comp(1)
predict asset_prod
sum asset_prod
xtile prod_asset_index=asset, nq(5)
table prod_asset_index, stat(mean asset)

keep household_id asset_prod prod_asset_index

tempfile prod_asset_index
save `prod_asset_index'


* Non-farm enterprise and Other income- sections 12 & 13 -----------------------

use "${rawdata}/HH/sect13_hh_w5.dta", clear

sort s13q02
replace s13q02 = . if s13q02 >= 2000000

collapse (sum) s13q02, by ( household_id)
label variable s13q02 "Off-farm income in the  last 12 months? (BIRR)"
winsor2 s13q02, replace cuts(1 99)

tempfile offfarm_inc
save `offfarm_inc'



* Merging ----------------------------------------------------------------------

use "${rawdata}/HH/sect_cover_hh_w5.dta", clear 

merge 1:1 household_id using `age_head'
drop _m

merge 1:1 household_id using `asset_index'
drop _m

merge 1:1 household_id using `prod_asset_index'
drop _m

merge 1:1 household_id using `offfarm_inc'
drop _m

gen HH_DEMO_EDUC_ASSET=.
order HH_DEMO_EDUC_ASSET, after ( saq21 )

save "${tmp}/HH_LEVEL_DATA.dta", replace


*===============================================================================
** ** Covariates from ESS4-PP Modules 
*===============================================================================

**PP module-section2 and section3

 {/*sect2_pp_w4*/
 
 *sect2_pp_w4


use "${raw4}\PP\sect2_pp_w4",clear

order s2q16,after ( s2q17 )
*order s2q03,after ( s2q16_os)
recode s2q16 (7=6)
recode s2q03 (2=0)
label define Yes_no 1 "Yes" 0 "No", replace
lab values s2q03  Yes_no
tabulate s2q17, gen ( s2q17 )
tabulate s2q16, gen ( s2q16)

save "$temp\sect2_pp_w4_Cleaned", replace

use "$temp\sect2_pp_w4_Cleaned", replace

collapse (mean) s2q171 s2q172 s2q173 s2q161 s2q162 s2q163 s2q164 s2q165 s2q166, by ( household_id )

label variable s2q171 "% of plot with good soil quality"
label variable s2q172 "% of plot with fair soil quality"
label variable s2q173 "% of plot with poor soil quality"
label variable s2q161 "% of plot with Leptosol  soil type"
label variable s2q162 "% of plot with Cambisol  soil type"
label variable s2q163 "% of plot with Vertisol soil type"
label variable s2q164 "% of plot with Luvisol soil type"
label variable s2q165 "% of plot with mixed soil type"
label variable s2q166 "% of plot with other soil type"
save "$temp\sect2_pp_w4_hh", replace



*sect3_pp_w4



use "${raw4}\PP\sect3_pp_w4",clear

order saq15 s3q02a s3q02b s3q03 s3q03b s3q04 s3q05 s3q07 s3q08 s3q16 s3q17 s3q21 s3q22 s3q23 s3q24 s3q25 s3q42,after ( s3q41 )
gen Plot_level=.
order Plot_level,after ( s3q41 )

gen parcesizeHA = s3q08/10000
order parcesizeHA,after ( Plot_level )

replace parcesizeHA = s3q02a/10000 if s3q02b==2 & parcesizeHA==.

replace parcesizeHA = s3q02a if s3q02b==1 & parcesizeHA==.

replace parcesizeHA = s3q02a *0.25 if s3q02b==3 & parcesizeHA==.

replace parcesizeHA = s3q02a *0.25 if s3q02b==6 & parcesizeHA==.

sum s3q08 if s3q02b==4 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==5 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==7 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==8 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==10 & s3q02a==1 & s3q07==1
replace parcesizeHA = (s3q02a * 227.76)/10000 if s3q02b==4 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 1339.289)/10000 if s3q02b==5 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 204.4169)/10000 if s3q02b==7 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 69.28191 )/10000 if s3q02b==8 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 6176.3808 )/10000 if s3q02b==10 & parcesizeHA==.
replace parcesizeHA=. if parcesizeHA==0
winsor2 parcesizeHA , replace cuts(1 99)

label variable parcesizeHA "FieldsizeHA"

order s3q02a s3q02b s3q07 s3q08,after ( s3q41 )
order s3q12,after ( parcesizeHA )

tab s3q12, gen ( s3q12 )
order s3q121 s3q122 s3q123,after ( parcesizeHA )
order s3q12,after ( s3q08 )

order s3q35,after ( s3q12 )

gen fild_prp =1 if s3q35<=6
replace fild_prp=0 if s3q35==7
replace fild_prp=0 if s3q35==8
order s3q34,after ( s3q12 )
replace s3q35=0 if s3q35==8

gen fild_prpa = s3q35
order fild_prpa,after ( fild_prp )
lab values fild_prpa  s3q35
fre fild_prpa
replace fild_prpa=. if fild_prpa==7
replace fild_prpa=. if fild_prpa==8

*replace s3q35_os = subinstr(s3q35_os, " ", "", .)
replace s3q35_o = subinstr(s3q35_o, " ", "", .)								// (!) IMPORTANT CHANGE DOUBLE-CHECK

replace fild_prpa= 3 if s3q35_o == "BORROWEDOXEN"
replace fild_prpa= 3 if s3q35_o == "PARENTS/RELATIVESOXEN"
replace fild_prpa= 3 if s3q35_o == "RENTEDOXEN(HAYWILLBEGIVENTOTHEOWNER)"
replace fild_prpa= 3 if s3q35_o == "SHAREDOXEN"
replace fild_prpa= 3 if s3q35_o == "USINGLANDLORD'SOXEN"
replace fild_prpa= 3 if s3q35_o == "USINGOTHERLIVESTOCKS(HOURSE)"
replace fild_prpa= 5 if s3q35_o == "HANDTOOLS"

recode fild_prpa (2=1)(4=3)

replace fild_prpa=. if fild_prpa==0


tab fild_prpa, gen ( fild_prpa )
order fild_prpa1- fild_prpa4,after ( fild_prp )
order fild_prpa,after ( s3q35 )

label variable fild_prpa1 "fild_prpa==1. USING OWN/rented TRACTOR"
label variable fild_prpa2 "fild_prpa==3. USING OWNED/rented/borrowed LIVESTOCK"

order fild_prpa1- fild_prpa4,after ( fild_prp )
order fild_prpa,after ( s3q35 )

for var fild_prpa1- fild_prpa4: replace X=0 if fild_prp==0
sum fild_prp- fild_prpa4

order s3q16 s3q17,after ( s3q05 )
gen fert_orginor =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1| s3q25==1 |s3q26==1 |s3q27==1
replace fert_orginor =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2 & s3q25==0 & s3q26==2 & s3q27==2

order s3q03,after ( fild_prpa4 )
order fert_orginor,after ( s3q03 )
order fert_orginor,after ( s3q17 )
order s3q25,after ( fert_orginor )

gen inorgfer =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1
replace inorgfer =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2

label variable fert_orginor "Is fertilizer used - both org and inorganic"
label variable fert_orginor "Is fertilizer used - both org and inorganic?"
label variable inorgfer "Only inorganic fer"

label variable fert_orginor "Is fertilizer used-organic or inorganic?"

replace inorgfer=0 if fert_orginor==0
replace s3q25 =0 if fert_orginor==0

gen fert_orginor_both =1 if s3q25==1 & inorgfer==1
replace fert_orginor_both=0 if inorgfer==0 & s3q25==0
replace fert_orginor_both=0 if inorgfer==1 & s3q25==0
replace fert_orginor_both=0 if inorgfer==0 & s3q25==1
sum fert_orginor_both
order fert_orginor_both,after ( fert_orginor )
label variable fert_orginor_both "Is fertilizer used- both organic and inorganic?"


save "$temp\sect3_pp_w4_cleaned", replace

use "$temp\sect3_pp_w4_cleaned", replace

collapse (sum) parcesizeHA  (max) fild_prp (mean) fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 (max) s3q16 s3q17 fert_orginor inorgfer, by ( household_id )

label variable parcesizeHA "parcesizeHA"

label variable fild_prp "Was [FIELD] prepared for planting? "

label variable fild_prpa1 "% of plot prepared by Tractor"
label variable fild_prpa2 "% of plot prepared by Animal"
label variable fild_prpa3 "% of plot prepared by Digging hand"
label variable fild_prpa4 "% of plot prepared by other methods"

label variable s3q16 "Is  [FIELD] under Extension Program during the current agricultural season?"
label variable s3q17 "Is [FIELD] irrigated during the current agricultural season?"
label variable fert_orginor "Is fertilizer used   both org and inorganic?"
label variable inorgfer "Only inorganic fert"


save "$temp\sect3_pp_w4_hh", replace

}

*Merging PP module-section2, section3,section4 HH_LEVEL_DATA_2018

{/*Merging plot level data*/

use "$temp\HH_LEVEL_DATA.dta", clear 

merge 1:1 household_id using "$temp\sect3_pp_w4_hh.dta"
drop if _merge==2
drop _m
merge 1:1 household_id using "$temp\sect2_pp_w4_hh.dta"
drop if _merge==2
drop _m
gen INFORMAION_PLOT_LEVEL =.
order INFORMAION_PLOT_LEVEL ,after ( s13q02 )
save "$temp\HH_PP_LEVEL_DATA.dta", replace

}