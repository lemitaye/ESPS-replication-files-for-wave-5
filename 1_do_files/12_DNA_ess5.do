
* Preliminary analysis of DNA for ESS5

/*
Does the excel files used in this section need to be updated? (ask Solomon)
*/
* Barcoded sample
import excel "${rawdata}\DNA_data_21May20.xlsx", sheet("DNA_data") firstrow clear
save "${rawdata}\PP\PP_DNA_data", replace
//Count 1,129

* Varieties info - reference library
import excel "${rawdata}\Var_data.xlsx", sheet("Var_data") firstrow clear
save "${rawdata}\PP\Var_data", replace


use "${rawdata}\PP\PP_DNA_data", clear
rename *, lower 

duplicates list id puritypuritypercent subbinreferences, force
// 0 duplicates --> ok

duplicates tag id, gen(dup)
// 0 duplicates --> ok
keep if dup==0
drop dup

replace subbinreferences="RLi-BIRHAN-I-A" if subbinreferences=="RLi-BIRHAN-A"
generate dnadata=1
tempfile dna_data
save `dna_data'


use "${rawdata}\PP\Var_data", clear
rename *, lower

replace subbinreferences="RLi-MELEKA-A"   if subbinreferences=="RLi-MELAKA-A"
replace subbinreferences="RLi-mezezo a"   if subbinreferences==" RLi-mezezo a"
replace subbinreferences="not identified" if subbinreferences=="Non identified"

tempfile var_data
save `var_data'



*****************************************
use "${rawdata}\PP\sect9a_pp_w5", clear
rename sccq05 id     // sccq05: Crop cut sample bar code
destring id, force replace
/*
* Enumerator wrongly recoding sorghum sample as maize sample
replace id=707 if interview__key=="98-70-88-03" & s4q01b==6
foreach i in sccq01 sccq02a sccq02b sccq03 sccq04 {
replace `i'=`i'[625] if id==707
}
drop if id==707 & s4q01b==2 & interview__key=="98-70-88-03"
drop if id==154 & s4q01b==2 & interview__key=="99-91-74-53"
*/
*************************************************************
drop if id==.   

duplicates tag id, gen(dup)
duplicates drop id, force

merge 1:1 id using `dna_data'

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            72
        from master                        66  (_merge==1) // samples that did not arrive to the lab
        from using                          6  (_merge==2) // samples that do not come from the field (controls)

    matched                             1,126  (_merge==3)
    -----------------------------------------

*/

keep if _m==3
drop _m

* Merge with reference library
merge m:1 subbinreferences using `var_data'

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                             1
        from master                         0  (_merge==1)
        from using                          1  (_merge==2)

    matched                             1,123  (_merge==3)
    -----------------------------------------

*/

// RLi-ABSHIR-2_A	Barley from var data


keep if _m==3
drop _m


drop saq21
* Merge with post-planting survey cover
merge m:1 household_id using "${data}\w4_coverPP_new"
/*
 Result                           # of obs.
    -----------------------------------------
    not matched                         2,098
        from master                         0  (_merge==1)
        from using                      2,098  (_merge==2)

    matched                             1,123  (_merge==3)
    -----------------------------------------
*/
keep if _m==3
drop _m

merge 1:1 household_id holder_id Parcelroster__id Fieldroster__id Croproster__id s4q01b using "${raw4}\PP\sect4_pp_w4"

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                        15,790
        from master                         0  (_merge==1)
        from using                     15,790  (_merge==2)

    matched                             1,123  (_merge==3)
    -----------------------------------------


*/

keep if _m==3 | (interview__key=="99-91-74-53" & s4q01b==6) | (interview__key=="98-70-88-03" & s4q01b==6) 
drop _m


* Dummy for crops of interest
g maize=s4q01b==2
g sorghum=s4q01b==6
g barley=s4q01b==1


g       dtmz=. if dtmz_status=="NA"
replace dtmz=0 if dtmz_status=="No"
replace dtmz=1 if dtmz_status=="Yes"


g       qpm=. if maize==0
replace qpm=0 if maize==1 
replace qpm=1 if maize==1 & qpm_status=="Yes"



clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

g wave=4
* Cleaning intemediate variables
drop dup n

* Labels
lab var maize     "Maize"
lab var sorghum   "Sorghum"
lab var barley    "Barley"
lab var dtmz      "Drought Tolerant Maize"
lab var qpm       "Quality Protein Maize"

save "${data}\\ess4_dna_new", replace

* Misclassification variable construction

* CG - germplasm recode
g       cg=0 if cg_source=="No"
replace cg=1 if cg_source=="Yes"