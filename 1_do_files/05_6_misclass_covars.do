********************************************************************************
*                           Ethiopia Synthesis Report - v2
*                     DO: Correlates of misclassification
* Country: Ethiopia 
* Data: ESS4 (replication files) and ESS 5
* Author: Lemi Daba (tayelemi@gmail.com) 
*         [code adopted from Paola Mallia from ESS4 rep. file]
* STATA Version: MP 17.0
********************************************************************************


use "${tmp}/missclass/06_3_misclass_year.dta", clear


* To what extent does misclassification depend on source of seed? -------------

// collapsing source to two categories:
recode s5q03_1 (1/4 10 = 1) (5/8 99 = 2), generate(source)
label define source 1 "Government and related" 2 "Market and related"
label values source source

// tables generated from the following:

// 1.
foreach var in maize_tp1 maize_tn1 maize_fp1 maize_fn1 {
    mean `var' [pw=pw_w5] if source==1
    mean `var' [pw=pw_w5] if source==2
}

tab s5q02
tab source
count if cg_source=="Yes" & source==1
count if cg_source=="Yes" & source==2
count if cg_source=="No" & source==1
count if cg_source=="No" & source==2

// 2.
foreach var in maize_tp2a maize_fn2a maize_tp2b maize_fn2b maize_tp2c maize_fn2c {
    mean `var' [pw=pw_w5] if source==1
    mean `var' [pw=pw_w5] if source==2
}

count if cg_source=="Yes" & purity_percent>=70 & source==1
count if cg_source=="Yes" & purity_percent>=70 & source==2
count if cg_source=="Yes" & purity_percent>=90 & source==1
count if cg_source=="Yes" & purity_percent>=90 & source==2
count if cg_source=="Yes" & purity_percent>=95 & source==1
count if cg_source=="Yes" & purity_percent>=95 & source==2

// 3.
foreach var in maize_tp3abis maize_fn3abis maize_tp3bbis maize_fn3bbis maize_tp3cbis maize_fn3cbis {
    mean `var' [pw=pw_w5] if source==1
    mean `var' [pw=pw_w5] if source==2
}

count if cg_source=="Yes" & year>=1990 & source==1
count if cg_source=="Yes" & year>=1990 & source==2
count if cg_source=="Yes" & year>=2000 & source==1
count if cg_source=="Yes" & year>=2000 & source==2
count if cg_source=="Yes" & year>=2010 & source==1
count if cg_source=="Yes" & year>=2010 & source==2

    