
/*
Created on: November 24, 2022
Author: Lemi Taye Daba (tayelemi@gmail.com)
Purpose: Preliminary analysis of the LSMS-ESS5 data
*/

clear all

* d. Installation of packages
* ssc install xml_tab, replace
* ssc install winsor2, replace
* ssc install estout, replace
* ssc install rsource, replace   // enables to run R code from within Stata

* to be added to master later
global root     "C:/Users/l.daba/OneDrive/SPIA/Ethiopia/LSMS_W5"
global code     "$root/1_do_files"
global rawdata  "$root/2_raw_data/data"
global aux      "$root/2_raw_data/auxiliary"
global data     "$root/3_report_data"
global table    "$root/4_table"
global supp     "$root/supplemental"
global tmp      "$root/tmp"

/*
* Call all do files:
do "${code}/01_0_hh.do"
do "${code}/02_0_community.do"
do "${code}/03_0_pp.do"
*do "${code}/04_0.do"
*do "${code}/05_0.do"


