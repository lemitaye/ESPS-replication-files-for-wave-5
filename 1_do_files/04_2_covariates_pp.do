*********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Covariates from PP Modules 
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Solomon Alemu]
* STATA Version: MP 17.0
********************************************************************************



* Section 2: Parcel Roster -----------------------------------------------------

use "${rawdata}/PP/sect2_pp_w5.dta", clear

order s2q16, after(s2q17)

recode s2q16 (7=6)
recode s2q03 (2=0)
label define Yes_no 1 "Yes" 0 "No", replace
lab values s2q03  Yes_no

tabulate s2q17, gen(s2q17)
tabulate s2q16, gen(s2q16)

collapse (mean) s2q171 s2q172 s2q173 s2q161 s2q162 s2q163 s2q164 s2q165 s2q166, ///
  by (household_id)

label variable s2q171 "% of plot with good soil quality"
label variable s2q172 "% of plot with fair soil quality"
label variable s2q173 "% of plot with poor soil quality"
label variable s2q161 "% of plot with Leptosol  soil type"
label variable s2q162 "% of plot with Cambisol  soil type"
label variable s2q163 "% of plot with Vertisol soil type"
label variable s2q164 "% of plot with Luvisol soil type"
label variable s2q165 "% of plot with mixed soil type"
label variable s2q166 "% of plot with other soil type"


save "${tmp}/covariates/pp_parcel_hh.dta", replace


* Section 3: Field Roster ------------------------------------------------------

use "${rawdata}/PP/sect3_pp_w5.dta", clear

order saq15 s3q02a s3q02b s3q03 s3q03b s3q04 s3q05 s3q07 s3q08 s3q16 s3q17 ///
  s3q21 s3q22 s3q23 s3q24 s3q25 s3q42, after(s3q41)

gen plot_level=.
order plot_level, after(s3q41)

gen parcesizeHA = s3q08/10000
order parcesizeHA, after(plot_level)

replace parcesizeHA = s3q02a/10000 if s3q02b==2 & parcesizeHA==.

replace parcesizeHA = s3q02a if s3q02b==1 & parcesizeHA==.

replace parcesizeHA = s3q02a*0.25 if s3q02b==3 & parcesizeHA==.

replace parcesizeHA = s3q02a*0.25 if s3q02b==6 & parcesizeHA==.

sum s3q08 if s3q02b==4 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==5 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==7 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==8 & s3q02a==1 & s3q07==1
sum s3q08 if s3q02b==10 & s3q02a==1 & s3q07==1
replace parcesizeHA = (s3q02a * 227.76)/10000 if s3q02b==4 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 1339.289)/10000 if s3q02b==5 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 204.4169)/10000 if s3q02b==7 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 69.28191)/10000 if s3q02b==8 & parcesizeHA==.
replace parcesizeHA = (s3q02a * 6176.3808)/10000 if s3q02b==10 & parcesizeHA==.
replace parcesizeHA =. if parcesizeHA==0
winsor2 parcesizeHA, replace cuts(1 99)

label variable parcesizeHA "FieldsizeHA"

order s3q02a s3q02b s3q07 s3q08, after(s3q41)
order s3q12, after(parcesizeHA)

tab s3q12, gen(s3q12)
order s3q121 s3q122 s3q123, after(parcesizeHA)
order s3q12, after(s3q08)

order s3q35, after(s3q12)

gen fild_prp=1 if s3q35<=6
replace fild_prp=0 if s3q35==7
replace fild_prp=0 if s3q35==8
order s3q34, after(s3q12)
replace s3q35=0 if s3q35==8

gen fild_prpa = s3q35
order fild_prpa, after(fild_prp)
lab values fild_prpa  s3q35

replace fild_prpa=. if fild_prpa==7
replace fild_prpa=. if fild_prpa==8

*replace s3q35_os = subinstr(s3q35_os, " ", "", .)
replace s3q35_o = subinstr(s3q35_o, " ", "", .)	 // (!) IMPORTANT CHANGE DOUBLE-CHECK

replace fild_prpa= 3 if s3q35_o == "BORROWEDOXEN"
replace fild_prpa= 3 if s3q35_o == "PARENTS/RELATIVESOXEN"
replace fild_prpa= 3 if s3q35_o == "RENTEDOXEN(HAYWILLBEGIVENTOTHEOWNER)"
replace fild_prpa= 3 if s3q35_o == "SHAREDOXEN"
replace fild_prpa= 3 if s3q35_o == "USINGLANDLORD'SOXEN"
replace fild_prpa= 3 if s3q35_o == "USINGOTHERLIVESTOCKS(HOURSE)"
replace fild_prpa= 5 if s3q35_o == "HANDTOOLS"

recode fild_prpa (2=1) (4=3)

replace fild_prpa=. if fild_prpa==0


tab fild_prpa, gen(fild_prpa)
order fild_prpa1- fild_prpa4, after(fild_prp)
order fild_prpa, after(s3q35)

label variable fild_prpa1 "fild_prpa==1. USING OWN/rented TRACTOR"
label variable fild_prpa2 "fild_prpa==3. USING OWNED/rented/borrowed LIVESTOCK"

order fild_prpa1- fild_prpa4, after(fild_prp)
order fild_prpa, after(s3q35)

for var fild_prpa1- fild_prpa4: replace X=0 if fild_prp==0
sum fild_prp- fild_prpa4

