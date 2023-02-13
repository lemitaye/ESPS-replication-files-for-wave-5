
* Adopters and non adopters decriptive stats.
* T-stats of means by region
*ESPS5*

use "${data}\ess5_pp_hh_new", clear // INNOVATIONS DATASET 

preserve
    use "${data}\ess4_pp_cov_new", clear

    rename nom_totcons_aeq nmtotcons
    rename hhd_mintillage hhd_mintil
    rename hhd_sweetpotato hhd_sp
    rename  total_cons_ann_win totconswin
    replace hhd_impcr2=. if maize_cg==.

    keep household_id hhd_flab flivman parcesizeHA asset_index pssetindex income_offfarm total_cons_ann ///
    totconswin nmtotcons consq1 consq2 adulteq age_head

    tempfile ess4_pp_cov_new
    save `ess4_pp_cov_new'
restore

merge 1:1 household_id using `ess4_pp_cov_new'
keep if _m==3   // keep only panel households (n=1823)
drop _merge

rename hhd_cross_largerum crlargerum
rename hhd_cross_smallrum crsmallrum
rename hhd_cross_poultry crpoultry


*HH level 
#delimit;
global hhdemo      
hhd_flab flivman age_head parcesizeHA asset_index pssetindex income_offfarm total_cons_ann 
totconswin nmtotcons consq1 consq2 adulteq 
;
#delimit cr

*ex
#delimit;
global adopt     
hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 hhd_mintil 
hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor 
hhd_ploc hhd_ofsp hhd_awassa83 hhd_kabuli hhd_seedv1 hhd_seedv2 hhd_malt hhd_durum 
hhd_avocado hhd_papaya hhd_mango hhd_fieldp  
maize_cg dtmz hhd_agroind hhd_grass hhd_cross crlargerum crsmallrum crpoultry
;
#delimit cr

/*
The following were excluded from the above global call:
hhd_cross  hhd_crlr  hhd_crpo  hhd_indprod hhd_psnp  
sorghum_cg barley_cg  
*/

*qpm dtmz

matrix drop _all
 
foreach i in   $adopt {

    foreach var in $hhdemo {

        qui: mean    `var' [pw=pw_w5]           if wave==5 & `i'==1
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

    matrix C=nullmat(C), AA`i'
    matrix C_STARS=nullmat(C_STARS), A`i'_STARS

}



local rname ""
foreach var in $hhdemo {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" " " "'		
}

local ceqname ""
foreach var in $adopt {
    local lbl : variable label `var'
    local ceqname `" `ceqname' "`lbl'" "`lbl'" "`lbl'" "`lbl'" "`lbl'" "'		
}	

#delimit ;
xml_tab C,  save("$table\Table14_ess5.xml") replace sheet("Table 1_hh_ESPS5", nogridlines)  
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq( `ceqname' ) showeq ///
rblanks(COL_NAMES "HH level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 1: ESPS5 - Correlates of adoption (only for panel households))  font("Times New Roman" 10) ///
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

    matrix C=nullmat(C), A1`i'
    matrix C_STARS=nullmat(C_STARS), A1`i'_STARS 

}

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
xml_tab D,  save("$table\Table14_ess5.xml") append sheet("Table 14 - coefs", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title(Table 1: ESPS5 - Correlates of adoption (only for panel households))  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes(Each cell is a coefficient estimate from a separate regression of the column variable on the row variable.); 
# delimit cr


********************************************************************************
* EA level
********************************************************************************

use "${data}\ess5_pp_ea_new", clear // INNOVATIONS DATASET 

preserve
    use "${data}\ess4_pp_cov_ea_new", clear

    rename Dist_CG_LargeR  d1
    rename Dist_CG_SmallR d2
    rename Dist_CG_chicken d3
    rename Dist_CG_Avocado d4
    rename Dist_CG_DTMZ d5
    rename Dist_CG_CA d6
    rename Dist_CG_OFSP d7
    rename Dist_CG_NUME d8
    rename Dist_CG_SLM d9
    rename Dist_CG_Barley d10
    rename Dist_CG_Sorghum d11

    keep ea_id cs9q01 cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 ///
    cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 ///
    cs6q15_13 cs4q011 cs4q012 cs4q013 cs4q014 cs4q03 cs4q08 cs4q11 cs4q14 cs4q52 ///
    cs9q13 cs9q13wiz cs9q14 cs6q01 cs6q10 cs4q02 cs4q02wiz cs4q01 cs4q09 cs4q09wiz ///
    cs4q11 cs4q12b cs4q12bwiz  cs4q15 cs4q15wiz cs3q02 cs3q02wiz cs4q52 cs4q53 csdq53wiz 

    tempfile ess4_pp_cov_ea_new
    save `ess4_pp_cov_ea_new'
restore

merge 1:1 ea_id using `ess4_pp_cov_ea_new'
keep if _m==3   // keep only panel EAs (n=172)
drop _merge

rename ead_sweetpotato ead_sp
rename ead_mintillage ead_mtill
rename ead_cross_largerum crlargerum
rename ead_cross_smallrum crsmallrum
rename ead_cross_poultry crpoultry


*Adoption status
*4
#delimit;
global adopt5 ead_ofsp ead_awassa83 ead_avocado ead_papaya ead_mango ead_fieldp 
ead_sp ead_kabuli ead_motorpump ead_rdisp ead_rotlegume ead_cresidue1 ead_cresidue2 ead_mtill 
ead_zerotill ead_consag1 ead_consag2 ead_swc ead_terr ead_wcatch ead_affor ead_ploc  
commirr ead_cross crlargerum crsmallrum crpoultry ead_livIA ead_agroind ead_grass 
comm_psnp maize_cg dtmz 
;
#delimit cr

#delimit;
global eacov4 cs9q01 cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 
cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 
cs6q15_13 cs4q011 cs4q012 cs4q013 cs4q014 cs4q03 cs4q08 cs4q11 cs4q14 cs4q52 cs9q13 
cs9q13wiz cs9q14 cs6q01 cs6q10   cs4q02 cs4q02wiz cs4q01    cs4q09 cs4q09wiz cs4q11 
cs4q12b cs4q12bwiz  cs4q15 cs4q15wiz cs3q02 cs3q02wiz cs4q52 cs4q53 csdq53wiz 
;
#delimit cr

matrix drop _all
 
foreach i in   $adopt5 {

    foreach var in $eacov4 {

    qui: mean    `var' [pw=pw_w5]           if wave==5 & `i'==1
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

    matrix C=nullmat(C), AA`i'
    matrix C_STARS=nullmat(C_STARS), A`i'_STARS

}


local rname ""
foreach var in $eacov4 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" " " "'		
}

