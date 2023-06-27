********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: CG Germplasm and year of release
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${tmp}/missclass/05_1_misclass_purity.dta", clear


* Year Before 1990

* True positive
gen     maize_tp3a=.
replace maize_tp3a=0  
replace maize_tp3a=1 if cg_source=="Yes" & year<1990 & (s4q11>1 & s4q11!=.)  // ?

* True negative
gen     maize_tn3a=.
replace maize_tn3a=0 
replace maize_tn3a=1 if cg_source=="Yes" &  year>=1990 &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp3a=.
replace maize_fp3a=0 
replace maize_fp3a=1 if cg_source=="Yes" & year>=1990  & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn3a=.
replace maize_fn3a=0 
replace maize_fn3a=1 if cg_source=="Yes" & year<1990 & (s4q11==1)

lab var maize_tp3a "True positive maize Purity Before 1990"
lab var maize_tn3a "True negative maize Purity Before 1990"
lab var maize_fp3a "False positive maize Purity Before 1990"
lab var maize_fn3a "False negative maize Purity Before 1990"


* Year: 1990- 2000

* True positive
gen     maize_tp3b=.
replace maize_tp3b=0  
replace maize_tp3b=1 if cg_source=="Yes" & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn3b=.
replace maize_tn3b=0 
replace maize_tn3b=1 if cg_source=="Yes" &  (year<1990 | year>=2000) &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp3b=.
replace maize_fp3b=0 
replace maize_fp3b=1 if cg_source=="Yes" & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn3b=.
replace maize_fn3b=0 
replace maize_fn3b=1 if cg_source=="Yes" & (year>=1990 & year<2000)  & (s4q11==1)

lab var maize_tp3b "True positive maize Purity cut-off: 1990-2000"
lab var maize_tn3b "True negative maize Purity cut-off: 1990-2000"
lab var maize_fp3b "False positive maize Purity cut-off: 1990-2000"
lab var maize_fn3b "False negative maize Purity cut-off: 1990-2000"


* Year: 2000-2010

* True positive
gen     maize_tp3c=.
replace maize_tp3c=0  
replace maize_tp3c=1 if cg_source=="Yes" & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn3c=.
replace maize_tn3c=0 
replace maize_tn3c=1 if cg_source=="Yes" &  (year<2000 | year>=2010) &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp3c=.
replace maize_fp3c=0 
replace maize_fp3c=1 if cg_source=="Yes" & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn3c=.
replace maize_fn3c=0 
replace maize_fn3c=1 if cg_source=="Yes" & (year>=2000 & year<2010)  & (s4q11==1)

lab var maize_tp3c "True positive maize Purity 2000-2010"
lab var maize_tn3c "True negative maize Purity 2000-2010"
lab var maize_fp3c "False positive maize Purity 2000-2010"
lab var maize_fn3c "False negative maize Purity 2000-2010"


* Year: 2010-2020
* True positive
gen     maize_tp3d=.
replace maize_tp3d=0  
replace maize_tp3d=1 if cg_source=="Yes" & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn3d=.
replace maize_tn3d=0 
replace maize_tn3d=1 if cg_source=="Yes" &  (year<2010 | year>=2020) &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp3d=.
replace maize_fp3d=0 
replace maize_fp3d=1 if cg_source=="Yes" & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn3d=.
replace maize_fn3d=0 
replace maize_fn3d=1 if cg_source=="Yes" & (year>=2010 & year<2020)  & (s4q11==1)

lab var maize_tp3d "True positive maize Purity 2010-2020"
lab var maize_tn3d "True negative maize Purity 2010-2020"
lab var maize_fp3d "False positive maize Purity 2010-2020"
lab var maize_fn3d "False negative maize Purity 2010-2020"



* Table
global var3   maize_tp3a maize_tn3a maize_fp3a maize_fn3a maize_tp3b maize_tn3b /// 
    maize_fp3b maize_fn3b maize_tp3c maize_tn3c maize_fp3c maize_fn3c maize_tp3d ///
    maize_tn3d maize_fp3d maize_fn3d 

