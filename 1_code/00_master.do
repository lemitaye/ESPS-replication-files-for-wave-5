
*==============================================================================*
*                        Ethiopia Synthesis Report - v 2.0 
*                                MASTER DO-FILE
* Country: Ethiopia 
* Data: ESS3, ESS4, & ESS5
* Author: Lemi Taye Daba (tayelemi@gmail.com) 
*  [with code adopted from Paola Mallia (paola_mallia@ymail.com) from rep. file]  
* STATA Version: MP 17.0
* Created on: November 24, 2022
*==============================================================================*

clear all
clear matrix
capture log close

*------------------------------------------------------------------------------*
*  USER WRITTEN PACKAGES (uncomment and run if not already installed)
*------------------------------------------------------------------------------*
/* 
ssc install xml_tab, replace
ssc install winsor2, replace
ssc install estout, replace
*/

*------------------------------------------------------------------------------*
*  DIRECTORIES
*------------------------------------------------------------------------------*

global root     "C:/Users/l.daba/SPIA Dropbox/SPIA General/5. OBJ.3 - Data collection/Country teams/Ethiopia/LSMS_W5"
global code     "${root}/1_code"
global rawdata  "${root}/2_raw_data/data"
global data     "${root}/3_report_data"
global table    "${root}/4_table"
global supp     "${root}/supplemental"
global tmp      "${root}/tmp"

global dataw4   "${supp}/replication_files/3_report_data"
global raw4     "${supp}/replication_files/2_raw_data/ESS4_2018-19/Data"
global raw3     "${supp}/replication_files/2_raw_data/ESS3_2015-16/Data"


*------------------------------------------------------------------------------*
*  RUN
*------------------------------------------------------------------------------*

* Household -----------
do "${code}/01_0_hh.do"

* Community -----------
do "${code}/02_0_community.do"

* Post-Planting -----------
do "${code}/03_0_pp.do"

* Covariates -----------
do "${code}/04_0_covariates.do"

* Misclassification -----------
do "${code}/05_0_misclass.do"

* Dynamics -----------
do "${code}/06_0_dynamics.do"

* Chickpea -----------
do "${code}/07_0_chickpea.do"


* Tables -----------
do "${code}/09_0_tables.do"

* Adoption reach -----------
do "${code}/10_0_adopt_reach.do"


*------------------------------------------------------------------------------*
*  END
*------------------------------------------------------------------------------*