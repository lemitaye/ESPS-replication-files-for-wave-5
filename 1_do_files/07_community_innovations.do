* Community survey 

*Community Irrigation Scheme (only for rural EAs): ESS5

use "${rawdata}\Community\sect06_com_w5", clear

merge 1:1 ea_id using "${rawdata}\Community\sect03_com_w5"
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

keep commirr shhh_commirr ea_id 
save "${data}\ess5_community_new", replace 