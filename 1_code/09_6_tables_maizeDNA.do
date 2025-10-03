********************************************************************************
*                           Ethiopia Synthesis Report - v2
*            DO: ESS4-ESS5 dynamics - Regressions comparing SR vs. DNAFP
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* Date created: August 19, 2023
* STATA Version: MP 17.0
********************************************************************************


* Correction of DNA data in ESS4 (by Solomon) ---------------------

/*
MELKASSA-2 should be CG source
BH-140*- Hybrid not OPV
*/
  

use "${dataw4}/ess4_dna_new.dta", clear

gen cg_source_m= cg_source

replace cg_source_m= "Yes" if subbinreferences=="MELKASSA-2"

gen crop_specific_variety_type_m= crop_specific_variety_type

replace crop_specific_variety_type_m = "Hybrid" if subbinreferences=="BH-140"
replace crop_specific_variety_type_m = "Hybrid" if subbinreferences=="RM0262017"


gen nameofvaraity_N=""

replace nameofvaraity_N= "GIBE1" if subbinreferences=="RM0512017"
replace nameofvaraity_N= "KULANI" if subbinreferences=="RM0042017"	
replace nameofvaraity_N= "shone" if subbinreferences=="RM0202017"	
replace nameofvaraity_N= "Damote" if subbinreferences=="RM0212017"	
replace nameofvaraity_N= "Jabi" if subbinreferences=="RM0222017"	
replace nameofvaraity_N= "Limu" if subbinreferences=="RM0232017"	
replace nameofvaraity_N= "BH-140" if subbinreferences=="RM0262017"	
replace nameofvaraity_N= "BH-661" if subbinreferences=="RM0292017"	
replace nameofvaraity_N= "BH-661" if subbinreferences=="RM0472017"	
replace nameofvaraity_N= "BH-660" if subbinreferences=="RM0482017"	
replace nameofvaraity_N= "BH-540" if subbinreferences=="RM0312017"	
replace nameofvaraity_N= "AMH-850(Wenchi)" if subbinreferences=="RM0142017"	
replace nameofvaraity_N= "AMH852Q" if subbinreferences=="RM0012017"
replace nameofvaraity_N= "Melkassa-1" if subbinreferences=="RM0022017"
replace nameofvaraity_N= "Melkasa-1Q" if subbinreferences=="RM0062017"
replace nameofvaraity_N= subbinreferences if  s4q01b==2 & nameofvaraity_N==""

gen Pedigree =""

replace Pedigree = "EIAR/CIMMYT" if cg_source=="Yes"


replace Pedigree = "Private" if nameofvaraity_N=="shone" & s4q01b==2

replace Pedigree = "Private" if nameofvaraity_N=="Jabi" & s4q01b==2
 
replace Pedigree = "Private" if nameofvaraity_N=="Limu" & s4q01b==2

replace Pedigree = "Private" if nameofvaraity_N=="Damote" & s4q01b==2
replace Pedigree  ="EIAR" if Pedigree =="" & s4q01b==2 & s4q01b==2


gen Pedigree_M =""

replace Pedigree_M = "EIAR/CIMMYT" if cg_source_m=="Yes"


replace Pedigree_M = "Private" if nameofvaraity_N=="shone" & s4q01b==2

replace Pedigree_M = "Private" if nameofvaraity_N=="Jabi" & s4q01b==2
 
replace Pedigree_M = "Private" if nameofvaraity_N=="Limu" & s4q01b==2

replace Pedigree_M = "Private" if nameofvaraity_N=="Damote" & s4q01b==2
replace Pedigree_M ="EIAR" if Pedigree_M =="" & s4q01b==2 & s4q01b==2
label variable Pedigree_M  " new_ variable _Origin / Pedigree "

label variable cg_source_m "Revised_CG_Source"
label variable nameofvaraity_N "Name of Varaity (new varaible)"

** correction _DT Statsus

gen dtmz_status_m= dtmz_status
ta dtmz_status_m

replace dtmz_status_m="Yes" if nameofvaraity_N== "MELKASSA-2"
replace dtmz_status_m="Yes" if nameofvaraity_N== "Melkassa-1"
replace dtmz_status_m="Yes" if nameofvaraity_N== "Melkasa-1Q"

rename id barcode

*** Based on the above correction- I have modified "def4_status"

* Paola data: improved if contains CG related germplasm unless traditional/ local

gen def4_status_m = ""

gen exotic_source_m= exotic_source

replace exotic_source_m = "Yes" if subbinreferences=="RM0312017"

order exotic_source_m, after (cg_source_m)

