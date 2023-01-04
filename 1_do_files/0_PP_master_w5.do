
/*
Created on: November 24, 2022
Author: Lemi Taye Daba (tayelemi@gmail.com)
Purpose: Preliminary analysis of the LSMS-ESS5 data
*/

clear all

* to be added to master later
global root     "C:\Users\tayel\Dropbox\Documents\SPIA\Ethiopia\LSMS_W5"
global code     "$root\1_do_files"
global rawdata  "$root\2_raw_data\data"
global data     "$root\3_report_data"
global table    "$root\4_table"
global tmp      "$root\tmp"


do "${code}\01_PP_cover_sect2_parcel.do"
do "${code}\02_PP_sect3_field.do"
do "${code}\03_PP_sect4_crop.do"
do "${code}\04_PP_sect81_livestock.do"
do "${code}\05_PP_merge.do"


