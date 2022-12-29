
use "${data}\wave4_hh_new", clear

#delimit ;
global hhlevel     
hhd_livIA hhd_cross_largerum hhd_cross_smallrum hhd_cross_poultry hhd_grass 
hhd_ofsp hhd_awassa83
hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 hhd_affor hhd_mango hhd_papaya hhd_avocado
hhd_impcr13 hhd_impcr19 hhd_impcr11 hhd_impcr24 hhd_impcr14 hhd_impcr3 hhd_impcr5 hhd_impcr60 hhd_impcr62
;
#delimit cr

********************************************************************************
* TABLE 1 - HH LEVEL
********************************************************************************

*wave4 
matrix drop _all

foreach x in 1 3 4 7 0 {  // these are the four main regions and others

	foreach var in $hhlevel {

		cap:mean `var' [pw=pw_w4] if region==`x' & wave==4
		if _rc==2000 {
			matrix  `var'meanr`x'=0
			matrix define `var'V`x'= 0

			scalar `var'se`x'=0
		}
		else if _rc!=0 {
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
		sum    `var'  if region==`x' & wave==4
		scalar `var'minr`x'=r(min)   // "summarize" is an r-class command (see "return list")
		scalar `var'maxr`x'=r(max)
		scalar `var'n`x'=r(N)

		qui sum region if region==`x' & wave==4
		local obsr`x'=r(N)  // # of households in region `x'

		matrix mat`var'`x' = (`var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')
		// (,) is a  row-join operator

		matrix list mat`var'`x'  // "matrix list" - Display the contents of a matrix

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'  // "\" is a column join operator
        
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