replace def4_status_m ="Improved" if  cg_source_m=="Yes" 

replace def4_status_m= "Non-improved" if  cg_source_m=="No" 


save "${data}/ess4_dna_new_mod.dta", replace



* Merging with covariates data

use "${dataw4}/ess4_pp_cov_new.dta", clear

// merge with tracking file to id panel hhs:
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

// merge with EA covariates:
merge m:1 ea_id using "${dataw4}/ess4_pp_cov_ea_new.dta", keepusing(cs4q011 cs4q15 cs4q53)
keep if _merge==1 | _merge==3
drop _merge

label var cs4q15 "Distance to the nearest large weekly market (Km)"

// merge with data on geo-covariates:
merge 1:1 household_id using "${raw4}/ETH_HouseholdGeovariables_Y4.dta", ///
    keepusing(dist_road dist_market dist_border dist_popcenter dist_admhq)
keep if _merge==1 | _merge==3
drop _merge

// renaming some covariates
rename nom_totcons_aeq nmtotcons
rename hhd_mintillage hhd_mintil
rename hhd_sweetpotato hhd_sp
rename  total_cons_ann_win totconswin
replace hhd_impcr2=. if maize_cg==.

* transform hh dist vars to log
gen ldist_road = log(dist_road) 
gen ldist_market = log(dist_market)
gen ldist_popcen = log(dist_popcenter)

label var ldist_road "Log HH Distance in (KMs) to Nearest Major Road"
label var ldist_market "Log HH Distance in (KMs) to Nearest Market"
label var ldist_popcen "Log HH Distance in (KMs) to Nearest Population Center with +20,000"

// Global of covariates to keepusing
#delimit;
global relcovar
hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann 
totconswin nmtotcons consq1 consq2 adulteq age_head cs4q011 cs4q15 cs4q53 dist_road 
dist_market dist_popcenter ldist_road ldist_market ldist_popcen largerum_cross poultry_cross barley_cg dtmz hhd_rdisp hhd_swc hhd_mintil hhd_avocado hhd_papaya hhd_mango hhd_psnp 
;
#delimit cr

#delimit;
global hhcov4
hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann nmtotcons consq1 consq2 adulteq age_head cs4q011 cs4q15 cs4q53 ldist_road ldist_market ldist_popcen
;
#delimit cr

keep holder_id-hh_ea $relcovar hhd_impcr2

for var hhd_rdisp hhd_swc hhd_mintil hhd_avocado  hhd_papaya hhd_mango: recode X (100=1)  // recode 100 to 1 to make dummy

winsor2 income_offfarm total_cons_ann nmtotcons, suffix(_win) label

gen largerum_cross_bin=0 if largerum_cross==0
replace largerum_cross_bin=1 if largerum_cross>0
replace largerum_cross_bin=. if missing(largerum_cross)

gen poultry_cross_bin=0 if poultry_cross==0
replace poultry_cross_bin=1 if poultry_cross>0
replace poultry_cross_bin=. if missing(poultry_cross)


* Summary Table 
tabstat  hhd_flab flivman parcesizeHA pssetindex income_offfarm_win nmtotcons_win consq2 age_head dist_market largerum_cross_bin poultry_cross_bin barley_cg dtmz hhd_rdisp hhd_swc hhd_mintil hhd_avocado hhd_papaya hhd_mango hhd_psnp, statistics(N mean sd min max) columns(s)

logout, save("summary_stat_covar.csv") excel replace: tabstat hhd_flab flivman parcesizeHA pssetindex income_offfarm_win nmtotcons_win consq2 age_head dist_market largerum_cross_bin poultry_cross_bin barley_cg dtmz hhd_rdisp hhd_swc hhd_mintil hhd_avocado hhd_papaya hhd_mango hhd_psnp, statistics(N mean sd min max) columns(s)

ex

// merge with DNAFP data
merge 1:m household_id using "${data}/ess4_dna_new_mod.dta", force
keep if _merge==3
drop _merge

// retain only maize
keep if maize==1

gen 	maize_cg = 1 if cg_source_m=="Yes"
replace maize_cg = 0 if cg_source_m=="No"

label var maize_cg "DNAFP"


* Variable indicating ownership of innovation: 

gen innov_own = 1 if subbinreferences == "RM0202017" | subbinreferences == "RM0232017" | subbinreferences == "RM0212017" | subbinreferences == "RM0222017"

replace innov_own = 2 if subbinreferences == "RM0292017" | subbinreferences == "RM0482017" | subbinreferences == "RM0312017" | subbinreferences == "RM0142017" | subbinreferences == "BH-140" | subbinreferences == "RM0012017" | subbinreferences == "BH-670" | subbinreferences == "RM0242017" | subbinreferences == "RM0072017" | subbinreferences == "RM0182017" | subbinreferences == "RM0472017"

