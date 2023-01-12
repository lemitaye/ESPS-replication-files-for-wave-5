

********************************************************************************
*** LS - Sec.8_1 - Crossbred animals
********************************************************************************

use "${rawdata}\PP\sect8_1_ls_w5", clear


generate ls_type=1 if ls_code>=1 & ls_code<=6
replace ls_type=2 if ls_code==7 | ls_code==8
replace ls_type=3 if ls_code==9
replace ls_type=4 if ls_code>=10 & ls_code<=12
replace ls_type=5 if ls_code>=13 & ls_code<=15
replace ls_type=6 if ls_code==16

* 8.3 Livestock breeding, health, shelter, water, and feed
merge m:1 household_id ls_type holder_id using "${rawdata}\PP\sect8_3_ls_w5"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            10,650  (_merge==3)
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
g       hh_livx=0
replace hh_livx=1 if (ls_type==1 | ls_type==2 | ls_type==4) & ls_s8_1q01>0 & ls_s8_1q01!=.
egen hh_liv=max(hh_livx), by(household_id)
drop hh_livx




g largerum_x=0
replace largerum_x=1 if ls_type==1  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen largerum_d=max(largerum_x), by(household_id)
drop largerum_x

g smallrum_x=0
replace smallrum_x=1 if ls_type==2  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen smallrum_d=max(smallrum_x), by(household_id)
drop smallrum_x

g poultry_x=0
replace poultry_x=1 if ls_type==4  & ls_s8_1q01>0 & ls_s8_1q01!=.
egen poultry_d=max(poultry_x), by(household_id)
drop poultry_x




* Total no. of ... per household: KEEP vs. OWN

* Large ruminants
g ls_s8_1q02bis=ls_s8_1q01-ls_s8_1q02

egen largerum_nbhh_k= sum(ls_s8_1q01) if ls_type==1, by(household_id) // livestock kept +owned

egen largerum_nbhh_o= sum(ls_s8_1q02bis) if ls_type==1 & ls_s8_1q01>0, by(household_id) // livestock owned


egen largerum_cross=sum(ls_s8_1q03) if ls_type==1 & ls_s8_1q01>0, by(household_id) // crossbred animals

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
*donkeys
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
replace hhd_cross=1 if             (largerum_cross>0 & largerum_cross!=.) | (smallrum_cross>0 & smallrum_cross!=.) | (poultry_cross>0 & poultry_cross!=.)

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
replace livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) & hh_liv==1
replace livIA=1 if ls_s8_3q02==5
lab var livIA "Livestock AI"


egen hhd_livIA=max(livIA), by(household_id)



* Dummy artificial insemination by livestock type
generate lr_livIA=.
replace lr_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) &     ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=. //large ruminants
replace lr_livIA=1 if  ls_s8_3q02==5               &     ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=. //large ruminants

generate sr_livIA=.
replace sr_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) &     ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=. //smallruminants
replace sr_livIA=1 if  ls_s8_3q02==5               &     ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=. //smallruminants

generate po_livIA=.
replace po_livIA=0 if (ls_s8_3q02!=5 | ls_s8_3q01==2) &    ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=. //poultry
replace po_livIA=1 if  ls_s8_3q02==5               &    ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=. //poultry


* Feed and forages

generate elepgrass=.
replace elepgrass=0 if (ls_s8_3q16==2 | ls_s8_3q17!=1) & hh_liv==1
replace elepgrass=1 if ls_s8_3q17==1


generate gaya=.
replace gaya=0 if (ls_s8_3q16==2 | ls_s8_3q17!=2) & hh_liv==1
replace gaya=1 if ls_s8_3q17==2

generate sasbaniya=.
replace sasbaniya=0 if (ls_s8_3q16==2 | ls_s8_3q17!=3) & hh_liv==1
replace sasbaniya=1 if ls_s8_3q17==3


generate alfa=.
replace alfa=0 if (ls_s8_3q16==2 | ls_s8_3q17!=6) & hh_liv==1
replace alfa=1 if ls_s8_3q17==6


generate indprod      =.
replace indprod=0 if (ls_s8_3q16==2 | ls_s8_3q17!=6) & hh_liv==1
replace indprod=1 if ls_s8_3q17==7

generate grass=.
replace grass=0   if (ls_s8_3q16==2 | ls_s8_3q17!=3) & hh_liv==1
replace grass=1 if elepgrass==1 | gaya==1 | sasbaniya==1 | alfa==1

