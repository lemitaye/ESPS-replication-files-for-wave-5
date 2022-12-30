
use "${data}\wave5_hh_new", clear

/*
The following varaibles corresponding to livestock are removed from global call
above:
hhd_livIA hhd_cross_largerum hhd_cross_smallrum hhd_cross_poultry hhd_grass 
*/

#delimit ;
global hhlevel     
hhd_ofsp hhd_awassa83 hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 
hhd_affor hhd_mango hhd_papaya hhd_avocado hhd_impcr13 hhd_impcr19 hhd_impcr11 
hhd_impcr24 hhd_impcr14 hhd_impcr3 hhd_impcr5 hhd_impcr60 hhd_impcr62
;
#delimit cr

********************************************************************************
* TABLE 1 - HH LEVEL
********************************************************************************

* By region:

matrix drop _all

foreach x in 3 4 7 0 {  // these are the three main regions (Tigray excluded) and others

	foreach var in $hhlevel {

		cap:mean `var' [pw=pw_w5] if region==`x' & wave==5
		if _rc==2000 {  // error code = 2000. no observations [see "help error"]
			matrix  `var'meanr`x'=0
			matrix define `var'V`x'= 0
			scalar `var'se`x'=0
		}
		else if _rc!=0 {  // all other errors
			error _rc
		}
		else {            // "mean" is an e-class command (see "ereturn list")
			matrix  `var'meanr`x'=e(b)'    // mean 
			matrix define `var'V`x'= e(V)' // variance 
			matrix define `var'VV`x'=(vecdiag(`var'V`x'))' 
			// "vecdiag(M)" - the row vector containing the diagonal of matrix M
			matrix list `var'VV`x'  // display the contents of a matrix
			scalar `var'se`x'=sqrt(`var'VV`x'[1,1])  // standard error
		}
		// we do the following to get min, max, and # of obs; weighted mean is computed above
		sum    `var'  if region==`x' & wave==5
		scalar `var'minr`x'=r(min)   // "summarize" is an r-class command (see "return list")
		scalar `var'maxr`x'=r(max)
		scalar `var'n`x'=r(N)

		qui sum region if region==`x' & wave==5
		local obsr`x'=r(N)  // # of households in region `x'

		matrix mat`var'`x' = (`var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')
		// (,) is a  row-join operator
		matrix rownames mat`var'`x' = "`var'"

		matrix list mat`var'`x'  // "matrix list" - Display the contents of a matrix

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'  // "\" is a column join operator
        // appends row vector to matrix
		mat A2`x'=(`obsr`x'', . , ., .,.)  
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"
	}

	local rname ""
	foreach var in $hhlevel {
		local lbl : variable label `var'
		local rname `"  `rname'   "`lbl'" " " "'		
	}	

}	


* National:

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
	matrix rownames mat`var'N = "`var'"

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(`obsrN', . , ., .,.)
	mat BN=A1N\A2N

	matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $hhlevel {
	local lbl: variable label `var'
	local rname " '`rname'' '`lbl'' "
}
di "`rname'"   // "rname" is a local containing row names

mat C = B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table\Sec6_ESS5.xml") replace sheet("Table 1_hh", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) 
showeq 
rblanks(hhd_grass_r "Crop germplasm improvementes"   S2149,
hhd_awassa83_r "Natural resource management" S2149)	 
title(Table 1: ESS5 - Rural Household level - Section 6)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)   
	notes(Point estimates are weighted sample means. ) 
;
#delimit cr		



