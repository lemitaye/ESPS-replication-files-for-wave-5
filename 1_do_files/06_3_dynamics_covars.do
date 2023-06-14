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

gen int_var = wave5*hhd_motorpump

reg totconswin wave5 hhd_motorpump int_var

reg totconswin wave5##hhd_motorpump 


matrix drop _all
 
foreach covar in $hhcov4 {

    foreach var in $adopt {

        qui: reg `covar' `var'##wave5 [pw=pw_panel]

        scalar bwv5`covar'`var' = r(table)[1,2]
        scalar bcov`covar'`var' = r(table)[1,4]
        scalar bint`covar'`var' = r(table)[1,8]
        scalar bcon`covar'`var' = r(table)[1,9]

        scalar `covar'sewv5`var' = r(table)[2,2]
        scalar `covar'secov`var' = r(table)[2,4]
        scalar `covar'seint`var' = r(table)[2,8]
        scalar `covar'secon`var' = r(table)[2,9]

        scalar `covar'pwv5`var'  = r(table)[4,2]
        scalar `covar'pcov`var'  = r(table)[4,4]
        scalar `covar'pint`var'  = r(table)[4,8]
        scalar `covar'pcon`var'  = r(table)[4,9]

        matrix bse`covar'`var' = (bwv5`covar'`var' \ `covar'sewv5`var' \ ///
                                  bcov`covar'`var' \ `covar'secov`var' \ ///
                                  bint`covar'`var' \ `covar'seint`var' \ ///
                                  bcon`covar'`var' \ `covar'secon`var')

        matrix rownames bse`covar'`var' = Wave5 . `var' . Wave5x`var' . Constant .
        
        
        // p-values:
        // "# / 0" b/c no stars needed for s.e.  
        foreach suffix in wv5 cov int con {
                
            if (`covar'p`suffix'`var'<=0.1 & `covar'p`suffix'`var'>0.05)  {
                matrix p`covar'`var'`suffix' = (3 \ .)      // significant at 10% level
            }
            
            if (`covar'p`suffix'`var'  <=0.05 & `covar'p`suffix'`var'>0.01)  {
                matrix p`covar'`var'`suffix' = (2 \ .)      // significant at 5% level
            }
            
            if `covar'p`suffix'`var'  <=0.01 {
                matrix p`covar'`var'`suffix' = (1 \ .)      // significant at 1% level
            }
            
            if `covar'p`suffix'`var'   >0.1 {
                matrix p`covar'`var'`suffix' = (0 \ .)       // Non-significant
            }
        }

        matrix p`covar'`var' = (p`covar'`var'wv5 \ p`covar'`var'cov \ p`covar'`var'int \ p`covar'`var'con)

        matrix A1`covar' = nullmat(A1`covar')\ bse`covar'`var'

        matrix A1`covar'_STARS =  nullmat(A1`covar'_STARS)\p`covar'`var'

    }

    matrix colnames A1`covar' = `covar'

    matrix C = (nullmat(C), A1`covar')
    matrix C_STARS = (nullmat(C_STARS), A1`covar'_STARS)

}

/*
local cname ""
foreach var in $hhcov4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $adopt {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "." "'		
}

#delimit ;
xml_tab C,  save("$table/06_3_dynamics_adopters_chrxs.xml") replace 
sheet("Table14_dyn", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: Dynamics in correlates of adoption")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("."); 
# delimit cr
