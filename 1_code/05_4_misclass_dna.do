********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Adoption estimates using DNA-fingerprinting
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************

use "${tmp}/missclass/05_3_misclass_exotic.dta", clear

* CG - GERMPLASM AND PURITY LEVEL	

g       maize_cgp70=.
replace maize_cgp70=0 
replace maize_cgp70=1 if cg_source=="Yes" & purity_percent>=70

g       maize_cgp90=.
replace maize_cgp90=0 
replace maize_cgp90=1 if cg_source=="Yes" & purity_percent>=90

g       maize_cgp95=.
replace maize_cgp95=0 
replace maize_cgp95=1 if cg_source=="Yes" & purity_percent>=95


label var maize_cgp70 "Maize CG-germplasm, purity >=70"
label var maize_cgp90 "Maize CG-germplasm, purity >=90"
label var maize_cgp95 "Maize CG-germplasm, purity >=95"


* CG - GERMPLASM AND YEAR OF RELEASE

g       maize_cgy1=.
replace maize_cgy1=0 
replace maize_cgy1=1 if cg_source=="Yes" & year<1990

g       maize_cgy2=.
replace maize_cgy2=0 
replace maize_cgy2=1 if cg_source=="Yes" & (year>=1990 & year<2000) 


g       maize_cgy3=.
replace maize_cgy3=0 
replace maize_cgy3=1 if cg_source=="Yes" & (year>=2000 & year<2010) 

g       maize_cgy4=.
replace maize_cgy4=0 
replace maize_cgy4=1 if cg_source=="Yes" & (year>=2010 & year<=2020) 


label var maize_cgy1 "Maize CG-germplasm, year of release: before 1990"
label var maize_cgy2 "Maize CG-germplasm, year of release: 1990-2000"
label var maize_cgy3 "Maize CG-germplasm, year of release: 2000-2010"
label var maize_cgy4 "Maize CG-germplasm, year of release: 2010-2020"



* EXOTIC GERMPLASM 

g       maize_ex=.
replace maize_ex=0 
replace maize_ex=1 if exotic_source=="Yes"

label var maize_ex "Maize DNA - Exotic source"

* EXOTIC GERMPLASM & PURITY LEVEL	

g       maize_exp70=.
replace maize_exp70=0 
replace maize_exp70=1 if exotic_source=="Yes" & purity_percent>=70

g       maize_exp90=.
replace maize_exp90=0 
replace maize_exp90=1 if exotic_source=="Yes" & purity_percent>=90

g       maize_exp95=.
replace maize_exp95=0 
replace maize_exp95=1 if exotic_source=="Yes" & purity_percent>=95

label var maize_exp70 "Maize DNA - Exotic source, purity >=70"
label var maize_exp90 "Maize DNA - Exotic source, purity >=90"
label var maize_exp95 "Maize DNA - Exotic source, purity >=95"



* EXOTIC GERMPLASM & YEAR OF RELEASE

g       maize_exy1=.
replace maize_exy1=0 
replace maize_exy1=1 if exotic_source=="Yes" & year<1990

g       maize_exy2=.                                  
replace maize_exy2=0                        
replace maize_exy2=1 if exotic_source=="Yes" & (year>=1990 & year<2000) 
                                                    
g       maize_exy3=.                                  
replace maize_exy3=0                        
replace maize_exy3=1 if exotic_source=="Yes" & (year>=2000 & year<2010)  
                                                    
g       maize_exy4=.                                  
replace maize_exy4=0                        
replace maize_exy4=1 if exotic_source=="Yes" & (year>=2010 & year<=2020) 
                                                

label var maize_exy1 "Maize DNA - Exotic source, year: before 1990"
label var maize_exy2 "Maize DNA - Exotic source, year: 1990-2000"
label var maize_exy3 "Maize DNA - Exotic source, year: 2000-2010"
label var maize_exy4 "Maize DNA - Exotic source, year: 2010-2020"


* UNCONDITIONAL - PURITY LEVEL

g       maize_p70=.
replace maize_p70=0 
replace maize_p70=1 if purity_percent>=70

g       maize_p90=.
replace maize_p90=0 
replace maize_p90=1 if purity_percent>=90

g       maize_p95=.
replace maize_p95=0 
replace maize_p95=1 if purity_percent>=95

label var maize_p70 "Maize DNA - purity >=70"
label var maize_p90 "Maize DNA - purity >=90"
label var maize_p95 "Maize DNA - purity >=95"



* UNCONDITIONAL - YEAR OF RELEASE


g       maize_y1=.
replace maize_y1=0 
replace maize_y1=1 if year<1990

g       maize_y2=.
replace maize_y2=0 
replace maize_y2=1 if (year>=1990 & year<2000)

g       maize_y3=.
replace maize_y3=0 
replace maize_y3=1 if (year>=2000 & year<2010) 

g       maize_y4=.
replace maize_y4=0 
replace maize_y4=1 if(year>=2010 & year<=2020) 


label var maize_y1 "Maize DNA - year of release: before 1990"
label var maize_y2 "Maize DNA - year of release: 1990-2000"
label var maize_y3 "Maize DNA - year of release: 2000-2010"
label var maize_y4 "Maize DNA - year of release: 2010-2020"


 * Table 
global var7 maize_cg maize_cgp70 maize_cgp90 maize_cgp95 maize_cgy1 maize_cgy2 ///
    maize_cgy3 maize_cgy4 maize_y1 maize_y2 maize_y3 maize_y4 

descr_tab $var7, regions("3 4 7 13 15") wt(pw_w5)

local rname ""
foreach var in $var7 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit ;
xml_tab C, save("${table}/05_4_ess5_missclass_dna.xml") replace sheet("Table 1", nogridlines)  
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
save "${tmp}/missclass/05_4_misclass_dna.dta", replace
