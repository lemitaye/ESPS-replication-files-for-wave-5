********************************************************************************
*                           Ethiopia Synthesis Report 
*                                16_Synergies
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************


* Household level ---------------------------------------------------------

* ESS5 -----------------------------------

use "${data}/wave5_hh_new.dta", clear

// merge with tracking file to id panel hhs
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge

rename largerum_cross hhd_crlr
rename smallrum_cross hhd_crsm
rename poultry_cross  hhd_crpo

// NRM
generate nrm=0
replace nrm=1 if hhd_treadle==1 | hhd_motorpump==1 | hhd_rdisp==1 | hhd_swc==1 ///
    | hhd_terr==1 | hhd_wcatch==1 | hhd_affor==1 | hhd_ploc==1  

generate ca=0
replace ca=1 if hhd_consag1==1 | hhd_consag2==1 

generate ca1=0
replace ca1=1 if hhd_rotlegume==1 | hhd_cresidue2==1  

generate ca2=0
replace ca2=1 if hhd_rotlegume==1 | hhd_mintillage==1  

generate ca3=0
replace ca3=1 if hhd_rotlegume==1 | hhd_zerotill==1 

generate ca4=0
replace ca4=1 if hhd_cresidue2==1 | hhd_mintillage==1 

generate ca5=0
replace ca5=1 if hhd_cresidue2==1 | hhd_zerotill==1 


// Crop
generate crop=0
replace crop=1 if hhd_ofsp==1  | hhd_awassa83==1  |  hhd_fieldp==1  | hhd_sweetpotato==1  

generate tree=0
replace tree=1 if hhd_avocado==1  | hhd_papaya==1  | hhd_mango==1  

generate animal=0
replace animal=1 if  hhd_elepgrass==1  | hhd_sesbaniya==1  |  hhd_alfalfa==1  | hhd_agroind==1 
 
generate breed=0
replace breed=1 if hhd_cross==1  | hhd_crlr==1  | hhd_crsm==1  | hhd_crpo==1  | hhd_livIA==1 

generate breed2=0
replace breed2=1 if hhd_crlr==1  | hhd_crsm==1   | hhd_livIA==1 

* psnp
clonevar psnp=hhd_psnp
generate psnp2=.
replace psnp2=0 if hhd_psnp==0 & hhd_psnp_dir==0
replace psnp2=1 if hhd_psnp==1 | hhd_psnp_dir==1


*Different combinations of CA practices
generate rotlegume=0
replace rotlegume=1 if hhd_rotlegume==1 

generate cresidue=0
replace cresidue=1 if hhd_cresidue2==1  

generate mintillage=hhd_mintillage==1  
generate zerotill=hhd_zerotill==1  

local vars nrm ca crop tree animal breed breed2 psnp psnp2 rotlegume cresidue ///
    mintillage zerotill ca1 ca2 ca3 ca4 ca5 

local vars2  ca crop tree animal breed breed2 psnp psnp2 rotlegume cresidue ///
    mintillage zerotill ca1 ca2 ca3 ca4 ca5


foreach var of local vars {
    local lbl : variable label `var'

    foreach i of local vars2 {
        local lbl2 : variable label `i'
        generate `var'_`i'=(`var'*`i') 
        label variable `var'_`i' `" `lbl' - `lbl2'"'
    }
}

