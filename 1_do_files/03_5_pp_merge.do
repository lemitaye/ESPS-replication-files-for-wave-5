
********************************************************************************
* MERGE DIFFERENT MODULES *
********************************************************************************

use "${data}/w5_coverPP_new", clear

merge 1:1 household_id using "${tmp}/PP_W5S3"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            60
        from master                        60  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             2,019  (_merge==3)
    -----------------------------------------
*/

drop _merge

merge 1:1 household_id using "${tmp}/PP_W4S81"  

drop _merge

merge 1:1 household_id using "${tmp}/pp_w5s4"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           449
        from master                       449  (_merge==1)
        from using                          0  (_merge==2)

    Matched                             1,630  (_merge==3)
    -----------------------------------------
*/

drop _m 

* Merge with household cover for panel weights ---------------------------------

merge 1:1 household_id using "${rawdata}/HH/ESS5_weights_hh.dta", keepusing(pw_panel)
/*
     Result                      Number of obs
    -----------------------------------------
    Not matched                         2,920
        from master                         0  (_merge==1)
        from using                      2,920  (_merge==2)

    Matched                             2,079  (_merge==3)
    -----------------------------------------
*/
keep if _merge==1 | _merge==3
drop _merge

order holder_id-pw_w5 pw_panel

* Merge with psnp data:
merge 1:1 household_id using "${data}/ess5_hh_psnp.dta", keepusing(hhd_psnp)
keep if _merge==1 | _merge==3
drop _merge 


foreach i in cr1 cr2 cr6 po_livIA po_agroind po_elepgrass po_deshograss po_sesbaniya ///
        po_sinar po_lablab po_alfalfa po_vetch po_rhodesgrass lr_livIA lr_agroind lr_cowpea ///
        lr_elepgrass lr_deshograss lr_sesbaniya lr_sinar lr_lablab lr_alfalfa lr_vetch lr_rhodesgrass ///
        sr_livIA sr_agroind sr_cowpea sr_elepgrass sr_deshograss sr_sesbaniya sr_sinar sr_lablab sr_alfalfa ///
        sr_vetch sr_rhodesgrass {
    replace `i'=0 if `i'==.
}

*Cleaning intermediate variables
drop impcr*max impcr*_sum*  sh_plothh_swc2_cond*

* 8028 Farmer hotline (IVR)
preserve
    use "${rawdata}/PP/sect7_pp_w5", clear

    tab s7q03b  // s7q03b: Have you ever called the '8028', or agricultural hotline?
    generate hotline=.
    replace hotline=1 if s7q03b==1
    replace hotline=0 if s7q03b==2 | s7q03b==3

    collapse (max) hotline, by(household_id)

    label var hotline "Called the 8028, or agricultural hotline"

    tempfile hotline
    save `hotline'
restore

merge 1:1 household_id using `hotline'
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             2,079  (_merge==3)
    -----------------------------------------

*/
drop _m


merge 1:1 household_id using "${data}/ess5_dna_hh_new"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,643
        from master                     1,643  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               436  (_merge==3)
    -----------------------------------------

*/
drop _m

* append with livestock data from hh -------------------------------------------

append using "${data}/01_6_hh_livestock.dta", generate(from_hh)

// take care of duplicates
duplicates tag household_id, generate(dup)
drop if dup==1 & from_hh==1
drop dup

// final cleaning:
generate wave = 5
drop region
clonevar region = saq01
replace region=0 if saq01==2 | saq01==5 | saq01==6 | saq01==12 | saq01==13 | saq01==15 
// region = 0 for Afar (2), Somali (5), Benishangul Gumuz (6), Gambela (12), 
// Harar (12), and Dire Dawa (15)

generate othregion = 0
replace othregion = saq01 if saq01==2 | saq01==5 | saq01==6 | saq01==12 | saq01==13 | saq01==15


* save -------------------------------------------------------------------------
save "${data}/wave5_hh_new", replace
save "${data}/ess5_pp_hh_new", replace