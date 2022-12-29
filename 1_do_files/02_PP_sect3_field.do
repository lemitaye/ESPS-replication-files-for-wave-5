

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
 

* Plot size (by SR and GPS) [need to be updated using ESS4 conversion factors]

*Change names of vars.
generate zone = substr(saq02, -2, .)
generate woreda = substr(saq03, -2, .)

rename saq01 region
rename saq04 city
rename saq05 subcity
rename saq06 kebele

destring region zone woreda city subcity kebele, force replace

merge m:1 region zone woreda using "${rawdata}\ESS3_ET_local_area_unit_conversion"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                        13,534
        from master                    13,312  (_merge==1)
        from using                        222  (_merge==2)

    Matched                             1,566  (_merge==3)
    -----------------------------------------
		
*/

drop if _m  ==  2
drop _merge

*Self reported plot area
generate plotarea_sr = .
replace plotarea_sr = s3q02a                       if s3q02b == 1 // ha
replace plotarea_sr = s3q02a/10000                 if (s3q02b == 2 | s3q2b_os == "METER" | s3q2b_os == "SQUIRE METER") //sq meters
replace plotarea_sr = (s3q02a*conv_timad)/10000  if s3q02b  ==  3 & conv_timad! = .
replace plotarea_sr=(s3q02a*conv_timad_z)/10000  if s3q02b  ==  3 & conv_timad == .
replace plotarea_sr=(s3q02a*conv_timad_r)/10000  if s3q02b  ==  3 & conv_timad_z == . & conv_timad == . //timad
replace plotarea_sr=(s3q02a*0.25)                if s3q02b  ==  3 & conv_timad_r == . & conv_timad_z == . & conv_timad == .

replace plotarea_sr=(s3q02a*conv_boy  )/10000 if (s3q02b  ==  4 | s3q2b_os == "BOY") & conv_boy! = .
replace plotarea_sr=(s3q02a*conv_boy_z)/10000 if (s3q02b  ==  4 | s3q2b_os == "BOY")  & conv_boy == .
replace plotarea_sr=(s3q02a*conv_boy_r)/10000 if (s3q02b  ==  4 | s3q2b_os == "BOY")  & conv_boy_z == . & conv_boy == . //boy
replace plotarea_sr=(s3q02a*227.76)/10000     if (s3q02b  ==  4 | s3q2b_os == "BOY") & conv_boy_r == . & conv_boy_z == . & conv_boy == .

replace plotarea_sr=(s3q02a*conv_senga  )/10000 if s3q02b == 5 & conv_senga! = .
replace plotarea_sr=(s3q02a*conv_senga_z)/10000 if s3q02b == 5 & conv_senga == .
replace plotarea_sr=(s3q02a*conv_senga_r)/10000 if s3q02b == 5 & conv_senga_z == . & conv_senga == . //senga
replace plotarea_sr=(s3q02a*1339.289)/10000 if s3q02b == 5 & conv_senga_r == . & conv_senga_z == . & conv_senga == .



replace plotarea_sr=(s3q02a*conv_kert  )/10000 if s3q02b == 6 & conv_kert! = .
replace plotarea_sr=(s3q02a*conv_kert_z)/10000 if s3q02b == 6 & conv_kert == .
replace plotarea_sr=(s3q02a*conv_kert_r)/10000 if s3q02b == 6 & conv_kert_z == . & conv_kert == . //kert

replace plotarea_sr=(s3q02a*0.25)/10000 if s3q02b == 6 & conv_kert_r == . & conv_kert_z == . & conv_kert == . 


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
replace plotarea_full=plotarea_sr if plotarea_gps == .
lab var plotarea_full "Plot area: GPS imputed with SR"


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
replace  lprep = 0 if s3q35  == .
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
    replace `i' = 0 if `i'  == .  // replace by 0 if missing
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

/*  This section produces error "interactions not allowed"
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
*/

tempfile  PP_W5S3
save     `PP_W5S3'