replace innov_own = 3 if subbinreferences == "GIBE1" | subbinreferences == "KULANI" | subbinreferences == "MELKASSA-2" | subbinreferences == "RM0022017" | subbinreferences == "RM0062017" | subbinreferences == "RM0522017" | subbinreferences == "GAMBELA" | subbinreferences == "RM0042017" | subbinreferences == "RM0262017" | subbinreferences == "RM0512017"


tab innov_own, gen(innov_own)

label var innov_own1 "1. Private innovations"
label var innov_own2 "2a. Public innovation (Hybrids only)"
label var innov_own3 "2b. Public innovation (OPVs only)"

#delimit;
global adoptdna4 hhd_impcr2 maize_cg innov_own1 innov_own2 innov_own3
;
#delimit cr

* Regressions ------------------------------------------------

for var $adoptdna4: recode X (100=1)  // recode 100 to 1 to make dummy

// matrix of regs (all):

covar_regress_stats $adoptdna4, covar($hhcov4) wt(pw_w4)

local cname ""
foreach var in $adoptdna4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "." "R^2" "N" "'		
}


#delimit ;
xml_tab C,  save("$table/09_3_ess4_dna_adopters_chrxs.xml") replace 
sheet("Table20 - All", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: ESS4 - Correlates of adoption of improved maize - DNAFP vs. Self-reported data")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("Each cell is a coefficient estimate from a separate regression of the row variable on the column variable."); 
# delimit cr


* Purity above 90 percent -----------

covar_regress_stats $adoptdna4 if puritypuritypercent>90, covar($hhcov4) wt(pw_w4)

local cname ""
foreach var in $adoptdna4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "." "R^2" "N" "'		
}


#delimit ;
xml_tab C,  save("$table/09_3_ess4_dna_adopters_chrxs.xml") append 
sheet("Table20 - purity_90", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: ESS4 - Correlates of adoption of improved maize - DNAFP vs. Self-reported data")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("Each cell is a coefficient estimate from a separate regression of the row variable on the column variable."); 
# delimit cr


* Separate regressions by ownership of innovation ----
 
// 1. Private innovations -------

covar_regress_stats hhd_impcr2 if innov_own1 == 1, covar($hhcov4) wt(pw_w4) 

local cname ""
foreach var in $adoptdna4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "." "R^2" "N" "'		
}


#delimit ;
xml_tab C,  save("$table/09_3_ess4_dna_adopters_chrxs.xml") append 
sheet("1. Private", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: ESS4 - Correlates of adoption of improved maize - DNAFP vs. Self-reported data")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("Each cell is a coefficient estimate from a separate regression of the row variable on the column variable."); 
# delimit cr


// 2a. Public innovation (Hybrids only) -------

covar_regress_stats hhd_impcr2 if innov_own2 == 1, covar($hhcov4) wt(pw_w4) 

local cname ""
foreach var in $adoptdna4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "." "R^2" "N" "'		
}


#delimit ;
xml_tab C,  save("$table/09_3_ess4_dna_adopters_chrxs.xml") append 
sheet("2a. Public (Hybrids)", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: ESS4 - Correlates of adoption of improved maize - DNAFP vs. Self-reported data")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("Each cell is a coefficient estimate from a separate regression of the row variable on the column variable."); 
# delimit cr


// 2b. Public innovation (OPVs only) -------

covar_regress_stats hhd_impcr2 if innov_own3 == 1, covar($hhcov4) wt(pw_w4) 

local cname ""
foreach var in $adoptdna4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $hhcov4 {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "." "R^2" "N" "'		
}


#delimit ;
xml_tab C,  save("$table/09_3_ess4_dna_adopters_chrxs.xml") append 
sheet("2b. Public (OPVs)", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: ESS4 - Correlates of adoption of improved maize - DNAFP vs. Self-reported data")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("Each cell is a coefficient estimate from a separate regression of the row variable on the column variable."); 
# delimit cr

 

* Table of summary statistics for DNAFP vars 

tabstat $adoptdna4 $hhcov4, statistics(N mean sd min max) columns(s)

logout, save("summary_stat_dna.csv") excel replace: tabstat $adoptdna4, statistics(N mean sd min max) columns(s)




/*
DNAFP = B + C

"1. Private innovations" = D
"2a. Public innovation (Hybrids only)" = C
"2b. Public innovation (OPVs only)" = B
*/









