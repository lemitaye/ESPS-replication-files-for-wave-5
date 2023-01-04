
********************************************************************************
* EA - LEVEL ANALYSIS *
********************************************************************************

use "${data}\wave5_hh_new", clear

// livIA elepgrass gaya sasbaniya alfa indprod cross grass [livestock vars.]
foreach i in  treadle motorpump rotlegume cresidue1 cresidue2 mintillage ///
        zerotill consag1 consag2 swc terr wcatch affor ploc rdisp { 

    generate ead_`i'=.
    replace ead_`i'=0 if hhd_`i'==0
    replace ead_`i'=1 if hhd_`i'==100  // multiplied by 100 in 05_PP_merge.do

    egen nbhhd_`i'=sum(hhd_`i'), by(ea_id)
    generate sh_ea_`i'=(nbhhd_`i'/hh_ea) if nbhhd_`i'!=.  

}

/*
generate ead_feed=0
replace ead_feed=1 if nbhhd_elepgrass>0 | nbhhd_gaya>0 | nbhhd_sasbaniya>0 | nbhhd_alfa>0 | nbhhd_indprod>0
*/
 
rename sh_hhea_ofsp        sh_ea_ofsp
rename sh_hhea_awassa83    sh_ea_awassa83
rename sh_hhea_desi        sh_ea_desi
rename sh_hhea_kabuli      sh_ea_kabuli
rename sh_hhea_avocado     sh_ea_avocado
rename sh_hhea_mango       sh_ea_mango
rename sh_hhea_papaya      sh_ea_papaya
rename sh_hhea_sweetpotato sh_ea_sweetpotato
rename sh_hhea_fieldp      sh_ea_fieldp


foreach i in impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 /// 
        impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 /// 
        impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 ///
        impcr72  impveg impftr improot impccr {

    rename sh_hhea_`i'  sh_ea_`i' 

}

/*
*Livestock
foreach i in largerum smallrum poultry {
g       ead_cross_`i'=.
replace ead_cross_`i'=0 if hhd_cross_`i'==0
replace ead_cross_`i'=1 if hhd_cross_`i'==100

egen eanb_`i'_cross=sum(`i'_cross), by(ea_id)
egen eanb_`i'_k=sum(`i'_nbhh_k), by(ea_id)
egen eanb_`i'_o=sum(`i'_nbhh_o), by(ea_id)

g   sh_ea_`i'_k=(eanb_`i'_cross/eanb_`i'_k) if eanb_`i'_cross!=.
g   sh_ea_`i'_o=(eanb_`i'_cross/eanb_`i'_o) if eanb_`i'_cross!=.
}
*/

local ead ead* 
foreach var of varlist `ead' {
    replace `var'=`var'*100
}

collapse (max) ead* sh_plotea* sh_ea_* wave region othregion (firstnm) pw_w5, by(ea_id)

/*
The following (livestock variables) removed from the loop below:
livIA elepgrass gaya sasbaniya alfa indprod cross 
*/
foreach i in treadle motorpump rotlegume cresidue1 cresidue2 mintillage zerotill ///
        consag1 consag2 swc terr wcatch affor ploc rdisp ofsp awassa83 desi kabuli ///
		avocado mango fieldp papaya ///
        sweetpotato impcr1 impcr2 impcr3 impcr4 impcr5 impcr6 impcr7 impcr8 impcr9 ///
        impcr10 impcr11 impcr12 impcr13 impcr14 impcr15 impcr18 impcr19 impcr23 ///
        impcr24 impcr25 impcr26 impcr27 impcr42 impcr49 impcr60 impcr62 impcr71 ///
        impcr72  impveg impftr improot impccr {

    replace ead_`i' =0 if ead_`i' ==.
    replace sh_ea_`i'=. if ead_`i'==0 

}

foreach i in ofsp awassa83 desi kabuli {
    replace sh_plotea_`i'=. if ead_`i'==0
}

/*
foreach i in largerum smallrum poultry {

    replace ead_cross_`i'=0 if ead_cross_`i'==.
    replace sh_ea_`i'_o=. if ead_cross_`i'==0 
    replace sh_ea_`i'_k=. if ead_cross_`i'==0 

}
*/

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

foreach i in ead_ofsp sh_plotea_ofsp sh_ea_ofsp {
    lab var `i' "Sweet potato OFSP variety"
}

foreach i in  ead_awassa83  sh_plotea_awassa83 sh_ea_awassa83 {
    lab var `i' "Sweet potato Awassa83 variety"
}

foreach i in  ead_desi  sh_plotea_desi sh_ea_desi {
    lab var `i' "Chickpea Desi variety"
}

foreach i in  ead_kabuli  sh_plotea_kabuli sh_ea_kabuli {
    lab var `i' "Chickpea Kabuli variety"
}

