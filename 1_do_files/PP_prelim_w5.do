
/*

Created on: November 24, 2022
Author: Lemi Taye Daba (tayelemi@gmail.com)
Purpose: Preliminary analysis of the LSMS-ESS5 data

*/

clear all

* to be added to master later
global root     "C:\Users\tayel\Dropbox\Documents\SPIA\Ethiopia\LSMS_W5"
global rawdata  "$root\2_raw_data\data"
global data     "$root\3_report_data"

********************************************************************************
* PP - COVER 
******************************************************************************** 

use "${rawdata}\PP\sect_cover_pp_w5", clear

count //2,110
* tostring saq12, force replace   // What is the reason for converting hh_size (saq12) to string
* destring saq16, force replace

tab saq14      // PP moduls is available only for rural households.
/*

        14. |
  Location: |
     rural, |
town, small |
       town |      Freq.     Percent        Cum.
------------+-----------------------------------
   1. RURAL |      2,110      100.00      100.00
------------+-----------------------------------
      Total |      2,110      100.00

*/

tab saq01  // The entire region of Tigray is missing
/*
         Region code |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             2. AFAR |         85        4.03        4.03
           3. AMHARA |        302       14.31       18.34
           4. OROMIA |        413       19.57       37.91
           5. SOMALI |        261       12.37       50.28
6. BENISHANGUL GUMUZ |        109        5.17       55.45
             7. SNNP |        434       20.57       76.02
         12. GAMBELA |        178        8.44       84.45
           13. HARAR |        185        8.77       93.22
       15. DIRE DAWA |        143        6.78      100.00
---------------------+-----------------------------------
               Total |      2,110      100.00
*/  

isid holder_id   // holder_id is a uniuqe ID 

* # of households per EA from PP cover
egen hh_ea = count(household_id), by(ea_id)
lab var hh_ea "Number of households per EA"

duplicates drop household_id ea_id saq01 saq02 saq03 saq04 saq05 saq06 saq07 /// 
                saq08, force

tempfile w5_coverPP
save `w5_coverPP'

save "${data}\w5_coverPP_new", replace

********************************************************************************
* PP - SECT. 1: HOUSEHOLD ROSTER
********************************************************************************

use "${rawdata}\PP\sect1_pp_w5", clear

* NOTHING TO RECOVER

********************************************************************************
* PP - SECT. 2:  PARCEL ROSTER
********************************************************************************

use "${rawdata}\PP\sect2_pp_w5", clear


** Parcel title:
preserve
    generate title = (s2q03  ==  1)   // s2q03: Does your household have a document for this [PARCEL]?

    *Reshape for parcel title hh member listed
    reshape long s2q04b_, i(holder_id household_id parcel_id) j(membernb)
    // s2q04b_: Which HH members are listed as owners or use rights holders

    drop if s2q04b_  ==  .a & title  ==  1   // removes hh members who are not owners of parcels
    rename  s2q04b_ s1q00         // s1q00 is Individual ID in the hh roster (sect1_pp_w4)

    * Individual characteristics
    merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5"  // merge with hh roster

    keep if _merge  ==  3
    drop _merge

    generate fow = 1 if s1q03  ==  2    // fow is dummy for female owner
    bysort household_id holder_id parcel_id: egen fowner = max(fow) if title  ==  1  // dummy for at least 1 female owner in hh
    replace fowner = 0 if fowner  ==  . & s1q03  ==  1  
    drop fow

    rename s1q00  s2q04b_
    drop s1*
    collapse (max) fowner title saq15, by(household_id holder_id parcel_id)  // saq15: holder's farm type (crop, lvstk, etc.)
    label var fowner "At lest 1 female hh-member listed as owner in parcel title"
    label var title "HH has title for the parcel"
    tempfile fowner
    save  `fowner'
restore


