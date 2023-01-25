

********************************************************************************
*** LS - Sec.8_1 - Crossbred animals
********************************************************************************

use "${rawdata}\PP\sect8_1_ls_w5", clear


generate ls_type=1 if ls_code>=1 & ls_code<=6   // large ruminants (Bulls, Oxen, Cows, Steers, Heifers, and Calves)
replace ls_type=2 if ls_code==7 | ls_code==8    // small ruminants (Goats and Sheep)
replace ls_type=3 if ls_code==9                 // Camels
replace ls_type=4 if ls_code>=10 & ls_code<=12  // Poultry (Chicken and Chicks)
replace ls_type=5 if ls_code>=13 & ls_code<=15  // Horses, Mules, Donkeys
replace ls_type=6 if ls_code==16                // Bees

* 8.3 Livestock breeding, health, shelter, water, and feed
merge m:1 household_id ls_type holder_id using "${rawdata}\PP\sect8_3_ls_w5"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,376
        from master                     3,376  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            28,400  (_merge==3)
    -----------------------------------------
*/

drop _merge

*8.4 Milk and egg production, animal power, and dung
merge 1:1 household_id ls_code holder_id using "${rawdata}\PP\sect8_4_ls_w5"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         3,376
        from master                     3,376  (_merge==1)
        from using                          0  (_merge==2)

    Matched                            28,400  (_merge==3)
    -----------------------------------------
*/


drop _merge



* Dummy for hh owning at least 1 livestock type (large ruminant, small ruminant or poultry)
generate hh_livx=0
replace hh_livx=1 if (ls_type==1 | ls_type==2 | ls_type==4) & ls_s8_1q01>0 & ls_s8_1q01!=.
egen hh_liv=max(hh_livx), by(household_id)
drop hh_livx


generate largerum_x=0
replace largerum_x=1 if ls_type==1  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen largerum_d=max(largerum_x), by(household_id)
drop largerum_x

generate smallrum_x=0
replace smallrum_x=1 if ls_type==2  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen smallrum_d=max(smallrum_x), by(household_id)
drop smallrum_x

generate poultry_x=0
replace poultry_x=1 if ls_type==4  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen poultry_d=max(poultry_x), by(household_id)
drop poultry_x

* Total no. of ... per household: KEEP vs. OWN

* Large ruminants
generate ls_s8_1q02bis=ls_s8_1q01-ls_s8_1q02

egen largerum_nbhh_k= sum(ls_s8_1q01) if ls_type==1, by(household_id) // livestock kept +owned

egen largerum_nbhh_o= sum(ls_s8_1q02bis) if ls_type==1 & ls_s8_1q01>0, by(household_id) // livestock owned

egen largerum_cross=sum(ls_s8_1q03) if ls_type==1 & ls_s8_1q01>0, by(household_id) // crossbred animals

* egen largerum_eartag=sum(eartag) if ls_type==1 & ls_s8_1q01>0, by(household_id)
// Ear tag question only delivered to seven households and only available for
// large ruminants

* Small ruminants
egen smallrum_nbhh_k= sum(ls_s8_1q01) if ls_type==2, by(household_id) // livestock kept

egen smallrum_nbhh_o= sum(ls_s8_1q02bis) if ls_type==2 & ls_s8_1q01>0, by(household_id) // livestock owned

egen smallrum_cross=sum(ls_s8_1q03) if ls_type==2 & ls_s8_1q01>0, by(household_id) // crossbred animals

* Poultry
egen poultry_nbhh_k= sum(ls_s8_1q01) if ls_type==4, by(household_id) // livestock holded/owned

egen poultry_nbhh_o= sum(ls_s8_1q02bis) if ls_type==4, by(household_id) // livestock holded/owned

egen poultry_cross=sum(ls_s8_1q03) if ls_type==4 & ls_s8_1q01>0, by(household_id) // crossbred animals


*Sheep 
egen sheep_nbhh_o= sum(ls_s8_1q02bis) if ls_code==8 & ls_s8_1q01>0, by(household_id) // livestock owned

*Goats
egen goat_nbhh_o= sum(ls_s8_1q02bis) if ls_code==7 & ls_s8_1q01>0, by(household_id) // livestock owned

*Horses
egen horse_nbhh_o= sum(ls_s8_1q02bis) if ls_code==13 & ls_s8_1q01>0, by(household_id) // livestock owned

