

********************************************************************************
**************************** TABLES OF COVARIATES ONLY   ***********************
************************************* ESPS4 *************************************

* HH - LEVEL *


use "${data}\ess4_pp_cov_new", clear


* The following is to retain only panel households
preserve
    use "${rawdata}\PP\sect_cover_pp_w5", clear

    collapse (firstnm) ea_id saq14 pw_w5 saq01, by(household_id)
    rename saq01 region_w5
    rename saq14 location_w5
    rename ea_id ea_id_w5

    tempfile cover_pp_w5
    save `cover_pp_w5'
restore

merge 1:1 household_id using `cover_pp_w5'
keep if _merge==3  // retain only panel households (count=1823)
drop region_w5 location_w5 ea_id_w5


#delimit;
global hhlevel   
parcesizeHA fem_head fowner flivman hhd_flab  age_head nom_totcons_aeq consq1 
consq2 asset_index pssetindex income_offfarm
;
#delimit cr


* TABLES * Table 13 -Household level variables
matrix drop _all

foreach x in 3 4 7 0 {

	foreach var in $hhlevel {

		cap:mean `var' [pw=pw_w5] if region==`x' & wave==4
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

		sum    `var'  if region==`x' & wave==4
		scalar `var'minr`x'=r(min)
		scalar `var'maxr`x'=r(max)
		scalar `var'n`x'=r(N)

		qui sum region if region==`x' & wave==4
		local obsr`x'=r(N)

		matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

		matrix list mat`var'`x'

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

		mat A2`x'=(., . , ., .,`obsr`x'')
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

	}

}
	
* National
foreach var in $hhlevel {

	cap:mean `var' [pw=pw_w5] if wave==4

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

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
	local obsrN=r(N)

	matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B3, B4, B7, B0, BN											

#delimit;
xml_tab C,  save("$table\Table13_ess4.xml") replace sheet("HH level - panel hhs", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" 
"Other regions" "Other regions" "Other regions" "National" "National" "National" 
"National" "National" ) showeq 
title(Table 1: ESPS4 - Household characteristics (only panel households) )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. These are multiplied by 100 for dummy variables to express them as percengages. 
Only rural sample included.) //Add your notes here
;
#delimit cr		



* The following is to retian only ESPS4 hhs that were in EAs surveyed in ESPS5
use "${data}\ess4_pp_cov_new", clear

preserve
	use "${rawdata}\sect_cover_pp_w4", clear

	collapse (firstnm) ea_id saq14 saq01, by(household_id)
	rename saq01 region_w4
	rename saq14 location_w4

	tempfile cover_pp_w4
	save `cover_pp_w4'

	use "${rawdata}\PP\sect_cover_pp_w5", clear

	destring household_id, replace
	collapse (firstnm) saq14 saq01 pw_w5 (count) household_id, by(ea_id)
	rename saq01 region_w5
	rename saq14 location_w5
	rename household_id nohh_per_ea_w5

	merge 1:m ea_id using `cover_pp_w4'

	generate ea_missing=.
	replace ea_missing=1 if _merge==2
	replace ea_missing=0 if _merge==1 | _merge==3

	tab region_w4 ea_missing
	drop if household_id==""   // 28 obs. (all from wave 5)
	drop _merge

	save "${tmp}\ea_merged_w5", replace
restore

merge 1:1 household_id using "${tmp}\ea_merged_w5"
/*
   Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                             2,899  (_merge==3)
    -----------------------------------------
*/

drop if ea_missing==1  // (967 obs. deleted; 1,932 remain)
drop _m



* Table 13 - sheet 2: Household level variables (hhs with non-missing EAs in ESPS5)
matrix drop _all

foreach x in 3 4 7 0 {

	foreach var in $hhlevel {

		cap:mean `var' [pw=pw_w5] if region==`x' & wave==4
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

		sum    `var'  if region==`x' & wave==4
		scalar `var'minr`x'=r(min)
		scalar `var'maxr`x'=r(max)
		scalar `var'n`x'=r(N)

		qui sum region if region==`x' & wave==4
		local obsr`x'=r(N)

		matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

		matrix list mat`var'`x'

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

		mat A2`x'=(., . , ., .,`obsr`x'')
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

	}

}
	
* National
foreach var in $hhlevel {

	cap:mean `var' [pw=pw_w5] if wave==4

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

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
	local obsrN=r(N)

	matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	

mat C= B3, B4, B7, B0, BN											

#delimit;
xml_tab C,  save("$table\Table13_ess4.xml") append sheet("HH level - non-missing EAs", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" 
"Other regions" "Other regions" "Other regions" "National" "National" "National" 
"National" "National" ) showeq 
title(Table 1: ESPS4 - Household characteristics (only panel households) )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. These are multiplied by 100 for dummy variables to express them as percengages. 
Only rural sample included.) //Add your notes here
;
#delimit cr	




********************************************************************************
* Plot level
********************************************************************************

use "${data}\ess4_pp_cov_plot_new", clear

merge m:1 household_id using "${tmp}\ea_merged_w5"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             9
        from master                         0  (_merge==1)
        from using                          9  (_merge==2)

    Matched                            19,805  (_merge==3)
    -----------------------------------------
*/
drop if _m==2
drop _m
drop if ea_missing==1  // (5,293 deleted; 14,512 remain)


#delimit ;
global plotlevel 
title fowner frsell acqparc1 acqparc2 acqparc3 acqparc6 acqparc7 acqparcoth 
soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6

plotarea_sr plotarea_gps  plotarea_full
cropt1 cropt2 cropt3 cropm1 falloq 
fplotm extprog
irr irrm1 urea dap nps othfert manure hiredlab lprep soiler 

improv cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell  
s3q121 s3q122 s3q123  s3q05 fild_prpa1 fild_prpa2 fild_prpa3 fild_prpa4 s4q05 s4q06 s4q07;
#delimit cr

matrix drop _all
foreach x in 3 4 7 0 {

	foreach var in $plotlevel {

		cap:mean `var' [pw=pw_w5] if region==`x' & wave==4
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

		sum    `var'  if region==`x' & wave==4
		scalar `var'minr`x'=r(min)
		scalar `var'maxr`x'=r(max)
		scalar `var'n`x'=r(N)

		qui sum region if region==`x' & wave==4
		local obsr`x'=r(N)

		matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

		matrix list mat`var'`x'

		matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

		mat A2`x'=(., . , ., .,`obsr`x'')
		mat B`x'=A1`x'\A2`x'

		matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

	}

	local rname ""
	foreach var in $plotlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
	}	

}	


* National
foreach var in $plotlevel {

	cap:mean `var' [pw=pw_w5] if wave==4
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

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
	local obsrN=r(N)

	matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

local rname ""
foreach var in $plotlevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	
mat C= B3, B4, B7, B0, BN


#delimit;																			
xml_tab C,  save("$table\Table13_ess4.xml") append sheet("Plot level - non-missing EAs", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" "Other regions" "National" "National" "National" "National" "National" ) showeq ///
title(Table 2: ESPS4 - Plot characteristics )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. These are multiplied by 100 for dummy variables to express them as percengages. 
Only rural sample included.) //Add your notes here
;
#delimit cr		

********************************************************************************
* EA - level 
********************************************************************************


use "${data}\\ess4_pp_cov_ea_new", clear

preserve
	use "${tmp}\ea_merged_w5", clear
	collapse (max) ea_missing (firstnm) pw_w5 region_w4, by(ea_id)

	tempfile ea_w5
	save `ea_w5'
restore

merge 1:1 ea_id using `ea_w5'
drop if _m==2
drop _m
drop if ea_missing==1  // (81 EAs deleted; 172 remain)



#delimit ;
global ealevel 
cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 //Major source of fertilizer in the community
cs6q13_11 cs6q13_12 cs6q13_13 cs6q13_14 // Major source of pesticides/herbicides in the community
cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 // Major source of hybrid seeds in the community
cs6q15_11 cs6q15_12 cs6q15_13           // Type of facility to store crops prior to sale
cs4q011   cs4q012   cs4q013   cs4q014   // Type of main access road surface
cs4q52                                  //Incidence of SACCO in the community
cs4q53 csdq53wiz                        // Distance to the nearest place with SACCO 
cs4q15								    // Distance to the nearest large weekly market
                                        
;
#delimit cr		

matrix drop _all

foreach x in 3 4 7 0 {

	foreach var in $ealevel {

	cap:mean `var' [pw=pw_w5] if region==`x' & wave==4
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

	sum    `var'  if region==`x' & wave==4
	scalar `var'minr`x'=r(min)
	scalar `var'maxr`x'=r(max)
	scalar `var'n`x'=r(N)

	qui sum region if region==`x' & wave==4
	local obsr`x'=r(N)

	matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

	matrix list mat`var'`x'

	matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

	mat A2`x'=(., . , ., .,`obsr`x'')
	mat B`x'=A1`x'\A2`x'

	matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

	}

	local rname ""
	foreach var in $ealevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" " " "'		
	}	



}	
* National
foreach var in $ealevel {

	cap:mean `var' [pw=pw_w5] if wave==4
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

	sum    `var'  if  wave==4
	scalar `var'minrN=r(min)
	scalar `var'maxrN=r(max)
	scalar `var'nN=r(N)

	qui sum region if  wave==4
	local obsrN=r(N)

	matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)

	matrix list mat`var'N

	matrix A1N = nullmat(A1N)\ mat`var'N

	mat A2N=(., . , ., .,`obsrN')
	mat BN=A1N\A2N

	matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}


local rname ""
foreach var in $ealevel {
local lbl : variable label `var'
local rname `"  `rname'   "`lbl'" "'		
}	
mat C= B3, B4, B7, B0, BN


#delimit;
xml_tab C,  save("$table\Table13_ess4.xml") append sheet("EA level - matched EAs", nogridlines) 
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" "Other regions" "Other regions" "Other regions" 
"Other regions" "National" "National" "National" "National" "National" ) showeq 
title(Table 3: ESPS4 - EA characteristics for matched EAs with ESPS5 )  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
)  
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
star(.1 .05 .01)  
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  
notes(Point estimates are weighted sample means. These are multiplied by 100 for dummy variables to express them as percengages. 
Only rural sample included.) 
;
#delimit cr		







