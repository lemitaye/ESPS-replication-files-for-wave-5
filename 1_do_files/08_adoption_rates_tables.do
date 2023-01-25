
use "${data}\wave5_hh_new", clear

#delimit ;
global hhlevel     
hhd_ofsp hhd_awassa83 hhd_kabuli hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 
hhd_affor hhd_mango hhd_papaya hhd_avocado hotline hhd_malt hhd_durum hhd_seedv1 hhd_seedv2 
hhd_livIA hhd_livIA_publ hhd_livIA_priv hhd_cross_largerum hhd_cross_smallrum hhd_cross_poultry 
hhd_agroind hhd_cowpea hhd_elepgrass hhd_deshograss  hhd_sesbaniya hhd_sinar hhd_lablab hhd_alfalfa 
hhd_vetch hhd_rhodesgrass hhd_grass dtmz maize_cg hhd_impcr13 hhd_impcr19 hhd_impcr11 hhd_impcr24  
hhd_impcr14 hhd_impcr3 hhd_impcr5 hhd_impcr60 hhd_impcr62 
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
			matrix  `var'meanr`x'=e(b)'*100    // mean (% out of 100)
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

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'  // "\" is a row join operator
        // appends row vector to matrix
		mat A2`x'=(., . , ., .,`obsr`x'')  
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean (%)" "SE" "Min" "Max" "N"
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
		matrix  `var'meanrN=e(b)'*100
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

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean (%)" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $hhlevel {
	local lbl: variable label `var'
	local rname `"  `rname'   "`lbl'" "'
}

// Create final matrix:
mat C = B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table\Sec6_ESS5.xml") replace sheet("Table_1_hh", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" 
"Other regions" "Other regions" "Other regions" "Other regions" "National" 
"National" "National" "National" "National" ) 
showeq 
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	 
title(Table 1: ESS5 - Rural Household level - Section 6)  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)   
	notes("Point estimates are wegihted sample means. These are multiplied by 100 for dummy variables to express them as percengages.") 
;
#delimit cr		


**** Other regions: wave5 ****************************************************** 

matrix drop _all

foreach x in 2 5 6 12 13 15  {

	foreach var in $hhlevel {

		cap: mean `var' [pw=pw_w5] if othregion==`x' & wave==5
		
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

		sum    `var'  if othregion==`x' & wave==5
		if r(N)==0 {
			scalar `var'minr`x'=0
			scalar `var'maxr`x'=0
			scalar `var'n`x'=0
					}
		else {
			scalar `var'minr`x'=r(min)
			scalar `var'maxr`x'=r(max)
			scalar `var'n`x'=r(N)
		}

		qui sum region if othregion==`x' & wave==5
		local obsr`x'=r(N)

		matrix mat`var'`x' = (`var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

		matrix list mat`var'`x'

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

		mat A2`x'=(., . , ., .,`obsr`x'')
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean (%)" "SE" "Min" "Max" "N"

	}	

}

local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'	
}

mat C = B2, B5, B6, B12, B13, B15

# delimit;
xml_tab C,  save("$table\Sec6_ESS5.xml") append sheet("Table_1_hh_oth regions", nogridlines) 
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Somali" "Somali" "Somali" "Somali" "Somali" 
"Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz"  "Benshangul Gumuz"  "Benshangul Gumuz"  
"Gambela"  "Gambela" "Gambela"    "Gambela"  "Gambela"  "Harar" "Harar" "Harar" "Harar" "Harar" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa") showeq 
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, hhd_impccr  "Share of plots per household" S2149)	
title(Table 1: ESS4 - Rural Household level - Section 6 - Other regions)  
font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0))   
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
	notes( "Point estimates are wegihted sample means. These are multiplied by 100 for dummy variables to express them as percengages."  ) //Add your notes here
; 
# delimit cr


********************************************************************************
* EA LEVEL TABLES
********************************************************************************
use "${data}\wave5_ea_new", clear


#delimit ;
global ealevel
ead_ofsp ead_awassa83 ead_kabuli ead_rdisp ead_motorpump ead_swc  ead_consag1 ead_consag2 
ead_affor ead_mango ead_papaya ead_avocado ead_malt ead_durum ead_hotline ead_seedv1 ead_seedv2 
ead_livIA ead_livIA_publ ead_livIA_priv ead_cross_largerum ead_cross_smallrum ead_cross_poultry
ead_agroind ead_cowpea ead_elepgrass ead_deshograss ead_sesbaniya ead_sinar ead_lablab ead_alfalfa 
ead_vetch ead_rhodesgrass ead_grass dtmz maize_cg
commirr comm_video comm_video_all comm_2wt_own comm_2wt_use comm_psnp ead_impcr13 ead_impcr19 
ead_impcr11 ead_impcr24 ead_impcr14 ead_impcr3 ead_impcr5 ead_impcr60 ead_impcr62;
#delimit cr
	

matrix drop _all

foreach x in 3 4 7 0 {

    foreach var in $ealevel {
    
        cap: mean `var' [pw=pw_w5] if region==`x' & wave==5
        if _rc==2000 {
            matrix  `var'meanr`x'=0
            matrix define `var'V`x'= 0
            scalar `var'se`x'=0
        }
        else if _rc!=0 {
            error _rc
        }
        else {
            matrix  `var'meanr`x'=e(b)'*100
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

        matrix colnames B`x' = "Mean (%)" "SE" "Min" "Max" "N"
    }

    local rname ""
    foreach var in $ealevel {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
    }	

}
	
* National
foreach var in $ealevel {
 
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
        matrix list `var'VVN
        scalar `var'seN=sqrt(`var'VVN[1,1])
    }

    sum    `var'  if  wave==5
    scalar `var'minrN=r(min)
    scalar `var'maxrN=r(max)
    scalar `var'nN=r(N)

    qui sum region if  wave==5
    local obsrN=r(N)

    matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)

    matrix list mat`var'N

    matrix A1N = nullmat(A1N)\ mat`var'N

    mat A2N=(., . , ., .,`obsrN')
    mat BN=A1N\A2N

    matrix colnames BN = "Mean (%)" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $ealevel {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	


mat C= B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table\Sec6_ESS5.xml") append sheet("Table_5_ea", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" 
"Other regions" "Other regions" "Other regions"  "National" "National" "National" 
"National" "National"  ) showeq 
rblanks(COL_NAMES "Perc. of EA in the sample with at least 1 hh adopting:" S2149,
ead_impccr   "Perc. of hh per EA adopting" S2149, 
sh_ea_impccr"Perc. of plots per EA adopting" S2149)	 
title(Table 5: ESS5 - Crop variety - EA )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
    (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
    (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
    (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
    (NBCR0) (NBCR0)) 
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
	notes("Point estimates are wegihted sample means. These are multiplied by 100 for dummy variables to express them as percengages.") 
; 
# delimit cr


********************************************************************************
* OTHER REGIONS
* TABLE 5	
	
matrix drop _all

foreach x in 2 5 6 12 13 15 {

	foreach var in $ealevel {

		cap: mean `var' if othregion==`x' & wave==5
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

		sum    `var'  if othregion==`x' & wave==5
		if r(N)==0 {
			scalar `var'minr`x'=0
			scalar `var'maxr`x'=0
			scalar `var'n`x'=0
		}
		else {
			scalar `var'minr`x'=r(min)
			scalar `var'maxr`x'=r(max)
			scalar `var'n`x'=r(N)
		}

		qui sum region if othregion==`x' & wave==5
		local obsr`x'=r(N)

		matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

		matrix list mat`var'`x'

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

		mat A2`x'=(., . , ., .,`obsr`x'')
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean (%)" "SE" "Min" "Max" "N"

	}

	local rname ""
	foreach var in $ealevel {
		local lbl : variable label `var'
		local rname `"  `rname'   "`lbl'" "'			
	}	

}
	
