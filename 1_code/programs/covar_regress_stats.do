
// Description: A program to perform a pair-wise regression. Note: ADOPT and COVAR must be
// provided as global macros. Returns a matrix, D, that can be exported to a 
// table.
// Date created: August 20, 2023
// Author: Lemi Daba (tayelemi@gmail.com)

capture program drop covar_regress_stats

program covar_regress_stats
    version 17.0
    syntax varlist [if] [in], covar(varlist) [wt(varname)]
    marksample touse, novarlist  // see documentation for "mark"

    if "`wt'" == "" { 
        local wt 1 
    } 
	
	matrix drop _all 
 
	foreach i of local varlist {

		foreach var of local covar {

			qui: reg `var' `i' if `touse' [pw=`wt']

			scalar bcov`var'`i'  = r(table)[1,1]
			scalar secov`var'`i' = r(table)[2,1]
			scalar pcov`var'`i'  = r(table)[4,1]

			scalar N  = e(N)
			scalar F  = e(F)
			scalar r2 = e(r2)

			matrix bse`var'`i' = (bcov`var'`i' \ secov`var'`i' \ r2 \ N)
			
			matrix rownames bse`var'`i' = `var' . r2 N
			
			
			// p-values:
			// "# / 0" b/c no stars needed for s.e.  					
				if (pcov`var'`i'<=0.1 & pcov`var'`i'>0.05)  {
					matrix p`var'`i' = (3 \ 0)      // significant at 10% level
				}
				
				if (pcov`var'`i'  <=0.05 & pcov`var'`i'>0.01)  {
					matrix p`var'`i' = (2 \ 0)      // significant at 5% level
				}
				
				if pcov`var'`i'  <=0.01 {
					matrix p`var'`i' = (1 \ 0)      // significant at 1% level
				}
				
				if pcov`var'`i'   >0.1 {
					matrix p`var'`i' = (0 \ 0)       // Non-significant
				}

			matrix p`var'`i'fin = (p`var'`i' \ 0 \ 0)  // add two more rows for r2 & N

			matrix A1`i' = nullmat(A1`i')\ bse`var'`i'

			matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\ p`var'`i'fin

		}

		matrix colnames A1`i' = "Difference"

		matrix C = (nullmat(C), A1`i')
		matrix C_STARS = (nullmat(C_STARS), A1`i'_STARS)
	}
	
	// Transpose:
    matrix D = C'
    matrix D_STARS = C_STARS' 
end