*Donkeys
egen donkey_nbhh_o= sum(ls_s8_1q02bis) if (ls_code==15 | ls_code==14) &  ls_s8_1q01>0, by(household_id) // livestock owned

gen cfcattle   = 0.6
gen cfsheep    = 0.1
gen cfgoats    = 0.1
gen cfchicken  = 0.01
gen cfhorses   = 0.65
gen cfyaks     = 0.7
gen cfdonkeys  = 0.5




* Max number of crossbred animals
foreach i in largerum smallrum poultry {
    egen `i'_crossm=max(`i'_cross), by(household_id)
}

* Nb. of animals owned, kept, and crossbred
foreach i in largerum smallrum poultry {

    replace `i'_nbhh_k=0   if `i'_nbhh_k==.  &  hh_liv!=.
    replace `i'_nbhh_o=0   if `i'_nbhh_o==.  &  hh_liv!=.
    replace `i'_crossm=0   if `i'_cross==.   &  `i'_d==1
    replace `i'_cross=`i'_crossm 
    drop `i'_crossm

}

* Dummy for owning at least 1 crossbred animal per hh
generate hhd_cross=.
replace hhd_cross=0 if hh_liv==1 
replace hhd_cross=1 if (largerum_cross>0 & largerum_cross!=.) | (smallrum_cross>0 & smallrum_cross!=.) | (poultry_cross>0 & poultry_cross!=.)

foreach i in largerum smallrum poultry {
    generate hhd_cross_`i'=. if hh_liv==0
    replace hhd_cross_`i'=0 if hh_liv==1 
    replace hhd_cross_`i'=1 if hh_liv==1 & `i'_cross>0 & `i'_cross!=.
}

* Shares of livestock per HH 
foreach i in largerum smallrum poultry {

    * Share of crossbred per hh HOLDED/OWNED
    generate sh_hh_`i'_k=(`i'_cross/`i'_nbhh_k)*100 // household level
    replace sh_hh_`i'_k=0 if `i'_cross==0 & `i'_nbhh_k==0 & hh_liv==1

    generate sh_hh_`i'_o=(`i'_cross/`i'_nbhh_o)*100 // household level
    replace sh_hh_`i'_o=0 if `i'_cross==0 & `i'_nbhh_o==0 & hh_liv==1

}

* Dummy for artificial insemination by hh
generate livIA=.
replace livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q02!=6 | ls_s8_3q01==2) & hh_liv==1
replace livIA=1 if ls_s8_3q02==5 | ls_s8_3q02==6
lab var livIA "Livestock AI - both public & private"

generate livIA_publ=.
replace livIA_publ=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) & hh_liv==1
replace livIA_publ=1 if ls_s8_3q02==5 
lab var livIA_publ "Livestock AI - public"

generate livIA_priv=.
replace livIA_priv=0 if (ls_s8_3q02!=6 | ls_s8_3q01==2) & hh_liv==1
replace livIA_priv=1 if ls_s8_3q02==6
lab var livIA_priv "Livestock AI - private"


egen hhd_livIA=max(livIA), by(household_id)
egen hhd_livIA_publ=max(livIA_publ), by(household_id)
egen hhd_livIA_priv=max(livIA_priv), by(household_id)


* Dummy artificial insemination by livestock type
generate lr_livIA=.
replace lr_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q02!=6 | ls_s8_3q01==2) &     ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=. //large ruminants
replace lr_livIA=1 if  ls_s8_3q02==5               &     ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=. //large ruminants

generate sr_livIA=.
replace sr_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q02!=6 | ls_s8_3q01==2) &     ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=. //smallruminants
replace sr_livIA=1 if  ls_s8_3q02==5               &     ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=. //smallruminants

generate po_livIA=.
replace po_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q02!=6 | ls_s8_3q01==2) &    ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=. //poultry
replace po_livIA=1 if  ls_s8_3q02==5               &    ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=. //poultry


* Feed and forages

// Agro-industry
generate agroind=.
replace agroind=0 if ls_s8_3q17_1!=1 & hh_liv==1
replace agroind=1 if ls_s8_3q17_1==1

// Cowpea
generate cowpea=.
replace cowpea=0 if ls_s8_3q17_2!=1 & hh_liv==1
replace cowpea=1 if ls_s8_3q17_2==1

// Elephant grass
generate elepgrass=.
replace elepgrass=0 if ls_s8_3q17_3!=1 & hh_liv==1
replace elepgrass=1 if ls_s8_3q17_3==1

// Desho grass
generate deshograss=.
replace deshograss=0 if ls_s8_3q17_4!=1 & hh_liv==1
replace deshograss=1 if ls_s8_3q17_4==1

// Sesbaniya
generate sesbaniya=.
replace sesbaniya=0 if ls_s8_3q17_5!=1 & hh_liv==1
replace sesbaniya=1 if ls_s8_3q17_5==1

// Sinar
generate sinar=.
replace sinar=0 if ls_s8_3q17_6!=1 & hh_liv==1
replace sinar=1 if ls_s8_3q17_6==1

// Lablab
generate lablab=.
replace lablab=0 if ls_s8_3q17_7!=1 & hh_liv==1
replace lablab=1 if ls_s8_3q17_7==1

// Alfalfa
generate alfalfa=.
replace alfalfa=0 if ls_s8_3q17_8!=1 & hh_liv==1
replace alfalfa=1 if ls_s8_3q17_8==1

// Vetch
generate vetch=.
replace vetch=0 if ls_s8_3q17_9!=1 & hh_liv==1
replace vetch=1 if ls_s8_3q17_9==1

// Rhodes grass
generate rhodesgrass=.
replace rhodesgrass=0 if ls_s8_3q17_10!=1 & hh_liv==1
replace rhodesgrass=1 if ls_s8_3q17_10==1

// Grass: Elephant, Desho, Sesbaniya, Sinar, Lablab, Alfalfa, Vetch, Rhodes
generate grass=.
replace grass=0 if elepgrass==0 & deshograss==0 & sesbaniya==0 & sinar==0 & lablab==0 & alfalfa==0 & vetch==0 & rhodesgrass==0
replace grass=1 if elepgrass==1 | deshograss==1 | sesbaniya==1 | sinar==1 | lablab==1 | alfalfa==1 | vetch==1 | rhodesgrass==1


foreach i in agroind cowpea elepgrass deshograss sesbaniya sinar lablab alfalfa vetch rhodesgrass grass {
    *Dummy for hh 
    egen hhd_`i'=max(`i'), by(household_id)

    *Dummy by livestock type
    generate lr_`i'=`i' if ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=.   //large ruminants
    generate sr_`i'=`i' if ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=.   //small ruminants
    generate po_`i'=`i' if ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=.   //poultry
}   



