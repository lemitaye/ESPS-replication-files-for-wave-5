********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Correlates of misclassification
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${tmp}/missclass/05_2_misclass_year.dta", clear


* To what extent does misclassification depend on source of seed? -------------

// collapsing source to two categories:
recode s5q03_1 (1/4 10 = 1) (5/8 99 = 2), generate(source)
label define source 1 "Government and related" 2 "Market and related"
label values source source

// tables generated from the following:



global var8 maize_tp1 maize_tn1 maize_fp1 maize_fn1

descr_tab $var8  if source==1, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var8 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_5_ess5_missclass_source.xml") replace sheet("Government and Related-1", nogridlines)  
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


descr_tab $var8 if source==2, regions("3 4 7 13 15") wt(pw_w5) 

local rname ""
foreach var in $var8 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_5_ess5_missclass_source.xml") append sheet("Market and Related-1", nogridlines)  
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

count if cg_source=="Yes" & source==1
count if cg_source=="Yes" & source==2
count if cg_source=="No" & source==1
count if cg_source=="No" & source==2


global var9 maize_tp2a maize_fn2a maize_tp2b maize_fn2b maize_tp2c maize_fn2c

descr_tab $var9  if source==1, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var9 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_5_ess5_missclass_source.xml") append sheet("Government and Related-2", nogridlines)  
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


descr_tab $var9 if source==2, regions("3 4 7 13 15") wt(pw_w5) 

local rname ""
foreach var in $var9 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_5_ess5_missclass_source.xml") append sheet("Market and Related-2", nogridlines)  
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


count if cg_source=="Yes" & purity_percent>=70 & source==1
count if cg_source=="Yes" & purity_percent>=70 & source==2
count if cg_source=="Yes" & purity_percent>=90 & source==1
count if cg_source=="Yes" & purity_percent>=90 & source==2
count if cg_source=="Yes" & purity_percent>=95 & source==1
count if cg_source=="Yes" & purity_percent>=95 & source==2



global var10 maize_tp3abis maize_fn3abis maize_tp3bbis maize_fn3bbis maize_tp3cbis maize_fn3cbis

descr_tab $var10  if source==1, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var10 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_5_ess5_missclass_source.xml") append sheet("Government and Related-3", nogridlines)  
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


descr_tab $var10 if source==2, regions("3 4 7 13 15") wt(pw_w5) 

local rname ""
foreach var in $var10 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_5_ess5_missclass_source.xml") append sheet("Market and Related-3", nogridlines)  
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

count if cg_source=="Yes" & year>=1990 & source==1
count if cg_source=="Yes" & year>=1990 & source==2
count if cg_source=="Yes" & year>=2000 & source==1
count if cg_source=="Yes" & year>=2000 & source==2
count if cg_source=="Yes" & year>=2010 & source==1
count if cg_source=="Yes" & year>=2010 & source==2