** Right to sell parcel:
preserve
    reshape long s2q07_, i(holder_id household_id parcel_id) j(membernb) 
    // s2q07_: Who in this household can decide whether to sell [PARCEL]?

    drop if s2q07_  ==  .a & s2q06  ==  1
    // s2q06: Does anyone in HH have the right to sell [PARCEL] or use as collateral?
    rename  s2q07_ s1q00
    merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5"
    keep if _m  ==  3
    drop _merge

    generate fow = 1 if s1q03  ==  2
    bysort household_id holder_id parcel_id: egen frsell=max(fow) if s2q06= = 1
    replace frsell = 0 if frsell= = . & s1q03= = 1
    drop fow
    rename s1q00  s2q07_
    drop s1*
    drop membernb

    collapse (max) frsell saq15, by(household_id holder_id parcel_id)
    lab var frsell "At lest 1 female hh-member has the right to sell the parcel"
    tempfile frsell 
    save `frsell'
restore


** Acquiring parcel:

/* tab varname, gen(newvar) // generates dummy for each entry */

tab s2q05, gen(acqparc)  // s2q05: How did your household acquire [PARCEL]?
lab var acqparc1 "Parcel granted by local leaders"
lab var acqparc2 "Parcel acquired as gift/inherited"
lab var acqparc3 "Parcel rented"
lab var acqparc6 "Parcel shared crop"
lab var acqparc7 "Parcel purchased"

generate acqparcoth = 0
replace acqparcoth = 1 if acqparc4  ==  1 | acqparc5  ==  1 | acqparc8  ==  1
lab var acqparcoth "Parcel acquired through: other means"

tab s2q17, gen(soilq)  // s2q17: What is the soil quality of this [PARCEL]?
lab var soilq1 "Soil quality: Good"
lab var soilq2 "Soil quality: Fair"
lab var soilq3 "Soil quality: Poor"

tab s2q16, gen(soilt)  // s2q16: What is the predominant soil type of [PARCEL]?
lab var soilt1 "Soil type: Leptosol"
lab var soilt2 "Soil type: Cambisol"
lab var soilt3 "Soil type: Vertisol"
lab var soilt4 "Soil type: Luvisol"
lab var soilt5 "Soil type: Mixed type"
lab var soilt6 "Soil type: other"
lab var soilt7 "Other parcel use (barn, residential, etc.)" // to be checked?

merge 1:1 household_id parcel_id holder_id using `frsell'
drop _merge
merge 1:1 household_id parcel_id holder_id using `fowner'
drop _merge

keep holder_id household_id parcel_id ea_id title fowner frsell acqparc1 ///
     acqparc2 acqparc3 acqparc4 acqparc5 acqparc6 acqparc7 acqparc8 acqparcoth /// 
     soilq1 soilq2 soilq3 soilt1 soilt2 soilt3 soilt4 soilt5 soilt6 soilt7 saq01 saq15

preserve
    collapse (max) title fowner frsell , by(household_id)
    lab var frsell "At lest 1 female hh-member has the right to sell the parcel"
    lab var fowner "At lest 1 female hh-member listed as owner in parcel title"
    lab var title "HH has title for the parcel"
    save "${data}\ess5_pp_hhlevel_parcel_new", replace
restore

save "${data}\w5_sect2_pp_parcel_new", replace


********************************************************************************
* PP - SECT. 3 - FIELD ROSTER
********************************************************************************

* The analysis in this section focuses on natural resource managment (NRM) variables

use "${rawdata}\PP\sect3_pp_w5", clear  

count // 14,878
distinct household_id  // 2,019 households

tab s3q03
/*
   3.During this season, what is |
     the status of this [FIELD]? |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                   1. Cultivated |     10,572       71.12       71.12
                      2. Pasture |        975        6.56       77.68
                       3. Fallow |        351        2.36       80.04
                       4. Forest |        392        2.64       82.68
5. Land Prepared for Belg Season |         96        0.65       83.32
               6. Home/Homestead |      1,988       13.37       96.70
               7. Other(Specify) |        491        3.30      100.00
---------------------------------+-----------------------------------
                           Total |     14,865      100.00
*/

tab s3q03b
/*
  3.During this season, what is |
    the status of this [FIELD]? |      Freq.     Percent        Cum.
--------------------------------+-----------------------------------
              1. Temporary crop |      6,286       59.46       59.46
              2. Permanent crop |      3,083       29.16       88.63
3. Temporary and permanent crop |      1,202       11.37      100.00
--------------------------------+-----------------------------------
                          Total |     10,571      100.00
*/

* Plot is irrigated:
generate plotirr = .
replace  plotirr = 1 if s3q17  ==  1  // s3q17: Is [FIELD] irrigated during the current agricultural season?


* IRRIGATION: LIMITING TO CULTIVATED PLOTS AS PER ENABLING CONDITION 

* Irrigations method available only for those using irrigation 
* (see "tab s3q17 s3q20")

* (dummy for irrigation by river/spring diversion)
generate rdisp = .
replace  rdisp = 0 if (s3q20 != . | s3q17  ==  2) & s3q03  ==  1 // not this irrigation or no irrigation at all
// s3q20: What is the method of irrigation used on [FIELD]?
replace  rdisp = 1 if s3q20  ==  1                & s3q03  ==  1 
replace  rdisp = 1 if s3q20_os  ==  "Diverting hole" | s3q20_os  ==  "Water body"  
// these have changed from ESS4; need to be checked

* (dummy for irrigation by Pressure treadle pump) 
generate treadle = . 
replace  treadle = 0 if (s3q20 != . | s3q17  ==  2) & s3q03  ==  1 // not this irrigation or no irrigation at all.
replace  treadle = 1 if  s3q20  ==  2               & s3q03  ==  1 

* (dymmy for irrigation by Motorized pump)
generate motorpump = .
replace  motorpump = 0 if (s3q20 != . | s3q17  ==  2) & s3q03  ==  1  // not this irrigation or no irrigation at all.
replace  motorpump = 1 if s3q20  ==  3                & s3q03  ==  1 

generate motorpum2 = 0
replace  motorpum2 = 1 if s3q20  ==  3


* LEGUME ROTATION (ask if plot cultivated)
generate rotlegume = .
replace  rotlegume = 0 if s3q34 != . & s3q03  ==  1
replace  rotlegume = 1 if s3q34  ==  1 & s3q03  ==  1 
// s3q34: During the last three years, have you planted a legume on this [FIELD]?


* CROP RESIDUE:  
/*
Two versions of variables: 
1. using single select question (Only if 1. Cultivated,  2. Pasture, 3. Fallow, 
   4. Forest, 5. Land Prepared for Belg Season )
2. using visual aid. (limited to cultivated plot with  1. Temporary crop || 3. Temporary and permanent crop
*/

generate cresidue1 = .
replace  cresidue1 = 0 if                           (s3q03 >= 1 &  s3q03 <= 5)
replace  cresidue1 = 1 if s3q41  ==  2 & s3q40  ==  1 & (s3q03 >= 1 &  s3q03 <= 5)
// s3q41: What did you use to maintain or | sustain fertility?

generate cresidue2 = .
replace  cresidue2 = 0 if s3q42 != . & s3q03  ==  1 & (s3q03b  ==  1 | s3q03b  ==  3)
replace  cresidue2 = 1 if s3q42 >= 3 & s3q03  ==  1 & (s3q03b  ==  1 | s3q03b  ==  3) 
// s3q42 is a visual aid question (the value labels are consistent but need to 
// be checked if they are identical)


* MINIMUM TILLAGE: cultivated plot with  1. Temporary crop || 3. Temporary and permanent crop

generate mintillage = .
replace  mintillage = 0 if  s3q03  ==  1 &  (s3q03b  ==  1 | s3q03b  ==  3) & (s3q35 >= 1 & s3q35 <= 6)
// s3q35: How was [FIELD] prepared for planting?
replace  mintillage = 1 if  (s3q36  ==  1 | s3q36  ==  2 | s3q36  ==  5) & s3q03  ==  1 &  /// 
                         (s3q03b  ==  1 | s3q03b  ==  3) & (s3q35 >= 1 & s3q35 <= 6)
// s3q36: How many times was [FIELD] tilled in this agricultural season?

generate zerotill = .
replace  zerotill = 0 if  s3q03  ==  1 &  (s3q03b  ==  1 | s3q03b  ==  3) & (s3q35 >= 1 & s3q35 <= 6)
replace  zerotill = 1 if (s3q36  ==  1 | s3q36  ==  5) & s3q03  ==  1 & /// 
                       (s3q03b  ==  1 | s3q03b  ==  3) & (s3q35 >= 1 & s3q35 <= 6)

/*
Note on change of value labels from wave 4 to wave 5
- For s3q35, value labels for 1-6 are the same, but a 9th value label has been added 
- For s3q36, the value label for 5 has changed, but seems similar
- For s3q39, value labels have changed starting from 5, but 1-4 are the same,
which is all that matters (see below)
*/

* SWC : Only if 1. Cultivated,  2. Pasture, 3. Fallow, 4. Forest, 5. Land Prepared for Belg Season 

generate swc = .
replace  swc = 0 if (s3q03 >= 1 &  s3q03 <= 5) 
replace  swc = 1 if (s3q39  ==  1 | s3q39  ==  2| s3q39  ==  3 | s3q39  ==  4) & ///
                    (s3q03 >= 1 &  s3q03 <= 5)
// s3q39: What is the common way of preventing erosion on [FIELD]?

* Terracing
generate terr = .
replace  terr = 0 if (s3q03 >= 1 & s3q03 <= 5) 
replace  terr = 1 if (s3q39  ==  1) & (s3q03 >= 1 &  s3q03 <= 5)

* Water Catchments
generate wcatch = .
replace  wcatch = 0 if (s3q03 >= 1 &  s3q03 <= 5) 
replace  wcatch = 1 if (s3q39  ==  2) & (s3q03 >= 1 &  s3q03 <= 5)

* Afforestation
generate affor = .
replace  affor = 0 if (s3q03 >= 1 &  s3q03 <= 5) 
replace  affor = 1 if (s3q39  ==  3) & (s3q03 >= 1 &  s3q03 <= 5)

* Plough Along the Contour
generate ploc = .
replace  ploc = 0 if (s3q03 >= 1 &  s3q03 <= 5) 
replace  ploc = 1 if (s3q39  ==  4) & (s3q03 >= 1 &  s3q03 <= 5)

generate swc2 = 0
replace  swc2 = 1 if (s3q39  ==  1 | s3q39  ==  2| s3q39  ==  3 | s3q39  ==  4)


* CONSERVATION AGRICULTURE - with minimum tillage

generate consag1 = .
replace  consag1 = 0 if (rotlegume != 1 | cresidue2 != 1 | mintillage != 1) & (s3q03 >= 1 &  s3q03 <= 5)
replace  consag1 = 1 if (rotlegume  ==  1 & cresidue2  ==  1 & mintillage  ==  1) & (s3q03 >= 1 &  s3q03 <= 5)


* CONSERVATION AGRICULTURE - with zero tillage

generate consag2 = .
replace  consag2 = 0 if (rotlegume != 1 | cresidue2 != 1 | zerotill != 1) & (s3q03 >= 1 &  s3q03 <= 5)
replace  consag2 = 1 if (rotlegume  ==  1 & cresidue2  ==  1 & zerotill  ==  1) & (s3q03 >= 1 &  s3q03 <= 5)


* No. of plots per HH - total
egen hh_plot_nb = count(field_id), by(household_id)
lab var hh_plot_nb "Number of plots per household"

* No. of plots per EA -total
egen ea_plot_nb = count(field_id), by(ea_id)
lab var ea_plot_nb "Number of plots per EA"

* No. of plots IRRIGATED and CULTIVATED per HH
egen hh_plot_irr_nb = count(field_id) if s3q03  ==  1 & s3q17  ==  1, by(household_id)
lab var hh_plot_irr_nb "Number of plots irrigated per household"

* No. of plots IRRIGATED and CULTIVATED per EA
egen ea_plot_irr_nb = count(field_id) if s3q03  ==  1 & s3q17  ==  1, by(ea_id)
lab var ea_plot_irr_nb "Number of plots irrigated per EA"

* No. of plots CULTIVATED per HH
egen hh_plot_cult_nb = count(field_id) if s3q03  ==  1, by(household_id)
lab var hh_plot_cult_nb "Number of plots cultivated per household"

* No. of plots CULTIVATED per EA
egen ea_plot_cult_nb = count(field_id) if s3q03  ==  1, by(ea_id)
lab var ea_plot_cult_nb "Number of plots cultivated per EA"

* No. of plots: CULTIVATED, PASTURE, FALLOW, FOREST, LAND PREPARED FOR BELG SEASON
egen hh_plot_uses_nb = count(field_id) if (s3q03 >= 1 &  s3q03 <= 5), by(household_id)
lab var hh_plot_uses_nb "Number of plots cultivated, pasture, fallow, forest etc. per household"

egen ea_plot_uses_nb = count(field_id) if (s3q03 >= 1 &  s3q03 <= 5), by(ea_id)
lab var ea_plot_uses_nb "Number of plots cultivated, pasture, fallow, forest etc. per EA"

*No. of plots WITH EROSION PREVENTION per HH (on cultivated, fallow, pasture etc.)
egen hh_plot_eros_nb = count(field_id) if (s3q03 >= 1 &  s3q03 <= 5) & s3q38  ==  1, by(household_id)
lab var hh_plot_eros_nb "Number of plots with erosion prevention structures per household"

egen ea_plot_eros_nb = count(field_id) if (s3q03 >= 1 &  s3q03 <= 5) & s3q38  ==  1, by(ea_id)
lab var ea_plot_eros_nb "Number of plots  with erosion prevention structures per EA"

*No. of plots CULTIVATED AND TEMPORARY CROP PLANTED
egen hh_plot_cplus_nb = count(field_id) if s3q03  ==  1 &  (s3q03b  ==  1 | s3q03b  ==  3), by(household_id)
lab var hh_plot_cplus_nb "Number of plots cultivated and land prep per household"

egen ea_plot_cplus_nb = count(field_id) if s3q03  ==  1 &  (s3q03b  ==  1 | s3q03b  ==  3), by(ea_id)
lab var ea_plot_cplus_nb "Number of plots cultivated and temp. crop planted per EA"

* No. of plots CULTIVATED, TEMP. CROP AND LAND PREPARATION. 

egen hh_plot_lprep_nb = count(field_id) if s3q03  ==  1 &  (s3q03b  ==  1 | s3q03b  ==  3) & (s3q35 >= 1 & s3q35 <= 6), by(household_id)
lab var hh_plot_cplus_nb "Number of plots cultivated and land prep per household"

egen ea_plot_lprep_nb = count(field_id) if s3q03  ==  1 &  (s3q03b  ==  1 | s3q03b  ==  3) & (s3q35 >= 1 & s3q35 <= 6), by(ea_id)
lab var ea_plot_cplus_nb "Number of plots cultivated and land prep per EA"


* HOUSEHOLD MEASURE :- UNCONDITIONAL
foreach i in treadle motorpump rotlegume cresidue1 cresidue2 mintillage ///
             zerotill consag1 consag2 swc swc2 terr wcatch affor ploc rdisp {

    egen hhd_`i' = max(`i'), by(household_id)   // we'll only use this for conditioning (1 if at least one plot per hh using `i')
    egen hhs_`i' = sum(`i'), by(household_id)   // total # of plots using `i' in each hh
    generate sh_plothh_`i' = (hhs_`i' / hh_plot_nb) * 100 if hhs_`i'! = . & hhd_`i'  ==  1  // share of plots using `i' in each hh

} 


