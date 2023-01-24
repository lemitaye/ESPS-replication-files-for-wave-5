
* Adopters and non adopters decriptive stats.
* T-stats of means by region
*ESS4*

use "${data}\ess5_pp_cov_new", clear // HH-level 
/*
replace hhd_psnp=100 if hhd_psnp==1

foreach i in maize_cg barley_cg sorghum_cg qpm dtmz {
	replace `i'=100 if `i'==1

}
*/
rename nom_totcons_aeq nmtotcons
rename hhd_mintillage hhd_mintil
rename hhd_sweetpotato hhd_sp
rename  total_cons_ann_win totconswin
replace hhd_impcr2=. if maize_cg==.

* retaining only panel hhs:
preserve
    use "${rawdata}\sect_cover_pp_w4", clear

    collapse (firstnm) ea_id saq14 pw_w4 saq01, by(household_id)
    rename saq01 region_w4
    rename saq14 location_w4
    rename ea_id ea_id_w4

    tempfile cover_pp_w4
    save `cover_pp_w4'
restore

merge 1:1 household_id using `cover_pp_w4'
keep if _merge==3  // retain only panel households (count=1823)
drop region_w4 location_w4 ea_id_w4


*HH level 
#delimit;
global hhdemo      
hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann 
totconswin nmtotcons consq1 consq2 adulteq 
;
#delimit cr

*ex
#delimit;
global adopt     
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor 
hhd_ploc hhd_ofsp hhd_awassa83 hhd_avocado hhd_papaya hhd_mango  hhd_fieldp hhd_sp 
hhd_impcr2 hhd_impcr1
;
#delimit cr

/*
The following were excluded from the above global call:
hhd_cross  hhd_crlr  hhd_crpo  hhd_indprod hhd_grass hhd_psnp maize_cg 
sorghum_cg barley_cg dtmz 
*/

*qpm dtmz

matrix drop _all
 
foreach i in   $adopt {

    foreach var in $hhdemo {

        qui: mean    `var' [pw=pw_w5]           if wave==5 & `i'==100
        matrix  `var'mt`i'=e(b)'
        scalar  `var'mt`i'= `var'mt`i'[1,1]

        matrix define `var'Vt`i'= e(V)'
        matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
        matrix list `var'VVt`i'
        scalar `var'vart`i'=`var'VVt`i'[1,1]
        scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



        qui: mean `var' [pw=pw_w5]              if  wave==5 & `i'==0
        matrix  `var'mc`i'=e(b)'
        scalar  `var'mc`i'= `var'mc`i'[1,1]
        matrix define `var'Vc`i'= e(V)'
        matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
        matrix list `var'VVc`i'
        scalar `var'varc`i'=`var'VVc`i'[1,1]
        scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


        qui sum `i' if `i'==0  & wave==5
        local controbs`i'=r(N)

        qui sum `i' if `i'==100 & wave==5
        local treatobs`i'=r(N)


        matrix mstrhelp`i'=(0,0,0,0,0)


            
        scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

        *scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

        qui: reg `var' `i' if  wave==5 [pw=pw_w5]
        *local t = _b[`i']/_se[`i']
        *scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
        test `i'=0
        scalar `var'pval`i'=r(p)

        qui: reg `var' `i'   i.region if  wave==5 [pw=pw_w5]
        *local t = _b[`i']/_se[`i']
        *scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
        test `i'=0
        scalar `var'pvalf`i'=r(p)



        matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
        matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 


            if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)   & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
            matrix mstr`var'`i' = (0, 0, 0, 3, 3) 
            }
            if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
            matrix mstr`var'`i' = (0, 0, 0, 3, 2) 
            }
            if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'<=0.01 {
            matrix mstr`var'`i' = (0, 0, 0, 3, 1) 
            }
            if (`var'pval`i'  <=0.1 & `var'pval`i'>0.05) & `var'pvalf`i'>0.1   {
            matrix mstr`var'`i' = (0, 0, 0, 3, 0) 
            }
            
            
            if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
            matrix mstr`var'`i' = (0, 0, 0, 2, 3) 
            }
            if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
            matrix mstr`var'`i' = (0, 0, 0, 2, 2) 
            }
            if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'<=0.01 {
            matrix mstr`var'`i' = (0, 0, 0, 2, 1) 
            }
            if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)   & `var'pvalf`i'>0.1  {
            matrix mstr`var'`i' = (0, 0, 0, 2, 0) 
            }	 
            
            
            if `var'pval`i'  <=0.01 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05) {
            matrix mstr`var'`i' = (0, 0, 0, 1, 3) 
            }
            if `var'pval`i'  <=0.01 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
            matrix mstr`var'`i' = (0, 0, 0, 1, 2) 
            }
            if `var'pval`i'  <=0.01 &  `var'pvalf`i'<=0.01 {
            matrix mstr`var'`i' = (0, 0, 0, 1, 1) 
            }
            if `var'pval`i'  <=0.01  & `var'pvalf`i'>0.1 {
            matrix mstr`var'`i' = (0, 0, 0, 1, 0) 
            }
            
            
            if `var'pval`i'   >0.1 & (`var'pvalf`i'<=0.1  & `var'pvalf`i'>0.05)  {
            matrix mstr`var'`i' = (0, 0, 0, 0, 3) 
            }
            if `var'pval`i'   >0.1 & (`var'pvalf`i' <=0.05 & `var'pvalf`i' >0.01) {
            matrix mstr`var'`i' = (0, 0, 0, 0, 2) 
            }
            if `var'pval`i'  >0.1 & `var'pvalf`i'<=0.01 {
            matrix mstr`var'`i' = (0, 0, 0, 0, 1) 
            }
            if `var'pval`i'  >0.1 & `var'pvalf`i'>0.1  {
            matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
            }
                       

        matrix list mat`var'`i'

        matrix A1`i' = nullmat(A1`i')\ mat`var'`i'\mat1`var'`i'

        matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'\mstrhelp`i'
    }

    mat A`i'_STARS=A1`i'_STARS\mstrhelp`i'
    mat A2`i'=(`treatobs`i'',`controbs`i'',.,.,.)
    mat AA`i'=A1`i'\A2`i'

    matrix colnames AA`i' = "Adopters" "Non-Adopters" "Difference" "p-value" "p-valuefe" 

}

