********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - appending ESS4 and ESS5 data
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
* STATA Version: MP 17.0
********************************************************************************


* Merging ---------------------------------------------------------------------

use "${supp}/replication_files/3_report_data/ess4_pp_cov_new.dta", clear

drop sh_* s2* s3* s4* cs* 

// recode 100 to 1 for dummies for consistency:
for var hhd_treadle-hhd_ploc hhd_cross-hhd_grass lr_livIA-sr_grass ///
    hhd_ofsp-hhd_fieldp hhd_impcr1-ead_impccr: recode X (100=1)

order hhd_psnp, after(ead_impccr)

gen hhd_fruitrees=., after( hhd_papaya )
replace hhd_fruitrees=0 if hhd_avocado==0 & hhd_mango==0 & hhd_papaya==0
replace hhd_fruitrees=1 if hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1
label variable hhd_fruitrees "Avocado, Mango, or Papaya tree"

for var hh_ea-hhd_psnp: rename X X_w4

preserve
    use "${data}/wave5_hh_new.dta", clear
    drop sh_*

    gen hhd_fruitrees=., after( hhd_papaya )
    replace hhd_fruitrees=0 if hhd_avocado==0 & hhd_mango==0 & hhd_papaya==0
    replace hhd_fruitrees=1 if hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1
    label variable hhd_fruitrees "Avocado, Mango, or Papaya tree"

    rename hhd_cross_largerum hhd_crlr
    rename hhd_cross_smallrum hhd_crsr
    rename hhd_cross_poultry hhd_crpo
 
    for var hh_ea-othregion: rename X X_w5

    tempfile wave5_hh_new 
    save `wave5_hh_new'
restore

merge 1:1 household_id using `wave5_hh_new', force
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,265
        from master                       947  (_merge==1)
        from using                        318  (_merge==2)

    Matched                             1,952  (_merge==3)
    -----------------------------------------
*/
keep if _merge==3
drop _merge

drop hhd_livIA_publ_w5 hhd_livIA_priv_w5

#delimit ;
global hhinnov     
hhd_ofsp hhd_awassa83 hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 
hhd_affor hhd_mango hhd_papaya hhd_avocado hhd_fruitrees hhd_livIA hhd_crlr 
hhd_crsr hhd_crpo hhd_elepgrass hhd_grass hhd_psnp 
hhd_impcr13 hhd_impcr19 hhd_impcr11 hhd_impcr24  
hhd_impcr14 hhd_impcr3 hhd_impcr5 hhd_impcr60 hhd_impcr62 
;
#delimit cr

// Adoption matrices:
label define Yes_no 1 "Yes" 0 "No"

foreach var in $hhinnov {
    label values `var'_* Yes_no
    
    local lbl : variable label `var'_w4

    est clear
    estpost tab `var'_*

    esttab . using "${tmp}/dynamics/tables/05_2_adoption_matrix_`var'.tex", replace ///
        cell(b pct(fmt(2) par) par) unstack noobs nonumber mtitle("Wave 5") ///
        collabels(none) modelwidth(15) ///
        label booktabs title("`lbl'") eqlabels(, lhs("Wave 4"))
}


foreach var in $hhinnov {
    gen `var'_a_a = .
    replace `var'_a_a = 0 if `var'_w4!=. & `var'_w5!=.
    replace `var'_a_a = 1 if `var'_w4==1 & `var'_w5==1

    gen `var'_a_d = .
    replace `var'_a_d = 0 if `var'_w4!=. & `var'_w5!=.
    replace `var'_a_d = 1 if `var'_w4==1 & `var'_w5==0

    gen `var'_d_a = .
    replace `var'_d_a = 0 if `var'_w4!=. & `var'_w5!=.
    replace `var'_d_a = 1 if `var'_w4==0 & `var'_w5==1

    gen `var'_d_d = .
    replace `var'_d_d = 0 if `var'_w4!=. & `var'_w5!=.
    replace `var'_d_d = 1 if `var'_w4==0 & `var'_w5==0
} 

rename nom_totcons_aeq nmtotcons
rename income_offfarm incofffarm
rename  total_cons_ann_win totconswin

#delimit;
global hhcovar   
parcesizeHA fem_head fowner flivman hhd_flab  age_head nmtotcons consq1 
consq2 asset_index pssetindex incofffarm
;
#delimit cr

matrix drop _all
 