local ceqname ""
foreach var in $adopt5 {
    local lbl : variable label `var'
    local ceqname `" `ceqname' "`lbl'" "`lbl'" "`lbl'" "`lbl'" "`lbl'" "'		
}		

#delimit ;
xml_tab C,  save("$table\Adopters_chrxs_EA_ESS5.xml") replace sheet("Table_3_EA_ESS5", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames') ceq( `ceqname' ) showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 3: ESS4 - EA level )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  
14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 
27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. Rural sample only ); //Add your notes here
# delimit cr


* Only for panel households for wave 4

use "${data}\ess4_pp_cov_new", clear

merge 1:1 household_id using "${data}\ess5_pp_hh_new", keepusing(household_id) keep(3)
drop _m


replace hhd_psnp=100 if hhd_psnp==1

foreach i in maize_cg barley_cg sorghum_cg qpm dtmz {
	replace `i'=100 if `i'==1

}

rename nom_totcons_aeq nmtotcons
rename hhd_mintillage hhd_mintil
rename hhd_sweetpotato hhd_sp
rename  total_cons_ann_win totconswin
replace hhd_impcr2=. if maize_cg==.

*HH level 
#delimit;
global hhdemo age_head hhd_flab flivman parcesizeHA  asset_index pssetindex income_offfarm 
total_cons_ann totconswin nmtotcons consq1 consq2 adulteq 
;
#delimit cr

#delimit;
global adopt hhd_rdisp hhd_motorpump hhd_rotlegume hhd_cresidue1 hhd_cresidue2 
hhd_mintil hhd_zerotill hhd_consag1 hhd_consag2 hhd_swc hhd_terr hhd_wcatch hhd_affor 
hhd_ploc hhd_ofsp hhd_awassa83 hhd_avocado hhd_papaya hhd_mango  hhd_fieldp hhd_sp 
hhd_cross  hhd_crlr  hhd_crpo  hhd_indprod hhd_grass hhd_psnp maize_cg sorghum_cg 
barley_cg dtmz hhd_impcr2 hhd_impcr1
;
#delimit cr
*ex


*qpm dtmz

matrix drop _all
 
