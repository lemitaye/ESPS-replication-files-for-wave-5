* Community survey 

*Community Irrigation Scheme (only for rural EAs): ESS5

use "${rawdata}/Community/sect06_com_w5", clear

merge 1:1 ea_id using "${rawdata}/Community/sect03_com_w5"
drop _m

generate commirr=.
replace  commirr=0 if cs6q10==2 // Ics6q10: s there an irrigation scheme in this community?
replace  commirr=1 if cs6q10==1
lab var commirr "Community Irrigation Scheme"


generate shhh_commirr=.
replace  shhh_commirr=cs6q11/cs3q04b if cs6q11!=. & cs6q11<cs3q04b 
// cs6q11: How many farmers from the community in total farm in the irrigation scheme?
// cs3q04b: Approximately how many households practice?
replace  shhh_commirr=1 if cs6q11!=. & cs6q11>cs3q04b
replace  shhh_commirr=0 if cs6q11==. & commirr==0
lab var shhh_commirr "Share of farmers that farm in the irrigation scheme (out of tot. no. of hh in community)"

keep ea_id saq01 saq14 commirr shhh_commirr  

tempfile commirr
save `commirr'


* Digital green: video-based extension
use "${rawdata}/Community/sect12_com_w5", clear

generate comm_video=.
replace comm_video=1 if s12q01==1 & (s12q02_1==1 | s12q02_1==3 | s12q02_2==1 | s12q02_2==3 | s12q02_os=="back yard Vegitable production")
replace comm_video=0 if s12q01==2 | (s12q01==1 & s12q02_1==2) // crop, nutrition and backyard=1; health=0

generate comm_video_all=.
replace comm_video_all=1 if s12q01==1 
replace comm_video_all=0 if s12q01==2 // includes health

label var comm_video "Community video based extension - crop, nutrition & backyard"
label var comm_video_all "Community video based extension - health included"

keep ea_id comm_video comm_video_all

tempfile comm_video
save `comm_video'


* 2WT based tech.
use "${rawdata}/Community/sect11_com_w5", clear

generate comm_2wt_own=.
replace comm_2wt_own=1 if s11q01==1 & (cs11q00==1 | cs11q00==2 | cs11q00==3 | cs11q00==4 | cs11q00==5)
replace comm_2wt_own=0 if s11q01==2 & (cs11q00==1 | cs11q00==2 | cs11q00==3 | cs11q00==4 | cs11q00==5)

generate comm_2wt_use=.
replace comm_2wt_use=1 if s11q03==1 & (cs11q00==1 | cs11q00==2 | cs11q00==3 | cs11q00==4 | cs11q00==5)
replace comm_2wt_use=0 if s11q03==2 & (cs11q00==1 | cs11q00==2 | cs11q00==3 | cs11q00==4 | cs11q00==5)

collapse (max) comm_2wt_own comm_2wt_use, by(ea_id)

label var comm_2wt_own "Two-wheel tractor - Ownership"
label var comm_2wt_use "Two-wheel tractor - Usage"

tempfile comm_2wt
save `comm_2wt'


* community psnp
use "${rawdata}/Community/sect09_com_w5", clear

generate comm_psnp=.
replace comm_psnp=1 if cs9q01==1
replace comm_psnp=0 if cs9q01==2

label var comm_psnp "Community PSNP"

keep ea_id comm_psnp

tempfile comm_psnp
save `comm_psnp'

* merge:
use `commirr', clear

merge 1:1 ea_id using `comm_video'
drop _m

merge 1:1 ea_id using `comm_2wt'
drop _m

merge 1:1 ea_id using `comm_psnp'
drop _m

save "${data}/ess5_community_new.dta", replace 