* 1. Conditional on plot cultivated 
* 2. Conditional on plot irrigated & cultivated
* 3. Conditional on plot cultivated, pasture, fallow, forest etc.
* 4. Conditional on using soil erosion preventing measures & use
* 5. Cultivated and temporary crop planted
* 6. Cultivated and temporary crop and land preparation
foreach i in treadle motorpump rdisp rotlegume cresidue1 cresidue2 mintillage ///
             zerotill consag1 consag2 swc swc2 terr wcatch affor ploc {

    generate sh_plothh_`i'_cond1 = (hhs_`i' / hh_plot_cult_nb) * 100  if `i' != . & hhd_`i'  ==  1
    generate sh_plothh_`i'_cond2 = (hhs_`i' / hh_plot_irr_nb) * 100   if `i' != . & hhd_`i'  ==  1
    generate sh_plothh_`i'_cond3 = (hhs_`i' / hh_plot_uses_nb) * 100  if `i' != . & hhd_`i'  ==  1
    generate sh_plothh_`i'_cond4 = (hhs_`i' / hh_plot_eros_nb) * 100  if `i' != . & hhd_`i'  ==  1
    generate sh_plothh_`i'_cond5 = (hhs_`i' / hh_plot_cplus_nb) * 100 if `i' != . & hhd_`i'  ==  1
    generate sh_plothh_`i'_cond6 = (hhs_`i' / hh_plot_lprep_nb) * 100 if `i' != . & hhd_`i'  ==  1

} 
 

/*
* Plot size (by SR and GPS) [need to be updated using ESS4 conversion factors]

*Change names of vars.
generate zone=substr(saq02, -2, .)
generate woreda=substr(saq03, -2, .)

rename saq01 region
rename saq04 city
rename saq05 subcity
rename saq06 kebele

destring region zone woreda city subcity kebele, force replace

merge m:1 region zone woreda using "${rawdata}\Auxiliary_data\ESS3_ET_local_area_unit_conversion"

/*
Result	#	of obs.
		
not matched		12,865
from master		12,721	(_merge= = 1)
from using		144	(_merge  ==  2)

matched		6,618	(_merge  ==  3)
		
*/

drop if _m  ==  2
drop _merge

*Self reported plot area
generate plotarea_sr = .
replace plotarea_sr=s3q02a                       if s3q02b= = 1 //ha
replace plotarea_sr=s3q02a/10000                 if (s3q02b  ==  2 | s3q2b_os == "METER" | s3q2b_os == "SQUIRE METER") //sq meters
replace plotarea_sr=(s3q02a*conv_timad  )/10000  if s3q02b  ==  3 & conv_timad! = .
replace plotarea_sr=(s3q02a*conv_timad_z)/10000  if s3q02b  ==  3 & conv_timad= = .
replace plotarea_sr=(s3q02a*conv_timad_r)/10000  if s3q02b  ==  3 & conv_timad_z= = . & conv_timad= = . //timad
replace plotarea_sr=(s3q02a*0.25)                if s3q02b  ==  3 & conv_timad_r= = . & conv_timad_z= = . & conv_timad= = .

replace plotarea_sr=(s3q02a*conv_boy  )/10000 if (s3q02b  ==  4 | s3q2b_os == "BOY") & conv_boy! = .
replace plotarea_sr=(s3q02a*conv_boy_z)/10000 if (s3q02b  ==  4 | s3q2b_os == "BOY")  & conv_boy= = .
replace plotarea_sr=(s3q02a*conv_boy_r)/10000 if (s3q02b  ==  4 | s3q2b_os == "BOY")  & conv_boy_z= = . & conv_boy= = . //boy
replace plotarea_sr=(s3q02a*227.76)/10000     if (s3q02b  ==  4 | s3q2b_os == "BOY") & conv_boy_r= = . & conv_boy_z= = . & conv_boy= = .

