// Description: A program to perform a pair-wise regression. Note: ADOPT and COVAR must be
// provided as global macros. Returns a matrix, D, that can be exported to a 
// table.
// Date created: May 02, 2023
// Author: Lemi Daba (tayelemi@gmail.com)

capture program drop covar_regress

program covar_regress
    args ADOPT COVAR 

    local adopt `"`ADOPT'"'
    local covar `"`COVAR'"'

	matrix drop _all

    foreach i of local adopt {
		
        foreach var of local covar {

        qui: reg `var' `i' if  wave==5 [pw=pw_w5]
        scalar coef`var'`i'=e(b)[1,1]   // coefficient
        matrix mat`var'`i'=coef`var'`i'

        qui: test `i'=0
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

        matrix C = nullmat(C), A1`i'
        matrix C_STARS = nullmat(C_STARS), A1`i'_STARS
    }

    // Transpose:
    matrix D = C'
    matrix D_STARS = C_STARS' 
end