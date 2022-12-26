
/*

Created on: November 24, 2022
Author: Lemi Taye Daba (tayelemi@gmail.com)
Purpose: Preliminary analysis of the LSMS-ESS5 data

*/

clear all

* to be added to master later
global root     "C:\Users\tayel\Dropbox\Documents\SPIA\Ethiopia\LSMS_W5"
global rawdata  "$root\2_raw_data"
global data     "$root\3_report_data"

********************************************************************************
* COVER - PP
******************************************************************************** 

use "${rawdata}\data\PP\sect_cover_pp_w5", clear

count //2,110
* tostring saq12, force replace   // What is the reason for converting hh_size (saq12) to string
* destring saq16, force replace

tab saq14      // PP moduls is available only for rural households.
/*

        14. |
  Location: |
     rural, |
town, small |
       town |      Freq.     Percent        Cum.
------------+-----------------------------------
   1. RURAL |      2,110      100.00      100.00
------------+-----------------------------------
      Total |      2,110      100.00

*/

tab saq01  // The entire region of Tigray is missing
/*
         Region code |      Freq.     Percent        Cum.
---------------------+-----------------------------------
             2. AFAR |         85        4.03        4.03
           3. AMHARA |        302       14.31       18.34
           4. OROMIA |        413       19.57       37.91
           5. SOMALI |        261       12.37       50.28
6. BENISHANGUL GUMUZ |        109        5.17       55.45
             7. SNNP |        434       20.57       76.02
         12. GAMBELA |        178        8.44       84.45
           13. HARAR |        185        8.77       93.22
       15. DIRE DAWA |        143        6.78      100.00
---------------------+-----------------------------------
               Total |      2,110      100.00
*/  

isid holder_id   // holder_id is a uniuqe ID 

* # of households per EA from PP cover
egen hh_ea = count(household_id), by(ea_id)
lab var hh_ea "Number of households per EA"

duplicates drop household_id ea_id saq01 saq02 saq03 saq04 saq05 saq06 saq07 /// 
                saq08, force

tempfile w5_coverPP
save `w5_coverPP'

save "${data}\w5_coverPP_new", replace
