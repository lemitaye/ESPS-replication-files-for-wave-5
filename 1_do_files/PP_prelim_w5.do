
/*

Created on: November 24, 2022
Author: Lemi Taye Daba (tayelemi@gmail.com)
Purpose: Preliminary analysis of the LSMS-ESS5 data

*/

clear all

global root "C:\Users\tayel\Dropbox\Documents\SPIA\Ethiopia\LSMS_W5"

* COVER:
use "$root\PP\sect_cover_pp_w5", clear

* SECTION 1: HOUSEHOLD ROSTER
use "$root\PP\sect1_pp_w5", clear

* SECTION 2: PARCEL ROSTER
use "$root\PP\sect2_pp_w5", clear

* SECTION 3: FIELD ROSTER
use "$root\PP\sect3_pp_w5", clear

* SECTION 4: CROP ROSTER
use "$root\PP\sect4_pp_w5", clear

* SECTION 5: SEEDS ROSTER
use "$root\PP\sect5_pp_w5", clear

* SECTION 9: CROP ROSTER
use "$root\PP\sect9a_pp_w5", clear
