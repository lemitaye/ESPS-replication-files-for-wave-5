********************************************************************************
*                           Ethiopia Synthesis Report 
*                                16_Synergies, Part I
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************


* Declare global (see program "gen_synergy") --------

#delimit;
global int 
nrm       ca            nrm_ca 
nrm       ca1           nrm_ca1 
nrm       ca2           nrm_ca2 
nrm       ca3           nrm_ca3 
nrm       ca4           nrm_ca4 
nrm       ca5           nrm_ca5
nrm       crop          nrm_crop 
nrm       tree          nrm_tree 
nrm       animal        nrm_animal 
nrm       breed         nrm_breed 
nrm       breed2        nrm_breed2 
nrm       psnp          nrm_psnp 
nrm       psnp2         nrm_psnp2 
nrm       rotlegume     nrm_rotlegume 
nrm       cresidue      nrm_cresidue 
nrm       mintillage    nrm_mintillage  
nrm       zerotill      nrm_zerotill 

ca        crop          ca_crop 
ca        tree          ca_tree 
ca        animal        ca_animal 
ca        breed         ca_breed 
ca        breed2        ca_breed2  
ca        psnp          ca_psnp 
ca        psnp2         ca_psnp2 

crop      tree          crop_tree 
crop      animal        crop_animal 
crop      breed         crop_breed 
crop      breed2        crop_breed2 
crop      psnp          crop_psnp 
crop      psnp2         crop_psnp2 
crop      rotlegume     crop_rotlegume 
crop      cresidue      crop_cresidue 
crop      mintillage    crop_mintillage 
crop      zerotill      crop_zerotill 
crop      ca1           crop_ca1 
crop      ca2           crop_ca2 
crop      ca3           crop_ca3 
crop      ca4           crop_ca4 
crop      ca5           crop_ca5

tree      animal        tree_animal 
tree      breed         tree_breed 
tree      breed2        tree_breed2 
tree      psnp          tree_psnp 
tree      psnp2         tree_psnp2 
tree      rotlegume     tree_rotlegume 
tree      cresidue      tree_cresidue 
tree      mintillage    tree_mintillage 
tree      zerotill      tree_zerotill 
tree      ca1           tree_ca1 
tree      ca2           tree_ca2 
tree      ca3           tree_ca3 
tree      ca4           tree_ca4 
tree      ca5           tree_ca5

animal    breed         animal_breed 
animal    breed2        animal_breed2 
animal    psnp          animal_psnp 
animal    psnp2         animal_psnp2 
animal    rotlegume     animal_rotlegume 
animal    cresidue      animal_cresidue 
animal    mintillage    animal_mintillage 
animal    zerotill      animal_zerotill 
animal    ca1           animal_ca1 
animal    ca2           animal_ca2 
animal    ca3           animal_ca3 
animal    ca4           animal_ca4 
animal    ca5           animal_ca5 

breed     psnp          breed_psnp 
breed     psnp2         breed_psnp2 
breed     rotlegume     breed_rotlegume 
breed     cresidue      breed_cresidue 
breed     mintillage    breed_mintillage 
breed     zerotill      breed_zerotill 
breed     ca1           breed_ca1 
breed     ca2           breed_ca2 
breed     ca3           breed_ca3 
breed     ca4           breed_ca4 
breed     ca5           breed_ca5

breed2    psnp          breed2_psnp  
breed2    psnp2         breed2_psnp2  
breed2    rotlegume     breed2_rotlegume 
breed2    cresidue      breed2_cresidue 
breed2    mintillage    breed2_mintillage 
breed2    zerotill      breed2_zerotill 
breed2    ca1           breed2_ca1 
breed2    ca2           breed2_ca2 
breed2    ca3           breed2_ca3 
breed2    ca4           breed2_ca4 
breed2    ca5           breed2_ca5 

psnp      rotlegume     psnp_rotlegume 
psnp      cresidue      psnp_cresidue 
psnp      mintillage    psnp_mintillage 
psnp      zerotill      psnp_zerotill 
psnp      ca1           psnp_ca1 
psnp      ca2           psnp_ca2 
psnp      ca3           psnp_ca3 
psnp      ca4           psnp_ca4 
psnp      ca5           psnp_ca5 

psnp2      rotlegume     psnp2_rotlegume 
psnp2      cresidue      psnp2_cresidue 
psnp2      mintillage    psnp2_mintillage 
psnp2      zerotill      psnp2_zerotill 
psnp2      ca1           psnp2_ca1 
psnp2      ca2           psnp2_ca2 
psnp2      ca3           psnp2_ca3 
psnp2      ca4           psnp2_ca4 
psnp2      ca5           psnp2_ca5 

rotlegume cresidue      rotlegume_cresidue 
rotlegume mintillage    rotlegume_mintillage 
rotlegume zerotill      rotlegume_zerotill 
cresidue  mintillage    cresidue_mintillage 
cresidue  zerotill      cresidue_zerotill 
;
#delimit cr		
* Household level ---------------------------------------------------------

* ESS5 -----------------------------------

use "${data}/wave5_hh_new.dta", clear

// merge with tracking file to id panel hhs
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

rename largerum_cross hhd_crlr
rename smallrum_cross hhd_crsm
rename poultry_cross  hhd_crpo

// run program to create interactions 
gen_synergy hhd 

