capture program drop descr_tab

program descr_tab
    args VARS 

    local vars `"`VARS'"'

    matrix drop _all

    foreach x in 3 4 7 0 {  // these are the three main regions (Tigray excluded) and others

        foreach var of local vars {

            cap: mean `var' [pw=pw_w5] if region==`x' & wave==5
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
            qui sum    `var'  if region==`x' & wave==5
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

        qui sum region if region==`x' & wave==5
        local obsr`x'=r(N)  // # of households in region `x'

        mat A2`x'=(., . , ., .,`obsr`x'')  
        mat B`x'=A1`x'\A2`x'

        matrix colnames B`x' = "Mean (%)" "SE" "Min" "Max" "N"

    }	


    * National:

    foreach var of local vars {

        cap: mean `var' [pw=pw_w5] if wave==5

        if _rc==2000 {
            matrix  `var'meanrN=0
            matrix define `var'VN= 0
            scalar `var'seN=0
        }
        else if _rc!=0 {
            error _rc
        }

        else {	
            matrix  `var'meanrN=e(b)'*100
            matrix define `var'VN= e(V)'
            matrix define `var'VVN=(vecdiag(`var'VN))'
            // matrix list `var'VVN
            scalar `var'seN=sqrt(`var'VVN[1,1])
        }

        qui sum    `var'  if  wave==5
        scalar `var'minrN=r(min)
        scalar `var'maxrN=r(max)
        scalar `var'nN=r(N)

        qui sum region if  wave==5
        local obsrN=r(N)

        matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)
        matrix rownames mat`var'N = "`var'"

        // matrix list mat`var'N

        matrix A1N = nullmat(A1N)\ mat`var'N

        mat A2N=(., . , ., .,`obsrN')
        mat BN=A1N\A2N

        matrix colnames BN = "Mean (%)" "SE" "Min" "Max" "N"

    }

    // Create final matrix:
    mat C = B3, B4, B7, B0, BN

end



