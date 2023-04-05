********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: CG Germplasm and year of release
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${data}/06_1_ess5_dna_plot.dta", clear


* Year cut-off: 1990

	* True positive
	g       maize_tp3a=.
	replace maize_tp3a=0  
	replace maize_tp3a=1 if cg_source=="Yes" & year<1990 & (s4q11>1 & s4q11!=.)

	* True negative
	g       maize_tn3a=.
	replace maize_tn3a=0 
	replace maize_tn3a=1 if cg_source=="Yes" &  year>=1990 &  (s4q11==1)

	* False positive (improved when traditional)
	g       maize_fp3a=.
	replace maize_fp3a=0 
	replace maize_fp3a=1 if cg_source=="Yes" & year>=1990  & (s4q11>1 & s4q11!=.)

	* False negative (traditional when improved)
	g       maize_fn3a=.
	replace maize_fn3a=0 
	replace maize_fn3a=1 if cg_source=="Yes" & year<1990 & (s4q11==1)


* Year: 1990- 2000
	* True positive
	g       maize_tp3b=.
	replace maize_tp3b=0  
	replace maize_tp3b=1 if cg_source=="Yes" & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       maize_tn3b=.
	replace maize_tn3b=0 
	replace maize_tn3b=1 if cg_source=="Yes" &  (year<1990 | year>=2000) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       maize_fp3b=.
	replace maize_fp3b=0 
	replace maize_fp3b=1 if cg_source=="Yes" & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       maize_fn3b=.
	replace maize_fn3b=0 
	replace maize_fn3b=1 if cg_source=="Yes" & (year>=1990 & year<2000)  & (s4q11==1)


* Year: 2000-2010

	* True positive
	g       maize_tp3c=.
	replace maize_tp3c=0  
	replace maize_tp3c=1 if cg_source=="Yes" & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       maize_tn3c=.
	replace maize_tn3c=0 
	replace maize_tn3c=1 if cg_source=="Yes" &  (year<2000 | year>=2010) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       maize_fp3c=.
	replace maize_fp3c=0 
	replace maize_fp3c=1 if cg_source=="Yes" & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       maize_fn3c=.
	replace maize_fn3c=0 
	replace maize_fn3c=1 if cg_source=="Yes" & (year>=2000 & year<2010)  & (s4q11==1)


* Year: 2010-2020
	* True positive
	g       maize_tp3d=.
	replace maize_tp3d=0  
	replace maize_tp3d=1 if cg_source=="Yes" & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       maize_tn3d=.
	replace maize_tn3d=0 
	replace maize_tn3d=1 if cg_source=="Yes" &  (year<2010 | year>=2020) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       maize_fp3d=.
	replace maize_fp3d=0 
	replace maize_fp3d=1 if cg_source=="Yes" & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       maize_fn3d=.
	replace maize_fn3d=0 
	replace maize_fn3d=1 if cg_source=="Yes" & (year>=2010 & year<2020)  & (s4q11==1)



* Table
global var3   maize_tp3a maize_tn3a maize_fp3a maize_fn3a maize_tp3b maize_tn3b /// 
    maize_fp3b maize_fn3b maize_tp3c maize_tn3c maize_fp3c maize_fn3c maize_tp3d ///
    maize_tn3d maize_fp3d maize_fn3d 

matrix drop _all

foreach var in $var3 {

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

foreach var in $var3 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN


xml_tab BN ,  save("${tables}/06_3_ess5_missclass_year.xml") replace sheet("Table 3", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 ///
title(Table 3: ESS4 - CG germplasm & Year of release)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used.)



* Cumulative years -------------------------------------------------------------

* After 1990

	* True positive
	g       maize_tp3abis=.
	replace maize_tp3abis=0  
	replace maize_tp3abis=1 if cg_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       maize_tn3abis=.
	replace maize_tn3abis=0 
	replace maize_tn3abis=1 if cg_source=="Yes" &  year<1990 &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       maize_fp3abis=.
	replace maize_fp3abis=0 
	replace maize_fp3abis=1 if cg_source=="Yes" & year<1990  & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       maize_fn3abis=.
	replace maize_fn3abis=0 
	replace maize_fn3abis=1 if cg_source=="Yes" & year>=1990 & (s4q11==1)



* After 2000

    * True positive
	g       maize_tp3bbis=.
	replace maize_tp3bbis=0  
	replace maize_tp3bbis=1 if cg_source=="Yes" & (year>=2000) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       maize_tn3bbis=.
	replace maize_tn3bbis=0 
	replace maize_tn3bbis=1 if cg_source=="Yes" &  (year<2000) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       maize_fp3bbis=.
	replace maize_fp3bbis=0 
	replace maize_fp3bbis=1 if cg_source=="Yes" &  (year<2000) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       maize_fn3bbis=.
	replace maize_fn3bbis=0 
	replace maize_fn3bbis=1 if cg_source=="Yes" &  (year>=2000)  & (s4q11==1)



* After 2010

	* True positive
	g       maize_tp3cbis=.
	replace maize_tp3cbis=0  
	replace maize_tp3cbis=1 if cg_source=="Yes" & (year>=2010) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       maize_tn3cbis=.
	replace maize_tn3cbis=0 
	replace maize_tn3cbis=1 if cg_source=="Yes" &  (year<2010) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       maize_fp3cbis=.
	replace maize_fp3cbis=0 
	replace maize_fp3cbis=1 if cg_source=="Yes" & (year<2010) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       maize_fn3cbis=.
	replace maize_fn3cbis=0 
	replace maize_fn3cbis=1 if cg_source=="Yes" & (year>=2010)  & (s4q11==1)



* Table
global var3b   maize_tp3abis maize_tn3abis maize_fp3abis maize_fn3abis ///
    maize_tp3bbis maize_tn3bbis maize_fp3bbis maize_fn3bbis maize_tp3cbis ///
    maize_tn3cbis maize_fp3cbis maize_fn3cbis 

matrix drop _all

foreach var in $var3b {

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
foreach var in $var3b {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("${tables}/06_3_ess5_missclass_year.xml") append sheet("Table 3b", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 3b: ESS4 - CG germplasm & Year of release - cumulative)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  ///
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 
/*
* NB of obs // additional
global var3brel  maize_tp3abis maize_fn3abis maize_tp3bbis maize_fn3bbis maize_tp3cbis maize_fn3cbis barley_tp3abis barley_fn3abis barley_tp3bbis barley_fn3bbis barley_tp3cbis barley_fn3cbis sorghum_tp3abis sorghum_fn3abis sorghum_tp3bbis sorghum_fn3bbis sorghum_tp3cbis sorghum_fn3cbis 

foreach var in $var3brel {
	tab `var'
}