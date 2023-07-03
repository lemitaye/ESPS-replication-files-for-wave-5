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
hhd_crlr hhd_crsr hhd_crpo hhd_grass maize_cg dtmz hhd_ofsp hhd_awassa83 hhd_rdisp 
hhd_motorpump hhd_consag1 hhd_consag2 hhd_swc hhd_affor hhd_avocado hhd_papaya 
hhd_mango hhd_psnp 
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


* ESS5 ------------------------------

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

gen wave5=(wave==5)


// Re-labelling some variables
label var maize_cg      "Maize CG-germplasm"
label var dtmz          "Drought tolerant maize"
label var hhd_psnp      "PSNP (Temporary Labor)"
label var cs4q15        "Distance to the nearest large weekly market (Km)"



// Running Diff-in-Diff regressions

matrix drop _all 
 
foreach covar in $adopt {

    foreach var in $hhcov4 {

        qui: reg `var' `covar'##wave5 [pw=pw_panel]

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

        scalar N  = e(N)
        scalar F  = e(F)
        scalar r2 = e(r2)

        matrix bse`covar'`var' = (bwv5`covar'`var' \ `covar'sewv5`var' \ ///
                                  bcov`covar'`var' \ `covar'secov`var' \ ///
                                  bint`covar'`var' \ `covar'seint`var' \ ///
                                  bcon`covar'`var' \ `covar'secon`var' \ ///
                                  N \ r2 \ F)

        matrix rownames bse`covar'`var' = Wave5 . `var' . Wave5x`var' . Constant . N r2 F
        
        
        // p-values:
        // "# / 0" b/c no stars needed for s.e.  
        foreach suffix in wv5 cov int con {
                
            if (`covar'p`suffix'`var'<=0.1 & `covar'p`suffix'`var'>0.05)  {
                matrix p`covar'`var'`suffix' = (3 \ 0)      // significant at 10% level
            }
            
            if (`covar'p`suffix'`var'  <=0.05 & `covar'p`suffix'`var'>0.01)  {
                matrix p`covar'`var'`suffix' = (2 \ 0)      // significant at 5% level
            }
            
            if `covar'p`suffix'`var'  <=0.01 {
                matrix p`covar'`var'`suffix' = (1 \ 0)      // significant at 1% level
            }
            
            if `covar'p`suffix'`var'   >0.1 {
                matrix p`covar'`var'`suffix' = (0 \ 0)       // Non-significant
            }
        }

        matrix p`covar'`var' = (p`covar'`var'wv5 \ p`covar'`var'cov \ p`covar'`var'int \ p`covar'`var'con \ 0 \ 0 \ 0)

        matrix A1`covar' = nullmat(A1`covar')\ bse`covar'`var'

        matrix A1`covar'_STARS =  nullmat(A1`covar'_STARS)\p`covar'`var'

    }

    matrix colnames A1`covar' = `covar'

    matrix C = (nullmat(C), A1`covar')
    matrix C_STARS = (nullmat(C_STARS), A1`covar'_STARS)

}


local cname ""
foreach var in $adopt {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "Wave 5" "." "`lbl'" "." "Wave 5 x `lbl'" "." "Constant" "." "Observations" "R-squared" "F" "'		
}

#delimit ;
xml_tab C,  save("$table/06_4_dynamics_adopters_chrxs.xml") replace 
sheet("Tab14_dyn", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: Dynamics in correlates of adoption")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(".")
; 
#delimit cr



* A version with all rural households -------------------------------------

for var $adopt: replace X=0 if X==.

matrix drop _all 
 
foreach covar in $adopt {

    foreach var in $hhcov4 {

        qui: reg `var' `covar'##wave5 [pw=pw_panel]

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

        scalar N  = e(N)
        scalar F  = e(F)
        scalar r2 = e(r2)

        matrix bse`covar'`var' = (bwv5`covar'`var' \ `covar'sewv5`var' \ ///
                                  bcov`covar'`var' \ `covar'secov`var' \ ///
                                  bint`covar'`var' \ `covar'seint`var' \ ///
                                  bcon`covar'`var' \ `covar'secon`var' \ ///
                                  N \ r2 \ F)

        matrix rownames bse`covar'`var' = Wave5 . `var' . Wave5x`var' . Constant . N r2 F
        
        
        // p-values:
        // "# / 0" b/c no stars needed for s.e.  
        foreach suffix in wv5 cov int con {
                
            if (`covar'p`suffix'`var'<=0.1 & `covar'p`suffix'`var'>0.05)  {
                matrix p`covar'`var'`suffix' = (3 \ 0)      // significant at 10% level
            }
            
            if (`covar'p`suffix'`var'  <=0.05 & `covar'p`suffix'`var'>0.01)  {
                matrix p`covar'`var'`suffix' = (2 \ 0)      // significant at 5% level
            }
            
            if `covar'p`suffix'`var'  <=0.01 {
                matrix p`covar'`var'`suffix' = (1 \ 0)      // significant at 1% level
            }
            
            if `covar'p`suffix'`var'   >0.1 {
                matrix p`covar'`var'`suffix' = (0 \ 0)       // Non-significant
            }
        }

        matrix p`covar'`var' = (p`covar'`var'wv5 \ p`covar'`var'cov \ p`covar'`var'int \ p`covar'`var'con \ 0 \ 0 \ 0)

        matrix A1`covar' = nullmat(A1`covar')\ bse`covar'`var'

        matrix A1`covar'_STARS =  nullmat(A1`covar'_STARS)\p`covar'`var'

    }

    matrix colnames A1`covar' = `covar'

    matrix C = (nullmat(C), A1`covar')
    matrix C_STARS = (nullmat(C_STARS), A1`covar'_STARS)

}


local cname ""
foreach var in $adopt {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "Wave 5" "." "`lbl'" "." "Wave 5 x `lbl'" "." "Constant" "." "Observations" "R-squared" "F" "'		
}

#delimit ;
xml_tab C,  save("$table/06_4_dynamics_adopters_chrxs.xml") apppend 
sheet("Tab14_dyn_all", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: Dynamics in correlates of adoption")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(".")
; 
#delimit cr