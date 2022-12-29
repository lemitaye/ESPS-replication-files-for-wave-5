

********************************************************************************
* MERGE DIFFERENT MODULES *
********************************************************************************

use "${data}\w5_coverPP_new", clear

merge 1:1 household_id using "${tmp}\PP_W5S3"
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                            20
        from master                        20  (_merge==1)
        from using                          0  (_merge==2)

    matched                             2,879  (_merge==3)
    -----------------------------------------

*/

drop _merge

* merge 1:1 household_id using `PP_W4S81'  // missing!

*drop _merge

merge 1:1 household_id using "${tmp}\pp_w5s4"
/*
   Result                           # of obs.
    -----------------------------------------
    not matched                           700
        from master                       700  (_merge==1)
        from using                          0  (_merge==2)

    matched                             2,199  (_merge==3)
    -----------------------------------------
*/

drop _m 
/*
*MERGE WITH HH-COVER FOR WEIGHTS
merge 1:1 household_id using `hh_sectcover'

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         4,109
        from master                       110  (_merge==1)
        from using                      3,999  (_merge==2)

    matched                             2,789  (_merge==3)
    -----------------------------------------
*/
keep if _m==3

lab var sh_hh_largerum_k "Large ruminants - kept" 
lab var sh_hh_largerum_o "Large ruminants - owned" 
lab var sh_hh_smallrum_k "Small ruminants - kept"
lab var sh_hh_smallrum_o "Small ruminants - owned"
lab var sh_hh_poultry_k  "Poultry - kept"
lab var sh_hh_poultry_o  "Poultry - owned"

lab var hhd_cross_largerum "Crossbred LARGE RUMINANTS"
lab var hhd_cross_smallrum "Crossbred SMALL RUMINANTS"
lab var hhd_cross_poultry  "Crossbred POULTRY"
*/

generate wave = 5
clonevar region = saq01
replace region=0 if saq01==2 | saq01==5 | saq01==6 | saq01==12 | saq01==13 | saq01==15 
// region = 0 for Afar (2), Somali (5), Benishangul Gumuz (6), Gambela (12), 
// Harar (12), and Dire Dawa (15)

generate othregion = 0
replace othregion = saq01 if saq01==2 | saq01==5 | saq01==6 | saq01==12 | saq01==13 | saq01==15 

/*
local hhd hhd_*  po_livIA po_elepgrass po_gaya po_sasbaniya po_alfa lr_livIA lr_elepgrass lr_gaya lr_sasbaniya lr_alfa sr_livIA sr_elepgrass sr_gaya sr_sasbaniya sr_alfa
foreach var of varlist `hhd' {
replace `var'=`var'*100	

}

foreach i in cr1 cr2 cr6 {
    replace `i'=0 if `i'==.
}
*/
*Cleaning intermediate variables
drop impcr*max impcr*_sum*  sh_plothh_swc2_cond*

save "${data}\wave5_hh_new", replace
save "${data}\ess5_pp_hh_new", replace