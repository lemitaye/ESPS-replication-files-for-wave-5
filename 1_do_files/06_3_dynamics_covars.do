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

// global of covariates and innovations to keep (for both waves)
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

// recode from 100 to 1
for var $adopt: replace X=1 if X==100

keep household_id $hhcov4 $adopt
gen wave=4

// merge with tracking file to id panel hhs:
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status pw_panel)
keep if _merge==1 | _merge==3
drop _merge

keep if hh_status==3

save "${tmp}/dynamics/06_3_covars_w4.dta", replace

use "${data}/ess5_pp_hh_new.dta", clear

// shorter names:
rename hhd_cross_largerum hhd_crlr
rename hhd_cross_smallrum hhd_crsr
rename hhd_cross_poultry hhd_crpo
rename hhd_agroind hhd_indprod

replace hhd_impcr2=. if maize_cg==.

keep household_id $adopt
gen wave=5

// merge with tracking file to id panel hhs:
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status pw_panel)
keep if _merge==1 | _merge==3
drop _merge

keep if hh_status==3

// merge with wave 4 covariates
merge 1:1 household_id using "${tmp}/dynamics/06_3_covars_w4.dta", keepusing($covar)
drop _merge

// save
save "${tmp}/dynamics/06_3_covars_w5.dta", replace


* Append
use "${tmp}/dynamics/06_3_covars_w4.dta", clear

append using "${tmp}/dynamics/06_3_covars_w5.dta", force


// Running Diff-in-Diff regression

gen wave5=(wave==5)


matrix drop _all
 
foreach covar in $hhcov4 {

    foreach var in $adopt {

        qui: reg `covar' `var'##wave5 [pw=pw_panel]

        scalar b`covar'`var'     = e(b)[1,8]
        scalar `covar'stder`var' = r(table)[2,8]
        scalar `covar'pval`var'  = r(table)[4,8]

        matrix bse`covar'`var' = (b`covar'`var')
        matrix bse`covar'`var' = (b`covar'`var'\ `covar'stder`var')
        matrix rownames bse`covar'`var' = b`var' stder`var'
        
        // p-values:
        // "# \ 0" b/c no stars needed for s.e.        
        if (`covar'pval`var'<=0.1 & `covar'pval`var'>0.05)  {
            matrix mstr`covar'`var' = (3 \ 0)      // significant at 10% level
        }
        
        if (`covar'pval`var'  <=0.05 & `covar'pval`var'>0.01)  {
            matrix mstr`covar'`var' = (2 \ 0)      // significant at 5% level
        }
        
        if `covar'pval`var'  <=0.01 {
            matrix mstr`covar'`var' = (1 \ 0)      // significant at 1% level
        }
        
        if `covar'pval`var'   >0.1 {
            matrix mstr`covar'`var' = (0 \ 0)       // Non-significant
        }

        matrix A1`covar' = nullmat(A1`covar')\ bse`covar'`var'

        matrix A1`covar'_STARS =  nullmat(A1`covar'_STARS)\mstr`covar'`var'

    }

    matrix colnames A1`covar' = `covar'

    matrix C = (nullmat(C), A1`covar')
    matrix C_STARS = (nullmat(C_STARS), A1`covar'_STARS)

}