foreach i in  elepgrass gaya sasbaniya alfa indprod grass {
*Dummy for hh 
egen hhd_`i'=max(`i'), by(household_id)

*Dummy by livestock type
    generate lr_`i'=`i' if ls_type==1 & ls_s8_1q01>0 & ls_s8_1q01!=.   //large ruminants
    generate sr_`i'=`i' if ls_type==2 & ls_s8_1q01>0 & ls_s8_1q01!=.   //small ruminants
    generate po_`i'=`i' if ls_type==4 & ls_s8_1q01>0 & ls_s8_1q01!=.   //poultry
}   



*Plot level - Animal agriculture
preserve 
save "${data}\ess5_pp_livestock_plot_new", replace
restore

* Collapse at the hh-level
collapse (max) hh_liv largerum_nbhh* largerum_cross smallrum_nbhh* smallrum_cross sh*  lr* sr* po* hhd*  goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken cfhorses cfyaks cfdonkeys, by(household_id)

gen TLU_cattle = largerum_nbhh_o*cfcattle   
gen TLU_horses = horse_nbhh_o*cfhorses  
gen TLU_donkeys= donkey_nbhh_o*cfdonkeys

gen TLU_chicken= poultry_nbhh_o*cfchicken
gen TLU_goats  = goat_nbhh_o*cfgoats    
gen TLU_sheep  = sheep_nbhh_o*cfsheep   

egen TLU_total = rsum(TLU_*)

lab var TLU_total "Total Livestock owned by the household (TLU)"

drop goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken cfhorses cfyaks cfdonkeys TLU_cattle TLU_horses TLU_donkeys TLU_chicken TLU_goats TLU_sheep

lab var hhd_cross			  "At least 1 crossbred animal in hh"
lab var hhd_cross_largerum    "Crossbred large ruminants"
lab var largerum_cross        "Large ruminants"
lab var largerum_nbhh_k       "No. of LARGE RUMINANTS per hh - kept"
lab var largerum_nbhh_o       "No. of LARGE RUMINANTS per hh - owned"
lab var hhd_cross_smallrum	 "Crossbred small ruminants"
lab var smallrum_cross        "Small ruminants" 
lab var smallrum_nbhh_k       "No. of SMALL RUMINANTS per hh - kept"
lab var smallrum_nbhh_o       "No. of SMALL RUMINANTS per hh - owned"
lab var hhd_cross_poultry	  "Crossbred poultry"
lab var poultry_cross         "Poultry"
lab var poultry_nbhh_k        "No. of POULTRY per hh - kept"
lab var poultry_nbhh_o        "No. of POULTRY per hh - owned"

lab var hhd_livIA             "AI on any livestock type"
lab var lr_livIA              "Large ruminants: AI"
lab var sr_livIA              "Small ruminants: AI"
lab var po_livIA              "Poultry: AI"

lab var hhd_elepgrass        "Feed and Forage: Elephant Grass"
lab var hhd_gaya             "Feed and Forage: Gaya"
lab var hhd_sasbaniya        "Feed and Forage: Sasbaniya"
lab var hhd_alfa             "Feed and Forage: Alfalfa"
lab var hhd_indprod			 "Feed and Forage: Industry by-products"
lab var hhd_grass            "Elephant grass, gaya, sasbaniya, alfalfa"

lab var lr_elepgrass         "Large ruminants: Elephant Grass"
lab var lr_gaya              "Large ruminants: Gaya"
lab var lr_sasbaniya         "Large ruminants: Sasbaniya"
lab var lr_alfa              "Large ruminants: Alfalfa"
lab var lr_indprod			 "Large ruminants: Industry by-products"

lab var sr_elepgrass         "Small ruminants: Elephant Grass"
lab var sr_gaya              "Small ruminants: Gaya"
lab var sr_sasbaniya         "Small ruminants: Sasbaniya"
lab var sr_alfa              "Small ruminants: Alfalfa"
lab var sr_indprod			 "Small ruminants: Industry by-products"

lab var po_elepgrass         "Poultry: Elephant Grass"
lab var po_gaya              "Poultry: Gaya"
lab var po_sasbaniya         "Poultry: Sasbaniya"
lab var po_alfa              "Poultry: Alfalfa"
lab var po_indprod			 "Poultry: Industry by-products"

tempfile PP_W4S81
save `PP_W4S81'

* Cross bred animals: by eartag
* Better information from self-reporting