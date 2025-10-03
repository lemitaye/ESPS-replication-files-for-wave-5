********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - Descriptive stats of covariates
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* Date created: May 02, 2023
* STATA Version: MP 17.0
********************************************************************************


* ESS5 ------------------------------------

* Household level ----------
use "${tmp}/covariates/04_2_covars_hh_pp.dta", clear

// merge with tracking file to id panel hhs:
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge


* inflation adjustment for monetary figures using CPI
* (note: CPI adjustment factor taken from the world bank)
gen incoff_adj = income_offfarm / 1.768
gen nmtotcons_adj = nom_totcons_aeq / 1.768
gen totcons_adj = total_cons_ann / 1.768

label var incoff_adj "Annual Off-farm income in BIRR (Inflation adjusted)"
label var nmtotcons_adj "Nominal annual consumption per adult equivalent (Inflation adjusted)"
label var totcons_adj "Total annual consumption (Inflation adjusted)"


#delimit;
global hhcov5   
parcesizeHA fem_head fowner flivman hhd_flab age_head nom_totcons_aeq nmtotcons_adj consq1 
consq2 asset_index pssetindex income_offfarm incoff_adj dist_road dist_market dist_popcenter
;
#delimit cr

// prep:
local rname ""
foreach var in $hhcov5 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

#delimit;
global options1
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
        6 55, 7 55, 8 30, 9 30, 10 40,
        11 55, 12 55, 13 30, 14 30, 15 40,
        16 55, 17 55, 18 30, 19 30, 20 40,
        21 55, 22 55, 23 30, 24 30, 25 40,
        26 55, 27 55, 28 30, 29 30, 30 40,
        31 55, 32 55, 33 30, 34 30, 35 40,
        36 55, 37 55, 38 30, 39 30, 40 40,
        41 55, 42 55, 43 30, 44 30, 45 40
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes("Point estimates are weighted sample means.") //Add your notes here
;
#delimit cr	

// All households:
descr_tab $hhcov5, regions("2 3 4 5 6 7 12 13 15") wt(pw_w5)	

xml_tab C,  save("$table/09_2_ess5_covar_dstats.xml") replace sheet("Table13_HH", nogridlines) ///
    title("Table: ESS5 - Descriptive statistics of covariates") $options1

// Panel households
descr_tab $hhcov5 if hh_status==3, regions("2 3 4 5 6 7 12 13 15") wt(pw_panel)	

xml_tab C,  save("$table/09_2_ess5_covar_dstats.xml") append sheet("Table13_HH_panel", nogridlines) ///
    title("Table: ESS5 - Descriptive statistics of covariates: only panel households") $options1


* EA level --------------------------------

use "${data}/ess5_pp_cov_ea_new.dta", clear

// merge with tracking file to id panel EAs
merge 1:1 ea_id using "${tmp}/dynamics/06_1_track_ea.dta", keepusing(ea_status)
keep if _merge==1 | _merge==3
drop _merge

// replace missing distances with zero:
for var cs4q15 cs4q53 cs4q15_wiz cs4q53_wiz: replace X=0 if X==.

#delimit;
global eacov5 cs9q01 cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 
cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 
cs6q15_13 cs4q01_11 cs4q01_12 cs4q01_13 cs4q01_14 cs4q03 cs4q08 cs4q11 cs4q14 
cs4q52 cs9q13 cs9q13_wiz cs9q14 cs6q01 cs6q10 cs4q02 cs4q02_wiz cs4q01 cs4q09 
cs4q09_wiz cs4q11 cs4q12b cs4q12b_wiz  cs4q15 cs4q15_wiz cs3q02 cs3q02_wiz cs4q52 
cs4q53 cs4q53_wiz 
;
#delimit cr

// prep:
local rname ""
foreach var in $eacov5 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

#delimit;
global options2
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
    6 55, 7 55, 8 30, 9 30, 10 40,
    11 55, 12 55, 13 30, 14 30, 15 40,
    16 55, 17 55, 18 30, 19 30, 20 40,
    21 55, 22 55, 23 30, 24 30, 25 40,
    26 55, 27 55, 28 30, 29 30, 30 40,
    31 55, 32 55, 33 30, 34 30, 35 40,
    36 55, 37 55, 38 30, 39 30, 40 40,
    41 55, 42 55, 43 30, 44 30, 45 40,
    46 55, 47 55, 48 30, 49 30, 50 40) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
notes("Point estimates are un-weighted sample means.") //Add your notes here
;
#delimit cr	

// All EAs:
descr_tab $eacov5, regions("2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_2_ess5_covar_dstats.xml") append sheet("Table13_EA", nogridlines) ///
    title("Table: ESS5 - Descriptive statistics of covariates") $options2

// Panel EAs:
descr_tab $eacov5 if ea_status==3, regions("2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_2_ess5_covar_dstats.xml") append sheet("Table13_EA_panel", nogridlines) ///
    title("Table: ESS5 - Descriptive statistics of covariates: only panel EAs") $options2    



* ESS4 -----------------------------------------------

