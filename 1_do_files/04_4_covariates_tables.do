*********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Covariates at the community (EA) level 
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Paola Mallia and Solomon Alemu]
* STATA Version: MP 17.0
********************************************************************************

* Descriptive stats ----------------------------------------------------

use "${tmp}/covariates/04_2_covars_hh_pp.dta", clear


#delimit;
global hhlevel   
parcesizeHA fem_head fowner flivman hhd_flab age_head nom_totcons_aeq consq1 
consq2 asset_index pssetindex income_offfarm
;
#delimit cr


* TABLES * Table 13 -Household level variables
matrix drop _all

foreach x in 3 4 7 0 {

	foreach var in $hhlevel {

		cap:mean `var' [pw=pw_w5] if region==`x' & wave==5
		if _rc==2000 {
			matrix  `var'meanr`x'=0
			matrix define `var'V`x'= 0
			scalar `var'se`x'=0
		}
		else if _rc!=0 {
			error _rc
		}
		else {
			matrix  `var'meanr`x'=e(b)'
			matrix define `var'V`x'= e(V)'
			matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
			matrix list `var'VV`x'
			scalar `var'se`x'=sqrt(`var'VV`x'[1,1])
		}

		sum    `var'  if region==`x' & wave==5
		scalar `var'minr`x'=r(min)
		scalar `var'maxr`x'=r(max)
		scalar `var'n`x'=r(N)

		qui sum region if region==`x' & wave==5
		local obsr`x'=r(N)

		matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

		matrix list mat`var'`x'

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

		mat A2`x'=(., . , ., .,`obsr`x'')
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

	}

}
	
* National
foreach var in $hhlevel {

	cap:mean `var' [pw=pw_w5] if wave==5

	if _rc==2000 {
		matrix  `var'meanrN=0
		matrix define `var'VN= 0
		scalar `var'seN=0
					}
	else if _rc!=0 {
		error _rc
					}
	else {	
		matrix  `var'meanrN=e(b)'
		matrix define `var'VN= e(V)'
		matrix define `var'VVN=(vecdiag(`var'VN))'
		matrix list `var'VVN
		scalar `var'seN=sqrt(`var'VVN[1,1])
	}

	sum    `var'  if  wave==5
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==5
	local obsrN=r(N)

	matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B3, B4, B7, B0, BN											

#delimit;
xml_tab C,  save("${tmp}/covariates/tables/04_4_1_descriptive_stats.xml") replace 
sheet("Table 13 - ESS5", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" 
"Other regions" "Other regions" "Other regions" "National" "National" "National" 
"National" "National" ) showeq 
title(Table 1: ESS5 - Household characteristics)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4D 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. These are multiplied by 100 for dummy variables to express them as percengages. 
Only rural sample included.) //Add your notes here
;
#delimit cr		



/* Who are the adopters? --------------------------------------------------------

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
xml_tab D,  save("${tmp}/covariates/tables/04_4_2_adopters_chrxs.xml") replace 
sheet("Table 14 - ESS5", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESPS5 - Correlates of adoption)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the 
	column variable on the row variable.); 
# delimit cr
