
*********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: Covariates at the community (EA) level 
* Country: Ethiopia 
* Data: ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) [code adopted from Paola Mallia and Solomon Alemu]
* STATA Version: MP 17.0
********************************************************************************



use "${rawdata}/Community/sect03_com_w5.dta", clear

merge 1:1 ea_id using "${rawdata}/Community/sect04_com_w5.dta"
drop _m

merge 1:1 ea_id using "${rawdata}/Community/sect06_com_w5.dta"
drop _m

merge 1:1 ea_id using "${rawdata}/Community/sect09_com_w5.dta"
drop _m

*keep ea_id cs3q02 cs9q01 cs6q01 cs6q10 cs4q02 cs4q08 cs4q09 cs4q11 cs4q12b ///
*    cs4q14 cs4q15 

* winsorize:
global covarwiz cs3q02 cs4q02 cs4q09 cs4q12b cs4q15 cs9q13 cs6q11 cs4q53

for var $covarwiz: winsor2 X, cuts(1 99) suffix(_wiz) label

for var $covarwiz: order X_wiz, after (X)

* turn to dummy:
global binvar cs9q01 cs6q01 cs6q10 cs4q08 cs4q11 cs4q14 cs4q03 

for var $binvar: recode X (2=0)
for var $binvar: label define X 1 "Yes" 0 "No", replace
for var $binvar: label values X X

* tab, gen:
for var cs4q01 cs6q12 cs6q13 cs6q14 cs6q15: tab X, gen(X_1)


*save "$temp\community_S4_S6_S9_for_merghh.dta", replace



*use "${cov4com}\com_level_S3_S4_S6_S9_APRIL16_V2.dta", clear

merge 1:1 ea_id using "${data}/ess5_pp_ea_new.dta"
keep if _m==3
drop _m

lab var cs9q01               "PSNP operated in this kebele" //bin
lab var cs9q13               "No. of hhs that graduated from PSNP"
lab var cs9q13_wiz           "No. of hhs that graduated from PSNP - winsorized"
lab var cs9q14               "% of hhs that graduated from PSNP"

lab var cs6q01               "Hhs farm crops or keep livestock in this community" 

lab var cs6q10               "Irrigation scheme in the community"
lab var cs6q11               "No. of farmers in community irrigation scheme"   
lab var cs6q11_wiz           "No. of farmers in community irrigation scheme - winsorized"
lab var cs6q12_11            "Major source of fertilizer in the community: Government" //bin
lab var cs6q12_12            "Major source of fertilizer in the community: Private dealer" //bin
lab var cs6q12_13            "Major source of fertilizer in the community: Union" //bin
lab var cs6q12_14            "Major source of fertilizer in the community: Other" //bin

lab var cs6q13_11            "Major source of pesticides/herbicides in the community: Government" //bin
lab var cs6q13_12            "Major source of pesticides/herbicides in the community: Private dealer" //bin
lab var cs6q13_13            "Major source of pesticides/herbicides in the community: Union" //bin
lab var cs6q13_14            "Major source of pesticides/herbicides in the community: Other" //bin

lab var cs6q14_11            "Major source of hybrid seeds in the community: Government" //bin
lab var cs6q14_12            "Major source of hybrid seeds in the community: Private dealer" //bin
lab var cs6q14_13            "Major source of hybrid seeds in the community: Union" //bin
lab var cs6q14_14            "Major source of hybrid seeds in the community: Other" //bin

lab var cs6q15_11            "Type of facility used to store crops prior to sale: Traditional" //bin
lab var cs6q15_12            "Type of facility used to store crops prior to sale: Modern" //bin
lab var cs6q15_13            "Type of facility used to store crops prior to sale: Other" //bin

lab var cs4q02               "Distance to the nearest tar/asphalt road (KM)"
lab var cs4q02_wiz           "Distance to the nearest tar/asphalt road (KM) - winsorized"
lab var cs4q01_11            "Type of main access road surfarce: tar/asphalt" //bin
lab var cs4q01_12            "Type of main access road surfarce: graded graveled" //bin
lab var cs4q01_13            "Type of main access road surfarce: dirt road (maintained)" //bin
lab var cs4q01_14            "Type of main access road surfarce: dirt track" //bin

lab var cs4q03               "Vehicles pass on the main road throughout the year" //bin

*lab var dist_roadmedi2015    "HH distance to nearest major road (GPS) -median values"
lab var cs4q08               "Community is a woreda town"                                //bin
lab var cs4q09               "Distance to the nearest Woreda/town (KM)"
lab var cs4q09_wiz           "Distance to the nearest Woreda/town (KM) - winsorized"
lab var cs4q11               "Community is a major urban center (Regional or Zonal Capital)" //bin
lab var cs4q12b              "Distance to the major urban center (KM)"
lab var cs4q12b_wiz          "Distance to the major urban center (KM) - winsorized" 