replace plotarea_sr=(s3q02a*conv_senga  )/10000 if s3q02b == 5 & conv_senga! = .
replace plotarea_sr=(s3q02a*conv_senga_z)/10000 if s3q02b == 5 & conv_senga= = .
replace plotarea_sr=(s3q02a*conv_senga_r)/10000 if s3q02b == 5 & conv_senga_z= = . & conv_senga= = . //senga
replace plotarea_sr=(s3q02a*1339.289)/10000 if s3q02b == 5 & conv_senga_r= = . & conv_senga_z= = . & conv_senga= = .



replace plotarea_sr=(s3q02a*conv_kert  )/10000 if s3q02b == 6 & conv_kert! = .
replace plotarea_sr=(s3q02a*conv_kert_z)/10000 if s3q02b == 6 & conv_kert= = .
replace plotarea_sr=(s3q02a*conv_kert_r)/10000 if s3q02b == 6 & conv_kert_z= = . & conv_kert= = . //kert

replace plotarea_sr=(s3q02a*0.25)/10000 if s3q02b == 6 & conv_kert_r= = . & conv_kert_z= = . & conv_kert= = . 


replace plotarea_sr=(s3q02a* 204.4169)/10000 if s3q02b == 7 //tilm
replace plotarea_sr=(s3q02a*69.28191)/10000  if s3q02b == 8 //medeb
*replace plotarea_sr=pp_s3q02_a if pp_s3q02_c == 9 //rope
replace plotarea_sr=(s3q02a*6176.3808)/10000 if s3q02b == 10 //ermija


lab var plotarea_sr "Plot area in HA - Self-reported"

* Compass and rope // N/A

* GPS
generate       plotarea_gps = .
replace plotarea_gps=s3q08/10000
lab var plotarea_gps "Plot area in HA - GPS"

* Variable without missing: order of importance: 1.Rope and compass, 2. GPS, 3. Self-reported

generate plotarea_full=plotarea_gps 
replace plotarea_full=plotarea_sr if plotarea_gps= = .
lab var plotarea_full "Plot area: GPS imputed with SR"
*/

* Crop type
tab s3q03b, gen(cropt)
lab var cropt1 "Plot with temporary crop"
lab var cropt2 "Plot with permanent crop"
lab var cropt3 "Plot with temporary and permanent crop"

tab s3q04, gen(cropm)
lab var cropm1 "Purestand"
lab var cropm2 "Mixed crop"

generate falloq = .
replace falloq = 1 if s3q05  ==  1
replace falloq = 0 if s3q05  ==  2
lab var falloq "Plot left fallow in the last 5 years"

rename s3q13 s1q00  // s3q13: Who in HH makes primary decisions on [FIELD]?
merge m:1 holder_id household_id s1q00 using "${rawdata}\PP\sect1_pp_w5"
drop if _m  ==  2
drop _m
  
generate fplotm = .     
replace  fplotm = 0 if s1q03  ==  1
replace  fplotm = 1 if s1q03  ==  2
lab var fplotm "Plot manager is female"
rename s1q00 s3q13
drop s1*

* One obs reporting negative plot area SR
* drop if plotarea_sr<0


generate extprog = .
replace extprog = 0 if s3q16  ==  2 
replace extprog = 1 if s3q16  ==  1 
// s3q16: Is [FIELD] under Extension Program during the current agricultural season?
lab var extprog "Plot under Extension Program"

generate irr = .
replace  irr = 0 if s3q17  ==  2
replace  irr = 1 if s3q17  ==  1
lab var irr "Plot is irrigated"

tab s3q19, gen(irrm) // s3q19: What is the source of water used for irrigation on [FIELD]?
lab var irrm1 "Source of water for irrigation is: river"

generate urea = .
replace  urea = 1 if s3q21  ==  1 // s3q21: Do you use any UREA on [FIELD] in this agricultural season?
replace  urea = 0 if s3q21  ==  2
lab var urea "Urea use on plot"

generate dap = .
replace  dap = 1 if s3q22  ==  1 // s3q22: Do you use any DAP on [FIELD] in this agricultural season?
replace  dap = 0 if s3q22  ==  2
lab var dap "Use of DAP on plot"

generate nps = .
replace  nps = 1 if s3q23  ==  1 // s3q23: Do you use any NPS on [FIELD] in this agricultural season?
replace  nps = 0 if s3q23  ==  2
lab var nps "Use of NPS on plot"

generate othfert = .
replace  othfert = 1 if s3q24  ==  1 // s3q24: Do you use any other chemical fertilizers(other than UREA,DAP and NPS)
replace  othfert = 0 if s3q24  ==  2
lab var othfert "Use of other chemical fert. on plot"

generate manure = .
replace  manure = 1 if s3q25  ==  1 // s3q25: Do you use any manure on [FIELD] in this agricultural season?
replace  manure = 0 if s3q25  ==  2
lab var manure "Use of manure on plot"

generate hiredlab = .
replace  hiredlab = 0 if s3q30a  ==  0 & s3q30d  ==  0 & s3q30g  ==  0
replace  hiredlab = 1 if (s3q30a > 0 & s3q30a != .) | (s3q30d > 0 & s3q30d != .) | (s3q30g > 0 & s3q30g != .)
lab var hiredlab "Hired labor used"
// s3q30a: Hired Men (Number of Men)
// s3q30d: Hired Women (Number of Women)
// s3q30g: Hired Children (Number of Children)

generate lprep = .
replace  lprep = 1 if s3q35 != .  // s3q35: How was [FIELD] prepared for planting?
replace  lprep = 0 if s3q35  ==  .
lab var lprep "Plot prepared for planting"

generate soiler = .
replace  soiler = 1 if s3q38  ==  1  // s3q38: Is [Field] prevented from Erosion?
replace  soiler = 0 if s3q38  ==  2
lab var soiler "Plot prevented from soil erosion"

* labelling variables
lab var swc        "Soil Water Conservation practices"
lab var terr       "Terracing"
lab var wcatch     "Water catchments"
lab var affor      "Afforestation"
lab var ploc	   "Plough along the contour"
lab var mintillage "Minimum tillage"
lab var zerotill   "Zero tillage"
lab var cresidue1  "Crop residue cover - Farmer's elicitation"
lab var cresidue2  "Crop residue cover - visual aid"
lab var rotlegume  "Crop rotation with a legume"
lab var consag1    "Conservation Agriculture - using Minimum tillage"
lab var consag2    "Conservation Agriculture - using Zero tillage"
lab var rdisp      "River dispersion"
lab var treadle    "Treadle pump used for irrigation"
lab var motorpump  "Motor pump used for irrigation"


* Plot level - NRM

preserve 
#delimit ;
keep   holder_id household_id ea_id saq01 region saq02 saq03 city subcity kebele 
	   saq07 saq08 saq09 saq14 saq15 parcel_id field_id rdisp treadle motorpump 
	   rotlegume cresidue1 cresidue2 mintillage zerotill swc terr wcatch affor 
	   ploc consag1 consag2 hh_plot_nb ea_plot_nb hh_plot_irr_nb ea_plot_irr_nb 
	   hh_plot_cult_nb ea_plot_cult_nb hh_plot_uses_nb ea_plot_uses_nb 
	   hh_plot_eros_nb ea_plot_eros_nb hh_plot_cplus_nb ea_plot_cplus_nb 
	   hh_plot_lprep_nb ea_plot_lprep_nb plotarea_sr plotarea_gps plotarea_full 
	   cropt1 cropt2 cropt3 cropm1 cropm2 falloq fplotm extprog irr irrm1 urea 
	   dap nps othfert manure hiredlab lprep soiler plotirr 
