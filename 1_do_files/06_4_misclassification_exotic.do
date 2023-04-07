********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: EXOTIC GERMPLASM (NOT IN THE REPORT)
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


* Exotic  only

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp4=.
	replace `i'_tp4=0 if `i'==1 
	replace `i'_tp4=1 if `i'==1 & exotic_source=="Yes" & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn4=.
	replace `i'_tn4=0 if `i'==1
	replace `i'_tn4=1 if `i'==1 & exotic_source=="No" & (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp4=.
	replace `i'_fp4=0 if `i'==1
	replace `i'_fp4=1 if `i'==1 & exotic_source=="No" & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn4=.
	replace `i'_fn4=0 if `i'==1
	replace `i'_fn4=1 if `i'==1 & exotic_source=="Yes" & (s4q11==1)

}


global var4    maize_tp4 maize_tn4 maize_fp4 maize_fn4 barley_tp4 barley_tn4 barley_fp4 barley_fn4 sorghum_tp4 sorghum_tn4 sorghum_fp4 sorghum_fn4

matrix drop _all
foreach var in $var4 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
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
foreach var in $var4 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN

xml_tab BN ,  save("$table\ESS4_MisclassificationNEW.xml") append sheet("Table 4", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220) title(Table 4: ESS4 - Exotic germplasm )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01) lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 


* CG germplasm & purity levels

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp5a=.
	replace `i'_tp5a=0 if `i'==1 
	replace `i'_tp5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=70  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn5a=.
	replace `i'_tn5a=0 if `i'==1
	replace `i'_tn5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<70 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp5a=.
	replace `i'_fp5a=0 if `i'==1
	replace `i'_fp5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<70 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn5a=.
	replace `i'_fn5a=0 if `i'==1
	replace `i'_fn5a=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=70 & (s4q11==1)
}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp5b=.
	replace `i'_tp5b=0 if `i'==1 
	replace `i'_tp5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=90  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn5b=.
	replace `i'_tn5b=0 if `i'==1
	replace `i'_tn5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<90 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp5b=.
	replace `i'_fp5b=0 if `i'==1
	replace `i'_fp5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<90 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn5b=.
	replace `i'_fn5b=0 if `i'==1
	replace `i'_fn5b=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=90 & (s4q11==1)

}

foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp5c=.
	replace `i'_tp5c=0 if `i'==1 
	replace `i'_tp5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=95  & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn5c=.
	replace `i'_tn5c=0 if `i'==1
	replace `i'_tn5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<95 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp5c=.
	replace `i'_fp5c=0 if `i'==1
	replace `i'_fp5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent<95 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn5c=.
	replace `i'_fn5c=0 if `i'==1
	replace `i'_fn5c=1 if `i'==1 & exotic_source=="Yes" & puritypuritypercent>=95 & (s4q11==1)

}


global var5    maize_tp5a maize_tn5a maize_fp5a maize_fn5a maize_tp5b maize_tn5b maize_fp5b maize_fn5b maize_tp5c maize_tn5c maize_fp5c maize_fn5c barley_tp5a barley_tn5a barley_fp5a barley_fn5a barley_tp5b barley_tn5b barley_fp5b barley_fn5b barley_tp5c barley_tn5c barley_fp5c barley_fn5c sorghum_tp5a sorghum_tn5a sorghum_fp5a sorghum_fn5a sorghum_tp5b sorghum_tn5b sorghum_fp5b sorghum_fn5b sorghum_tp5c sorghum_tn5c sorghum_fp5c sorghum_fn5c

matrix drop _all
foreach var in $var5 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)
	
	qui sum region if  wave==4
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
foreach var in $var5 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN


xml_tab BN ,  save("$table\ESS4_MisclassificationNEW.xml") append sheet("Table 5", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 5: ESS4 - Exotic germplasm & purity level)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 