foreach covar in $hhcovar {

    foreach var in $hhinnov {

        qui: reg `covar' `var'_a_a [pw=pw_panel]
        scalar b`covar'`var'_a_a=e(b)[1,1]
        scalar `covar'pval`var'_aa=r(table)[4,1]

        qui: reg `covar' `var'_a_d [pw=pw_panel]
        scalar b`covar'`var'_a_d=e(b)[1,1]
        scalar `covar'pval`var'_ad=r(table)[4,1]        

        qui: reg `covar' `var'_d_a [pw=pw_panel]
        scalar b`covar'`var'_d_a=e(b)[1,1]
        scalar `covar'pval`var'_da=r(table)[4,1]

        qui: reg `covar' `var'_d_d [pw=pw_panel]
        scalar b`covar'`var'_d_d=e(b)[1,1]
        scalar `covar'pval`var'_dd=r(table)[4,1]

        matrix b`covar'`var'=(b`covar'`var'_a_a\ b`covar'`var'_a_d \ b`covar'`var'_d_a \ b`covar'`var'_d_d)
        matrix rownames b`covar'`var' = `var'_a_a `var'_a_d `var'_d_a `var'_d_d
        
        // p-values:
        foreach suffix in _aa _ad _da _dd {
                
            if (`covar'pval`var'`suffix'<=0.1 & `covar'pval`var'`suffix'>0.05)  {
                matrix mstr`covar'`var'`suffix' = (3)      // significant at 10% level
            }
            
            if (`covar'pval`var'`suffix'  <=0.05 & `covar'pval`var'`suffix'>0.01)  {
                matrix mstr`covar'`var'`suffix' = (2)      // significant at 5% level
            }
            
            if `covar'pval`var'`suffix'  <=0.01 {
                matrix mstr`covar'`var'`suffix' = (1)      // significant at 1% level
            }
            
            if `covar'pval`var'`suffix'   >0.1 {
                matrix mstr`covar'`var'`suffix' = (0)       // Non-significant
            }
        }

        matrix mstr`covar'`var' = (mstr`covar'`var'_aa\ mstr`covar'`var'_ad\ mstr`covar'`var'_da\ mstr`covar'`var'_dd)

        matrix A1`covar' = nullmat(A1`covar')\ b`covar'`var'

        matrix A1`covar'_STARS =  nullmat(A1`covar'_STARS)\mstr`covar'`var'`suffix'

    }

    matrix colnames A1`covar' = `covar'

    matrix C = (nullmat(C), A1`covar')
    matrix C_STARS = (nullmat(C_STARS), A1`covar'_STARS)

}

local cname ""
foreach covar in $hhcovar {
    local lbl : variable label `covar'
    local cname `" `cname' "`lbl'" "'		
}
/*
local rname ""
foreach var in $adopt {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "'		
}
*/
#delimit ;
xml_tab C,  save("${tmp}/dynamics/tables/05_2_matrix_reg.xml") replace 
sheet("regs", nogridlines)  
/*rnames(`rname')*/ cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESPS5 - Correlates of adoption (only for panel households))  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the column variable on the row variable.); 
# delimit cr


* Disaggregating (dis-)adoption of conservation agriculture (CA)

// CA with minimum tillage

for var hhd_rotlegume_w4 hhd_cresidue2_w4 hhd_mintillage_w4 hhd_zerotill_w4: ///
    replace X=0 if (X==. & hhd_consag1_w4!=.)

for var hhd_rotlegume_w5 hhd_cresidue2_w5 hhd_mintillage_w5 hhd_zerotill_w4: ///
    replace X=0 if (X==. & hhd_consag1_w5!=.)

gen no_compntca_mtw4 = hhd_rotlegume_w4 + hhd_cresidue2_w4 + hhd_mintillage_w4
gen no_compntca_mtw5 = hhd_rotlegume_w5 + hhd_cresidue2_w5 + hhd_mintillage_w5

gen ca_mt_da = .
replace ca_mt_da = 0 if hhd_consag1_d_a==1 & (no_compntca_mtw4==0 | no_compntca_mtw4==.)
replace ca_mt_da = 1 if hhd_consag1_d_a==1 & no_compntca_mtw4==1
replace ca_mt_da = 2 if hhd_consag1_d_a==1 & (no_compntca_mtw4==2 | no_compntca_mtw4==3)

gen ca_mt_ad = .
replace ca_mt_ad = 0 if hhd_consag1_a_d==1 & (no_compntca_mtw5==0 | no_compntca_mtw5==.)
replace ca_mt_ad = 1 if hhd_consag1_a_d==1 & no_compntca_mtw5==1
replace ca_mt_ad = 2 if hhd_consag1_a_d==1 & (no_compntca_mtw5==2 | no_compntca_mtw5==3)

tab ca_mt_da
tab ca_mt_ad