* All Other regions
foreach var in $ealevel {

	cap:mean `var' if wave==5 & region==0
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

	sum    `var'  if  wave==5 & region==0
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==5 & region==0
	local obsrN=r(N)

	matrix mat`var'N  = ( `var'meanrN, `var'seN, `var'minrN, `var'maxrN, `var'nN)

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean (%)" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $ealevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	


mat C= B2, B5, B6, B12, B13, B15, BN

#delimit;
xml_tab C,  save("$table\Sec6_ESS5.xml") append sheet("Table_5_ea_oth regions", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Afar" "Afar" "Afar" "Afar" 
"Afar" "Somali"  "Somali" "Somali" "Somali" "Somali" "Benshangul Gumuz" "Benshangul Gumuz" 
"Benshangul Gumuz" "Benshangul Gumuz"  "Benshangul Gumuz"  "Gambela" "Gambela"  "Gambela"  
"Gambela"  "Gambela"  "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Other regions"   "Other regions" "Other regions" 
"Other regions" "Other regions") showeq 
rblanks(COL_NAMES "Perc. of EA in the sample with at least 1 hh adopting:" S2149,
ead_sweetpotato   "Perc. of hh per EA adopting" S2149, 
sh_ea_sweetpotato "Perc. of plots per EA adopting" S2149)	 
title(Table 5_b: ESS5 - Crop variety - EA - Other regions )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
	(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
	(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
	(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
	(NBCR0) (NBCR0))  
	star(.1 .05 .01)   
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
	notes("Point estimates are wegihted sample means. These are multiplied by 100 for dummy variables to express them as percengages.") //Add your notes here
; 
# delimit cr


********************************************************************************
* Crop-germplasm improvement
********************************************************************************

use "${data}\ess5_dna_new", clear

global hhlevel dtmz maize_cg 

matrix drop _all

foreach x in 3 4 7 13 15 {  // Regions: Amhara, Oromia, SNNP, Harar, and Dire Dawa

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
			matrix  `var'meanr`x'=e(b)'*100    // mean (% out of 100)
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

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'  // "\" is a row join operator
        // appends row vector to matrix
		mat A2`x'=(., . , ., .,`obsr`x'')  
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean (%)" "SE" "Min" "Max" "N"
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
		matrix  `var'meanrN=e(b)'*100
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

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean (%)" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $hhlevel {
	local lbl: variable label `var'
	local rname `"  `rname'   "`lbl'" "'
}

// Create final matrix:
mat C = B3, B4, B7, B13, B15, BN

xml_tab C ,  save("$table\Sec6_ESS5.xml") append sheet("Table_5_hh", nogridlines)  rnames(`rname' "Total No. of obs. per region") ///
cnames(`cnames')  ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "National" "National" "National" "National" "National") showeq ///
rblanks(COL_NAMES "Field level data" S2220)	 /// 
title(Table 5: ESS5 - DNA fingerprinting - by region)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40  ) /// 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) )  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes("Point estimates are wegihted sample means. These are multiplied by 100 for dummy variables to express them as percengages.") 

