********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: EXOTIC GERMPLASM (NOT IN THE REPORT)
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${tmp}/missclass/05_2_misclass_year.dta", clear


* Exotic  only -----------------

* True positive
gen     maize_tp4=.
replace maize_tp4=0  
replace maize_tp4=1 if exotic_source=="Yes" & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn4=.
replace maize_tn4=0 
replace maize_tn4=1 if exotic_source=="No" & (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp4=.
replace maize_fp4=0 
replace maize_fp4=1 if exotic_source=="No" & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn4=.
replace maize_fn4=0 
replace maize_fn4=1 if exotic_source=="Yes" & (s4q11==1)

* label
lab var maize_tp4 "True positive maize: exotic status"
lab var maize_tn4 "True negative maize: exotic status"
lab var maize_fp4 "False positive maize: exotic status"
lab var maize_fn4 "False negative maize: exotic status"


* Table:
global var4 maize_tp4 maize_tn4 maize_fp4 maize_fn4 

descr_tab $var4, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var4 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_3_ess5_missclass_exotic.xml") replace sheet("Table 1", nogridlines)  
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


***************************************
* Exotic Germplasm and purity levels
***************************************

* 70 % cut-off --------

* True positive
gen     maize_tp5a=.
replace maize_tp5a=0  
replace maize_tp5a=1 if exotic_source=="Yes" & purity_percent>=70  & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn5a=.
replace maize_tn5a=0 
replace maize_tn5a=1 if exotic_source=="Yes" & purity_percent<70 &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp5a=.
replace maize_fp5a=0 
replace maize_fp5a=1 if exotic_source=="Yes" & purity_percent<70 & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn5a=.
replace maize_fn5a=0 
replace maize_fn5a=1 if exotic_source=="Yes" & purity_percent>=70 & (s4q11==1)


lab var maize_tp5a "True positive maize Purity cut-off: 70 & exotic status"
lab var maize_tn5a "True negative maize Purity cut-off: 70 & exotic status"
lab var maize_fp5a "False positive maize Purity cut-off: 70 & exotic status"
lab var maize_fn5a "False negative maize Purity cut-off: 70 & exotic status"


* 90 % cut-off --------

* True positive
gen     maize_tp5b=.
replace maize_tp5b=0  
replace maize_tp5b=1 if exotic_source=="Yes" & purity_percent>=90  & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn5b=.
replace maize_tn5b=0 
replace maize_tn5b=1 if exotic_source=="Yes" & purity_percent<90 &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp5b=.
replace maize_fp5b=0 
replace maize_fp5b=1 if exotic_source=="Yes" & purity_percent<90 & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn5b=.
replace maize_fn5b=0 
replace maize_fn5b=1 if exotic_source=="Yes" & purity_percent>=90 & (s4q11==1)

lab var maize_tp5b "True positive maize Purity cut-off: 90 & exotic status"
lab var maize_tn5b "True negative maize Purity cut-off: 90 & exotic status"
lab var maize_fp5b "False positive maize Purity cut-off: 90 & exotic status"
lab var maize_fn5b "False negative maize Purity cut-off: 90 & exotic status"


* 95 % cut-off --------

* True positive
gen     maize_tp5c=.
replace maize_tp5c=0  
replace maize_tp5c=1 if exotic_source=="Yes" & purity_percent>=95  & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn5c=.
replace maize_tn5c=0 
replace maize_tn5c=1 if exotic_source=="Yes" & purity_percent<95 &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp5c=.
replace maize_fp5c=0 
replace maize_fp5c=1 if exotic_source=="Yes" & purity_percent<95 & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn5c=.
replace maize_fn5c=0 
replace maize_fn5c=1 if exotic_source=="Yes" & purity_percent>=95 & (s4q11==1)


lab var maize_tp5c "True positive maize Purity cut-off: 95 & exotic status"
lab var maize_tn5c "True negative maize Purity cut-off: 95 & exotic status"
lab var maize_fp5c "False positive maize Purity cut-off: 95 & exotic status"
lab var maize_fn5c "False negative maize Purity cut-off: 95 & exotic status"



global var5 maize_tp5a maize_tn5a maize_fp5a maize_fn5a maize_tp5b maize_tn5b ///
	maize_fp5b maize_fn5b maize_tp5c maize_tn5c maize_fp5c maize_fn5c 

descr_tab $var5, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var5 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_3_ess5_missclass_exotic.xml") append sheet("Table 2", nogridlines)  
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



***************************************
* Exotic Germplasm and year of release
***************************************

* Before 1990 --------------

* True positive
gen     maize_tp6a=.
replace maize_tp6a=0  
replace maize_tp6a=1 if exotic_source=="Yes" & year<1990 & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn6a=.
replace maize_tn6a=0 
replace maize_tn6a=1 if exotic_source=="Yes" &  year>=1990 &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp6a=.
replace maize_fp6a=0 
replace maize_fp6a=1 if exotic_source=="Yes" & year>=1990 & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn6a=.
replace maize_fn6a=0 
replace maize_fn6a=1 if exotic_source=="Yes" & year<1990 & (s4q11==1)


lab var maize_tp6a "True positive maize year before 1990 & exotic status"
lab var maize_tn6a "True negative maize year before 1990 & exotic status"
lab var maize_fp6a "False positive maize year before 1990 & exotic status"
lab var maize_fn6a "False negative maize year before 1990 & exotic status"



* 1990- 2000 --------
gen     maize_tp6b=.
replace maize_tp6b=0  
replace maize_tp6b=1 if exotic_source=="Yes" & (year>=1990 & year<2000) & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn6b=.
replace maize_tn6b=0 
replace maize_tn6b=1 if exotic_source=="Yes" &  (year<1990 | year>=2000) &  (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp6b=.
replace maize_fp6b=0 
replace maize_fp6b=1 if exotic_source=="Yes" & (year<1990 | year>=2000) & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn6b=.
replace maize_fn6b=0 
replace maize_fn6b=1 if exotic_source=="Yes" & (year>=1990 & year<2000)  & (s4q11==1)


lab var maize_tp6b "True positive maize year 1990-2000 & exotic status"
lab var maize_tn6b "True negative maize year 1990-2000 & exotic status"
lab var maize_fp6b "False positive maize year 1990-2000 & exotic status"
lab var maize_fn6b "False negative maize year 1990-2000 & exotic status"




* 2000-2010 --------------

* True positive
gen     maize_tp6c=.
replace maize_tp6c=0  
replace maize_tp6c=1 if exotic_source=="Yes" & (year>=2000 & year<2010) & (s4q11>1 & s4q11!=.)

*True negative
gen     maize_tn6c=.
replace maize_tn6c=0 
replace maize_tn6c=1 if exotic_source=="Yes" &  (year<2000 | year>=2010) &  (s4q11==1)

*False positive (improved when traditional)
gen     maize_fp6c=.
replace maize_fp6c=0 
replace maize_fp6c=1 if exotic_source=="Yes" & (year<2000 | year>=2010) & (s4q11>1 & s4q11!=.)

*False negative (traditional when improved)
gen     maize_fn6c=.
replace maize_fn6c=0 
replace maize_fn6c=1 if exotic_source=="Yes" & (year>=2000 & year<2010)  & (s4q11==1)


lab var maize_tp6c "True positive maize year 2000-2010 & exotic status"
lab var maize_tn6c "True negative maize year 2000-2010 & exotic status"
lab var maize_fp6c "False positive maize year 2000-2010 & exotic status"
lab var maize_fn6c "False negative maize year 2000-2010 & exotic status"



* 2010-2020 -----------------

* True positive
gen     maize_tp6d=.
replace maize_tp6d=0  
replace maize_tp6d=1 if exotic_source=="Yes" & (year>=2010 & year<2020) & (s4q11>1 & s4q11!=.)

* True negative
gen     maize_tn6d=.
replace maize_tn6d=0 
replace maize_tn6d=1 if exotic_source=="Yes" &  (year<2010 | year>=2020) &  (s4q11==1)

* False positive (improved when traditional)
gen     maize_fp6d=.
replace maize_fp6d=0 
replace maize_fp6d=1 if exotic_source=="Yes" & (year<2010 | year>=2020) & (s4q11>1 & s4q11!=.)

* False negative (traditional when improved)
gen     maize_fn6d=.
replace maize_fn6d=0 
replace maize_fn6d=1 if exotic_source=="Yes" & (year>=2010 & year<2020)  & (s4q11==1)


lab var maize_tp6d "True positive maize year 2010-2020 & exotic status"
lab var maize_tn6d "True negative maize year 2010-2020 & exotic status"
lab var maize_fp6d "False positive maize year 2010-2020 & exotic status"
lab var maize_fn6d "False negative maize year 2010-2020 & exotic status"


global var6  maize_tp6a maize_tn6a maize_fp6a maize_fn6a maize_tp6b maize_tn6b ///
	maize_fp6b maize_fn6b maize_tp6c maize_tn6c maize_fp6c maize_fn6c maize_tp6d ///
	maize_tn6d maize_fp6d maize_fn6d 


descr_tab $var6, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var6 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_3_ess5_missclass_exotic.xml") append sheet("Table 3", nogridlines)  
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


* save -----------
save "${tmp}/missclass/05_3_misclass_exotic.dta", replace