*Plot level - Animal agriculture
save "${data}\ess5_pp_livestock_plot_new", replace


* Collapse at the hh-level
#delimit ;
collapse (max) hh_liv largerum_nbhh* largerum_cross smallrum_nbhh* smallrum_cross 
sh*  lr* sr* po* hhd*  goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep 
cfgoats cfchicken cfhorses cfyaks cfdonkeys, by(household_id)
;
#delimit cr

gen TLU_cattle = largerum_nbhh_o*cfcattle   
gen TLU_horses = horse_nbhh_o*cfhorses  
gen TLU_donkeys= donkey_nbhh_o*cfdonkeys

gen TLU_chicken= poultry_nbhh_o*cfchicken
gen TLU_goats  = goat_nbhh_o*cfgoats    
gen TLU_sheep  = sheep_nbhh_o*cfsheep   

egen TLU_total = rsum(TLU_*)

lab var TLU_total "Total Livestock owned by the household (TLU)"

drop goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken ///
cfhorses cfyaks cfdonkeys TLU_cattle TLU_horses TLU_donkeys TLU_chicken TLU_goats TLU_sheep

lab var hhd_cross			  "At least 1 crossbred animal in hh"
lab var hhd_cross_largerum    "Crossbred large ruminants"
lab var largerum_cross        "Large ruminants"
lab var largerum_nbhh_k       "No. of LARGE RUMINANTS per hh - kept"
lab var largerum_nbhh_o       "No. of LARGE RUMINANTS per hh - owned"
lab var hhd_cross_smallrum	  "Crossbred small ruminants"
lab var smallrum_cross        "Small ruminants" 
lab var smallrum_nbhh_k       "No. of SMALL RUMINANTS per hh - kept"
lab var smallrum_nbhh_o       "No. of SMALL RUMINANTS per hh - owned"
lab var hhd_cross_poultry	  "Crossbred poultry"
lab var poultry_cross         "Poultry"
lab var poultry_nbhh_k        "No. of POULTRY per hh - kept"
lab var poultry_nbhh_o        "No. of POULTRY per hh - owned"