/*
The following were excluded from the matrix definition below:
mat C: AAhhd_cross,  AAhhd_crlr, AAhhd_crpo, AAhhd_indprod, AAhhd_grass, 
AAhhd_psnp, AAmaize_cg, AAsorghum_cg, AAbarley_cg, AAdtmz;

mat C_STARS: Ahhd_cross_STARS,   Ahhd_crlr_STARS,    Ahhd_crpo_STARS,    
Ahhd_indprod_STARS,  Ahhd_grass_STARS,  Ahhd_psnp_STARS,  Amaize_cg_STARS, 
Asorghum_cg_STARS, Abarley_cg_STARS, Adtmz_STARS
*/

#delimit; 
mat C = AAhhd_rdisp,  AAhhd_motorpump, AAhhd_rotlegume, AAhhd_cresidue1, AAhhd_cresidue2, 
AAhhd_mintil, AAhhd_zerotill, AAhhd_consag1, AAhhd_consag2, AAhhd_swc, AAhhd_terr, 
AAhhd_wcatch, AAhhd_affor, AAhhd_ploc, AAhhd_ofsp, AAhhd_awassa83, AAhhd_avocado, 
AAhhd_papaya, AAhhd_mango,  AAhhd_fieldp, AAhhd_sp, AAhhd_impcr2, AAhhd_impcr1;

mat C_STARS = Ahhd_rdisp_STARS,   Ahhd_motorpump_STARS,  Ahhd_rotlegume_STARS,  
Ahhd_cresidue1_STARS,  Ahhd_cresidue2_STARS,  Ahhd_mintil_STARS,  Ahhd_zerotill_STARS,  
Ahhd_consag1_STARS, Ahhd_consag2_STARS,  Ahhd_swc_STARS,  Ahhd_terr_STARS,  Ahhd_wcatch_STARS,  
Ahhd_affor_STARS,  Ahhd_ploc_STARS,  Ahhd_ofsp_STARS,  Ahhd_awassa83_STARS,  
Ahhd_avocado_STARS,  Ahhd_papaya_STARS,  Ahhd_mango_STARS,   Ahhd_fieldp_STARS,  
Ahhd_sp_STARS, Ahhd_impcr2_STARS, Ahhd_impcr1_STARS;
#delimit cr

local rname ""
foreach var in $hhdemo {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" " " "'		
}		

