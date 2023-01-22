
* Preliminary analysis of DNA for ESS5

*****************************************
use "${rawdata}\PP\sect9a_pp_w5", clear
rename sccq05 barcode22     // sccq05: Crop cut sample bar code
destring barcode22, force replace
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
drop if barcode22==.   

duplicates tag barcode22, gen(dup)   // no duplicates
duplicates drop barcode22, force

merge 1:1 barcode22 using "${rawdata}\DNA_with_varinfo_2022_last" // DNA data prepared by Solomon
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            14
        from master                         2  (_merge==1)
        from using                         12  (_merge==2)

    Matched                               476  (_merge==3)
    -----------------------------------------

*/

keep if _m==3  
drop _m


* Merge with post-planting survey cover
merge m:1 household_id using "${data}\w5_coverPP_new", force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,643
        from master                         0  (_merge==1)
        from using                      1,643  (_merge==2)

    Matched                               476  (_merge==3)
    -----------------------------------------
*/
keep if _m==3
drop _m

merge 1:1 household_id holder_id parcel_id field_id crop_id s4q01b using "${rawdata}\PP\sect4_pp_w5"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        13,763
        from master                         0  (_merge==1)
        from using                     13,763  (_merge==2)

    Matched                               476  (_merge==3)
    -----------------------------------------

*/

keep if _m==3 
drop _m


* Dummy for crops of interest
tab s4q01b   // maize is the only crop
/*
          1.Crop code |      Freq.     Percent        Cum.
----------------------+-----------------------------------
             2. MAIZE |        476      100.00      100.00
----------------------+-----------------------------------
                Total |        476      100.00

*/


generate dtmz=. if dtmz_status22=="NA"
replace dtmz=0 if dtmz_status22=="No"
replace dtmz=1 if dtmz_status22=="Yes"

/*
generate qpm=.
replace qpm=0 
replace qpm=1 if qpm_status22=="Yes"   // qpm_status is missing (?)
*/
* CG - GERMPLASM
generate maize_cg=0 
replace maize_cg=1 if cg_source22=="Yes"

drop region
clonevar region=saq01  
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

generate wave=5

* Cleaning intemediate variables
drop dup n

* Labels
lab var dtmz      "Drought Tolerant Maize"
lab var qpm       "Quality Protein Maize"
lab var maize_cg "Maize DNA-fingerprinting"

save "${data}\ess5_dna_new", replace


* Collapse at HH-level 

collapse (max) qpm dtmz maize_cg (firstnm) pw_w5 region saq01 ea_id, by(household_id)

lab var dtmz      "Drought Tolerant Maize"
lab var maize_cg  "Maize DNA-fingerprinting"

save "${data}\ess5_dna_hh_new", replace




* Misclassification variable construction

* CG - germplasm recode
* generate cg=0 if cg_source=="No"
* replace cg=1 if cg_source=="Yes"


 
