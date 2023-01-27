********************************************************************************
*                           Ethiopia Synthesis Report 
*                                16_Synergies
* Country: Ethiopia 
* Data: ESS4 
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************


*** EA -LEVEL
* ESS4 *

use "${data}\wave4_ea_new", clear
merge 1:1 ea_id using "${data}\ess4_ea_psnp"
keep if _m==3 | _m==1
drop _m

rename ead_cross_largerum ead_crlr
rename ead_cross_smallrum ead_crsm
rename ead_cross_poultry  ead_crpo

g nrm=0
replace nrm=1 if ead_treadle==100 | ead_motorpump==100 | ead_rdisp==100 |  ead_swc==100 | ead_terr==100 | ead_wcatch==100 | ead_affor==100 | ead_ploc==100 
g ca=0
replace ca=1 if ead_consag1==100 | ead_consag2==100

g ca1=0
replace ca1=1 if ead_rotlegume==100  | ead_cresidue2==100 

g ca2=0
replace ca2=1 if ead_rotlegume==100 | ead_mintillage==100 

g ca3=0
replace ca3=1 if ead_rotlegume==100 | ead_zerotill==100

g ca4=0
replace ca4=1 if ead_cresidue2==100 | ead_mintillage==100

g ca5=0
replace ca5=1 if ead_cresidue2==100 | ead_zerotill==100



g crop=0
replace crop=1 if ead_ofsp==100 | ead_awassa83==100 |  ead_fieldp==100 | ead_sweetpotato==100 

g tree=0
replace tree=1 if ead_avocado==100 | ead_papaya==100 | ead_mango==100 

g animal=0
replace animal=1 if  ead_elepgrass==100 | ead_gaya==100 |  ead_alfa==100 | ead_indprod==100
 
g breed=0
replace breed=1 if ead_cross==100 | ead_crlr==100 | ead_crsm==100 | ead_crpo==100 | ead_livIA==100

g breed2=0
replace breed2=1 if ead_crlr==100 | ead_crsm==100  | ead_livIA==100

*psnp
g psnp=ead_psnp

*Different combinations of CA practices
g       rotlegume=0
replace rotlegume=1 if ead_rotlegume==100
g cresidue=0
replace cresidue=1 if ead_cresidue2==100 
g mintillage=ead_mintillage==100 
g zerotill=ead_zerotill==100 






local vars nrm ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill ca1 ca2 ca3 ca4 ca5 

local vars2  ca crop tree animal breed breed2 psnp rotlegume cresidue mintillage zerotill ca1 ca2 ca3 ca4 ca5




foreach var of local vars {
local lbl : variable label `var'
foreach i of local vars2 {
local lbl2 : variable label `i'
g `var'_`i'=(`var'*`i') 
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


save "${data}\synergies_ea_ess4_new", replace


  
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