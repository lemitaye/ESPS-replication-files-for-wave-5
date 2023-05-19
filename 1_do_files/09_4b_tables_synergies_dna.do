********************************************************************************
*                           Ethiopia Synthesis Report 
*                16_Synergies, Part II - (Maize germplasm) synergies 
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

* Note: all DNA households in ESS5 are panel households. The panel sample in this
* context refers to panel DNA households.


* HH level --------------------------------

* ESS5 ----------------------------

use "${data}/ess5_dna_hh_new.dta", clear

merge 1:1 household_id using "${data}/synergies_hh_ess5_new.dta"
keep if _merge==3
drop _merge

// merge with dna tracking file (imported from a separate project on DNA)
preserve
    use "${supp}/track_dna_hh.dta", clear
    rename hh_status hh_status_dna
    
    tempfile track_dna_hh
    save `track_dna_hh'
restore

merge 1:1 household_id using `track_dna_hh', keepusing(hh_status_dna)
keep if _merge==1 | _merge==3
drop _merge

local vars nrm ca crop tree animal breed breed2 psnp psnp2 rotlegume cresidue mintillage zerotill  

rename maize_cg maize
lab var maize "Maize-CG germplasm"

foreach var of local vars {
    local lbl : variable label `var'
    local lbl2 : variable label maize

    generate `var'_maize=(`var'*maize) 
    label variable `var'_maize `"`lbl' & `lbl2'"'
}

#delimit;
global intdna 
nrm         maize   nrm_maize
ca          maize   ca_maize 
crop        maize   crop_maize 
tree        maize   tree_maize 
animal      maize   animal_maize 
breed       maize   breed_maize 
breed2      maize   breed2_maize 
psnp        maize   psnp_maize 
psnp2       maize   psnp2_maize 
rotlegume   maize   rotlegume_maize 
cresidue    maize   cresidue_maize 
mintillage  maize   mintillage_maize 
zerotill    maize   zerotill_maize 
;
#delimit cr		

local rname ""
foreach var in $intdna {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	

#delimit;
global options2
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" 
"National" "National" "National" "National" "National") showeq ///
font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 30, 4 30, 5 40, 
6 55, 7 55, 8 30, 9 30, 10 40,
11 55, 12 55, 13 30, 14 30, 15 40,
16 55, 17 55, 18 30, 19 30, 20 40,
21 55, 22 55, 23 30, 24 30, 25 40,
26 55, 27 55, 28 30, 29 30, 30 40,
) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
format((SCLR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) (NBCR0) (NBCR0) (NBCR3) (NBCR3) (NBCR0) 
(NBCR0) (NBCR0))  /// * format the columns. Each parentheses represents one column*
star(.1 .05 .01)  /// Define your star values/signs here (which are stored in B_STARS)
lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 13)  /// Draws lines in specific format (Numeric Value)
notes(Point estimates are weighted sample means.) 
;
#delimit cr


// All DNA sample

// construct matrix:
descr_tab $intdna, regions("3 4 7 13 15") wt(pw_w5)