// prep:
local rname ""
foreach var in $int {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit;
global options1
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq(
"Afar" "Afar" "Afar" "Afar" "Afar" "Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" 
"Oromia" "Oromia" "Oromia" "Oromia" "Oromia" "Somali" "Somali" "Somali" "Somali" "Somali"
"Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz" "Benishangul Gumuz"
"SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Gambela" "Gambela" "Gambela" "Gambela" "Gambela" 
"Harar" "Harar" "Harar" "Harar" "Harar" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa"
"National" "National" "National" "National" "National"
) showeq font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
    6 55, 7 55, 8 30, 9 30, 10 40,
    11 55, 12 55, 13 30, 14 30, 15 40,
    16 55, 17 55, 18 30, 19 30, 20 40,
    21 55, 22 55, 23 30, 24 30, 25 40,
    26 55, 27 55, 28 30, 29 30, 30 40,
    31 55, 32 55, 33 30, 34 30, 35 40,
    36 55, 37 55, 38 30, 39 30, 40 40,
    41 55, 42 55, 43 30, 44 30, 45 40,
    46 55, 47 55, 48 30, 49 30, 50 40)  /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
notes("Point estimates are weighted sample means. 
CA1 = Crop rotation with legume - Crop residue cover, 
CA2 = Crop rotation with legume -Minimum tillage, 
CA3 = Crop rotation with legume - Zero  tillage, 
CA4 = Crop residue cover - Minimum tillage, 
CA5 = Crop residue cover - Zero tillage.") 
;
#delimit cr	

// construct matrix:
descr_tab $int, regions("2 3 4 5 6 7 12 13 15") wt(pw_w5)

// export
xml_tab C, save("$table/09_4_ess5_synergies.xml") replace sheet("HH_w5", nogridlines) ///
    title("Table: ESS5 - Adoption rates of innovations among rural households") ///
    $options1


// only for panel households:

// matrix:
descr_tab $int if hh_status==3, regions("2 3 4 5 6 7 12 13 15") wt(pw_panel)

// export
xml_tab C, save("$table/09_4_ess5_synergies.xml") append sheet("HH_w5_panel", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies, only panel sample") ///
    $options1

* save ---------------
drop sh_* hhd_* sr_* po_* lr_* ead_* impcr*   
save "${data}/synergies_hh_ess5_new.dta", replace    


* ESS4: Household level ----------------------------------------------

use "${dataw4}/synergies_hh_ess4_new.dta", clear

// merge with tracking file to id panel hhs
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh_pp.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

// merge to get panel weights:
merge 1:1 household_id using "${rawdata}/HH/ESS5_weights_hh.dta", keepusing(pw_panel)
keep if _merge==1 | _merge==3
drop _merge


// Add direct assistance PSNP for wave 4
preserve
    use "${raw4}/sect14_hh_w4.dta", clear

    keep if assistance_cd==1

    gen hhd_psnp_dir=.
    replace hhd_psnp_dir=0 if s14q01==2
    replace hhd_psnp_dir=1 if s14q01==1

    keep household_id hhd_psnp_dir
    label var hhd_psnp_dir "Direct support through PSNP"

    tempfile psnp_direct
    save `psnp_direct'
restore

merge 1:1 household_id using `psnp_direct'
keep if _merge==1 | _merge==3
drop _merge

* psnp
generate psnp2=.
replace psnp2=0 if hhd_psnp==0 & hhd_psnp_dir==0
replace psnp2=1 if hhd_psnp==1 | hhd_psnp_dir==1

// run program to create interactions 
gen_synergy hhd 


// All households:

// construct matrix:
descr_tab $int, regions("2 3 4 5 6 7 12 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_4_ess4_synergies.xml") replace sheet("HH_w4", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies") ///
    $options1


// Panel households:

// construct matrix:
descr_tab $int if hh_status==3, regions("2 3 4 5 6 7 12 13 15") wt(pw_panel)

// export
xml_tab C, save("$table/09_4_ess4_synergies.xml") append sheet("HH_w4_panel", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies, only panel sample") ///
    $options1

* save
save "${data}/synergies_hh_ess4_new.dta", replace


* EA level ----------------------------------------------

* ESS5 ---------------------------------

use "${data}/wave5_ea_new.dta", clear

// merge with tracking file to id panel EAs
merge 1:1 ea_id using "${tmp}/dynamics/06_1_track_ea.dta", keepusing(ea_status)
keep if _merge==1 | _merge==3
drop _merge

rename ead_cross_largerum ead_crlr
rename ead_cross_smallrum ead_crsm
rename ead_cross_poultry  ead_crpo

// run program to create interactions (EA level)
gen_synergy ead

// prep:
local rname ""
foreach var in $int {
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
descr_tab $int, regions("2 3 4 5 6 7 12 13 15")  // unweighted means at EA level

xml_tab C,  save("$table/09_4_ess5_synergies.xml") append sheet("EA_w5", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies") ///
    $options2

// panel EAs:
descr_tab $int if ea_status==3, regions("2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_4_ess5_synergies.xml") append sheet("EA_w5_panel", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies - panel sample only")  ///
    $options2


/* ESS4 (EA level) ----------------------

use "${dataw4}/synergies_ea_ess4_new.dta", clear

// merge with tracking file to id panel EAs
merge 1:1 ea_id using "${tmp}/dynamics/06_1_track_ea.dta", keepusing(ea_status)
keep if _merge==1 | _merge==3
drop _merge


// All EAs:	
descr_tab $int, regions("2 3 4 5 6 7 12 13 15")  // unweighted means at EA level

xml_tab C,  save("$table/09_4_ess4_synergies.xml") append sheet("EA_w4", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies") ///
    $options2

// panel EAs:
descr_tab $int if ea_status==3, regions("2 3 4 5 6 7 12 13 15")

xml_tab C,  save("$table/09_4_ess4_synergies.xml") append sheet("EA_w4_panel", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies - panel sample only")  ///
    $options2