#delimit cr
save "${data}\ess5_pp_nrm_plot_new", replace
restore

* COLLAPSE AT HH-LEVEL
collapse (max) hhd_treadle hhd_motorpump  hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintillage ///
               hhd_zerotill  hhd_consag* hhd_swc hhd_swc2 hhd_terr hhd_wcatch hhd_affor hhd_ploc ///
			   hhd_rdisp sh_plothh_* hh_plot_nb hh_plot_irr_nb hh_plot_cult_nb plotirr /// 
		 (firstnm) holder_id saq14, by(household_id )  // (firstnm): first nonmissing value

* HH dummy
lab var hhd_swc        "Soil Water Conservation practices"
lab var hhd_terr       "Terracing"
lab var hhd_wcatch     "Water catchments"
lab var hhd_affor      "Afforestation"
lab var hhd_ploc	   "Plough along the contour"
lab var hhd_mintillage "Minimum tillage"
lab var hhd_zerotill   "Zero tillage"
lab var hhd_cresidue1  "Crop residue cover"
lab var hhd_cresidue2  "Crop residue cover"
lab var hhd_rotlegume  "Crop rotation with a legume"
lab var hhd_consag1    "Conservation Agriculture - using Minimum tillage"
lab var hhd_consag2    "Conservation Agriculture - using Zero tillage"
lab var hhd_rdisp      "River dispersion"
lab var hhd_treadle    "Treadle pump used for irrigation"
lab var hhd_motorpump  "Motor pump used for irrigation"

lab var hh_plot_nb       "Number of plots per household"
lab var hh_plot_irr_nb   "Number of irrigated plots per household"
lab var hh_plot_cult_nb  "Number of cultivated plots per household"

foreach i in hh_plot_nb hh_plot_irr_nb hh_plot_cult_nb {
    replace `i' = 0 if `i'  ==  .  // replace by 0 if missing
}


* Share of plots per hh

lab var sh_plothh_treadle "Treadle pump used for irrigation"
forvalues x = 1/6{
    lab var sh_plothh_treadle_cond`x' "Treadle pump used for irrigation conditional on `x'* (see notes)"
}

lab var sh_plothh_motorpump "Motor pump used for irrigation"
forvalues x = 1/6 {
    lab var sh_plothh_motorpump_cond`x' "Motor pump used for irrigation conditional on `x'* (see notes)"
}

lab var sh_plothh_rotlegume "Crop rotation with a legume"
forvalues x = 1/6 {
    lab var sh_plothh_rotlegume_cond`x' "Crop rotation with a legume conditional on `x'* (see notes)"
}

forvalues x = 1/6 {

    lab var sh_plothh_cresidue1`z' "Crop residue cover - farmer elicitation"
    lab var sh_plothh_cresidue2`z' "Crop residue cover - visual aid"

    lab var sh_plothh_cresidue1_cond`x' "Crop residue cover - farmer alicitation conditional on `x'* (see notes)"
    lab var sh_plothh_cresidue2_cond`x' "Crop residue cover - visual aid conditional on `x'* (see notes)"

}

lab var sh_plothh_mintillage "Minimum tillage"
forvalues x = 1/6 {
    lab var sh_plothh_mintillage_cond`x' "Minimum tillage conditional on `x'* (see notes)"
}

lab var sh_plothh_zerotill "Zero tillage"
forvalues x = 1/6 {
    lab var sh_plothh_zerotill_cond`x' "Zero tillage conditional on `x'* (see notes)"
}

lab var sh_plothh_consag1 "Conservation Agriculture - using Minimum tillage"
forvalues x = 1/6 {
    lab var sh_plothh_consag1_cond`x' "Conservation Agriculture - using Minimum tillage conditional on `x'* (see notes)"
}

lab var sh_plothh_consag2 "Conservation Agriculture - using Zero tillage"
forvalues x = 1/6 {
    lab var sh_plothh_consag2_cond`x' "Conservation Agriculture - using Zero tillage conditional on `x'* (see notes)"
}

lab var sh_plothh_swc "Soil Water Conservation practices"
forvalues x = 1/6 {
    lab var sh_plothh_swc_cond`x' "Soil Water Conservation practices conditional on `x'* (see notes)"
}

lab var sh_plothh_rdisp "River dispersion"
forvalues x = 1/6 {
    lab var sh_plothh_rdisp_cond`x' "River dispersion conditional on `x'* (see notes)"
}

lab var sh_plothh_terr "Terracing"
forvalues x = 1/6 {
    lab var sh_plothh_terr_cond`x' "Terracing conditional on `x'* (see notes)"
}

lab var sh_plothh_wcatch "Water catchments"
forvalues x = 1/6 {
    lab var sh_plothh_wcatch_cond`x' "Water catchments conditional on `x'* (see notes)"
}

lab var sh_plothh_affor "Afforestation"
forvalues x = 1/6 {
    lab var sh_plothh_affor_cond`x' "Afforestation conditional on `x'* (see notes)"
}

lab var sh_plothh_ploc "Plough along the contour"
forvalues x = 1/6 {
    lab var sh_plothh_ploc_cond`x' "Plough along the contour conditional on `x'* (see notes)"
}

#delimit ;
global conditional sh_plothh_cresidue1_cond`x' sh_plothh_cresidue2_cond`x' 
	    sh_plothh_mintillage_cond`x' sh_plothh_zerotill_cond`x' sh_plothh_consag1_cond`x' 
		sh_plothh_consag2_cond`x' sh_plothh_swc_cond`x' sh_plothh_rdisp_cond`x' 
		sh_plothh_terr_cond`x' sh_plothh_wcatch_cond`x' sh_plothh_affor_cond`x'
        sh_plothh_ploc_cond`x' 
;
#delimit cr

foreach var in  $conditional {
    forvalues x = 1/6 {
        note `var'`x': Conditional on: ///
				                1. Plot cultivated, ///
								2. Plot irrigated & cultivated, ///
								3. Plot cultivated, pasture, fallow, forest etc., ///
								4. Using soil erosion preventing measures & use, ///
								5. Cultivated and temporary crop planted, ///
								6. Cultivated and temporary crop and land preparation.
}
}

