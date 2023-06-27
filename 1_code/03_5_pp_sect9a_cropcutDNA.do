

*****************************************
/*
Created on: February 20, 2023
Author: Lemi Daba (tayelemi@gmail.com)
Description: Merging ESPS5 DNA file with crop cut data and some of the other
files from PP module in ESPS5
*/


use "${rawdata}/PP/sect9a_pp_w5.dta", clear

rename sccq05 barcode22     // sccq05: Crop cut sample bar code

destring barcode22, force replace

drop if barcode22==.       // remove crop-cut obs. without DNA

duplicates tag barcode22, gen(dup)   // no duplicates
* duplicates drop barcode22, force
drop dup

merge 1:1 barcode22 using "${supp}/DNA_with_varinfo_2022_last.dta" 
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


* Merge with post-planting survey cover ----------------------------------------
preserve
    use "${rawdata}/PP/sect_cover_pp_w5.dta", clear
    isid holder_id   // holder_id is a uniuqe ID 

    * # of households per EA from PP cover
    egen hh_ea = count(household_id), by(ea_id)
    lab var hh_ea "Number of households per EA"

    duplicates drop household_id ea_id saq01 saq02 saq03 saq04 saq05 saq06 saq07 saq08, force

    tempfile w5_coverPP_new
    save `w5_coverPP_new'
restore


merge m:1 household_id using `w5_coverPP_new', force
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

* Merge with crop section from PP ----------------------------------------------
merge 1:1 household_id holder_id parcel_id field_id crop_id s4q01b ///
    using "${rawdata}/PP/sect4_pp_w5.dta"

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

* Merging with Section 5: Seeds Roster (to discover source of seed) -------------
preserve
    use "${rawdata}/PP/sect5_pp_w5.dta", clear
    
    keep if s5q0B==2 // retain only maize

    sort household_id holder_id seed_id
    duplicates drop holder_id household_id, force
    
    keep holder_id household_id s5q01a s5q01b s5q02 s5q03_1 s5q03_2
    
    save "${tmp}/01_3_seed_sources_w5.dta", replace
restore

merge m:1 holder_id household_id using "${tmp}/01_3_seed_sources_w5.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           570
        from master                         0  (_merge==1)
        from using                        570  (_merge==2)

    Matched                               476  (_merge==3)
    -----------------------------------------

*/
keep if _merge==1 | _merge==3
drop _merge

* removing unnecessary vars:
#delimit ;
drop region Holdername HHname holderid HHid EAcode village woreda zone saq10 
saq11 saq13 saq17 saq18 InterviewDate saq19__Latitude saq19__Longitude saq19__Accuracy 
saq19__Altitude saq19__Timestamp s4q14b s4q14c s4q14d s4q20 s4q25 s4q26 ;
#delimit cr

* clean variable names:
clonevar region=saq01  
rename Panel_household panel_hh
rename *22 *
rename puritypuritypercent purity_percent
rename nameofvaraity variety_name
rename yearrelease year_release
rename originpedigree origin_pedigree
rename def4_status_ def4_status

* Dummy for DTMZ status
generate dtmz=. if dtmz_status=="NA"
replace dtmz=0 if dtmz_status=="No"
replace dtmz=1 if dtmz_status=="Yes"


* CG - GERMPLASM
generate maize_cg=0 
replace maize_cg=1 if cg_source=="Yes"

generate wave=5

* Labels
lab var dtmz      "Drought Tolerant Maize"
lab var qpm       "Quality Protein Maize"
lab var maize_cg  "Maize CG-germplasm"

save "${data}/03_5_ess5_dna_plot.dta", replace
 

* A file collapsed at the household level: 

#delimit ;
collapse (max) sccq01 sccq01b panel_EA panel_hh qpm dtmz maize_cg (firstnm) 
pw_w5 region saq12 ea_id wave, by(household_id) ;
#delimit cr

lab var dtmz      "Drought Tolerant Maize"
lab var qpm       "Quality Protein Maize"
lab var maize_cg  "Maize CG-germplasm"

save "${data}/03_5_ess5_dna_hh.dta", replace

