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

* Dummy for owning at least 1 crossbred animal per hh
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
save "${data}/01_2_ess5_livestock_hh.dta", replace