*lab var dist_admctrmedi2015  "HH distance to Capital of Zone of residence (KM) - median values"
lab var cs4q14               "Large weekly market in this community" //bin
lab var cs4q15 				 "Distance to the nearest large weekly market (KM)"
lab var cs4q15_wiz 			 "Distance to the nearest large weekly market (KM) - winsorized"
*lab var dist_marketmedi2015  "HH distance to nearest market (KM) - median values"

lab var cs3q02                "Population size in the community"
lab var cs3q02_wiz            "Population size in the community - winsorized"
lab var cs4q52                "Incidence of SACCO in the community" //bin
lab var cs4q53                "Distance to the nearest place where there is SACCO (Km)"
lab var cs4q53_wiz            "Distance to the nearest place where there is SACCO (Km) - winsorized"

rename ead_cross_largerum ead_crlr
rename ead_cross_smallrum ead_crsr
rename ead_cross_poultry  ead_crpo


*Merging with info on PSNP created in do: 01_1_hh_psnp
merge 1:1 ea_id using "${data}/ess5_ea_psnp.dta"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           236
        from master                         0  (_merge==1)
        from using                        236  (_merge==2)

    Matched                               199  (_merge==3)
    -----------------------------------------
*/

keep if _m==3
drop _m

* Merging with Locations and Distances of CG activities
merge 1:1 ea_id using  "${supp}/dashboard_locations.dta"
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                            26
        from master                        15  (_merge==1)
        from using                         11  (_merge==2)

    matched                               238  (_merge==3)
    -----------------------------------------
*/

drop if _m==2
drop _m

/*
* Merging with DNA data created in do: 9_Crop varietal identification"
merge 1:1 ea_id using "${data}/ess4_dna_ea_new.dta"                         
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            96
        from master                        93  (_merge==1)
        from using                          3  (_merge==2)

    matched                               160  (_merge==3)
    -----------------------------------------
*/
drop if _m==2
drop _merge
*/

foreach i in LargeR SmallR chicken Avocado DTMZ CA OFSP NUME SLM Barley Sorghum {
	
    gen     d25_`i'=0 if Dist_CG_`i'>25 & Dist_CG_`i'!=.  //25
    replace d25_`i'=1 if Dist_CG_`i'<=25 & Dist_CG_`i'!=.	

    gen     d50_`i'=0 if Dist_CG_`i'>50 & Dist_CG_`i'!=.  //50
    replace d50_`i'=1 if Dist_CG_`i'<=50 & Dist_CG_`i'!=.

    gen     d75_`i'=0 if Dist_CG_`i'>75 & Dist_CG_`i'!=.  //75
    replace d75_`i'=1 if Dist_CG_`i'<=75 & Dist_CG_`i'!=.

    gen     d100_`i'=0 if Dist_CG_`i'>100 & Dist_CG_`i'!=.  //100
    replace d100_`i'=1 if Dist_CG_`i'<=100 & Dist_CG_`i'!=.

    gen     d125_`i'=0 if Dist_CG_`i'>125 & Dist_CG_`i'!=.  //100
    replace d125_`i'=1 if Dist_CG_`i'<=125 & Dist_CG_`i'!=.

    gen     d150_`i'=0 if Dist_CG_`i'>150 & Dist_CG_`i'!=.  //100
    replace d150_`i'=1 if Dist_CG_`i'<=150 & Dist_CG_`i'!=.
}


lab var d25_LargeR      "Distance < 25 Km to CG activity - Large ruminants crossbred"
lab var d50_LargeR      "Distance < 50 Km to CG activity - Large ruminants crossbred"
lab var d75_LargeR      "Distance < 75 Km to CG activity - Large ruminants crossbred"
lab var d100_LargeR     "Distance < 100 Km to CG activity - Large ruminants crossbred"
lab var d125_LargeR     "Distance < 125 Km to CG activity - Large ruminants crossbred"
lab var d150_LargeR     "Distance < 150 Km to CG activity - Large ruminants crossbred"

lab var d25_SmallR      "Distance < 25  Km to CG activity - Small ruminants crossbred" 
lab var d50_SmallR      "Distance < 50  Km to CG activity - Small ruminants crossbred" 
lab var d75_SmallR      "Distance < 75  Km to CG activity - Small ruminants crossbred" 
lab var d100_SmallR     "Distance < 100 Km to CG activity - Small ruminants crossbred" 
lab var d125_SmallR     "Distance < 125 Km to CG activity - Small ruminants crossbred" 
lab var d150_SmallR     "Distance < 150 Km to CG activity - Small ruminants crossbred" 

