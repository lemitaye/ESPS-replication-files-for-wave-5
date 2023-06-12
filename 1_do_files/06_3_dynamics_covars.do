********************************************************************************
*                           Ethiopia Synthesis Report - v2
*    DO: ESS4-ESS5 dynamics - appending ESS4 and ESS5 data for
*             covariate analysis across waves
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
* STATA Version: MP 17.0
********************************************************************************

* appending wave 4 and wave 5 datasets

// only need covariates in wave 4
use "${dataw4}/ess4_pp_cov_new.dta", clear

// merge with EA covariates:
merge m:1 ea_id using "${dataw4}/ess4_pp_cov_ea_new.dta", keepusing(cs4q011 cs4q15 cs4q53)
keep if _merge==1 | _merge==3
drop _merge

// merge with data on geo-covariates:
merge 1:1 household_id using "${raw4}/ETH_HouseholdGeovariables_Y4.dta", ///
    keepusing(dist_road dist_market dist_border dist_popcenter dist_admhq)
keep if _merge==1 | _merge==3
drop _merge


rename nom_totcons_aeq      nmtotcons
rename hhd_mintillage       hhd_mintil
rename  total_cons_ann_win  totconswin

replace hhd_impcr2=. if maize_cg==.


#delimit;
global hhcov4
hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann 
totconswin nmtotcons consq1 consq2 adulteq age_head cs4q011 cs4q15 cs4q53 dist_road 
dist_market dist_popcenter
;
#delimit cr

#delimit;
global adopt   
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor hhd_ploc 
hhd_ofsp hhd_awassa83 hhd_avocado hhd_papaya hhd_mango hhd_fieldp hhd_cross  
hhd_crlr hhd_crsr hhd_crpo hhd_indprod hhd_grass hhd_psnp maize_cg dtmz hhd_impcr2 
hhd_impcr1
;
#delimit cr

keep household_id $hhcov4 $adopt
gen wave=4

use "${data}/ess5_pp_hh_new.dta", clear

// shorter names:
rename hhd_cross_largerum hhd_crlr
rename hhd_cross_smallrum hhd_crsr
rename hhd_cross_poultry hhd_crpo
rename hhd_agroind hhd_indprod

replace hhd_impcr2=. if maize_cg==.

keep household_id $adopt






#delimit;
global adopt     
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor hhd_ploc 
hhd_ofsp hhd_awassa83 hhd_avocado hhd_papaya hhd_mango hhd_fieldp hhd_psnp 
maize_cg dtmz hhd_agroind hhd_grass hhd_cross crlargerum crsmallrum crpoultry 
hhd_impcr1 hhd_impcr2 
;
#delimit cr


























































































