lab var nrm_ca1       "NRM & CA1"
lab var nrm_ca2       "NRM & CA2"
lab var nrm_ca3       "NRM & CA3"
lab var nrm_ca4       "NRM & CA4"
lab var nrm_ca5       "NRM & CA5"
lab var crop_ca1      "Crop varieties & CA1"
lab var crop_ca2      "Crop varieties & CA2"
lab var crop_ca3      "Crop varieties & CA3"
lab var crop_ca4      "Crop varieties & CA4"
lab var crop_ca5      "Crop varieties & CA5"
lab var tree_ca1      "Trees & CA1"
lab var tree_ca2      "Trees & CA2"
lab var tree_ca3      "Trees & CA3"
lab var tree_ca4      "Trees & CA4"
lab var tree_ca5      "Trees & CA5"
lab var animal_ca1    "Feed and Forages & CA1"
lab var animal_ca2    "Feed and Forages & CA2"
lab var animal_ca3    "Feed and Forages & CA3"
lab var animal_ca4    "Feed and Forages & CA4"
lab var animal_ca5    "Feed and Forages & CA5"
lab var breed_ca1     "Breeding & CA1"
lab var breed_ca2     "Breeding & CA2"
lab var breed_ca3     "Breeding & CA3"
lab var breed_ca4     "Breeding & CA4"
lab var breed_ca5     "Breeding & CA5"
lab var breed2_ca1    "Breeding excl. poultry & CA1"
lab var breed2_ca2    "Breeding excl. poultry & CA2"
lab var breed2_ca3    "Breeding excl. poultry & CA3"
lab var breed2_ca4    "Breeding excl. poultry & CA4"
lab var breed2_ca5    "Breeding excl. poultry & CA5"
lab var psnp_ca1      "PSNP & CA1"
lab var psnp_ca2      "PSNP & CA2"
lab var psnp_ca3      "PSNP & CA3"
lab var psnp_ca4      "PSNP & CA4"
lab var psnp_ca5      "PSNP & CA5"
lab var psnp2_ca1      "PSNP (both) & CA1"
lab var psnp2_ca2      "PSNP (both) & CA2"
lab var psnp2_ca3      "PSNP (both) & CA3"
lab var psnp2_ca4      "PSNP (both) & CA4"
lab var psnp2_ca5      "PSNP (both) & CA5"

lab var nrm                "NRM"
lab var ca                 "CA"
lab var crop               "Crop varieties"
lab var tree               "Trees"
lab var animal             "Feed and Forages"
lab var breed              "Breeding"
lab var breed2             "Breeding (excl. poultry)"
lab var psnp               "PSNP"
lab var psnp2              "PSNP (both)"
lab var rotlegume          "Crop rotation with legume"
lab var cresidue           "Crop residue cover" 
lab var mintillage         "Minimum tillage"
lab var zerotill           "Zero tillage"  

lab var ca1                 "CA1 = Crop rotation with legume - Crop residue cover"
lab var ca2                 "CA2 = Crop rotation with legume -Minimum tillage "
lab var ca3                 "CA3 = Crop rotation with legume - Zero tillage"
lab var ca4                 "CA4 = Crop residue cover - Minimum tillage"
lab var ca5                 "CA5 = Crop residue cover - Zero tillage"

lab var nrm_ca              "NRM - CA"
lab var nrm_crop            "NRM & Crop varieties"
lab var nrm_tree            "NRM & Trees"
lab var nrm_animal          "NRM & Feed and Forages"
lab var nrm_breed           "NRM & Breeding"
lab var nrm_breed2          "NRM & Breeding (excl. poultry)"
lab var nrm_psnp            "NRM & PSNP"
lab var nrm_psnp2           "NRM & PSNP (both)"
lab var ca_crop             "CA & Crop varieties"
lab var ca_tree             "CA & Trees"
lab var ca_animal           "CA & Feed and Forages"
lab var ca_breed            "CA & Breeding"
lab var ca_breed2           "CA & Breeding (excl. poultry)"
lab var ca_psnp             "CA & PSNP"  
lab var ca_psnp2            "CA & PSNP (both)"  
lab var crop_tree           "Crop varieties & Trees"
lab var crop_animal         "Crop varieties & Feed and Forages"
lab var crop_breed          "Crop varieties & Breeding"
lab var crop_breed2         "Crop varieties & Breeding (excl. poultry)"
lab var crop_psnp           "Crop varieties & PSNP"
lab var crop_psnp2          "Crop varieties & PSNP (both)"
lab var tree_animal         "Trees & Feed and Forages"
lab var tree_breed          "Trees & Breeding"
lab var tree_breed2         "Trees & Breeding (excl. poultry)" 
lab var tree_psnp           "Trees & PSNP"
lab var tree_psnp2          "Trees & PSNP (both)"
lab var animal_breed        "Feed and Forages & Breeding"
lab var animal_breed2       "Feed and Forages & Breeding (excl. poultry)" 
lab var animal_psnp         "Feed and Forages &  PSNP"
lab var breed_psnp          "Breeding &  PSNP"
lab var breed_psnp2         "Breeding &  PSNP (both)"
lab var breed2_psnp         "Breeding (excl. poultry) &  PSNP"
lab var breed2_psnp2        "Breeding (excl. poultry) &  PSNP (both)"


