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


lab var hhd_psnp    "At least 1 member benefitting from PSNP" 
lab var hhm_psnp    "No. of members per hh benefitting from PSNP"
lab var hh_dpsnp    "No. of days per year hh benefitting from PSNP"
lab var hh_dpsnppc  "No. of days per year hh benefitting from PSNP - per member"
lab var hh_ipsnp    "Total income per hh per year from PSNP - USD"
lab var hh_dwpsnp   "Avg. daily income per hh-member from PSNP"
lab var ea_id       "ea id"
lab var pw_w5       "Sampling weight - wave 5" 

clonevar region=saq01
replace region=0 if saq01==2 | saq01==6 | saq01==15 | saq01==12 | saq01==13 | saq01==5

gen othregion=0
replace othregion=saq01 if  saq01==2 | saq01==6 | saq01==15 | saq01==12 | saq01==13 | saq01==5

gen wave=5


save "${data}/ess5_hh_psnp.dta", replace

/*
* EA - level 

egen ead_psnp=max(hhd_psnp), by(ea_id)
gen sh_ea_psnp=hhea_psnp/hh_ea

collapse (max) ead_psnp sh_ea_psnp (firstnm) saq14 wave region othregion saq01 pw_w5, by(ea_id)

lab var ead_psnp   "Perc. of EA with at least 1 hh benefitting from PSNP"
lab var sh_ea_psnp "Perc. of hh per EA benefitting from PSNP"
lab var wave       "wave"
lab var region     "region"
lab var othregion  "other regions"
lab var pw_w5      "Sampling weight - wave 4" 

save "${data}/ess4_ea_psnp.dta", replace