tempfile  PP_W5S3
save     `PP_W5S3'


********************************************************************************
* SECTION 4 - PP - CROP VARIETY
********************************************************************************

use "${rawdata}\PP\sect4_pp_w5", clear

// we want status of filed during this season (s3q03 & s3q03b)
merge m:1 holder_id household_id parcel_id field_id using "${rawdata}\PP\sect3_pp_w5", keepusing(s3q03 s3q03b) 
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         5,967
        from master                         0  (_merge == 1)
        from using                      5,967  (_merge == 2)

    matched                            16,913  (_merge == 3)
    -----------------------------------------
*/

keep if _m  ==  3
drop _merge


* ONLY cultivated plots
generate sp_ofsp = (s4q25  ==  2) 
lab var sp_ofsp "SP - OFSP"
// s4q25: What does the sweet potato flesh looks like? (visual aid)

generate sp_awassa83 = (s4q25  ==  1) & (s4q26  ==  2) 
lab var sp_awassa83 "SP- Awassa83"
// s4q26: What does the sweet potato skin looks like? (visual aid)
* s4q25 and s4q26 need to be checked if the pictures are the same as in ESS4

generate avocado = (s4q01b  ==  84)
generate mango = (s4q01b  ==  46)
generate papaya = (s4q01b  ==  48)
generate sweetpotato = (s4q01b  ==  62)
generate fieldp = (s4q01b  ==  15)

* Crop type *
generate improv = .
replace  improv = 1 if s4q11  ==  2 | s4q11  ==  3 | s4q11  ==  4
replace  improv = 0 if s4q11  ==  1
lab var improv "Improved crop used"
// s4q11: What type of Seed / was used for [CROP] on [FIELD]?


* Improved by crop *
generate cr1 = 0
generate cr2 = 0
generate cr3 = 0
generate cr4 = 0
generate cr5 = 0
generate cr6 = 0
generate cr7 = 0
generate cr8 = 0
generate cr9 = 0
generate cr10 = 0
generate cr11 = 0
generate cr12 = 0
generate cr13 = 0
generate cr14 = 0
generate cr15 = 0
generate cr16 = 0
generate cr17 = 0
generate cr18 = 0
generate cr19 = 0
generate cr20 = 0
generate cr23 = 0
generate cr24 = 0
generate cr25 = 0
generate cr26 = 0
generate cr27 = 0
generate cr28 = 0
generate cr33 = 0
generate cr34 = 0
generate cr36 = 0
generate cr37 = 0
generate cr38 = 0
generate cr39 = 0
generate cr40 = 0
generate cr41 = 0
generate cr42 = 0
generate cr44 = 0
generate cr45 = 0
generate cr46 = 0
generate cr47 = 0
generate cr48 = 0
generate cr49 = 0
generate cr50 = 0
generate cr51 = 0
generate cr52 = 0
generate cr53 = 0
generate cr54 = 0
generate cr55 = 0
generate cr56 = 0
generate cr57 = 0
generate cr58 = 0
generate cr59 = 0
generate cr60 = 0
generate cr61 = 0
generate cr62 = 0
generate cr63 = 0
generate cr64 = 0
generate cr65 = 0
generate cr66 = 0
generate cr69 = 0
generate cr71 = 0
generate cr72 = 0
generate cr73 = 0
generate cr74 = 0
generate cr75 = 0
generate cr76 = 0
generate cr78 = 0
generate cr79 = 0
generate cr80 = 0
generate cr81 = 0
generate cr82 = 0
generate cr83 = 0
generate cr84 = 0
generate cr85 = 0
generate cr86 = 0
generate cr98 = 0
generate cr99 = 0
generate cr108 = 0
generate cr112 = 0
generate cr114 = 0
generate cr115 = 0
generate cr117 = 0
generate cr118 = 0
generate cr119 = 0
generate cr120 = 0
generate cr123 = 0

replace cr1 = 1 if s4q01b == 1
replace cr2 = 1 if s4q01b == 2
replace cr3 = 1 if s4q01b == 3
replace cr4 = 1 if s4q01b == 4
replace cr5 = 1 if s4q01b == 5
replace cr6 = 1 if s4q01b == 6
replace cr7 = 1 if s4q01b == 7
replace cr8 = 1 if s4q01b == 8
replace cr9 = 1 if s4q01b == 9
replace cr10 = 1 if s4q01b == 10
replace cr11 = 1 if s4q01b == 11
replace cr12 = 1 if s4q01b == 12
replace cr13 = 1 if s4q01b == 13
replace cr14 = 1 if s4q01b == 14
replace cr15 = 1 if s4q01b == 15
replace cr16 = 1 if s4q01b == 16
replace cr17 = 1 if s4q01b == 17
replace cr18 = 1 if s4q01b == 18
replace cr19 = 1 if s4q01b == 19
replace cr20 = 1 if s4q01b == 20
replace cr23 = 1 if s4q01b == 23
replace cr24 = 1 if s4q01b == 24
replace cr25 = 1 if s4q01b == 25
replace cr26 = 1 if s4q01b == 26
replace cr27 = 1 if s4q01b == 27
replace cr28 = 1 if s4q01b == 28
replace cr33 = 1 if s4q01b == 33
replace cr34 = 1 if s4q01b == 34
replace cr36 = 1 if s4q01b == 36
replace cr37 = 1 if s4q01b == 37
replace cr38 = 1 if s4q01b == 38
replace cr39 = 1 if s4q01b == 39
replace cr40 = 1 if s4q01b == 40
replace cr41 = 1 if s4q01b == 41
replace cr42 = 1 if s4q01b == 42
replace cr44 = 1 if s4q01b == 44
replace cr45 = 1 if s4q01b == 45
replace cr46 = 1 if s4q01b == 46
replace cr47 = 1 if s4q01b == 47
replace cr48 = 1 if s4q01b == 48
replace cr49 = 1 if s4q01b == 49
replace cr50 = 1 if s4q01b == 50
replace cr51 = 1 if s4q01b == 51
replace cr52 = 1 if s4q01b == 52
replace cr53 = 1 if s4q01b == 53
replace cr54 = 1 if s4q01b == 54
replace cr55 = 1 if s4q01b == 55
replace cr56 = 1 if s4q01b == 56
replace cr57 = 1 if s4q01b == 57
replace cr58 = 1 if s4q01b == 58
replace cr59 = 1 if s4q01b == 59
replace cr60 = 1 if s4q01b == 60
replace cr61 = 1 if s4q01b == 61
replace cr62 = 1 if s4q01b == 62
replace cr63 = 1 if s4q01b == 63
replace cr64 = 1 if s4q01b == 64
replace cr65 = 1 if s4q01b == 65
replace cr66 = 1 if s4q01b == 66
replace cr69 = 1 if s4q01b == 69
replace cr71 = 1 if s4q01b == 71
replace cr72 = 1 if s4q01b == 72
replace cr73 = 1 if s4q01b == 73
replace cr74 = 1 if s4q01b == 74
replace cr75 = 1 if s4q01b == 75
replace cr76 = 1 if s4q01b == 76
replace cr78 = 1 if s4q01b == 78
replace cr79 = 1 if s4q01b == 79
replace cr80 = 1 if s4q01b == 80
replace cr81 = 1 if s4q01b == 81
replace cr82 = 1 if s4q01b == 82
replace cr83 = 1 if s4q01b == 83
replace cr84 = 1 if s4q01b == 84
replace cr85 = 1 if s4q01b == 85
replace cr86 = 1 if s4q01b == 86
replace cr98 = 1 if s4q01b == 98
replace cr99 = 1 if s4q01b == 99
replace cr108 = 1 if s4q01b == 108
replace cr112 = 1 if s4q01b == 112
replace cr114 = 1 if s4q01b == 114
replace cr115 = 1 if s4q01b == 115
replace cr117 = 1 if s4q01b == 117
replace cr118 = 1 if s4q01b == 118
replace cr119 = 1 if s4q01b == 119
replace cr120 = 1 if s4q01b == 120
replace cr123 = 1 if s4q01b == 123


foreach i in cr1 cr2 cr3 cr4 cr5 cr6 cr7 cr8 cr9 cr10 cr11 cr12 cr13 cr14 cr15 /// 
             cr18 cr19 cr23 cr24 cr25 cr26 cr27 cr42 cr49 cr60 cr62 cr71 cr72  {

    generate imp`i' = 0 if `i' == 1                // will be missing for other crops
    replace  imp`i' = 1 if `i' == 1 & improv == 1  // dummy for improved crop

}

#delimit ;
generate impveg = .;  // Improved vegetables and herbs:
replace  impveg = 0 if cr34 == 1 | cr38 == 1 | cr52 == 1 | cr54 == 1 | 
                       cr55 == 1 | cr56 == 1 | cr57 == 1 | cr58 == 1 | 
                       cr59 == 1 | cr61 == 1 | cr63 == 1 | cr69 == 1 | 
                       cr79 == 1 | cr80 == 1 | cr82 == 1 | cr83 == 1 | 
                       cr117 == 1;
