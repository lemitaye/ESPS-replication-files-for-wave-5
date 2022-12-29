

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

    drop if s2q04b_  == .a & title  ==  1   // removes hh members who are not owners of parcels
    rename  s2q04b_ s1q00         // s1q00 is Individual ID in the hh roster (sect1_pp_w4)

    * Individual characteristics
    merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5"  // merge with hh roster

    keep if _merge  ==  3
    drop _merge

    generate fow = 1 if s1q03  ==  2    // fow is dummy for female owner
    bysort household_id holder_id parcel_id: egen fowner = max(fow) if title  ==  1  // dummy for at least 1 female owner in hh
    replace fowner = 0 if fowner  == . & s1q03  ==  1  
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

    drop if s2q07_  == .a & s2q06  ==  1
    // s2q06: Does anyone in HH have the right to sell [PARCEL] or use as collateral?
    rename  s2q07_ s1q00
    merge m:1 holder_id household_id s1q00 using  "${rawdata}\PP\sect1_pp_w5"
    keep if _m  ==  3
    drop _merge

    generate fow = 1 if s1q03  ==  2
    bysort household_id holder_id parcel_id: egen frsell=max(fow) if s2q06 ==  1
    replace frsell = 0 if frsell == . & s1q03 ==  1
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