lab var nrm_rotlegume        "NRM & Crop rotation with legume"
lab var nrm_cresidue         "NRM & Crop residue cover"
lab var nrm_mintillage       "NRM & Minimum tillage"
lab var nrm_zerotill         "NRM & Zero tillage"
lab var crop_rotlegume       "Crop varieties & Crop rotation with legume"
lab var crop_cresidue        "Crop varieties & Crop residue cover"        
lab var crop_mintillage      "Crop varieties & Minimum tillage"            
lab var crop_zerotill        "Crop varieties & Zero tillage"               
lab var tree_rotlegume       "Trees & Crop rotation with legume"
lab var tree_cresidue        "Trees & Crop residue cover"        
lab var tree_mintillage      "Trees & Minimum tillage"            
lab var tree_zerotill        "Trees & Zero tillage"               
lab var animal_rotlegume     "Feed and Forages & Crop rotation with legume"
lab var animal_cresidue      "Feed and Forages & Crop residue cover"        
lab var animal_mintillage    "Feed and Forages & Minimum tillage"            
lab var animal_zerotill      "Feed and Forages & Zero tillage"               
lab var breed_rotlegume      "Breeding & Crop rotation with legume"
lab var breed_cresidue       "Breeding & Crop residue cover"        
lab var breed_mintillage     "Breeding & Minimum tillage"            
lab var breed_zerotill       "Breeding & Zero tillage"               
lab var breed2_rotlegume     "Breeding (excl. poultry) & Crop rotation with legume"
lab var breed2_cresidue      "Breeding (excl. poultry) & Crop residue cover"        
lab var breed2_mintillage    "Breeding (excl. poultry) & Minimum tillage"            
lab var breed2_zerotill      "Breeding (excl. poultry) & Zero tillage"               
lab var psnp_rotlegume       "PSNP & Crop rotation with legume"
lab var psnp_cresidue        "PSNP & Crop residue cover"        
lab var psnp_mintillage      "PSNP & Minimum tillage"            
lab var psnp_zerotill        "PSNP & Zero tillage"        
lab var psnp2_rotlegume      "PSNP (both) & Crop rotation with legume"
lab var psnp2_cresidue       "PSNP (both) & Crop residue cover"        
lab var psnp2_mintillage     "PSNP (both) & Minimum tillage"            
lab var psnp2_zerotill       "PSNP (both) & Zero tillage"               
lab var rotlegume_cresidue   "Crop rotation with legume & Crop residue cover"   
lab var rotlegume_mintillage "Crop rotation with legume & Minimum tillage"      
lab var rotlegume_zerotill   "Crop rotation with legume & Zero tillage"         
lab var cresidue_mintillage  "Crop residue cover & Minimum tillage" 
lab var cresidue_zerotill    "Crop residue cover & Zero tillage"  
  
  
save "${data}/synergies_hh_ess5_new.dta", replace  
  
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


