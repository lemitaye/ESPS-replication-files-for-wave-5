// Description: Programs to construct a matrix of descriptive statistics. 
//  Returns a matrix, C, that can be exported to a table.
// Date created: May 02, 2023
// Author: Lemi Daba (tayelemi@gmail.com)

capture program drop descr_tab

program descr_tab
    version 17.0
    syntax varlist [if] [in], regions(string) [wt(varname)]
    marksample touse, novarlist  // see documentation for "mark"

    if "`wt'" == "" { 
        local wt 1 
    } 

    matrix drop _all

    foreach x of local regions {  

        foreach var of local varlist {

            cap: mean `var' [pw=`wt'] if region==`x' & `touse'
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
                // matrix list `var'VV`x'  // display the contents of a matrix
                scalar `var'se`x'=sqrt(`var'VV`x'[1,1])  // standard error
            }
            // we do the following to get min, max, and # of obs; weighted mean is computed above
            qui sum `var'  if region==`x' & `touse'
            scalar `var'minr`x'=r(min)   // "summarize" is an r-class command (see "return list")
            scalar `var'maxr`x'=r(max)
            scalar `var'n`x'=r(N)

            matrix mat`var'`x' = (`var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')
            // (,) is a  row-join operator
            matrix rownames mat`var'`x' = "`var'"

            // matrix list mat`var'`x'  // "matrix list" - Display the contents of a matrix

            matrix A1`x' = nullmat(A1`x')\ mat`var'`x'  // "\" is a row join operator
            // appends row vector to matrix

        }

        qui sum region if region==`x' & `touse'
        local obsr`x'=r(N)  // # of households in region `x'

        mat A2`x'=(., . , ., .,`obsr`x'')  
        mat B`x'=A1`x'\A2`x'

        matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

    }	


    * National:

    foreach var of local varlist {

        cap: mean `var' [pw=`wt'] if `touse'

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
            // matrix list `var'VVN
            scalar `var'seN=sqrt(`var'VVN[1,1])
        }

        qui sum `var' if `touse'
        scalar `var'minrN=r(min)
        scalar `var'maxrN=r(max)
        scalar `var'nN=r(N)

        qui sum region if `touse'
        local obsrN=r(N)

        matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)
        matrix rownames mat`var'N = "`var'"

        // matrix list mat`var'N

        matrix A1N = nullmat(A1N)\ mat`var'N

        mat A2N=(., . , ., .,`obsrN')
        mat BN=A1N\A2N

        matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

    }

    // Create final matrix:
    foreach x of local regions {
        matrix C = (nullmat(C), B`x')
    }
    matrix C = (C, BN)     // append national

end

// For all other regions:
capture program drop descr_tab_othreg

program descr_tab_othreg
    version 17.0
    syntax varlist [if] [in], regions(string) [wt(varname)]
    marksample touse, novarlist

    if "`wt'" == "" { 
        local wt 1
    } 

    matrix drop _all

    foreach x of local regions {  

        foreach var of local varlist {

            cap: mean `var' [pw=`wt'] if othregion==`x' & `touse'
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
                // matrix list `var'VV`x'  // display the contents of a matrix
                scalar `var'se`x'=sqrt(`var'VV`x'[1,1])  // standard error
            }
            // we do the following to get min, max, and # of obs; weighted mean is computed above
            qui sum  `var'  if othregion==`x' & `touse'
            scalar `var'minr`x'=r(min)   // "summarize" is an r-class command (see "return list")
            scalar `var'maxr`x'=r(max)
            scalar `var'n`x'=r(N)

            matrix mat`var'`x' = (`var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')
            // (,) is a  row-join operator
            matrix rownames mat`var'`x' = "`var'"

            // matrix list mat`var'`x'  // "matrix list" - Display the contents of a matrix

            matrix A1`x' = nullmat(A1`x')\ mat`var'`x'  // "\" is a row join operator
            // appends row vector to matrix

        }

        qui sum othregion if othregion==`x' & `touse'
        local obsr`x'=r(N)  // # of households in region `x'

        mat A2`x'=(., . , ., .,`obsr`x'')  
        mat B`x'=A1`x'\A2`x'

        matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

    }

    // Create final matrix:
    foreach x of local regions {
        matrix C = (nullmat(C), B`x')
    }

end


capture program drop myprog
program myprog
    syntax varlist [if] [in], regions(string) [wt(varname)]
    marksample touse

    if "`wt'" == "" { 
        local wt 1 
    } 

    foreach x of local regions {

        foreach var of local varlist {
            mean `var' [pw=`wt'] if region==`x' & `touse'
        }

        sum region if region==`x' & `touse'

    }
end