#delimit ;
xml_tab C,  save("$table\Table14_ess5.xml") replace sheet("Table 1_hh_ESS5", nogridlines)  
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq( "River dispersion" "River dispersion" "River dispersion" "River dispersion"  "River dispersion" 
"Motor pump used for irrigation"  "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation" "Motor pump used for irrigation"
"Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume" "Crop rotation with a legume"  "Crop rotation with a legume"
"Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation" "Crop residue cover- farmers elicitation"
"Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid" "Crop residue cover - visual aid"  "Crop residue cover - visual aid"
"Minimum tillage" "Minimum tillage" "Minimum tillage" "Minimum tillage"  "Minimum tillage"
"Zero tillage" "Zero tillage" "Zero tillage" "Zero tillage"  "Zero tillage"
"Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage" "Conservation Agriculture - using Minimum tillage"
"Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage" "Conservation Agriculture - using Zero tillage"
"Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices" "Soil Water Conservation practices"
"Terracing" "Terracing" "Terracing" "Terracing" "Terracing"
"Water catchments" "Water catchments" "Water catchments" "Water catchments"  "Water catchments"
"Afforestation" "Afforestation" "Afforestation" "Afforestation" "Afforestation"
"Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour" "Plough along the contour"
"Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety" "Sweet potato OFSP variety"
"Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety" "Sweet potato Awassa83 variety"
"Avocado tree" "Avocado tree" "Avocado tree" "Avocado tree"  "Avocado tree"
"Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree" "Papaya tree"
"Mango tree" "Mango tree" "Mango tree" "Mango tree"  "Mango tree" 
"Field peas" "Field peas" "Field peas" "Field peas" "Field peas"
"Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato" "Sweetpotato"
"Improved maize - SR" "Improved maize - SR" "Improved maize - SR" "Improved maize - SR" "Improved maize - SR"
"Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR" "Improved barley - SR") showeq ///
rblanks(COL_NAMES "HH level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 1: ESS5 - Correlates of adoption (only for panel households))  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 
13 55,  14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 
25 55, 26 55, 27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 
37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , 
    Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr


* Only coefficients (and stars)

*HH level 
#delimit;
global hhdemo      
hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann 
totconswin nmtotcons consq1 consq2 adulteq 
;
#delimit cr

*ex
#delimit;
global adopt     
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor 
hhd_ploc hhd_ofsp hhd_awassa83 hhd_avocado hhd_papaya hhd_mango  hhd_fieldp hhd_sp 
hhd_impcr2 hhd_impcr1
;
#delimit cr

/*
The following were excluded from the above global call:
hhd_cross  hhd_crlr  hhd_crpo  hhd_indprod hhd_grass hhd_psnp maize_cg 
sorghum_cg barley_cg dtmz 
*/

*qpm dtmz

matrix drop _all
 
foreach i in   $adopt {

    foreach var in $hhdemo {

        qui: reg `var' `i' if  wave==5 [pw=pw_w5]
        scalar coef`var'`i'=e(b)[1,1]   // coefficient
        matrix mat`var'`i'=coef`var'`i'

        test `i'=0
        scalar `var'pval`i'=r(p)

            if (`var'pval`i'<=0.1 & `var'pval`i'>0.05)  {
            matrix mstr`var'`i' = (3)      // significant at 10% level
            }
            
            if (`var'pval`i'  <=0.05 & `var'pval`i'>0.01)  {
            matrix mstr`var'`i' = (2)      // significant at 5% level
            }
            
            if `var'pval`i'  <=0.01 {
            matrix mstr`var'`i' = (1)      // significant at 1% level
            }
            
            if `var'pval`i'   >0.1 {
            matrix mstr`var'`i' = (0)       // Non-significant
            }
                       
        matrix A1`i' = nullmat(A1`i')\ mat`var'`i'

        matrix A1`i'_STARS =  nullmat(A1`i'_STARS)\mstr`var'`i'

    }

    matrix colnames A1`i' = "Difference"

}

/*
The following were excluded from the matrix definition below:
mat C: AAhhd_cross,  AAhhd_crlr, AAhhd_crpo, AAhhd_indprod, AAhhd_grass, 
AAhhd_psnp, AAmaize_cg, AAsorghum_cg, AAbarley_cg, AAdtmz;

mat C_STARS: Ahhd_cross_STARS,   Ahhd_crlr_STARS,    Ahhd_crpo_STARS,    
Ahhd_indprod_STARS,  Ahhd_grass_STARS,  Ahhd_psnp_STARS,  Amaize_cg_STARS, 
Asorghum_cg_STARS, Abarley_cg_STARS, Adtmz_STARS
*/

#delimit; 
mat C = A1hhd_rdisp,  A1hhd_motorpump, A1hhd_rotlegume, A1hhd_cresidue1, A1hhd_cresidue2, 
A1hhd_mintil, A1hhd_zerotill, A1hhd_consag1, A1hhd_consag2, A1hhd_swc, A1hhd_terr, 
A1hhd_wcatch, A1hhd_affor, A1hhd_ploc, A1hhd_ofsp, A1hhd_awassa83, A1hhd_avocado, 
A1hhd_papaya, A1hhd_mango,  A1hhd_fieldp, A1hhd_sp, A1hhd_impcr2, A1hhd_impcr1;

mat C_STARS = A1hhd_rdisp_STARS,   A1hhd_motorpump_STARS,  A1hhd_rotlegume_STARS,  
A1hhd_cresidue1_STARS,  A1hhd_cresidue2_STARS,  A1hhd_mintil_STARS,  A1hhd_zerotill_STARS,  
A1hhd_consag1_STARS, A1hhd_consag2_STARS,  A1hhd_swc_STARS,  A1hhd_terr_STARS,  A1hhd_wcatch_STARS,  
A1hhd_affor_STARS,  A1hhd_ploc_STARS,  A1hhd_ofsp_STARS,  A1hhd_awassa83_STARS,  
A1hhd_avocado_STARS,  A1hhd_papaya_STARS,  A1hhd_mango_STARS,   A1hhd_fieldp_STARS,  
A1hhd_sp_STARS, A1hhd_impcr2_STARS, A1hhd_impcr1_STARS;
#delimit cr

* Transpose:
matrix D=C'
matrix D_STARS=C_STARS'


local cname ""
foreach var in $hhdemo {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $adopt {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "'		
}

#delimit ;
xml_tab D,  save("$table\Table14_coefs.xml") replace sheet("Table 14 - coefs", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESS5 - Correlates of adoption (only for panel households))  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the column variable on the row variable.); 
# delimit cr