descr_tab $var3, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var3 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_2_ess5_missclass_year.xml") replace sheet("Table 1", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Harar" "Harar" "Harar" "Harar" "Harar" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" 
"National" "National" "National" "National" "National") showeq 
rblanks(COL_NAMES "HH level data" S2220)	 
title("ESS5 - CG germplasm, Misclassification ")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 
12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 
23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30)  
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)
(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)
(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
star(.1 .05 .01)  
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  
notes("Point estimates are weighted sample means.") 
;
#delimit cr



* Cumulative years -------------------------------------------------------------

* After 1990

* True positive
gen     maize_tp3abis=.
replace maize_tp3abis=0  
replace maize_tp3abis=1 if cg_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn3abis=.
replace maize_tn3abis=0 
replace maize_tn3abis=1 if cg_source=="Yes" &  year<1990 &  (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp3abis=.
replace maize_fp3abis=0 
replace maize_fp3abis=1 if cg_source=="Yes" & year<1990  & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn3abis=.
replace maize_fn3abis=0 
replace maize_fn3abis=1 if cg_source=="Yes" & year>=1990 & (s4q11==1)

lab var maize_tp3abis "True positive maize (After 1990)"
lab var maize_tn3abis "True negative maize (After 1990)"
lab var maize_fp3abis "False positive maize (After 1990)"
lab var maize_fn3abis "False negative maize (After 1990)"


* After 2000

* True positive
gen     maize_tp3bbis=.
replace maize_tp3bbis=0  
replace maize_tp3bbis=1 if cg_source=="Yes" & (year>=2000) & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn3bbis=.
replace maize_tn3bbis=0 
replace maize_tn3bbis=1 if cg_source=="Yes" &  (year<2000) &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp3bbis=.
replace maize_fp3bbis=0 
replace maize_fp3bbis=1 if cg_source=="Yes" &  (year<2000) & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn3bbis=.
replace maize_fn3bbis=0 
replace maize_fn3bbis=1 if cg_source=="Yes" &  (year>=2000)  & (s4q11==1)

lab var maize_tp3bbis "True positive maize (After 2000)"
lab var maize_tn3bbis "True negative maize (After 2000)"
lab var maize_fp3bbis "False positive maize (After 2000)"
lab var maize_fn3bbis "False negative maize (After 2000)"    


* After 2010

* True positive
gen     maize_tp3cbis=.
replace maize_tp3cbis=0  
replace maize_tp3cbis=1 if cg_source=="Yes" & (year>=2010) & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn3cbis=.
replace maize_tn3cbis=0 
replace maize_tn3cbis=1 if cg_source=="Yes" &  (year<2010) &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp3cbis=.
replace maize_fp3cbis=0 
replace maize_fp3cbis=1 if cg_source=="Yes" & (year<2010) & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn3cbis=.
replace maize_fn3cbis=0 
replace maize_fn3cbis=1 if cg_source=="Yes" & (year>=2010)  & (s4q11==1)

lab var maize_tp3cbis "True positive maize (After 2010)"
lab var maize_tn3cbis "True negative maize (After 2010)"
lab var maize_fp3cbis "False positive maize (After 2010)"
lab var maize_fn3cbis "False negative maize (After 2010)"


* Table
global var3b   maize_tp3abis maize_tn3abis maize_fp3abis maize_fn3abis ///
    maize_tp3bbis maize_tn3bbis maize_fp3bbis maize_fn3bbis maize_tp3cbis ///
    maize_tn3cbis maize_fp3cbis maize_fn3cbis 

descr_tab $var3b, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var3b {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_2_ess5_missclass_year.xml") append sheet("Table 2", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" 
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Harar" "Harar" "Harar" "Harar" "Harar" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" 
"National" "National" "National" "National" "National") showeq 
rblanks(COL_NAMES "HH level data" S2220)	 
title("ESS5 - CG germplasm, Misclassification")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 30, 3 30, 4 40, 5 55, 6 30, 7 30, 8 40, 9 55, 10 30, 11 30, 
12 40, 13 55,  14 30,  15 30, 16 40, 17 55, 18 30, 19 30, 20 40, 21 55, 22 30, 
23 30, 24 40, 25 55, 26 30, 27 30, 28 40, 29 55, 30 30)  
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)
(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0)
(NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
star(.1 .05 .01)  
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  
notes("Point estimates are weighted sample means.") 
;
#delimit cr


* save -------------------------------------------------------------------------
save "${tmp}/missclass/05_2_misclass_year.dta", replace