lab var d25_chicken     "Distance < 25 Km to CG activity - Poultry crossbred" 
lab var d50_chicken     "Distance < 50  Km to CG activity - Poultry crossbred" 
lab var d75_chicken     "Distance < 75  Km to CG activity - Poultry crossbred" 
lab var d100_chicken    "Distance < 100 Km to CG activity - Poultry crossbred" 
lab var d125_chicken    "Distance < 125 Km to CG activity - Poultry crossbred" 
lab var d150_chicken    "Distance < 150 Km to CG activity - Poultry crossbred" 

lab var d25_Avocado     "Distance < 25 Km to CG activity - Avocado trees" 
lab var d50_Avocado     "Distance < 50 Km to CG activity - Avocado trees" 
lab var d75_Avocado     "Distance < 75 Km to CG activity - Avocado trees" 
lab var d100_Avocado    "Distance < 100 Km to CG activity - Avocado trees" 
lab var d125_Avocado    "Distance < 125 Km to CG activity - Avocado trees" 
lab var d150_Avocado    "Distance < 150 Km to CG activity - Avocado trees" 

lab var d25_DTMZ        "Distance < 25 Km to CG activity - DTMZ varieties" 
lab var d50_DTMZ        "Distance < 50 Km to CG activity - DTMZ varieties" 
lab var d75_DTMZ        "Distance < 75 Km to CG activity - DTMZ varieties" 
lab var d100_DTMZ       "Distance < 100 Km to CG activity - DTMZ varieties" 
lab var d125_DTMZ       "Distance < 125 Km to CG activity - DTMZ varieties" 
lab var d150_DTMZ       "Distance < 150 Km to CG activity - DTMZ varieties" 

lab var d25_CA          "Distance < 25 Km to CG activity - Conservation Agriculture" 
lab var d50_CA          "Distance < 50 Km to CG activity - Conservation Agriculture" 
lab var d75_CA          "Distance < 75 Km to CG activity - Conservation Agriculture" 
lab var d100_CA         "Distance < 100 Km to CG activity - Conservation Agriculture" 
lab var d125_CA         "Distance < 125 Km to CG activity - Conservation Agriculture" 
lab var d150_CA         "Distance < 150 Km to CG activity - Conservation Agriculture" 

lab var d25_OFSP        "Distance < 25  Km to CG activity - OFSP" 
lab var d50_OFSP        "Distance < 50  Km to CG activity - OFSP"
lab var d75_OFSP        "Distance < 75  Km to CG activity - OFSP" 
lab var d100_OFSP       "Distance < 100 Km to CG activity - OFSP"
lab var d125_OFSP       "Distance < 125 Km to CG activity - OFSP" 
lab var d150_OFSP       "Distance < 150 Km to CG activity - OFSP"

lab var d25_NUME       "Distance < 25 Km to CG activity - QPM varieties"
lab var d50_NUME       "Distance < 50 Km to CG activity - QPM varieties"
lab var d75_NUME       "Distance < 75 Km to CG activity - QPM varieties"
lab var d100_NUME       "Distance < 100 Km to CG activity - QPM varieties"
lab var d125_NUME       "Distance < 125 Km to CG activity - QPM varieties"
lab var d150_NUME       "Distance < 150 Km to CG activity - QPM varieties"

lab var d25_SLM        "Distance < 25  Km to CG activity - Watershed level SLM"
lab var d50_SLM        "Distance < 50  Km to CG activity - Watershed level SLM"
lab var d75_SLM        "Distance < 75  Km to CG activity - Watershed level SLM"
lab var d100_SLM       "Distance < 100 Km to CG activity - Watershed level SLM"
lab var d125_SLM       "Distance < 125 Km to CG activity - Watershed level SLM"
lab var d150_SLM       "Distance < 150 Km to CG activity - Watershed level SLM"

lab var d25_Barley     "Distance < 25  Km to CG activity - Public Private Partnership for barley"
lab var d50_Barley     "Distance < 50  Km to CG activity -Public Private Partnership for barley"
lab var d75_Barley     "Distance < 75  Km to CG activity - Public Private Partnership for barley"
lab var d100_Barley     "Distance < 100 Km to CG activity -Public Private Partnership for barley"
lab var d125_Barley     "Distance < 125 Km to CG activity - Public Private Partnership for barley"
lab var d150_Barley     "Distance < 150 Km to CG activity -Public Private Partnership for barley"

lab var d25_Sorghum    "Distance < 25 Km to CG activity - Improved sorghum varieties"
lab var d50_Sorghum    "Distance < 50 Km to CG activity -Improved sorghum varieties"
lab var d75_Sorghum    "Distance < 75 Km to CG activity - Improved sorghum varieties"
lab var d100_Sorghum   "Distance < 100 Km to CG activity -Improved sorghum varieties"
lab var d125_Sorghum   "Distance < 125 Km to CG activity - Improved sorghum varieties"
lab var d150_Sorghum   "Distance < 150 Km to CG activity -Improved sorghum varieties"
 

save "${data}/ess5_pp_cov_ea_new.dta", replace