order s3q16 s3q17, after(s3q05)
gen fert_orginor =1 if s3q21==1 | s3q22==1| s3q23==1 | s3q24==1| s3q25==1 |s3q26==1 |s3q27==1
replace fert_orginor =0 if s3q21==2 & s3q22==2 & s3q23==2 & s3q24==2 & s3q25==0 & s3q26==2 & s3q27==2

order s3q03, after(fild_prpa4)
order fert_orginor, after(s3q03)
order fert_orginor, after(s3q17)
order s3q25, after(fert_orginor)

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
order fert_orginor_both, after(fert_orginor)
label variable fert_orginor_both "Is fertilizer used- both organic and inorganic?"

* save before collapsing:
save "${tmp}/covariates/pp_field_plot.dta", replace

* collapse at hh level:
collapse (sum) parcesizeHA  (max) fild_prp (mean) fild_prpa1 fild_prpa2 ///
  fild_prpa3 fild_prpa4 (max) s3q16 s3q17 fert_orginor inorgfer, by (household_id)

label variable parcesizeHA "Total parcels size in HA per hh"
label variable fild_prp "Was [FIELD] prepared for planting?"

label variable fild_prpa1 "% of plot prepared by Tractor"
label variable fild_prpa2 "% of plot prepared by Animal"
label variable fild_prpa3 "% of plot prepared by Digging hand"
label variable fild_prpa4 "% of plot prepared by other methods"

label variable s3q16 "Is  [FIELD] under Extension Program during the current agricultural season?"
label variable s3q17 "Is [FIELD] irrigated during the current agricultural season?"
label variable fert_orginor "Is fertilizer used   both org and inorganic?"
label variable inorgfer "Only inorganic fert"


save "${tmp}/covariates/pp_field_hh.dta", replace


* Female family farm Labor -----------------------------------------------------

// Land preparation, planting, fertilizer application etc. 
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

merge m:1 household_id using "${tmp}/covariates/hh_demo_head.dta", keepusing(hh_size)
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


save "${tmp}/covariates/pp_female_labour.dta", replace


* Femal livestock owners and managers -----------------------------------------

use "${rawdata}/PP/sect8_1_ls_w5.dta", clear

* Owner:
preserve
    reshape long  ls_s8_1q04_, i(holder_id household_id ls_code) j(membernb)

    drop if ls_s8_1q04_==.
    drop if ls_s8_1q04_==.a

    rename  ls_s8_1q04_ s1q00
    merge m:1 holder_id household_id s1q00 using  "${rawdata}/PP/sect1_pp_w5.dta"
    keep if _m==3
    drop _merge

    gen flivown1=0 
    replace flivown1=1 if s1q03==2
    bysort household_id: egen flivown=max(flivown1)
    drop flivown1
    lab var flivown "Female livestock owner"

    rename   s1q00 ls_s8_1q04__
    drop membernb
    collapse (max) flivown (firstnm) ea_id saq01 saq14, by(household_id)
    lab var flivown "Female livestock owner"

    save "${tmp}/covariates/pp_female_lvstk_own.dta", replace
restore

* Manager:
reshape long ls_s8_1q05_, i(holder_id household_id ls_code) j(membernb)

drop if ls_s8_1q05_==.
drop if ls_s8_1q05_==.a

rename  ls_s8_1q05_ s1q00
merge m:1 holder_id household_id s1q00 using  "${rawdata}/PP/sect1_pp_w5.dta"

keep if _m==3
drop _merge

gen     flivman1=.
replace flivman1=0 if s1q03==1
replace flivman1=1 if s1q03==2

bysort household_id: egen flivman=max(flivman1)
drop flivman1

rename   s1q00 ls_s8_1q05_
drop membernb

collapse (max) flivman (firstnm) ea_id saq01 saq14, by(household_id)

lab var flivman "At least 1 female livestock manager/keeper in the hh"


save "${tmp}/covariates/pp_female_lvstk_mgmt.dta", replace



* Merging ----------------------------------------------------------------------

use "${tmp}/covariates/pp_parcel_hh.dta", clear 

merge 1:1 household_id using "${tmp}/covariates/pp_field_hh.dta"
drop _m

merge 1:1 household_id using "${tmp}/covariates/pp_female_labour.dta"
drop _m

merge 1:1 household_id using "${tmp}/covariates/pp_female_lvstk_own.dta"
drop _m

merge 1:1 household_id using "${tmp}/covariates/pp_female_lvstk_mgmt.dta"
drop _m

order household_id ea_id saq01 saq14


save "${tmp}/covariates/04_2_covars_pp.dta", replace


* Merge household and pp covariates with innovations data set ------------------

use "${data}/ess5_pp_hh_new.dta", clear

merge 1:1 household_id using "${data}/ess5_hh_psnp.dta", keepusing(hhd_psnp ///
    hhm_psnp hh_dpsnp hh_dpsnppc hh_ipsnp hh_dwpsnp)
keep if _merge==1 | _merge==3
drop _merge

merge 1:1 household_id using "${tmp}/covariates/04_1_covars_hh.dta"
keep if _merge==1 | _merge==3
drop _merge

merge 1:1 household_id using "${tmp}/covariates/04_2_covars_pp.dta"
keep if _merge==1 | _merge==3
drop _merge


save "${tmp}/covariates/04_2_covars_hh_pp.dta", replace