/*/ only for panel households:

// matrix:
descr_tab $int if hh_status==3, regions("2 3 4 5 6 7 12 13 15") wt(pw_w5)

// export
xml_tab C, save("$table/09_4_ess5_synergies.xml") append sheet("HH_w5_panel", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies, only panel sample") ///
    $options1


* ESS4: Household level ----------------------------------------------

use "${dataw4}/synergies_hh_ess4_new.dta", clear

// merge with tracking file to id panel hhs
merge 1:1 household_id using "${tmp}/dynamics/06_1_track_hh.dta", keepusing(hh_status)
keep if _merge==1 | _merge==3
drop _merge


// All households:

// construct matrix:
descr_tab $int, regions("2 3 4 5 6 7 12 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_4_ess4_synergies.xml") replace sheet("HH_w4", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies") ///
    $options1


// Panel households:

// construct matrix:
descr_tab $int if hh_status==3, regions("2 3 4 5 6 7 12 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_4_ess4_synergies.xml") append sheet("HH_w4_panel", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies, only panel sample") ///
    $options1




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

generate nrm=0
replace nrm=1 if ead_treadle==1 | ead_motorpump==1 | ead_rdisp==1 |  ead_swc==1 ///
    | ead_terr==1 | ead_wcatch==1 | ead_affor==1 | ead_ploc==1 

generate ca=0
replace ca=1 if ead_consag1==1 | ead_consag2==1

generate ca1=0
replace ca1=1 if ead_rotlegume==1  | ead_cresidue2==1 

generate ca2=0
replace ca2=1 if ead_rotlegume==1 | ead_mintillage==1 

generate ca3=0
replace ca3=1 if ead_rotlegume==1 | ead_zerotill==1

generate ca4=0
replace ca4=1 if ead_cresidue2==1 | ead_mintillage==1

generate ca5=0
replace ca5=1 if ead_cresidue2==1 | ead_zerotill==1


generate crop=0
replace crop=1 if ead_ofsp==1 | ead_awassa83==1 |  ead_fieldp==1 | ead_sweetpotato==1 

generate tree=0
replace tree=1 if ead_avocado==1 | ead_papaya==1 | ead_mango==1 

generate animal=0
replace animal=1 if  ead_elepgrass==1 | ead_sesbaniya==1 |  ead_alfalfa==1 | ead_agroind==1
 
generate breed=0
replace breed=1 if ead_cross==1 | ead_crlr==1 | ead_crsm==1 | ead_crpo==1 | ead_livIA==1

generate breed2=0
replace breed2=1 if ead_crlr==1 | ead_crsm==1  | ead_livIA==1

*psnp
clonevar psnp=ead_psnp

*Different combinations of CA practices
generate       rotlegume=0
replace rotlegume=1 if ead_rotlegume==1

generate cresidue=0
replace cresidue=1 if ead_cresidue2==1 

generate mintillage=ead_mintillage==1 
generate zerotill=ead_zerotill==1 


local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue ///
    mintillage zerotill ca1 ca2 ca3 ca4 ca5 

local vars2  ca crop tree animal breed breed2 psnp rotlegume cresidue ///
    mintillage zerotill ca1 ca2 ca3 ca4 ca5


foreach var of local vars {
    local lbl : variable label `var'

    foreach i of local vars2 {
        local lbl2 : variable label `i'
        generate `var'_`i'=(`var'*`i')      // interaction
        label variable `var'_`i' `" `lbl' - `lbl2'"'
    }
}

lab var nrm_ca1       "NRM & CA1"
lab var nrm_ca2       "NRM & CA2"
lab var nrm_ca3       "NRM & CA3"
lab var nrm_ca4       "NRM & CA4"
lab var nrm_ca5       "NRM & CA5"
lab var crop_ca1      "Crop varieties & CA1"
lab var crop_ca2      "Crop varieties & CA2"
lab var crop_ca3      "Crop varieties & CA3"
lab var crop_ca4      "Crop varieties & CA4"
lab var crop_ca5      "Crop varieties & CA5"
lab var tree_ca1      "Trees & CA1"
lab var tree_ca2      "Trees & CA2"
lab var tree_ca3      "Trees & CA3"
lab var tree_ca4      "Trees & CA4"
lab var tree_ca5      "Trees & CA5"
lab var animal_ca1    "Feed and Forages & CA1"
lab var animal_ca2    "Feed and Forages & CA2"
lab var animal_ca3    "Feed and Forages & CA3"
lab var animal_ca4    "Feed and Forages & CA4"
lab var animal_ca5    "Feed and Forages & CA5"
lab var breed_ca1     "Breeding & CA1"
lab var breed_ca2     "Breeding & CA2"
lab var breed_ca3     "Breeding & CA3"
lab var breed_ca4     "Breeding & CA4"
lab var breed_ca5     "Breeding & CA5"
lab var breed2_ca1    "Breeding excl. poultry & CA1"
lab var breed2_ca2    "Breeding excl. poultry & CA2"
lab var breed2_ca3    "Breeding excl. poultry & CA3"
lab var breed2_ca4    "Breeding excl. poultry & CA4"
lab var breed2_ca5    "Breeding excl. poultry & CA5"
lab var psnp_ca1      "PSNP & CA1"
lab var psnp_ca2      "PSNP & CA2"
lab var psnp_ca3      "PSNP & CA3"
lab var psnp_ca4      "PSNP & CA4"
lab var psnp_ca5      "PSNP & CA5"

lab var nrm                "NRM"
lab var ca                 "CA"
lab var crop               "Crop varieties"
lab var tree               "Trees"
lab var animal             "Feed and Forages"
lab var breed              "Breeding"
lab var breed2             "Breeding (excl. poultry)"
lab var psnp               "PSNP"
lab var rotlegume          "Crop rotation with legume"
lab var cresidue           "Crop residue cover" 
lab var mintillage         "Minimum tillage"
lab var zerotill           "Zero tillage"  

lab var ca1                 "CA1 = Crop rotation with legume - Crop residue cover"
lab var ca2                 "CA2 = Crop rotation with legume -Minimum tillage "
lab var ca3                 "CA3 = Crop rotation with legume - Zero tillage"
lab var ca4                 "CA4 = Crop residue cover - Minimum tillage"
lab var ca5                 "CA5 = Crop residue cover - Zero tillage"

lab var nrm_ca              "NRM - CA"
lab var nrm_crop            "NRM & Crop varieties"
lab var nrm_tree            "NRM & Trees"
lab var nrm_animal          "NRM & Feed and Forages"
lab var nrm_breed           "NRM & Breeding"
lab var nrm_breed2          "NRM & Breeding (excl. poultry)"
lab var nrm_psnp            "NRM & PSNP"
lab var ca_crop             "CA & Crop varieties"
lab var ca_tree             "CA & Trees"
lab var ca_animal           "CA & Feed and Forages"
lab var ca_breed            "CA & Breeding"
lab var ca_breed2           "CA & Breeding (excl. poultry)"
lab var ca_psnp             "CA & PSNP"  
lab var crop_tree           "Crop varieties & Trees"
lab var crop_animal         "Crop varieties & Feed and Forages"
lab var crop_breed          "Crop varieties & Breeding"
lab var crop_breed2         "Crop varieties & Breeding (excl. poultry)"
lab var crop_psnp           "Crop varieties & PSNP"
lab var tree_animal         "Trees & Feed and Forages"
lab var tree_breed          "Trees & Breeding"
lab var tree_breed2         "Trees & Breeding (excl. poultry)" 
lab var tree_psnp           "Trees & PSNP"
lab var animal_breed        "Feed and Forages & Breeding"
lab var animal_breed2       "Feed and Forages & Breeding (excl. poultry)" 
lab var animal_psnp         "Feed and Forages &  PSNP"
lab var breed_psnp          "Breeding &  PSNP"
lab var breed2_psnp         "Breeding (excl. poultry) &  PSNP"


lab var nrm_rotlegume        "NRM & Crop rotation with legume"
lab var nrm_cresidue         "NRM & Crop residue cover"
lab var nrm_mintillage       "NRM & Minimum tillage"
lab var nrm_zerotill         "NRM & Zero tillage"
lab var crop_rotlegume       "Crop varieties & Crop rotation with legume"
lab var crop_cresidue        "Crop varieties & Crop residue cover"        
lab var crop_mintillage      "Crop varieties & Minimum tillage"            
lab var crop_zerotill        "Crop varieties & Zero tillage"               
lab var tree_rotlegume       "Trees & Crop rotation with legume"
lab var tree_cresidue        "Trees & Crop residue cover"        
lab var tree_mintillage      "Trees & Minimum tillage"            
lab var tree_zerotill        "Trees & Zero tillage"               
lab var animal_rotlegume     "Feed and Forages & Crop rotation with legume"
lab var animal_cresidue      "Feed and Forages & Crop residue cover"        
lab var animal_mintillage    "Feed and Forages & Minimum tillage"            
lab var animal_zerotill      "Feed and Forages & Zero tillage"               
lab var breed_rotlegume      "Breeding & Crop rotation with legume"
lab var breed_cresidue       "Breeding & Crop residue cover"        
lab var breed_mintillage     "Breeding & Minimum tillage"            
lab var breed_zerotill       "Breeding & Zero tillage"               
lab var breed2_rotlegume     "Breeding (excl. poultry) & Crop rotation with legume"
lab var breed2_cresidue      "Breeding (excl. poultry) & Crop residue cover"        
lab var breed2_mintillage    "Breeding (excl. poultry) & Minimum tillage"            
lab var breed2_zerotill      "Breeding (excl. poultry) & Zero tillage"               
lab var psnp_rotlegume       "PSNP & Crop rotation with legume"
lab var psnp_cresidue        "PSNP & Crop residue cover"        
lab var psnp_mintillage      "PSNP & Minimum tillage"            
lab var psnp_zerotill        "PSNP & Zero tillage"               
lab var rotlegume_cresidue   "Crop rotation with legume & Crop residue cover"   
lab var rotlegume_mintillage "Crop rotation with legume & Minimum tillage"      
lab var rotlegume_zerotill   "Crop rotation with legume & Zero tillage"         
lab var cresidue_mintillage  "Crop residue cover & Minimum tillage" 
lab var cresidue_zerotill    "Crop residue cover & Zero tillage"  

save "${data}/synergies_ea_ess5_new.dta", replace

  
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
crop      tree          crop_tree 
crop      animal        crop_animal 
crop      breed         crop_breed 
crop      breed2        crop_breed2 
crop      psnp          crop_psnp 
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
rotlegume cresidue      rotlegume_cresidue 
rotlegume mintillage    rotlegume_mintillage 
rotlegume zerotill      rotlegume_zerotill 
cresidue  mintillage    cresidue_mintillage 
cresidue  zerotill      cresidue_zerotill 
;
#delimit cr	


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


* ESS4 (EA level) ----------------------

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





********************************************************************************
* DNA (Maize germplasm) synergies 
********************************************************************************

* HH level ------------------------------

* Note: all DNA households in ESS5 are panel households. So, no need to run 
* separate analysis for panel sample.

* ESS5 ----------------------------

use "${data}/ess5_dna_hh_new.dta", clear

merge 1:1 household_id using "${data}/synergies_hh_ess5_new.dta"
keep if _merge==3
drop _merge

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill  

rename maize_cg maize
lab var maize "Maize - CG germplasm"

foreach var of local vars {
    local lbl : variable label `var'
    local lbl2 : variable label maize

    generate `var'_maize=(`var'*maize) 
    label variable `var'_maize `" `lbl' - `lbl2'"'
}

foreach x in nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill {
    generate `x'maize=.
    replace `x'maize =`x' if maize!=.
}

local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill

foreach var of local vars {
    local lbl : variable label `var'
    label variable `var'maize `" `lbl'"'
}

save "${data}/synergies_dna_hh_ess5.dta", replace


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

// construct matrix:
descr_tab $intdna, regions("3 4 7 13 15") wt(pw_w5)

// export
xml_tab C, save("$table/09_4_ess5_synergies.xml") append sheet("HH_DNA_w5", nogridlines) ///
    title("Table: ESS5 - Joint adoption rates and synergies, maize DNA germplasm") ///
    $options2



* ESS4 (HH level) --------------------------

use "${data}/synergies_dna_hh_ess4.dta", clear

// construct matrix:
descr_tab $intdna, regions("3 4 7 13 15") wt(pw_w4)

// export
xml_tab C, save("$table/09_4_ess4_synergies.xml") append sheet("HH_DNA_w4", nogridlines) ///
    title("Table: ESS4 - Joint adoption rates and synergies, maize DNA germplasm") ///
    $options2



* EA level ------------------------------------

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




/* DNA for panel households in ESPS4

use "${data}\synergies_dna_hh_ess4", clear

keep if maize_cg!=.   // retain only maize

merge 1:1 household_id using "${data}\synergies_dna_hh_ess5", keepusing(household_id) keep(3)
drop _m


#delimit;
global int 
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


matrix drop _all

foreach x in 3 4 7 13 15 {

foreach var in $int {

    cap:mean `var' [pw=pw_w4] if saq01==`x' & wave==4

    if _rc==2000 {
        matrix  `var'meanr`x'=0
        matrix define `var'V`x'= 0
        scalar `var'se`x'=0
    }
    else if _rc!=0 {
        error _rc
    }
    else {
        matrix  `var'meanr`x'=e(b)'
        matrix define `var'V`x'= e(V)'
        matrix define `var'VV`x'=(vecdiag(`var'V`x'))'
        matrix list `var'VV`x'
        scalar `var'se`x'=sqrt(`var'VV`x'[1,1])
    }

    sum    `var'  if saq01==`x' & wave==4
    scalar `var'minr`x'=r(min)
    scalar `var'maxr`x'=r(max)
    scalar `var'n`x'=r(N)

    qui sum region if saq01==`x' & wave==4
    local obsr`x'=r(N)

    matrix mat`var'`x'  = ( `var'meanr`x', `var'se`x', `var'minr`x', `var'maxr`x', `var'n`x')

    matrix list mat`var'`x'

    matrix A1`x' = nullmat(A1`x')\ mat`var'`x'

    mat A2`x'=(., . , ., .,`obsr`x'')
    mat B`x'=A1`x'\A2`x'

    matrix colnames B`x' = "Mean" "SE" "Min" "Max" "N"

    }

    local rname ""
    foreach var in $int {
        local lbl : variable label `var'
        local rname `"  `rname'   "`lbl'" " " "'		
    }	

}	


* National
foreach var in $int {

    cap:mean `var' [pw=pw_w4] if wave==4

    if _rc==2000 {
        matrix  `var'meanrN=0
        matrix define `var'VN= 0
        scalar `var'seN=0
    }
    else if _rc!=0 {
        error _rc
    }
    else {	
        matrix  `var'meanrN=e(b)'
        matrix define `var'VN= e(V)'
        matrix define `var'VVN=(vecdiag(`var'VN))'
        matrix list `var'VVN
        scalar `var'seN=sqrt(`var'VVN[1,1])
    }

    sum    `var'  if  wave==4
    scalar `var'minrN=r(min)
    scalar `var'maxrN=r(max)
    scalar `var'nN=r(N)

    qui sum region if  wave==4
    local obsrN=r(N)

    matrix mat`var'N  = ( `var'meanrN,`var'seN, `var'minrN, `var'maxrN, `var'nN)

    matrix list mat`var'N

    matrix A1N = nullmat(A1N)\ mat`var'N

    mat A2N=(., . , ., .,`obsrN')
    mat BN=A1N\A2N

    matrix colnames BN = "Mean" "SE" "Min" "Max" "N"

}

mat C= B3, B4, B7, B13, B15, BN


local rname ""
foreach var in $int {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" "'		
}	


#delimit;
xml_tab C,  save("$table\ESS4_innovation_overlap_panel.xml") append sheet("Table_2_DNAhh_ess4_panel", nogridlines)  ///
rnames(`rname' "Total No. of obs. per region") cnames(`cnames') 
ceq("Amhara"  "Amhara"  "Amhara"  "Amhara" "Amhara" "Oromia" "Oromia" "Oromia" 
"Oromia" "Oromia" "SNNP"  "SNNP"  "SNNP"  "SNNP" "SNNP" "Harar" "Harar" "Harar" "Harar" "Harar" 
"Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" "Dire Dawa" 
"National" "National" "National" "National" "National") showeq ///
title(Table 2: ESS4 - HH LEVEL )  font("Times New Roman" 10) ///
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