// export
xml_tab C, save("$table/09_4_ess5_synergies_dna.xml") replace sheet("HH_DNA_w5", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies, maize DNA germplasm") ///
    $options2


// Only panel DNA sample

// construct matrix:
descr_tab $intdna if hh_status_dna==3, regions("3 4 7 13 15") wt(pw_panel)

// export
xml_tab C, save("$table/09_4_ess5_synergies_dna.xml") append sheet("HH_DNA_w5_panel", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies, maize DNA germplasm (only panel DNA sample)") ///
    $options2

* save -----------
save "${data}/synergies_dna_hh_ess5.dta", replace



* ESS4 (HH level) --------------------------

use "${dataw4}/ess4_dna_hh_new.dta", clear

merge 1:1 household_id using "${dataw4}/synergies_hh_ess4_new.dta"
keep if _merge==3
drop _merge

keep if maize_cg!=.  // retain only maize (vs. barley & sorghum)

// merge with dna tracking file (imported from a separate project on DNA)
preserve
    use "${supp}/track_dna_hh.dta", clear
    rename hh_status hh_status_dna
    
    tempfile track_dna_hh
    save `track_dna_hh'
restore

merge 1:1 household_id using `track_dna_hh', keepusing(hh_status_dna)
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

label var psnp2 "PSNP (both)"

rename maize_cg maize
lab var maize "Maize-CG germplasm"

local vars nrm ca crop tree animal breed breed2 psnp psnp2 rotlegume cresidue mintillage zerotill  

foreach var of local vars {
    local lbl : variable label `var'
    local lbl2 : variable label maize

    generate `var'_maize=(`var'*maize) 
    label variable `var'_maize `"`lbl' & `lbl2'"'
}

* All DNA sample in wave 4

// construct matrix:
descr_tab $intdna, regions("3 4 7 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_4_ess4_synergies_dna.xml") replace sheet("HH_DNA_w4", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies, maize DNA germplasm") ///
    $options2

* Panel DNA sample in wave 4

// construct matrix:
descr_tab $intdna if hh_status_dna==3, regions("3 4 7 13 15") wt(pw_panel)

// export
xml_tab C, save("$table/09_4_ess4_synergies_dna.xml") append sheet("HH_DNA_w4_panel", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies, maize DNA germplasm (only panel DNA sample)") ///
    $options2






/* EA level ------------------------------------

use "${data}/ess5_dna_ea_new.dta", clear

merge 1:1 ea_id using "${data}/synergies_ea_ess5_new.dta"
keep if _merge==3
drop _merge

rename maize_cg maize
lab var maize "Maize - CG germplasm"

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill  

foreach var of local vars {
    local lbl : variable label `var'
    local lbl2 : variable label maize

    generate `var'_maize=(`var'*maize) 
    label variable `var'_maize `" `lbl' - `lbl2'"'
}

foreach x in `vars' {
    generate `x'maize=.
    replace `x'maize =`x' if maize!=.
}

foreach var of local vars {
    local lbl : variable label `var'
    label variable `var'maize `" `lbl'"'
}

#delimit;
global intdna 
nrmmaize         maize nrm_maize
camaize          maize ca_maize 
cropmaize        maize crop_maize 
treemaize        maize tree_maize 
animalmaize      maize animal_maize 
breedmaize       maize breed_maize 
breed2maize      maize breed2_maize 
psnpmaize        maize psnp_maize 
rotlegumemaize   maize rotlegume_maize 
cresiduemaize    maize cresidue_maize 
mintillagemaize  maize mintillage_maize 
zerotillmaize    maize zerotill_maize 
;
#delimit cr		

save "${data}/synergies_dna_ea_ess5.dta", replace

// construct matrix:
descr_tab $intdna, regions("3 4 7 13 15") 

// export
xml_tab C, save("$table/09_4_ess5_synergies.xml") append sheet("EA_DNA_w5", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies, maize DNA germplasm") ///
    $options2


* ESS5 (EA level) --------------------------

use "${dataw4}/ess4_dna_ea_new.dta", clear

* Considering only dna sample cultivating households, respectively 
foreach i in qpm dtmz maize_cg barley_cg sorghum_cg {
    replace `i'=. if sample_dna_`i'==.
}

merge 1:1 ea_id using "${dataw4}/synergies_ea_ess4_new.dta"
keep if _merge==3
drop _merge

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill  

foreach var of local vars {
    local lbl : variable label `var'
    local lbl2 : variable label maize

    generate `var'_maize=(`var'*maize) 
    label variable `var'_maize `" `lbl' - `lbl2'"'
}

foreach x in `vars' {
    generate `x'maize=.
    replace `x'maize =`x' if maize!=.
}

foreach var of local vars {
    local lbl : variable label `var'
    label variable `var'maize `" `lbl'"'
}

#delimit;
global intdna
nrmmaize         maize nrm_maize 
camaize          maize ca_maize 
cropmaize        maize crop_maize 
treemaize        maize tree_maize 
animalmaize      maize animal_maize 
breedmaize       maize breed_maize 
breed2maize      maize breed2_maize 
psnpmaize        maize psnp_maize 
rotlegumemaize   maize rotlegume_maize 
cresiduemaize    maize cresidue_maize 
mintillagemaize  maize mintillage_maize 
zerotillmaize    maize zerotill_maize 
;
#delimit cr		

// construct matrix:
descr_tab $intdna, regions("3 4 7 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_4_ess4_synergies.xml") append sheet("EA_DNA_w4", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies, maize DNA germplasm") ///
    $options2