foreach i in   $adopt {

    foreach var in $hhdemo {

        qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==100
        matrix  `var'mt`i'=e(b)'
        scalar  `var'mt`i'= `var'mt`i'[1,1]

        matrix define `var'Vt`i'= e(V)'
        matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
        matrix list `var'VVt`i'
        scalar `var'vart`i'=`var'VVt`i'[1,1]
        scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])



        qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
        matrix  `var'mc`i'=e(b)'
        scalar  `var'mc`i'= `var'mc`i'[1,1]
        matrix define `var'Vc`i'= e(V)'
        matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
        matrix list `var'VVc`i'
        scalar `var'varc`i'=`var'VVc`i'[1,1]
        scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])


        qui sum `i' if `i'==0  & wave==4
        local controbs`i'=r(N)

        qui sum `i' if `i'==100 & wave==4
        local treatobs`i'=r(N)


        matrix mstrhelp`i'=(0,0,0,0,0)


            
        scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

        *scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

        qui: reg `var' `i' if  wave==4 [pw=pw_w4]
        *local t = _b[`i']/_se[`i']
        *scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
        test `i'=0
        scalar `var'pval`i'=r(p)

        qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
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

    matrix C=nullmat(C), AA`i'
    matrix C_STARS=nullmat(C_STARS), A`i'_STARS

}

local rname ""
foreach var in $hhdemo {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" " " "'		
}

local ceqname ""
foreach var in $adopt {
    local lbl : variable label `var'
    local ceqname `" `ceqname' "`lbl'" "`lbl'" "`lbl'" "`lbl'" "`lbl'" "'		
}


#delimit ;
xml_tab C,  save("$table\Table14_ess4_panel.xml") replace sheet("Table_1_hh_ESS4", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq( `ceqname' ) showeq ///
rblanks(COL_NAMES "HH level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 1: ESS4 - HH demo )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  
14 55,  15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 
27 55, 28 55, 29 55, 30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below. , Stars represent level of statistical significance of t-test/chi-squared test of difference in means. ); //Add your notes here
# delimit cr



* Wave 4: EA level

use "${data}\\ess4_pp_cov_ea_new", clear

* retain only panel EAs:
merge 1:1 ea_id using "${data}\ess5_pp_ea_new", keepusing(ea_id) keep(3)
drop _m

replace commirr=100 if commirr==1
rename ead_sweetpotato ead_sp
rename ead_mintillage ead_mtill

rename Dist_CG_LargeR  d1
rename Dist_CG_SmallR d2
rename Dist_CG_chicken d3
rename Dist_CG_Avocado d4
rename Dist_CG_DTMZ d5
rename Dist_CG_CA d6
rename Dist_CG_OFSP d7
rename Dist_CG_NUME d8
rename Dist_CG_SLM d9
rename Dist_CG_Barley d10
rename Dist_CG_Sorghum d11

foreach i in ead_psnp maize_cg sorghum_cg barley_cg  dtmz qpm ead_impcr2 ead_impcr1 {
    replace `i'=100 if `i'==1
}
replace ead_impcr2=. if maize_cg==.
replace ead_impcr1=. if barley_cg==.


*Adoption status
*ESS4
#delimit;
global adopt4 ead_ofsp ead_awassa83 ead_avocado ead_papaya ead_mango ead_fieldp 
ead_sp ead_motorpump ead_rdisp ead_rotlegume ead_cresidue1 ead_cresidue2 ead_mtill 
ead_zerotill ead_consag1 ead_consag2 ead_swc ead_terr ead_wcatch ead_affor ead_ploc  
commirr ead_cross ead_crlr ead_crpo ead_livIA ead_indprod ead_grass 
ead_psnp maize_cg sorghum_cg barley_cg dtmz 
;
#delimit cr


*ESS4
#delimit;
global eacov4 cs9q01 cs6q12_11 cs6q12_12 cs6q12_13 cs6q12_14 cs6q13_11 cs6q13_12 
cs6q13_13 cs6q13_14 cs6q14_11 cs6q14_12 cs6q14_13 cs6q14_14 cs6q15_11 cs6q15_12 
cs6q15_13 cs4q011 cs4q012 cs4q013 cs4q014 cs4q03 cs4q08 cs4q11 cs4q14 cs4q52 cs6q10 
cs4q02 cs4q02wiz cs4q01 cs4q09 cs4q09wiz cs4q11 cs4q12b cs4q12bwiz cs4q15 
cs4q15wiz cs3q02 cs3q02wiz cs4q52 cs4q53 csdq53wiz 
;
#delimit cr

matrix drop _all
 
foreach i in   $adopt4 {

    foreach var in $eacov4 {

        qui: mean    `var' [pw=pw_w4]           if wave==4 & `i'==100

        if _rc==2000 {  // error code = 2000. no observations [see "help error"]
            matrix  `var'mt`i'=0
            matrix define `var'Vt`i'= 0
            scalar `var'set`i'=0
            }
        else if _rc!=0 {  // all other errors
            error _rc
            }
        else {
            matrix  `var'mt`i'=e(b)'
            scalar  `var'mt`i'= `var'mt`i'[1,1]

            matrix define `var'Vt`i'= e(V)'
            matrix define `var'VVt`i'=(vecdiag(`var'Vt`i'))'
            matrix list `var'VVt`i'
            scalar `var'vart`i'=`var'VVt`i'[1,1]
            scalar `var'set`i'=sqrt(`var'VVt`i'[1,1])
            }

        qui: mean `var' [pw=pw_w4]              if  wave==4 & `i'==0
        if _rc==2000 {  // error code = 2000. no observations [see "help error"]
            matrix  `var'mc`i'=0
            matrix define `var'Vc`i'= 0
            scalar `var'sec`i'=0
            }
        else if _rc!=0 {  // all other errors
            error _rc
            }
        else {
            matrix  `var'mc`i'=e(b)'
            scalar  `var'mc`i'= `var'mc`i'[1,1]
            matrix define `var'Vc`i'= e(V)'
            matrix define `var'VVc`i'=(vecdiag(`var'Vc`i'))'
            matrix list `var'VVc`i'
            scalar `var'varc`i'=`var'VVc`i'[1,1]
            scalar `var'sec`i'=sqrt(`var'VVc`i'[1,1])
        }

    qui sum `i' if `i'==0  & wave==4
    local controbs`i'=r(N)

    qui sum `i' if `i'==100 & wave==4
    local treatobs`i'=r(N)


    matrix mstrhelp`i'=(0,0,0,0,0)


        
    scalar `var'df`i'=(`var'mt`i'-`var'mc`i') //Simple difference

    *scalar `var'df`i'=((`var'mt`i'-`var'mc`i') / sqrt((`var'vart`i'+ `var'varc`i')/2))

    qui: reg `var' `i' if  wave==4 [pw=pw_w4]
    *local t = _b[`i']/_se[`i']
    *scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
    test `i'=0
    scalar `var'pval`i'=r(p)

    qui: reg `var' `i'   i.region if  wave==4 [pw=pw_w4]
    *local t = _b[`i']/_se[`i']
    *scalar `var'pval`i' = 2*ttail(e(df_r), abs(`t'))
    test `i'=0
    scalar `var'pvalf`i'=r(p)



    matrix mat`var'`i'  = (`var'mt`i',  `var'mc`i', `var'df`i', `var'pval`i', `var'pvalf`i') 
    matrix mat1`var'`i' = (`var'set`i', `var'sec`i',         .,            .,             .) 

        if (`var'pval`i'==. & `var'pvalf`i'==.) {
            matrix mstr`var'`i' = (0, 0, 0, 0, 0) 
        }

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

matrix C=nullmat(C), AA`i'
matrix C_STARS=nullmat(C_STARS), A`i'_STARS

}

local rname ""
foreach var in $eacov4 {
    local lbl : variable label `var'
    local rname `"  `rname'   "`lbl'" " " "'		
}

local ceqname ""
foreach var in $adopt4 {
    local lbl : variable label `var'
    local ceqname `" `ceqname' "`lbl'" "`lbl'" "`lbl'" "`lbl'" "`lbl'" "'		
}

#delimit ;
xml_tab C,  save("$table\Table14_ess4_panel.xml") append sheet("Table_2_ea_ESS4", nogridlines)  ///
rnames(`rname' "Total No. of obs.") cnames(`cnames')
ceq(`ceqname') showeq ///
rblanks(COL_NAMES "EA level data" S2220)	 /// Adds blank columns which are used to separate Treatment and Control graphically.
title(Table 3: ESS4 - EA level )  font("Times New Roman" 10) ///
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55, 13 55,  14 55,  
15 55, 16 55, 17 55, 18 55, 19 55, 20 55, 21 55, 22 55, 23 55, 24 55, 25 55, 26 55, 27 55, 28 55, 29 55, 
30 55, 31 55, 32 55, 33 55, 34 55, 35 55, 36 55, 37 55, 38 55, 39 55, 40 55  ) /// *Adjust the column width of the table, column 0 are the variable names* 1, 5 and 9 are the blank columns. 
	format((SCLR0) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) 
    (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3) (NBCR3))  /// * format the columns. Each parentheses represents one column*
	stars(* 0.1 ** 0.05 *** 0.01)  /// Define your star values/signs here (which are stored in B_STARS)
	lines(SCOL_NAMES 2 COL_NAMES 2 LAST_ROW 2)  /// Draws lines in specific format (Numeric Value)
	notes(Point estimates are weighted sample means. Standard errors are reported below., 
    Stars represent level of statistical significance of t-test/chi-squared test of difference in means. 
    Rural sample only ); //Add your notes here
# delimit cr