replace  impveg = 1 if (cr34 == 1 | cr38 == 1 | cr52 == 1 | cr54 == 1 | 
                        cr55 == 1 | cr56 == 1 | cr57 == 1 | cr58 == 1 | 
                        cr59 == 1 | cr61 == 1 | cr63 == 1 | cr69 == 1 | 
                        cr79 == 1 | cr80 == 1 | cr82 == 1 | cr83 == 1 | 
                        cr117 == 1) & improv == 1;

generate impftr = .;  // Improved fruit trees:
replace  impftr = 0 if  cr41 == 1 | cr44 == 1 | cr45 == 1 | cr46 == 1 | 
                        cr47 == 1 | cr48 == 1 | cr50 == 1 | cr65 == 1 | 
                        cr66 == 1 | cr75 == 1 | cr84 == 1 | cr112 == 1 | 
                        cr115 == 1;
replace  impftr = 1 if (cr41 == 1 | cr44 == 1 | cr45 == 1 | cr46 == 1 | 
                        cr47 == 1 | cr48 == 1 | cr50 == 1 | cr65 == 1 | 
                        cr66 == 1 | cr75 == 1 | cr84 == 1 | cr112 == 1 | 
                        cr115 == 1 ) & improv == 1
delimit cr

* Improved roots:
generate improot = .
replace  improot = 0 if  cr51 == 1 | cr53 == 1 | cr74 == 1
replace  improot = 1 if (cr51 == 1 | cr53 == 1 | cr74 == 1) & improv == 1

* Improved cash crops:
generate impccr = .
replace  impccr = 0 if  cr76 == 1
replace  impccr = 1 if (cr76 == 1 & improv == 1)


foreach i in sp_ofsp sp_awassa83 avocado mango papaya sweetpotato fieldp /// 
			 impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 /// 
             impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 ///
             impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 ///
             impcr62 impcr71 impcr72  impveg impftr improot impccr {

    egen `i'max = max(`i'), by(household_id)  // dummy for at least 1 in hh

}

foreach i in avocado mango papaya sweetpotato fieldp impcr1 impcr2 impcr3 impcr4 impcr5 ///
		     impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 ///
             impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 ///
             impcr72  impveg impftr improot impccr {

    egen hhd_`i'=max(`i')         if `i'max!=., by(household_id)    // HH dummy  (at least 1 in hh)
    egen ead_`i'=max(`i')         if `i'max!=., by(ea_id)           // Ea dummy  (at least 1 in EA)
    egen `i'_sumhh=sum(`i')       if `i'max!=., by(household_id)    // Sum of crop per HH
    egen `i'_sumea=sum(`i')       if `i'max!=., by(ea_id)           // Sum of crop per EA
    egen `i'_sumhhea=sum(hhd_`i') if `i'max!=., by(ea_id)           // Sum of hh per EA

}

foreach i in ofsp awassa83 {

    egen hhd_`i'=max(sp_`i')      if sp_ofspmax!=., by(household_id)    // HH dummy 
    egen ead_`i'=max(sp_`i')      if sp_ofspmax!=., by(ea_id)           // Ea dummy  
    egen `i'_sumhh=sum(sp_`i')    if sp_ofspmax!=., by(household_id)    // Sum of crop per HH
    egen `i'_sumea=sum(sp_`i')    if sp_ofspmax!=., by(ea_id)           // Sum of crop per EA
    egen `i'_sumhhea=sum(hhd_`i') if sp_ofspmax!=., by(ea_id)           // Sum of hh per EA

}


egen ea_plot1=count(field_id)   if sp_ofspmax!=., by(ea_id)          //Tot no of plot per EA
       
egen hh_plot1=count(field_id)   if sp_ofspmax!=., by(household_id)  // Tot no of plots per HH

egen hh_ea1=count(household_id) if sp_ofspmax!=., by(ea_id)           		// Tot no of hh per EA

egen ea_plot2=count(field_id)   if s4q01b!=.,     by(ea_id)          //Tot no of plot per EA
       
egen hh_plot2=count(field_id)   if s4q01b!=.,     by(household_id)  // Tot no of plots per HH

egen hh_ea2=count(household_id) if s4q01b!=.,     by(ea_id)           		// Tot no of hh per EA


foreach i in ofsp awassa83 {

    g sh_plothh_`i'=(`i'_sumhh/hh_plot1)*100 if `i'_sumhh!=.   & hhd_`i'==1 // Share of plots per HH
    g sh_plotea_`i'=(`i'_sumea/ea_plot1)*100 if `i'_sumea!=.   & hhd_`i'==1 // Share of plots per EA
    g sh_hhea_`i'  =(`i'_sumhhea/hh_ea1)*100 if `i'_sumhhea!=. & hhd_`i'==1 // Share of HH per EA

}

foreach i in avocado mango papaya sweetpotato fieldp impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  impveg impftr improot impccr {

    g sh_plothh_`i'=(`i'_sumhh/hh_plot2)*100 if `i'_sumhh!=.   & hhd_`i'==1 // Share of plots per HH
    g sh_plotea_`i'=(`i'_sumea/ea_plot2)*100 if `i'_sumea!=.   & hhd_`i'==1 // Share of plots per EA
    g sh_hhea_`i'  =(`i'_sumhhea/hh_ea2)*100 if `i'_sumhhea!=. & hhd_`i'==1 // Share of HH per EA

}


* Crop damage cause
tab s4q09, gen(cdam)

// some adjustment needed since no values for "s4q09==14. Security Problems":
rename cdam15 cdam16
rename cdam14 cdam15
generate cdam14 = 0
label var cdam14 "s4q09==14. Security Problems"

g cdamoth = .
replace cdamoth = 1 if cdam6==1 | cdam7==1 | cdam8==1 | cdam9==1 | cdam10==1 | /// 
                     cdam11==1 | cdam12==1 | cdam13==1 | cdam14==1 | ///
                     cdam15==1 | cdam16==1 

foreach i in 1 2 3 4 5 oth {
replace cdam`i' =0 if s4q08==2
}
replace cdamoth=0 if cdamoth==. & s4q08!=.

* Intention to sell the harvest
g hsell=.
replace hsell=1 if s4q22==1
replace hsell=0 if s4q22==2

* Merge with plot area to gen % of plot area under maize, sorghum and barley
merge m:1 parcel_id field_id   holder_id household_id ea_id using "${data}\ess4_pp_nrm_plot_new", keepusing(plotarea_full)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         5,967
        from master                         0  (_merge==1)
        from using                      5,967  (_merge==2)

    matched                            16,913  (_merge==3)
    -----------------------------------------
*/


keep if _m==3
drop _merge

g       m_plotarea=plotarea_full              if s4q01b==2 &  s4q02==1  // Maize and pure stand
replace m_plotarea=plotarea_full*(s4q03/100)  if s4q01b==2 &  s4q02==2  // Maize and mixed

g       s_plotarea=plotarea_full              if s4q01b==6 &  s4q02==1  // Sorghum and pure stand
replace s_plotarea=plotarea_full*(s4q03/100)  if s4q01b==6 &  s4q02==2  // Sorghum and mixed

g       b_plotarea=plotarea_full              if s4q01b==1 &  s4q02==1  // Barley and pure stand
replace b_plotarea=plotarea_full*(s4q03/100)  if s4q01b==1 &  s4q02==2  // Barley and mixed

clonevar region=saq01
replace region=0 if region==2 | region==6 | region==15 | region==12 | region==13 | region==5

* calculating area covered by region
foreach i in m s b {
	replace `i'_plotarea=0 if `i'_plotarea==. 
		foreach x in 1 3 4 7 0  {
			egen `i'_plotarea`x'=sum(`i'_plotarea) if region==`x'
}
}

* calculating share of area by region
foreach x in 1 3 4 7 0  {
	egen tot_plotarea`x'=sum(plotarea_full) if region==`x'
		foreach i in m s b {
			g sh_`i'area`x'=`i'_plotarea`x'/tot_plotarea`x'
}
}


	
*Plot level - Crop variety
preserve 
keep saq01 sp_ofsp sp_awassa83 avocado mango papaya sweetpotato fieldp improv /// 
     cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell  parcel_id field_id crop_id ///
	 holder_id household_id ea_id impcr2 impcr1 pw_w4
	 
