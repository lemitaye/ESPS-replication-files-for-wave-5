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

merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

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

// prep:
local rname ""
foreach var in $hhlevel {
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
rblanks(COL_NAMES "Proportion of hh that adopt on at least one plot:" S2149, 
hhd_impccr  "Share of plots per household" S2149)	 
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

// construct matrix:
descr_tab $hhlevel, regions("2 3 4 5 6 7 12 13 15") wt(pw_w5)

// export
xml_tab C, save("$table/09_1_ess5_adoption_rates.xml") replace sheet("HH_w5", nogridlines) ///
    title("Table: ESS5 - Adoption rates of innovations among rural households") ///
    $options1


// only for panel sample:
descr_tab $hhlevel if hh_status==3, regions("2 3 4 5 6 7 12 13 15") wt(pw_panel)  // use panel weights

xml_tab C, save("$table/09_1_ess5_adoption_rates.xml") append sheet("HH_w5_panel", nogridlines) ///
    title("Table: ESS5 - Adoption rates of innovations among rural households - panel sample only") ///
    $options1


* EA level ------------------------------

use "${data}/wave5_ea_new.dta", clear

// merge with tracking file to id panel EAs
merge 1:1 ea_id using "${tmp}/dynamics/06_1_track_ea.dta", keepusing(ea_status)
keep if _merge==1 | _merge==3
drop _merge


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


// prep:
local rname ""
foreach var in $ealevel {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

# delimit;
global options2
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq(
"Afar" "Afar" "Afar" "Afar" "Afar" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq 
rblanks(COL_NAMES "Prop. of EA in the sample with at least 1 hh adopting:" S2149, 
hhd_impccr  "Share of plots per household" S2149)	 
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
	notes("Point estimates are un-wegihted sample means.") 
;
# delimit cr

// All EAs:	
descr_tab $ealevel, regions("2 3 4 5 6 7 12 13 15")  // unweighted means at EA level

xml_tab C,  save("$table/09_1_ess5_adoption_rates.xml") append sheet("EA_w5", nogridlines) ///
    title("Table: ESS5 - Adoption rates of innovations at the EA level")  ///
    $options2

// panel EAs:
descr_tab $ealevel if ea_status==3, regions("2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_1_ess5_adoption_rates.xml") append sheet("EA_w5_panel", nogridlines) ///
    title("Table: ESS5 - Adoption rates of innovations at the EA level - panel sample only")  ///
    $options2



* Crop-germplasm improvement (Plot level) -------------------

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
xml_tab C, save("$table/09_1_adoption_rates.xml") append sheet("DNA", nogridlines)  
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



* ESS4 -------------------------------------

* Household level ----------------

use "${dataw4}/wave4_hh_new.dta", clear

// merge to id panel hhs:
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

// merge to get panel weights:
merge 1:1 household_id using "${rawdata}/HH/ESS5_weights_hh.dta", keepusing(pw_panel)
keep if _merge==1 | _merge==3
drop _merge

* Adding vars from DNA data ----

preserve
    use "${dataw4}/misclassification_plot_new.dta", clear

    collapse (max) qpm dtmz *_cg, by(household_id)

    label var qpm        "Quality Protein Maize"
    label var dtmz       "Drought Tolerant Maize"
    label var maize_cg   "Maize DNA-fingerprinting"
    label var barley_cg  "Barley DNA-fingerprinting"
    label var sorghum_cg "Sorghum DNA-fingerprinting"

    tempfile dna_hh_w4
    save `dna_hh_w4'
restore

// merge with DNA data
merge 1:1 household_id using `dna_hh_w4'
keep if _merge==1 | _merge==3
drop _merge


#delimit ;
global hhlevel4     
hhd_livIA hhd_cross_largerum hhd_cross_smallrum hhd_cross_poultry hhd_grass
hhd_ofsp hhd_awassa83 hhd_rdisp hhd_motorpump hhd_swc hhd_consag1 hhd_consag2 
hhd_affor hhd_mango hhd_papaya hhd_avocado qpm dtmz maize_cg barley_cg sorghum_cg 
hhd_impcr13 hhd_impcr19 hhd_impcr11 hhd_impcr24 hhd_impcr14 hhd_impcr3 hhd_impcr5 
hhd_impcr60 hhd_impcr62
;
#delimit cr

// recode 100 to 1 for dummies for consistency:
for var $hhlevel4: recode X (100=1)

// prep:
local rname ""
foreach var in $hhlevel4 {
	local lbl : variable label `var'
	local rname `"  `rname'   "`lbl'" "'		
}

#delimit ;
global options3
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq(
"Tigray" "Tigray" "Tigray" "Tigray" "Tigray"
"Afar" "Afar" "Afar" "Afar" "Afar" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National") showeq 
rblanks(COL_NAMES "Proportion of hh that adopt on at least one plot:" S2149, 
hhd_impccr  "Share of plots per household" S2149)	 
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

// construct matrix:
descr_tab $hhlevel4, regions("1 2 3 4 5 6 7 12 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_1_ess4_adoption_rates.xml") replace sheet("HH_w4", nogridlines) ///
    title("Table: ESS4 - Adoption rates of innovations among rural households") ///
    $options3

// only for panel sample:
descr_tab $hhlevel4 if hh_status==3, regions("1 2 3 4 5 6 7 12 13 15") wt(pw_panel)  // use panel weights

xml_tab C, save("$table/09_1_ess4_adoption_rates.xml") append sheet("HH_w4_panel", nogridlines) ///
    title("Table: ESS4 - Adoption rates of innovations among rural households - panel sample only") ///
    $options3

* save ----
save "${tmp}/dynamics/ess4_hh_all.dta", replace