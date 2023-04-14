********************************************************************************
*                           Ethiopia Synthesis Report 
*                     DO: 5_psnp (Productive Safety Net Program)
* Country: Ethiopia 
* Data: ESS 5
* Author: Paola Mallia | p.mallia@cgiar.org | paola_mallia@ymail.com 
* STATA Version: SE 16.1
********************************************************************************

* Household level for PSNP

* ESS4

*use "${rawdata}/HH/sect_cover_hh_w5.dta", clear
use "${rawdata}/HH/sect1_hh_w5.dta", clear
/*
merge 1:m household_id using "${rawdata}/HH/sect1_hh_w5.dta"
drop _m 
*/
merge 1:1 individual_id household_id using "${rawdata}/HH/sect2_hh_w5.dta"
drop _m
/*
merge 1:1 individual_id household_id using "${rawdata}/HH/sect3_hh_w4.dta"
drop _m
*/
merge 1:1 individual_id household_id using "${rawdata}/HH/sect4_hh_w5.dta"
drop _m

* Individual dummy
gen psnp=.
replace psnp=0 if s4q45==2
replace psnp=1 if s4q45==1
* Household dummy
egen hhd_psnp=max(psnp), by(household_id)
* Nb. of members per hh
egen hhm_psnp=count(psnp) if psnp==1, by(household_id)
* Nb. of days per hh
egen hh_dpsnp=sum(s4q46) if psnp==1, by(household_id)
* Nb. of days per member per hh
g hh_dpsnppc=hh_dpsnp/hhm_psnp
* Income per hh
egen hh_ipsnp=sum(s4q47) if psnp==1, by(household_id)

* Daily wage per individual
gen dwpsnppc=s4q47/s4q46 if psnp==1
* Avg. daily wage per member per hh.
egen hh_dwpsnp=mean(dwpsnppc), by(household_id)
* Conversion birr to dollar ( rate of 15/9/2015)
*replace hh_dwpsnp=hh_dwpsnp/20.9653 if hhd_psnp==1
*replace hh_ipsnp=hh_ipsnp/20.9653 if hhd_psnp==1

egen hh_ea=count(household_id), by(ea_id)
egen hhea_psnp=sum(hhd_psnp), by(ea_id)

collapse (max) hhd_psnp  hhm_psnp  hh_dpsnp hh_dpsnppc hh_ipsnp hh_dwpsnp hh_ea ///
    hhea_psnp (firstnm) saq14  ea_id pw_w5  saq01 , by(household_id)


label var hhd_psnp    "At least 1 member benefitting from PSNP" 
label var hhm_psnp    "No. of members per hh benefitting from PSNP"
label var hh_dpsnp    "No. of days per year hh benefitting from PSNP"
label var hh_dpsnppc  "No. of days per year hh benefitting from PSNP - per member"
label var hh_ipsnp    "Total income per hh per year from PSNP - USD"
label var hh_dwpsnp   "Avg. daily income per hh-member from PSNP"
label var ea_id       "ea id"
label var pw_w5       "Sampling weight - wave 5" 


save "${data}/ess5_hh_psnp.dta", replace


* EA - level 

egen ead_psnp=max(hhd_psnp), by(ea_id)
gen sh_ea_psnp=hhea_psnp/hh_ea

collapse (max) ead_psnp sh_ea_psnp (firstnm) saq14 saq01 pw_w5, by(ea_id)

label var ead_psnp   "At least 1 hh benefitting from PSNP"
label var sh_ea_psnp "Perc. of hh per EA benefitting from PSNP"
label var pw_w5      "Sampling weight - wave 5" 
label var saq14      "Rural/Urban"
label var saq01      "Region code"

save "${data}/ess5_ea_psnp.dta", replace
