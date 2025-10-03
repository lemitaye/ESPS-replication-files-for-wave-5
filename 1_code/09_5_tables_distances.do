


use "${data}/ess5_pp_cov_ea_new.dta", clear


#delimit;
global adoptcg ead_ofsp ead_avocado ead_rotlegume ead_cresidue1 ead_cresidue2 
ead_consag1 ead_consag2 ead_swc ead_terr ead_wcatch ead_affor ead_ploc 
ead_crlr ead_crsr ead_crpo maize_cg dtmz 
;
#delimit cr

#delimit;
global eacov4 d25_LargeR d50_LargeR d75_LargeR d100_LargeR d125_LargeR d150_LargeR 
d25_SmallR d50_SmallR d75_SmallR d100_SmallR d125_SmallR d150_SmallR d25_chicken 
d50_chicken d75_chicken d100_chicken d125_chicken d150_chicken d25_Avocado 
d50_Avocado d75_Avocado d100_Avocado d125_Avocado d150_Avocado d25_DTMZ 
d50_DTMZ d75_DTMZ d100_DTMZ d125_DTMZ d150_DTMZ d25_CA d50_CA d75_CA d100_CA 
d125_CA d150_CA d25_OFSP d50_OFSP d75_OFSP d100_OFSP d125_OFSP d150_OFSP 
d25_SLM d50_SLM d75_SLM d100_SLM d125_SLM d150_SLM
;
#delimit cr


// matrix of regs:
covar_regress $adoptcg, covar($eacov4) wt(pw_w5)

local cname ""
foreach var in $eacov4 {
    local lbl : variable label `var'
    local cname `" `cname' "`lbl'" "'		
}

local rname ""
foreach var in $adoptcg {
	local lbl : variable label `var'
	local rname `" `rname' "`lbl'" "'		
}

#delimit ;
xml_tab D,  save("$table/09_5_ess5_distances.xml") replace 
sheet("Table32_ea", nogridlines)  
rnames(`rname') cnames(`cname') lines(COL_NAMES 2 LAST_ROW 2)  
title("Table: ESS4 - Correlates of adoption")  font("Times New Roman" 10) 
cw(0 110, 1 55, 2 55, 3 55, 4 55, 5 55, 6 55, 7 55, 8 55, 9 55, 10 55, 11 55, 12 55) 
	format((SCLR0) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) (NBCR2) 
    (NBCR2) (NBCR2) (NBCR2) (NBCR2))  
	stars(* 0.1 ** 0.05 *** 0.01)  
	notes("Each cell is a coefficient estimate from a separate regression of the 
	column variable on the row variable."); 
# delimit cr