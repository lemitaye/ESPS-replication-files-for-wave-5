

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

foreach i in avocado mango papaya sweetpotato fieldp impcr1 impcr2 impcr3 ///
             impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 impcr10 impcr11 ///
             impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 impcr24 /// 
             impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 ///
             impcr72  impveg impftr improot impccr {

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
	
	
save "${tmp}\pp_w5s4", replace
