********************************************************************************
*                           Ethiopia Synthesis Report 
*                Upper and lower bound estimates of absolute reach
* Country: Ethiopia 
* Data: ESS4 & ESS5 
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Paola Mallia (paola_mallia@ymail.com )] 
********************************************************************************


* ESS5 -------------------------------------------------------------------------

use "${data}/wave5_hh_new.dta", clear

merge m:1 ea_id using "${data}/wave5_ea_new.dta"
drop _merge
drop saq13

merge 1:1 household_id using "${data}/ess5_dna_hh_new.dta"

gen     dnadata=0
replace dnadata=1 if _merge==3
*keep if _m==3


* Upper bound ------------
// upper bound is # of households with at least one CG-related innovation.

sum hhd_treadle hhd_motorpump hhd_rdisp hhd_consag1 hhd_swc hhd_cross hhd_livIA ///
    hhd_elepgrass hhd_sesbaniya hhd_agroind  hhd_alfalfa  hhd_grass hhd_avocado ///
    hhd_mango hhd_papaya hhd_sweetpotato hhd_fieldp commirr plotirr maize hhd_ofsp  ///
    hhd_awassa83 hhd_desi hhd_kabuli


gen     ubound1 = 0 if dnadata==1
replace ubound1 = 1 if dnadata==1 & (maize==1 | hhd_treadle==1 | hhd_motorpump==1 | ///
    hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | ///
    hhd_elepgrass==1 | hhd_sesbaniya==1 | hhd_alfalfa==1 | hhd_agroind==1 | ///
    hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | ///
    hhd_fieldp==1 | (commirr==1 & plotirr==1) | hhd_ofsp==1 | hhd_awassa83==1 | ///
    hhd_desi==1 | hhd_kabuli==1)


gen     ubound2 = 0 
replace ubound2 = 1 if  (hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | ///
    hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | ///
    hhd_sesbaniya==1 | hhd_alfalfa==1 | hhd_agroind==1 | hhd_grass==1  | ///
    hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | ///
    (commirr==1 & plotirr==1) | hhd_ofsp==1 | hhd_awassa83==1 | hhd_desi==1 | hhd_kabuli==1)


gen     ubound3 = 0 
replace ubound3 = 1 if   (hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | ///
    hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | hhd_livIA==1 | hhd_elepgrass==1 | ///
    hhd_sesbaniya==1 | hhd_alfalfa==1 | hhd_agroind==1 | hhd_grass==1  | ///
    hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | hhd_sweetpotato==1 | hhd_fieldp==1 | ///
    (commirr==1 & plotirr==1) | hhd_ofsp==1 | hhd_awassa83==1 | hhd_desi==1 | hhd_kabuli==1)

gen     percrural = 0
replace percrural = 1 if maize==1 | hhd_ofsp==1 | hhd_awassa83==1 | hhd_treadle==1 | ///
    hhd_motorpump==1 | hhd_rdisp==1 | hhd_consag1==1 | hhd_swc==1 | hhd_cross==1 | ///
    hhd_livIA==1 | hhd_elepgrass==1 | hhd_sesbaniya==1 | hhd_alfalfa==1 | ///
    hhd_agroind==1 | hhd_grass==1  | hhd_avocado==1 | hhd_mango==1 | hhd_papaya==1 | ///
    hhd_sweetpotato==1 | hhd_fieldp==1 | (commirr==1 & plotirr==1) | hhd_desi==1 | hhd_kabuli==1

* lower bound -----------------
// Lower bound is # of hh with improved maize, sweet potato, or kabuli chickpea type

gen     lbound=0
replace lbound=1 if maize==1 | hhd_ofsp==1 | hhd_awassa83==100 | hhd_desi==1 | hhd_kabuli==1

* label variables
label var ubound1 "Upper bound - 1"   
label var ubound2 "Upper bound - 2" 
label var ubound3 "Upper bound - 3"  
label var lbound  "Lower bound"
label var cr2     "Perc. of rural hhs growing maize"


global dnastats maize cr2 ubound1 ubound2 ubound3 lbound

// construct matrix:
descr_tab $dnastats, regions("2 3 4 5 6 7 12 13 15") wt(pw_w5)

// prep:
local rname ""
foreach var in $dnastats {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

#delimit ;
global options1 
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq(
"Afar" "Afar" "Afar" "Afar" "Afar" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq  
font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
        6 55, 7 55, 8 30, 9 30, 10 40,
        11 55, 12 55, 13 30, 14 30, 15 40,
        16 55, 17 55, 18 30, 19 30, 20 40,
        21 55, 22 55, 23 30, 24 30, 25 40,
        26 55, 27 55, 28 30, 29 30, 30 40,
        31 55, 32 55, 33 30, 34 30, 35 40,
        36 55, 37 55, 38 30, 39 30, 40 40,
        41 55, 42 55, 43 30, 44 30, 45 40,
        46 55, 47 55, 48 30, 49 30, 50 40) 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0))  
	star(.1 .05 .01)  
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)   
	notes("Point estimates are wegihted sample means.") 
;
#delimit cr	


// export
xml_tab C, save("$table/09_5_ess5_number_bounds.xml") replace sheet("HH_w5", nogridlines) ///
    title("Table: ESS5 - Upper and lower bounds of adoption reach") ///
    $options1