***************************************
* Exotic Germplasm and year of release
***************************************
* Before 1990
foreach i in maize barley sorghum {
	* True positive
	g       `i'_tp6a=.
	replace `i'_tp6a=0 if `i'==1 
	replace `i'_tp6a=1 if `i'==1 & exotic_source=="Yes" & year<1990 & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn6a=.
	replace `i'_tn6a=0 if `i'==1
	replace `i'_tn6a=1 if `i'==1 & exotic_source=="Yes" &  year>=1990 &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp6a=.
	replace `i'_fp6a=0 if `i'==1
	replace `i'_fp6a=1 if `i'==1 & exotic_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn6a=.
	replace `i'_fn6a=0 if `i'==1
	replace `i'_fn6a=1 if `i'==1 & exotic_source=="Yes" & year<1990 & (s4q11==1)

}
* 1990- 2000
foreach i in maize barley sorghum { 
	g       `i'_tp6b=.
	replace `i'_tp6b=0 if `i'==1 
	replace `i'_tp6b=1 if `i'==1 & exotic_source=="Yes" & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn6b=.
	replace `i'_tn6b=0 if `i'==1
	replace `i'_tn6b=1 if `i'==1 & exotic_source=="Yes" &  (year<1990 | year>=2000) &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       `i'_fp6b=.
	replace `i'_fp6b=0 if `i'==1
	replace `i'_fp6b=1 if `i'==1 & exotic_source=="Yes" & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       `i'_fn6b=.
	replace `i'_fn6b=0 if `i'==1
	replace `i'_fn6b=1 if `i'==1 & exotic_source=="Yes" & (year>=1990 & year<2000)  & (s4q11==1)

}
* 2000-2010
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp6c=.
	replace `i'_tp6c=0 if `i'==1 
	replace `i'_tp6c=1 if `i'==1 & exotic_source=="Yes" & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)
	
	*True negative
	g       `i'_tn6c=.
	replace `i'_tn6c=0 if `i'==1
	replace `i'_tn6c=1 if `i'==1 & exotic_source=="Yes" &  (year<2000 | year>=2010) &  (s4q11==1)
	
	*False positive (improved when traditional)
	g       `i'_fp6c=.
	replace `i'_fp6c=0 if `i'==1
	replace `i'_fp6c=1 if `i'==1 & exotic_source=="Yes" & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)
	
	*False negative (traditional when improved)
	g       `i'_fn6c=.
	replace `i'_fn6c=0 if `i'==1
	replace `i'_fn6c=1 if `i'==1 & exotic_source=="Yes" & (year>=2000 & year<2010)  & (s4q11==1)
	
}
* 2010-2020
foreach i in maize barley sorghum { 
	* True positive
	g       `i'_tp6d=.
	replace `i'_tp6d=0 if `i'==1 
	replace `i'_tp6d=1 if `i'==1 & exotic_source=="Yes" & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)
	
	* True negative
	g       `i'_tn6d=.
	replace `i'_tn6d=0 if `i'==1
	replace `i'_tn6d=1 if `i'==1 & exotic_source=="Yes" &  (year<2010 | year>=2020) &  (s4q11==1)
	
	* False positive (improved when traditional)
	g       `i'_fp6d=.
	replace `i'_fp6d=0 if `i'==1
	replace `i'_fp6d=1 if `i'==1 & exotic_source=="Yes" & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)
	
	* False negative (traditional when improved)
	g       `i'_fn6d=.
	replace `i'_fn6d=0 if `i'==1
	replace `i'_fn6d=1 if `i'==1 & exotic_source=="Yes" & (year>=2010 & year<2020)  & (s4q11==1)

}

global var6    maize_tp6a maize_tn6a maize_fp6a maize_fn6a maize_tp6b maize_tn6b maize_fp6b maize_fn6b maize_tp6c maize_tn6c maize_fp6c maize_fn6c maize_tp6d maize_tn6d maize_fp6d maize_fn6d barley_tp6a barley_tn6a barley_fp6a barley_fn6a barley_tp6b barley_tn6b barley_fp6b barley_fn6b barley_tp6c barley_tn6c barley_fp6c barley_fn6c barley_tp6d barley_tn6d barley_fp6d barley_fn6d sorghum_tp6a sorghum_tn6a sorghum_fp6a sorghum_fn6a sorghum_tp6b sorghum_tn6b sorghum_fp6b sorghum_fn6b sorghum_tp6c sorghum_tn6c sorghum_fp6c sorghum_fn6c sorghum_tp6d sorghum_tn6d sorghum_fp6d sorghum_fn6d

matrix drop _all
foreach var in $var6 {

	mean `var' [pw=pw_w4] if wave==4
	matrix  `var'meanrN=e(b)'
	matrix define `var'VN= e(V)'
	matrix define `var'VVN=(vecdiag(`var'VN))'
	matrix list `var'VVN
	scalar `var'seN=sqrt(`var'VVN[1,1])
	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)	
	qui sum region if  wave==4
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
foreach var in $var6 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
}	

mat C= BN


xml_tab BN ,  save("$table\ESS4_MisclassificationNEW.xml") append sheet("Table 6", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ///
rblanks(COL_NAMES "Plot level data" S2220)	 /// 
title(Table 6: ESS4 - Exotic germplasm & Year of release)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30, 31 30, 32 40, 33 55, 34 30, 35 30, 36 40, 37 55, 38 30, 39 30, 40 40  ) /// 
format((SCLR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// 
star(.1 .05 .01)  ///
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// 
notes(Point estimates are weighted sample means. Standard errors are reported below. Sub-sample of national sample used. ) 