* Household level ---------------

use "${dataw4}/ess4_pp_cov_new.dta", clear

// merge to id panel hhs:
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

// merge to get panel weights:
merge 1:1 household_id using "${rawdata}/HH/ESS5_weights_hh.dta", keepusing(pw_panel)
keep if _merge==1 | _merge==3
drop _merge

// merge with data on geo-covariates:
merge 1:1 household_id using "${raw4}/ETH_HouseholdGeovariables_Y4.dta", ///
    keepusing(dist_road dist_market dist_border dist_popcenter dist_admhq)
keep if _merge==1 | _merge==3
drop _merge


#delimit;
global hhlevel4 
parcesizeHA fem_head fowne flivman hhd_flab  age_head nom_totcons_aeq consq1 
consq2 asset_index pssetindex income_offfarm dist_road dist_market dist_popcenter
;
# delimit cr

// prep:
local rname ""
foreach var in $hhlevel4 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

#delimit;
global options3
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Afar" "Afar" "Afar" "Afar" "Afar" 
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
        6 55, 7 55, 8 30, 9 30, 10 40,
        11 55, 12 55, 13 30, 14 30, 15 40,
        16 55, 17 55, 18 30, 19 30, 20 40,
        21 55, 22 55, 23 30, 24 30, 25 40,
        26 55, 27 55, 28 30, 29 30, 30 40,
        31 55, 32 55, 33 30, 34 30, 35 40,
        36 55, 37 55, 38 30, 39 30, 40 40,
        41 55, 42 55, 43 30, 44 30, 45 40
        46 55, 47 55, 48 30, 49 30, 50 40
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes("Point estimates are weighted sample means.") //Add your notes here
;
#delimit cr	


// All households:
descr_tab $hhlevel4, regions("1 2 3 4 5 6 7 12 13 15") wt(pw_w4)	

xml_tab C,  save("$table/09_2_ess4_covar_dstats.xml") replace sheet("Table13_HH", nogridlines) ///
    title("Table: ESS4 - Descriptive statistics of covariates") $options3

// Panel households
descr_tab $hhlevel4 if hh_status==3, regions("1 2 3 4 5 6 7 12 13 15") wt(pw_panel)	

xml_tab C,  save("$table/09_2_ess4_covar_dstats.xml") append sheet("Table13_HH_panel", nogridlines) ///
    title("Table: ESS4 - Descriptive statistics of covariates: only panel households") $options3


* EA level -------------

use "${dataw4}/ess4_pp_cov_ea_new.dta", clear

// merge with tracking file to id panel EAs
merge 1:1 ea_id using "${tmp}/dynamics/06_1_track_ea.dta", keepusing(ea_status)
keep if _merge==1 | _merge==3
drop _merge

// replace missing distances with zero:
for var cs4q15 cs4q53 cs4q15wiz csdq53wiz: replace X=0 if X==.

#delimit ;
global eacov4 
cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 //Major source of fertilizer in the community
cs6q13_11 cs6q13_12 cs6q13_13 cs6q13_14 // Major source of pesticides/herbicides in the community
cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 // Major source of hybrid seeds in the community
cs6q15_11 cs6q15_12 cs6q15_13           // Type of facility to store crops prior to sale
cs4q011   cs4q012   cs4q013   cs4q014   // Type of main access road surface
cs4q52                                  //Incidence of SACCO in the community
cs4q53 csdq53wiz                        // Distance to the nearest place with SACCO 
cs4q15 cs4q15wiz						// Distance to the nearest large weekly market                                      
;
#delimit cr		


// prep:
local rname ""
foreach var in $eacov4 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

#delimit;
global options4
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Tigray" "Tigray" "Tigray" "Tigray" "Tigray" "Afar" "Afar" "Afar" "Afar" "Afar" 
"Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
        6 55, 7 55, 8 30, 9 30, 10 40,
        11 55, 12 55, 13 30, 14 30, 15 40,
        16 55, 17 55, 18 30, 19 30, 20 40,
        21 55, 22 55, 23 30, 24 30, 25 40,
        26 55, 27 55, 28 30, 29 30, 30 40,
        31 55, 32 55, 33 30, 34 30, 35 40,
        36 55, 37 55, 38 30, 39 30, 40 40,
        41 55, 42 55, 43 30, 44 30, 45 40
        46 55, 47 55, 48 30, 49 30, 50 40
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) 
	(NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) 
	(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) 
	(NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
	star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
	notes("Point estimates are un-weighted sample means.") //Add your notes here
;
#delimit cr	


// All EAs:
descr_tab $eacov4, regions("1 2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_2_ess4_covar_dstats.xml") append sheet("Table13_EA", nogridlines) ///
    title("Table: ESS4 - Descriptive statistics of covariates") $options4

// Panel EAs:
descr_tab $eacov4 if ea_status==3, regions("1 2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_2_ess4_covar_dstats.xml") append sheet("Table13_EA_panel", nogridlines) ///
    title("Table: ESS4 - Descriptive statistics of covariates: only panel EAs") $options4