lab var hhd_livIA             "AI on any livestock type - both public & private"
lab var hhd_livIA_publ        "AI on any livestock type - public"
lab var hhd_livIA_priv        "AI on any livestock type - private"

lab var lr_livIA              "Large ruminants: AI"
lab var sr_livIA              "Small ruminants: AI"
lab var po_livIA              "Poultry: AI"

lab var sh_hh_largerum_k "Large ruminants - kept" 
lab var sh_hh_largerum_o "Large ruminants - owned" 
lab var sh_hh_smallrum_k "Small ruminants - kept"
lab var sh_hh_smallrum_o "Small ruminants - owned"
lab var sh_hh_poultry_k  "Poultry - kept"
lab var sh_hh_poultry_o  "Poultry - owned"

lab var hhd_cross_largerum "Crossbred LARGE RUMINANTS"
lab var hhd_cross_smallrum "Crossbred SMALL RUMINANTS"
lab var hhd_cross_poultry  "Crossbred POULTRY"

lab var hhd_agroind          "Feed and Forage: Agro-industry"
lab var hhd_cowpea           "Feed and Forage: Cowpea"
lab var hhd_elepgrass        "Feed and Forage: Elephant Grass"
lab var hhd_deshograss       "Feed and Forage: Desho Grass"
lab var hhd_sesbaniya        "Feed and Forage: Sesbania"
lab var hhd_sinar            "Feed and Forage: Sinar"
lab var hhd_lablab           "Feed and Forage: Lablab" 
lab var hhd_alfalfa          "Feed and Forage: Alfalfa"
lab var hhd_vetch            "Feed and Forage: Vetch"
lab var hhd_rhodesgrass      "Feed and Forage: Rhodes Grass"
lab var hhd_grass            "Grass: Elephant, Desho, Sesbaniya, Sinar, Lablab, Alfalfa, Vetch, & Rhodes"

lab var lr_agroind           "Large ruminants: Agro-industry"
lab var lr_cowpea            "Large ruminants: Cowpea" 
lab var lr_elepgrass         "Large ruminants: Elephant Grass" 
lab var lr_deshograss        "Large ruminants: Desho Grass" 
lab var lr_sesbaniya         "Large ruminants: Sesbania"  
lab var lr_sinar             "Large ruminants: Sinar" 
lab var lr_lablab            "Large ruminants: Lablab"  
lab var lr_alfalfa           "Large ruminants: Alfalfa" 
lab var lr_vetch             "Large ruminants: Vetch" 
lab var lr_rhodesgrass       "Large ruminants: Rhodes Grass" 

lab var sr_agroind           "Small ruminants: Agro-industry"
lab var sr_cowpea            "Small ruminants: Cowpea"
lab var sr_elepgrass         "Small ruminants: Elephant Grass"
lab var sr_deshograss        "Small ruminants: Desho Grass"
lab var sr_sesbaniya         "Small ruminants: Sesbania"  
lab var sr_sinar             "Small ruminants: Sinar"
lab var sr_lablab            "Small ruminants: Lablab"
lab var sr_alfalfa           "Small ruminants: Alfalfa"
lab var sr_vetch             "Small ruminants: Vetch"
lab var sr_rhodesgrass       "Small ruminants: Rhodes Grass"

lab var po_agroind           "Poultry: Agro-industry"
lab var po_cowpea            "Poultry: Cowpea"
lab var po_elepgrass         "Poultry: Elephant Grass"
lab var po_deshograss        "Poultry: Desho Grass"
lab var po_sesbaniya         "Poultry: Sesbania"  
lab var po_sinar             "Poultry: Sinar"
lab var po_lablab            "Poultry: Lablab"
lab var po_alfalfa           "Poultry: Alfalfa"
lab var po_vetch             "Poultry: Vetch"
lab var po_rhodesgrass       "Poultry: Rhodes Grass"


save "${tmp}\PP_W4S81", replace

* Cross bred animals: by eartag
* Better information from self-reporting
* Public vs. private farm AI