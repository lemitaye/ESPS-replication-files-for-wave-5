*********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Covariates at the community (EA) level 
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Paola Mallia and Solomon Alemu]
* STATA Version: MP 17.0
********************************************************************************



* Who are the adopters? --------------------------------------------------------

use "${data}/ess5_pp_hh_new.dta", clear // INNOVATIONS DATASET 

merge 1:1 household_id using "${tmp}/covariates/04_2_covars_hh_pp.dta"
keep if _m==3   // keep only panel households (n=1823)
drop _merge

rename hhd_cross_largerum crlargerum
rename hhd_cross_smallrum crsmallrum
rename hhd_cross_poultry crpoultry


*HH level 
#delimit;
global hhdemo      
hhd_flab flivman age_head parcesizeHA pssetindex income_offfarm 
;
#delimit cr
// The following covariates were removed from above:
// asset_index total_cons_ann  totconswin nmtotcons consq1 consq2 adulteq 

#delimit;
global adopt     
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor 
hhd_ploc hhd_ofsp hhd_awassa83 hhd_kabuli hhd_seedv1 hhd_seedv2 hhd_malt hhd_durum 
hhd_avocado hhd_papaya hhd_mango hhd_fieldp hhd_psnp 
maize_cg dtmz hhd_agroind hhd_grass hhd_cross crlargerum crsmallrum crpoultry
;
#delimit cr



matrix drop _all
 
foreach i in   $adopt {

    foreach var in $hhdemo {

        qui: reg `var' `i' if  wave==5 [pw=pw_w5]
        scalar coef`var'`i'=e(b)[1,1]   // coefficient
        matrix mat`var'`i'=coef`var'`i'

        test `i'=0
        scalar `var'pval`i'=r(p)

            if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)  {
            matrix mstr`var'`i' = (3)      // significant at 10% level
            }
            
            if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  {
            matrix mstr`var'`i' = (2)      // significant at 5% level
            }
            
            if `var'pval`i'  <=0.01 {
            matrix mstr`var'`i' = (1)      // significant at 1% level
            }
            
            if `var'pval`i'   >0.1 {
            matrix mstr`var'`i' = (0)       // Non-significant
            }
                       
        matrix A1`i' = nullmat(A1`i')\ mat`var'`i'

        matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'

    }

    matrix colnames A1`i' = "Difference"

    matrix C=nullmat(C), A1`i'
    matrix C_STARS=nullmat(C_STARS), A1`i'_STARS 

}

* Transpose:
matrix D=C'
matrix D_STARS=C_STARS'


local cname ""
foreach var in $hhdemo {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $adopt {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "'		
}

#delimit ;
xml_tab D,  save("${tmp}/covariates/tables/04_4_adopters_chrxs.xml") replace sheet("Table 14 - coefs", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESPS5 - Correlates of adoption (only for panel households))  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the column variable on the row variable.); 
# delimit cr
