********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Adoption estimates using DNA-fingerprinting
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************

use "${tmp}/missclass/06_3_misclass_year.dta", clear

* CG - GERMPLASM AND PURITY LEVEL	

g       maize_cgp70=.
replace maize_cgp70=0 
replace maize_cgp70=1 if cg_source=="Yes" & purity_percent>=70

g       maize_cgp90=.
replace maize_cgp90=0 
replace maize_cgp90=1 if cg_source=="Yes" & purity_percent>=90

g       maize_cgp95=.
replace maize_cgp95=0 
replace maize_cgp95=1 if cg_source=="Yes" & purity_percent>=95


* CG - GERMPLASM AND YEAR OF RELEASE

g       maize_cgy1=.
replace maize_cgy1=0 
replace maize_cgy1=1 if cg_source=="Yes" & year<1990

g       maize_cgy2=.
replace maize_cgy2=0 
replace maize_cgy2=1 if cg_source=="Yes" & (year>=1990 & year<2000) 


g       maize_cgy3=.
replace maize_cgy3=0 
replace maize_cgy3=1 if cg_source=="Yes" & (year>=2000 & year<2010) 

g       maize_cgy4=.
replace maize_cgy4=0 
replace maize_cgy4=1 if cg_source=="Yes" & (year>=2010 & year<=2020) 


* EXOTIC GERMPLASM 

g       maize_ex=.
replace maize_ex=0 
replace maize_ex=1 if exotic_source=="Yes"

* EXOTIC GERMPLASM & PURITY LEVEL	

g       maize_exp70=.
replace maize_exp70=0 
replace maize_exp70=1 if exotic_source=="Yes" & purity_percent>=70

g       maize_exp90=.
replace maize_exp90=0 
replace maize_exp90=1 if exotic_source=="Yes" & purity_percent>=90

g       maize_exp95=.
replace maize_exp95=0 
replace maize_exp95=1 if exotic_source=="Yes" & purity_percent>=95


* EXOTIC GERMPLASM & YEAR OF RELEASE

g       maize_exy1=.
replace maize_exy1=0 
replace maize_exy1=1 if exotic_source=="Yes" & year<1990

g       maize_exy2=.                                  
replace maize_exy2=0                        
replace maize_exy2=1 if exotic_source=="Yes" & (year>=1990 & year<2000) 
                                                    
g       maize_exy3=.                                  
replace maize_exy3=0                        
replace maize_exy3=1 if exotic_source=="Yes" & (year>=2000 & year<2010)  
                                                    
g       maize_exy4=.                                  
replace maize_exy4=0                        
replace maize_exy4=1 if exotic_source=="Yes" & (year>=2010 & year<=2020) 
                                                
                                                


* UNCONDITIONAL - PURITY LEVEL

g       maize_p70=.
replace maize_p70=0 
replace maize_p70=1  & purity_percent>=70

g       maize_p90=.
replace maize_p90=0 
replace maize_p90=1  & purity_percent>=90

g       maize_p95=.
replace maize_p95=0 
replace maize_p95=1  & purity_percent>=95


* UNCONDITIONAL - YEAR OF RELEASE


g       maize_y1=.
replace maize_y1=0 
replace maize_y1=1 if year<1990

g       maize_y2=.
replace maize_y2=0 
replace maize_y2=1  & (year>=1990 & year<2000)

g       maize_y3=.
replace maize_y3=0 
replace maize_y3=1  & (year>=2000 & year<2010) 

g       maize_y4=.
replace maize_y4=0 
replace maize_y4=1  & (year>=2010 & year<=2020) 


 * Table 
global var7 maize_cg maize_cgp70 maize_cgp90 maize_cgp95 maize_cgy1 maize_cgy2 ///
    maize_cgy3 maize_cgy4 maize_y1 maize_y2 maize_y3 maize_y4 

matrix drop _all

foreach var in $var7 {

	mean `var' [pw=pw_w5] if wave==5
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	sum    `var'  if  wave==5
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	qui sum region if  wave==5
	local obsrN=r(N)

    matrix mat`var'N  = ( `var'meanrN, `var'minrN, `var'maxrN, `var'nN)
    matrix mat1`var'N= (`var'seN, ., ., .)
    matrix list mat`var'N
    matrix A1N = nullmat(A1N)\ mat`var'N\mat1`var'N
    mat A2N=(`obsrN', . , ., .)
    mat BN=A1N\A2N
    matrix colnames BN = "Mean" "Min" "Max" "N"

}
local rname ""
foreach var in $var7 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("${tables}/06_4_ess5_missclass_dna.xml") replace sheet("Table 7", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 7: ESS4 - Related stats)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 
	

* save -------------------------------------------------------------------------
save "${tmp}/missclass/06_4_misclass_dna.dta", replace