collapse (max) saq01 sp_ofsp sp_awassa83 improv avocado mango papaya sweetpotato ///
               fieldp  cdam1 cdam2 cdam3 cdam4 cdam5 cdamoth hsell impcr2 impcr1 ///
		 (firstnm) pw_w4, by(parcel_id field_id holder_id household_id ea_id)

lab var improv      "Improved crop used"
lab var cdam1       "Crop damage due to: Too Much Rain "
lab var cdam2       "Crop damage due to: Too Little Rain"
lab var cdam3       "Crop damage due to: Insects"
lab var cdam4       "Crop damage due to: Crop Disease "
lab var cdam5       "Crop damage due to: Weeds"
lab var cdamoth     "Crop damage due to: Other "
lab var hsell       "Farmer intends to sell parts of the harvest"
lab var sp_ofsp     "Orange Fleshed sweet potato"
lab var sp_awassa83 "Awassa83 sweet potato"
lab var avocado     "Avocado tree"
lab var mango       "Mango tree"
lab var papaya      "Papaya tree"
lab var sweetpotato "Sweetpotato SR"
lab var fieldp		"Field peas"

save "${data}\ess4_pp_cropvar_plot_new", replace
restore



collapse (max) cr1 cr2 cr6 hhd_ofsp ead_ofsp hhd_awassa83 ead_awassa83 hhd_avocado ///
			   ead_avocado hhd_mango ead_mango ead_papaya hhd_papaya hhd_sweetpotato /// 
			   ead_sweetpotato  ead_fieldp hhd_fieldp sh_plothh_ofsp sh_plotea_ofsp ///
			   sh_hhea_ofsp sh_plothh_awassa83 sh_plotea_awassa83 sh_hhea_awassa83 ///
			   sh_plothh_avocado sh_plotea_avocado sh_hhea_avocado sh_plothh_mango ///
			   sh_plotea_mango sh_hhea_mango sh_plothh_papaya sh_plotea_papaya ///
			   sh_hhea_papaya sh_plothh_sweetpotato sh_plotea_sweetpotato ///
			   sh_hhea_sweetpotato sh_plothh_fieldp sh_plotea_fieldp ///
			   sh_hhea_fieldp *impcr*  *impveg *impftr *improot *impccr ///
		 (firstnm) saq01 saq14 ea_id, by(household_id)

foreach i in impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 ///
			 impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 ///
	         impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 impcr72  ///
	         impveg impftr improot impccr  {
replace sh_plothh_`i'=. if hhd_`i'==0
replace sh_plotea_`i'=. if ead_`i'==0
replace sh_hhea_`i'=. if ead_`i'==0
}


foreach i of varlist *impveg* {
lab var `i' "Improved (SR) vegetables and herbs" 
}
foreach i of varlist *impftr* {
lab var `i' "Improved (SR) fruit trees" 
}
foreach i of varlist *improot* {
lab var `i' "Improved (SR) other roots"
} 
foreach i of varlist *impccr* {
lab var `i' "Improved (SR) cash crop" 
}




foreach i in hhd_ofsp ead_ofsp sh_plothh_ofsp sh_plotea_ofsp sh_hhea_ofsp {
lab var `i' "Sweet potato OFSP variety"
}

foreach i in hhd_awassa83 ead_awassa83 sh_plothh_awassa83 sh_plotea_awassa83 sh_hhea_awassa83 {
lab var `i' "Sweet potato Awassa83 variety"
}

foreach i in hhd_avocado ead_avocado sh_plothh_avocado sh_plotea_avocado sh_hhea_avocado {
lab var `i' "Avocado tree"
}

foreach i in hhd_mango ead_mango sh_plothh_mango sh_plotea_mango sh_hhea_mango {
lab var `i' "Mango tree"
}

foreach i in hhd_papaya ead_papaya sh_plothh_papaya sh_plotea_papaya sh_hhea_papaya {
lab var `i' "Papaya tree"
}
foreach i in hhd_sweetpotato ead_sweetpotato sh_plothh_sweetpotato sh_plotea_sweetpotato sh_hhea_sweetpotato {
lab var `i' "Sweetpotato"
}
foreach i in hhd_fieldp ead_fieldp sh_plothh_fieldp sh_plotea_fieldp sh_hhea_fieldp {
lab var `i' "Field peas"
}
foreach i of varlist *impcr1{
	lab var `i' "Improved   BARLEY-SR"
	}
foreach i of varlist *impcr2{
	lab var `i' "Improved   MAIZE-SR"
	}
foreach i of varlist *impcr3{
	lab var `i' "Improved   MILLET-SR"
	}
foreach i of varlist *impcr4{
	lab var `i' "Improved   OATS-SR"
	}
foreach i of varlist *impcr5{
	lab var `i' "Improved   RICE-SR"
	}
foreach i of varlist *impcr6{
	lab var `i' "Improved   SORGHUM-SR"
	}
foreach i of varlist *impcr7{
	lab var `i' "Improved   TEFF-SR"
	}
foreach i of varlist *impcr8{
	lab var `i' "Improved   WHEAT-SR"
	}
foreach i of varlist *impcr9{
	lab var `i' "Improved   Mung Bean/ MASHO-SR"
	}
foreach i of varlist *impcr10{
	lab var `i' "Improved   CASSAVA-SR"
	}
foreach i of varlist *impcr11{
	lab var `i' "Improved   CHICK PEAS-SR"
	}
foreach i of varlist *impcr12{
	lab var `i' "Improved   HARICOT BEANS-SR"
	}
foreach i of varlist *impcr13{
	lab var `i' "Improved   HORSE BEANS-SR"
	}
foreach i of varlist *impcr14{
	lab var `i' "Improved   LENTILS-SR"
	}
foreach i of varlist *impcr15{
	lab var `i' "Improved   FIELD PEAS-SR"
	}
foreach i of varlist *impcr18{
	lab var `i' "Improved   SOYA BEANS-SR"
	}
foreach i of varlist *impcr19{
	lab var `i' "Improved   RED KIDENY BEANS-SR"
	}
foreach i of varlist *impcr23{
	lab var `i' "Improved   LINESEED-SR"
	}
foreach i of varlist *impcr24{
	lab var `i' "Improved   GROUND NUTS-SR"
	}
foreach i of varlist *impcr25{
	lab var `i' "Improved   NUEG-SR"
	}
foreach i of varlist *impcr26{
	lab var `i' "Improved   RAPE SEED-SR"
	}
foreach i of varlist *impcr27{
	lab var `i' "Improved   SESAME-SR"
	}
foreach i of varlist *impcr42{
	lab var `i' "Improved   BANANAS-SR"
	}
foreach i of varlist *impcr49{
	lab var `i' "Improved   PINAPPLES-SR"
	}
foreach i of varlist *impcr60{
	lab var `i' "Improved   POTATOES-SR"
	}
foreach i of varlist *impcr62{
	lab var `i' "Improved   SWEET POTATO-SR"
	}
foreach i of varlist *impcr71{
	lab var `i' "Improved   CHAT-SR"
	}
foreach i of varlist *impcr72{
	lab var `i' "Improved   COFFEE-SR"
	}
	
tempfile pp_w5s4
save `pp_w5s4'





















































































































