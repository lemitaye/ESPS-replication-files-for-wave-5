********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: ESS4-ESS5 dynamics - Tables of adoption rates
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [Paola Mallia from ESS4 rep. file]
* Date created: May 02, 2023
* STATA Version: MP 17.0
********************************************************************************


* Household level -------------------

use "${data}/wave5_hh_new.dta", clear

#delimit ;
global hhlevel     
hhd_ofsp hhd_awassa83 hhd_kabuli hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 
hhd_affor hhd_mango hhd_papaya hhd_avocado hotline hhd_malt hhd_durum hhd_seedv1 hhd_seedv2 
hhd_livIA hhd_livIA_publ hhd_livIA_priv hhd_cross_largerum hhd_cross_smallrum hhd_cross_poultry 
hhd_agroind hhd_cowpea hhd_elepgrass hhd_deshograss  hhd_sesbaniya hhd_sinar hhd_lablab hhd_alfalfa 
hhd_vetch hhd_rhodesgrass hhd_grass dtmz maize_cg hhd_impcr13 hhd_impcr19 hhd_impcr11 hhd_impcr24  
hhd_impcr14 hhd_impcr3 hhd_impcr5 hhd_impcr60 hhd_impcr62 hhd_psnp
;
#delimit cr

// construct matrix:
descr_tab "$hhlevel" "3 4 7 0" pw_w5

local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	

// export:
#delimit;
xml_tab C,  save("$table/09_1_adoption_rates.xml") replace sheet("HH_w5", nogridlines)  
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Other regions" 
"Other regions" "Other regions" "Other regions" "Other regions" "National" 
"National" "National" "National" "National" ) 
showeq 
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, 
hhd_impccr  "Share of plots per household" S2149)	 
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
	notes("Point estimates are wegihted sample means.") 
;
#delimit cr		


* Household level: other regions ---------------------------- 

descr_tab_othreg "$hhlevel" "2 5 6 12 13 15" pw_w5

local rname ""
foreach var in $hhlevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

# delimit;
xml_tab C,  save("$table/09_1_adoption_rates.xml") append sheet("HH_w5_othreg", nogridlines) 
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Afar" "Afar" "Afar" "Afar" "Afar" "Somali" "Somali" "Somali" "Somali" "Somali" 
"Benshangul Gumuz" "Benshangul Gumuz" "Benshangul Gumuz"  "Benshangul Gumuz"  "Benshangul Gumuz"  
"Gambela"  "Gambela" "Gambela"    "Gambela"  "Gambela"  "Harar" "Harar" "Harar" "Harar" "Harar" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa") showeq 
rblanks(COL_NAMES "Percentage of hh that adopt on at least one plot :" S2149, 
hhd_impccr  "Share of plots per household" S2149)	
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
	notes( "Point estimates are wegihted sample means."  ) //Add your notes here
; 
# delimit cr


* EA level ------------------------------

use "${data}/wave5_ea_new.dta", clear


#delimit ;
global ealevel
ead_ofsp ead_awassa83 ead_kabuli ead_rdisp ead_motorpump ead_swc  ead_consag1 ead_consag2 
ead_affor ead_mango ead_papaya ead_avocado ead_malt ead_durum ead_hotline ead_seedv1 ead_seedv2 
ead_livIA ead_livIA_publ ead_livIA_priv ead_cross_largerum ead_cross_smallrum ead_cross_poultry
ead_agroind ead_cowpea ead_elepgrass ead_deshograss ead_sesbaniya ead_sinar ead_lablab ead_alfalfa 
ead_vetch ead_rhodesgrass ead_grass dtmz maize_cg commirr comm_video comm_video_all 
comm_2wt_own comm_2wt_use comm_psnp ead_impcr13 ead_impcr19 ead_impcr11 ead_impcr24 
ead_impcr14 ead_impcr3 ead_impcr5 ead_impcr60 ead_impcr62
;
#delimit cr

// matrix:	
descr_tab "$ealevel" "3 4 7 0" 1  // unweighted means at EA level

local rname ""
foreach var in $ealevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	

// export:
#delimit;
xml_tab C,  save("$table/09_1_adoption_rates.xml") append sheet("EA_w5", nogridlines)  
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
	notes("Point estimates are wegihted sample means.") 
; 
# delimit cr


* EA level: other regions -----------------

descr_tab_othreg "$ealevel" "2 5 6 12 13 15" 1

local rname ""
foreach var in $ealevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}	

#delimit;
xml_tab C,  save("$table/09_1_adoption_rates.xml") append sheet("EA_w5_othreg", nogridlines)  
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
	notes("Point estimates are wegihted sample means.") //Add your notes here
; 
# delimit cr


* Crop-germplasm improvement -------------------

use "${data}/ess5_dna_new.dta", clear

rename region region_oth
rename saq01 region

// create matrix:
descr_tab "dtmz maize_cg" "3 4 7 13 15" pw_w5

local rname ""
foreach var in dtmz maize_cg {
	local lbl: variable label `var'
	local rname `"  `rname'   "`lbl'" "'
}

#delimit;
xml_tab C, save("$table/09_1_adoption_rates.xml") append sheet("HH_DNA", nogridlines)  
rnames(`rname' "Total No. of obs. per region") ///
cnames(`cnames')  ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" 
"Oromia" "Oromia" "Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" 
"Dire Dawa" "Dire Dawa" "National" "National" "National" "National" "National") showeq ///
rblanks(COL_NAMES "Field level data" S2220)	 /// 
title(Table 5: ESS5 - DNA fingerprinting - by region)  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 
3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 2 55, 3 30, 4 30, 5 40, 1 55, 
2 55, 3 30, 4 30, 5 40  ) /// 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) )  /// 
star(.1 .05 .01)  /// 
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  ///
notes("Point estimates are wegihted sample means.") 
; 
# delimit cr
