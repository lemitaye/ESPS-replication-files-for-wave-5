********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Urban livestock 
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com)
* STATA Version: MP 17.0
********************************************************************************

* read data --------------------------------------------------------------------
use "${rawdata}/HH/URBAN_AGG_LIVESTOCK_RURAL_hh_w5.dta", clear

* livestok types ---------------------------------------------------------------
generate ls_type=1 if Livestock_code>=1 & Livestock_code<=6   // large ruminants (Bulls, Oxen, Cows, Steers, Heifers, and Calves)
replace ls_type=2 if Livestock_code==7 | Livestock_code==8    // small ruminants (Goats and Sheep)
replace ls_type=3 if Livestock_code==9                 // Camels
replace ls_type=4 if Livestock_code>=10 & Livestock_code<=12  // Poultry (Chicken and Chicks)
replace ls_type=5 if Livestock_code>=13 & Livestock_code<=15  // Horses, Mules, Donkeys
replace ls_type=6 if Livestock_code==16                // Bees

#delimit ;
label define ls_type 
    1 "1. Large ruminants (Bulls, Oxen, Cows, Steers, Heifers, and Calves)" 
    2 "2. Small ruminants (Goats and Sheep)" 
    3 "3. Camels" 
    4 "4. Poultry (Chicken and Chicks)" 
    5 "5. Horses, Mules, Donkeys" 
    6 "6. Bees"
;
#delimit cr

label values ls_type ls_type

label variable ls_type "Livestok type"


* Dummy for hh owning at least 1 livestock type (large ruminant, small ruminant or poultry)
generate hh_liv=0
replace hh_liv=1 if (ls_type==1 | ls_type==2 | ls_type==4) & s12dq02>0 & s12dq02!=.

generate largerum_d=0
replace largerum_d=1 if ls_type==1  & s12dq02>0 & s12dq02!=.

generate smallrum_d=0
replace smallrum_d=1 if ls_type==2  & s12dq02>0 & s12dq02!=.

generate poultry_d=0
replace poultry_d=1 if ls_type==4  & s12dq02>0 & s12dq02!=.

* Total no. of ... owned per household -----------------------------------------
egen largerum_nbhh_o= sum(s12dq02) if ls_type==1, by(household_id) // large ruminants owned
egen smallrum_nbhh_o= sum(s12dq02) if ls_type==2, by(household_id) // small ruminants owned
egen poultry_nbhh_o= sum(s12dq02) if ls_type==4, by(household_id) // poultry owned

* Other livestock owned --------------------------------------------------------

// Sheep 
egen sheep_nbhh_o= sum(s12dq02) if Livestock_code==8, by(household_id) 
// Goats
egen goat_nbhh_o= sum(s12dq02) if Livestock_code==7, by(household_id) 
// Horses
egen horse_nbhh_o= sum(s12dq02) if Livestock_code==13, by(household_id) 
// Mules and Donkeys
egen donkey_nbhh_o= sum(s12dq02) if (Livestock_code==14 | Livestock_code==15), by(household_id) 

gen cfcattle   = 0.6
gen cfsheep    = 0.1
gen cfgoats    = 0.1
gen cfchicken  = 0.01
gen cfhorses   = 0.65
gen cfyaks     = 0.7
gen cfdonkeys  = 0.5


* Number of cross-breed in each household --------------------------------------
egen largerum_cross=sum(s12dq03) if ls_type==1 & s12dq02>0, by(household_id) // crossbred large ruminants
egen smallrum_cross=sum(s12dq03) if ls_type==2 & s12dq02>0, by(household_id) // crossbred small ruminants
egen poultry_cross=sum(s12dq03) if ls_type==4 & s12dq02>0, by(household_id) // crossbred poultry

/*
* Max number of crossbred animals  (why is this needed?) -----------------------
foreach i in largerum smallrum poultry {
    egen `i'_crossm=max(`i'_cross), by(household_id)
}
*/

* Nb. of animals owned and crossbred -------------------------------------------
foreach i in largerum smallrum poultry {
    replace `i'_nbhh_o=0   if `i'_nbhh_o==.  &  hh_liv!=.
*    replace `i'_crossm=0   if `i'_cross==.   &  `i'_d==1
*    replace `i'_cross=`i'_crossm 
*    drop `i'_crossm
}

* Dummy for owning at least 1 crossbred animal per hh --------------------------
generate hhd_cross=.
replace hhd_cross=0 if hh_liv==1 
replace hhd_cross=1 if (largerum_cross>0 & largerum_cross!=.) | ///
    (smallrum_cross>0 & smallrum_cross!=.) | (poultry_cross>0 & poultry_cross!=.)

foreach i in largerum smallrum poultry {
    generate hhd_cross_`i'=. if hh_liv==0
    replace hhd_cross_`i'=0 if hh_liv==1 
    replace hhd_cross_`i'=1 if hh_liv==1 & `i'_cross>0 & `i'_cross!=.
}

* Shares of livestock per HH ---------------------------------------------------
foreach i in largerum smallrum poultry {

    * Share of crossbred per hh HOLDED/OWNED
    generate sh_hh_`i'_o=(`i'_cross/`i'_nbhh_o)*100 // household level
    replace sh_hh_`i'_o=0 if `i'_cross==0 & `i'_nbhh_o==0 & hh_liv==1

}

* save -------------------------------------------------------------------------
save "${tmp}/01_2_ess5_hh_livestock.dta", replace


* Collapse at the hh-level -----------------------------------------------------
#delimit ;
collapse (firstnm) ea_id pw_w5 saq01 
         (max) largerum_nbhh_o largerum_cross smallrum_nbhh_o smallrum_cross 
            poultry_nbhh_o poultry_cross hhd* sh_hh_* sheep_nbhh_o goat_nbhh_o horse_nbhh_o 
            donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken cfhorses cfyaks cfdonkeys, 
            by(household_id)
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

drop sheep_nbhh_o goat_nbhh_o horse_nbhh_o donkey_nbhh_o cfcattle cfsheep cfgoats cfchicken ///
cfhorses cfyaks cfdonkeys TLU_cattle TLU_horses TLU_donkeys TLU_chicken TLU_goats TLU_sheep

label var ea_id "Unique Enumeration Area Identifier"
label var pw_w5 "household sample weight"
label var saq01 "Region code"

label values saq01 saq01

lab var hhd_cross			  "At least 1 crossbred animal in hh"
lab var hhd_cross_largerum    "Crossbred large ruminants"
lab var largerum_cross        "Large ruminants"
lab var largerum_nbhh_o       "No. of LARGE RUMINANTS per hh - owned"
lab var hhd_cross_smallrum	  "Crossbred small ruminants"
lab var smallrum_cross        "Small ruminants" 
lab var smallrum_nbhh_o       "No. of SMALL RUMINANTS per hh - owned"
lab var hhd_cross_poultry	  "Crossbred poultry"
lab var poultry_cross         "Poultry"
lab var poultry_nbhh_o        "No. of POULTRY per hh - owned"

lab var sh_hh_largerum_o      "Share of large ruminants - owned" 
lab var sh_hh_smallrum_o      "Share of small ruminants - owned"
lab var sh_hh_poultry_o       "Share of poultry - owned"

lab var hhd_cross_largerum    "Crossbred LARGE RUMINANTS"
lab var hhd_cross_smallrum    "Crossbred SMALL RUMINANTS"
lab var hhd_cross_poultry     "Crossbred POULTRY"


* save - hh level --------------------------------------------------------------
save "${data}/01_2_hh_livestock.dta", replace
