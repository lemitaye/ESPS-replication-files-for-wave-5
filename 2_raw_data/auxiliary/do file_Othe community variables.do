
clear all
clear matrix
capture log close
set more off

********************************************************************************
*                            Community - ESSW5-2021/22               
********************************************************************************
* Country: ETHIOPIA                                                            
* Created by: Solomon Alemu - S.Alemu@cgiar.org        
* Date:  Nov,2022                                                               
********************************************************************************
global indir  "C:\Users\SAlemu\OneDrive - CGIAR\Documents\NOV_ESS5_DATA\COMMUNITY"
global temp "C:\Users\SAlemu\OneDrive - CGIAR\Documents\NOV_ESS5_DATA\ESS5_Community_analysis"

*===============================================================================
**Community module-other community level variables
*===============================================================================

use "$indir\sect04_com_w5.dta", clear 
merge 1:1 ea_id using "$indir\sect06_com_w5.dta"
drop _m
merge 1:1 ea_id using "$indir\sect09_com_w5.dta"
drop _m

order cs9q01 cs6q01 cs6q10 cs4q02 cs4q08 cs4q09 cs4q11 cs4q12b cs4q14 cs4q15,after ( cs9q14 )
save "$temp\community_S4_S6_S9_W5.dta", replace

use "$temp\community_S4_S6_S9_W5.dta",clear

clonevar cs4q02_wiz=cs4q02
clonevar cs4q09_wiz=cs4q09
clonevar cs4q12b_wiz=cs4q12b
clonevar cs4q15_wiz=cs4q15
for var cs4q02_wiz- cs4q15_wiz: winsor2 X,replace cuts(1 99)
keep ea_id cs9q01 cs6q01 cs6q10 cs4q02 cs4q08 cs4q09 cs4q11 cs4q12b cs4q14 cs4q15 cs4q02_wiz cs4q09_wiz cs4q12b_wiz cs4q15_wiz

order cs4q02_wiz,after ( cs4q02)
order cs4q09_wiz,after ( cs4q09)
order cs4q12b_wiz,after ( cs4q12b)

for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: recode X (2=0)
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: label define X 1 "Yes" 0 "No", replace
for var cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14: label values X X

rename cs9q01 cs9q01_w5
rename cs6q01 cs6q01_w5
rename cs6q10 cs6q10_w5
rename cs4q02 cs4q02_w5
rename cs4q02_wiz cs4q02_wiz_w5
rename cs4q08 cs4q08_w5
rename cs4q09 cs4q09_w5
rename cs4q09_wiz cs4q09_wiz_w5
rename cs4q11 cs4q11_w
rename cs4q12b cs4q12b_w5
rename cs4q12b_wiz cs4q12b_wiz_w5
rename cs4q14 cs4q14_w5
rename cs4q15 cs4q15_w5
rename cs4q15_wiz cs4q15_wiz_w5

save "$temp\community_S4_S6_S9_w5for_merghh.dta", replace

*** panel community data_analysis

** from the replication file- 

use "$temp\com_level_S4_S6_S9_w4",clear
keep ea_id saq14- saq07 cs9q01 cs6q01 cs6q10 cs4q02 cs4q08 cs4q09 cs4q11 cs4q12b cs4q14 cs4q15 cs4q02_wiz cs4q09_wiz cs4q12b_wiz cs4q15_wiz
merge 1:1 ea_id using "$temp\community_S4_S6_S9_w5for_merghh.dta"

	/*Result	#	of	obs.
				
	not matched			145
	from master			120	(_merge==1)
	from using			25	(_merge==2)

	matched			407	(_merge==3)*/
	
	* note: still 25 eas not mathced with the ESS4, It seems a new EAs, WB working on it.
	
gen panel =1 if _merge==3
replace panel=2 if _merge ==2
replace panel=3 if _merge ==1
lab define panel 1 "Panel EA" 2 "ESS5 only" 3 "ESS4 only"
lab values panel panel
sum cs9q01 cs6q01 cs6q10 cs4q02_wiz cs4q08 cs4q09_wiz cs4q11 cs4q12b_wiz cs4q14 cs4q15_wiz cs9q01_w5 cs6q01_w5 cs6q10_w5 cs4q02_wiz_w5 cs4q08_w5 cs4q09_wiz_w5 cs4q11_w cs4q12b_wiz_w5 cs4q14_w5 cs4q15_wiz_w5
order cs9q01 cs9q01_w5 cs6q01 cs6q01_w5 cs6q10 cs6q10_w5 cs4q02_wiz cs4q02_wiz_w5 cs4q08 cs4q08_w5 cs4q09_wiz cs4q09_wiz_w5 cs4q11 cs4q11_w cs4q12b_wiz cs4q12b_wiz_w5 cs4q14 cs4q14_w5 cs4q15_wiz cs4q15_wiz_w5	
sum cs9q01- cs4q15_wiz_w5 if panel==1


	
	
	
	
				

. 










