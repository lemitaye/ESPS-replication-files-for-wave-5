********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Misclassification using maize DNA data
* Country: Ethiopia 
* Data: ESS5 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS5 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${data}/03_5_ess5_dna_plot.dta", clear

* CG - germplasm recode
gen     cg=0 if cg_source=="No"
replace cg=1 if cg_source=="Yes"


* CG - germplasm only ---------

*True positive
gen     maize_tp1=.
replace maize_tp1=0 
replace maize_tp1=1 if cg_source=="Yes" & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn1=.
replace maize_tn1=0 
replace maize_tn1=1 if cg_source=="No" & (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp1=.
replace maize_fp1=0 
replace maize_fp1=1 if cg_source=="No" & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn1=.
replace maize_fn1=0 
replace maize_fn1=1 if cg_source=="Yes" & (s4q11==1)

lab var maize_tp1 "True positive maize"
lab var maize_tn1 "True negative maize"
lab var maize_fp1 "False positive maize"
lab var maize_fn1 "False negative maize"



global var1 maize_tp1 maize_tn1 maize_fp1 maize_fn1 

descr_tab $var1, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var1 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_1_ess5_missclass_purity.xml") replace sheet("Table 1", nogridlines)  
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



* CG germplasm & purity levels -------------------------------------------------

* Purity cut-off: 70 --------

*True positive
gen     maize_tp2a=.
replace maize_tp2a=0  
replace maize_tp2a=1 if cg_source=="Yes" & purity_percent>=70  & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn2a=.
replace maize_tn2a=0 
replace maize_tn2a=1 if cg_source=="Yes" & purity_percent<70 &  (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp2a=.
replace maize_fp2a=0 
replace maize_fp2a=1 if cg_source=="Yes" & purity_percent<70 & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn2a=.
replace maize_fn2a=0 
replace maize_fn2a=1 if cg_source=="Yes" & purity_percent>=70 & (s4q11==1)

lab var maize_tp2a "True positive maize Purity cut-off: 70"
lab var maize_tn2a "True negative maize Purity cut-off: 70"
lab var maize_fp2a "False positive maize Purity cut-off: 70"
lab var maize_fn2a "False negative maize Purity cut-off: 70"


* Purity cut-off: 90 ----------

*True positive
gen     maize_tp2b=.
replace maize_tp2b=0  
replace maize_tp2b=1 if cg_source=="Yes" & purity_percent>=90  & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn2b=.
replace maize_tn2b=0 
replace maize_tn2b=1 if cg_source=="Yes" & purity_percent<90 &  (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp2b=.
replace maize_fp2b=0 
replace maize_fp2b=1 if cg_source=="Yes" & purity_percent<90 & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn2b=.
replace maize_fn2b=0 
replace maize_fn2b=1 if cg_source=="Yes" & purity_percent>=90 & (s4q11==1)

lab var maize_tp2b "True positive maize Purity cut-off: 90"
lab var maize_tn2b "True negative maize Purity cut-off: 90"
lab var maize_fp2b "False positive maize Purity cut-off: 90"
lab var maize_fn2b "False negative maize Purity cut-off: 90"


* Purity cut-off: 95 ------------

*True positive
gen     maize_tp2c=.
replace maize_tp2c=0  
replace maize_tp2c=1 if cg_source=="Yes" & purity_percent>=95  & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn2c=.
replace maize_tn2c=0 
replace maize_tn2c=1 if cg_source=="Yes" & purity_percent<95 &  (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp2c=.
replace maize_fp2c=0 
replace maize_fp2c=1 if cg_source=="Yes" & purity_percent<95 & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn2c=.
replace maize_fn2c=0 
replace maize_fn2c=1 if cg_source=="Yes" & purity_percent>=95 & (s4q11==1)

lab var maize_tp2c "True positive maize Purity cut-off: 95"
lab var maize_tn2c "True negative maize Purity cut-off: 95"
lab var maize_fp2c "False positive maize Purity cut-off: 95"
lab var maize_fn2c "False negative maize Purity cut-off: 95"



* Table - CG Germplasm by purity level
global var2 maize_tp2a maize_tn2a maize_fp2a maize_fn2a maize_tp2b maize_tn2b ///
    maize_fp2b maize_fn2b maize_tp2c maize_tn2c maize_fp2c maize_fn2c 

descr_tab $var2, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var2 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_1_ess5_missclass_purity.xml") append sheet("Table 2", nogridlines)  
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

* save -------------------------------------------------------------------------
save "${tmp}/missclass/05_1_misclass_purity.dta", replace