foreach i in ead_avocado sh_plotea_avocado sh_ea_avocado {
    lab var `i' "Avocado tree"
}
foreach i in ead_papaya sh_plotea_papaya sh_ea_papaya {
    lab var `i' "Papaya tree"
}
foreach i in ead_sweetpotato sh_plotea_sweetpotato sh_ea_sweetpotato {
    lab var `i' "Sweetpotato"
}
foreach i in ead_fieldp sh_plotea_fieldp sh_ea_fieldp {
    lab var `i' "Field peas"
}
foreach i in ead_mango sh_plotea_mango sh_ea_mango {
    lab var `i' "Mango tree"
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
	/*
foreach i of varlist *impcr108{
	lab var `i' "Improved   AMBOSHIKA-SR"
	}
*/

lab var ead_treadle     "Treadle pump" 
lab var ead_motorpump   "Motor pump"
lab var ead_rdisp       "River dispersion" 
lab var ead_rotlegume   "Crop rotation with a legume"
lab var ead_cresidue1   "Crop residue cover - farmer elicitation"
lab var ead_cresidue2   "Crop residue cover - visual aid"
lab var ead_mintillage  "Minimum tillage"
lab var ead_zerotill    "Zero tillage"
lab var ead_consag1     "Conservation Agriculture - using minimum tillage"
lab var ead_consag2     "Conservation Agriculture - using zero tillage"
lab var ead_swc         "Soil Water Conservation practices" 
lab var ead_terr        "Terracing"
lab var ead_wcatch      "Water catchments"
lab var ead_affor       "Afforestation"
lab var ead_ploc        "Plough along the contour"
/*
lab var ead_livIA       "Livestock AI"
lab var ead_elepgrass   "Feed and Forage: Elephant Grass"
lab var ead_gaya        "Feed and Forage: Gaya"
lab var ead_sasbaniya   "Feed and Forage: Sasbaniya"
lab var ead_alfa        "Feed and Forage: Alfalfa"
lab var ead_indprod     "Feed and Forage: Industry by-product"
lab var ead_feed		"Feed and forages"
lab var ead_grass        "Elephant grass, gaya, sasbaniya, alfalfa"
*/
lab var sh_ea_treadle    "Treadle pump" 
lab var sh_ea_motorpump  "Motor pump"
lab var sh_ea_rdisp      "River dispersion" 
lab var sh_ea_rotlegume  "Crop rotation with a legume"
lab var sh_ea_cresidue1  "Crop residue cover - farmer elicitation"
lab var sh_ea_cresidue2  "Crop residue cover - visual aid"
lab var sh_ea_mintillage "Minimum tillage"
lab var sh_ea_consag1    "Conservation Agriculture - using minimum tillage"
lab var sh_ea_consag2    "Conservation Agriculture - using zero tillage"
lab var sh_ea_swc        "Soil Water Conservation practices" 
lab var sh_ea_terr       "Terracing"
lab var sh_ea_wcatch     "Water catchments"
lab var sh_ea_affor      "Afforestation"
lab var sh_ea_ploc       "Plough along the contour"


/*
lab var sh_ea_livIA      "Livestock AI"
lab var sh_ea_elepgrass  "Feed and Forage: Elephant Grass"
lab var sh_ea_gaya       "Feed and Forage: Gaya"
lab var sh_ea_sasbaniya  "Feed and Forage: Sasbaniya"
lab var sh_ea_alfa       "Feed and Forage: Alfalfa"
lab var sh_ea_indprod    "Feed and Forage: Industry by-products"

lab var ead_cross          "Crossbreeding of large ruminants, small ruminants and poultry"
lab var ead_cross_largerum "Large ruminants crossbred"
lab var ead_cross_smallrum "Small ruminants crossbred"
lab var ead_cross_poultry  "Poultry crossbred"

lab var sh_ea_cross       "Crossbreeding of large ruminants, small ruminants and/or poultry"
lab var sh_ea_largerum_k  "Large ruminants crossbred"
lab var sh_ea_smallrum_k  "Small ruminants crossbred"
lab var sh_ea_poultry_k   "Poultry crossbred"

lab var sh_ea_largerum_o  "Large ruminants crossbred"
lab var sh_ea_smallrum_o  "Small ruminants crossbred"
lab var sh_ea_poultry_o   "Poultry crossbred"
*/


merge 1:1 ea_id using "${data}\ess5_community_new"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                           239
        from master                         6  (_merge==1)
        from using                        233  (_merge==2)

    Matched                               199  (_merge==3)
    -----------------------------------------
*/

drop if _m==2
drop _merge

save "${data}\wave5_ea_new", replace
save "${data}\ess5_pp_ea_new", replace