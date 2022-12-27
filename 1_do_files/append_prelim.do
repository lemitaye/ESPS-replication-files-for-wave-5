
* Appending LSMS data; waves 4 and 5

clear all

global root "C:\Users\tayel\Dropbox\Documents\SPIA\Ethiopia"
global w4raw "${root}\replication_files\2_raw_data\ESS4_2018-19\Data"
global w5raw "${root}\LSMS_W5\2_raw_data\data\PP"

* read wave4 data:
use "${w4raw}\sect3_pp_w4", clear
generate wave = "wave4"

preserve
	use "${w5raw}\sect3_pp_w5", clear
	generate wave = "wave5"
	tempfile wave5_pp
	save `wave5_pp'
restore

append using `wave5_pp', force

* The following variables were flagged:
label list s3q02b s3q03b s3q04 s3q07 s3q10 s3q11 s3q12 s3q18 s3q19 s3q20 \\\ 
s3q25a s3q26a s3q27a s3q32 s3q35 s3q36 s3q37 s3q39 s3q41 s3q42 saq01 saq14 saq15

* Value labels have changed for the following:
* s3q07; s3q11 (minor); s3q35 (one label added); s3q36 (label for 5 different); 
* s3q39 (labels rearranged starting from 5)