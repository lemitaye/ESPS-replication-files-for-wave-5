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


* matrix of misclassification --------------------------------------------------

use "${tmp}/missclass/06_3_misclass_year.dta", clear

gen correct_w5=.
replace correct_w5=1 if maize_tp1==1 | maize_tn1==1
replace correct_w5=0 if maize_fp1==1 | maize_fn1==1

collapse (max) correct_w5, by(household_id)

preserve
    use "${supp}/replication_files/3_report_data/misclassification_plot_new.dta", clear

    keep if maize==1
    drop barley_* sorghum_*

    gen correct_w4=.
    replace correct_w4=1 if maize_tp1==1 | maize_tn1==1
    replace correct_w4=0 if maize_fp1==1 | maize_fn1==1

    collapse (max) correct_w4, by(household_id)

    tempfile correct_hh_w4
    save `correct_hh_w4'
restore

merge 1:1 household_id using `correct_hh_w4'
keep if _merge==3
drop _merge

// table presented 
tab correct_w4 correct_w5

