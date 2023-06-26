// Description: ---
// Date created: May 17, 2023
// Author: Lemi Daba (tayelemi@gmail.com)


capture program drop gen_synergy

program gen_synergy
    version 17.0
    args lvl

    // NRM
    cap generate nrm=0
    cap replace nrm=1 if `lvl'_treadle==1 | `lvl'_motorpump==1 | `lvl'_rdisp==1 | `lvl'_swc==1 ///
        | `lvl'_terr==1 | `lvl'_wcatch==1 | `lvl'_affor==1 | `lvl'_ploc==1  

    cap generate ca=0
    cap replace ca=1 if `lvl'_consag1==1 | `lvl'_consag2==1 

    cap generate ca1=0
    cap replace ca1=1 if `lvl'_rotlegume==1 | `lvl'_cresidue2==1  

    cap generate ca2=0
    cap replace ca2=1 if `lvl'_rotlegume==1 | `lvl'_mintillage==1  

    cap generate ca3=0
    cap replace ca3=1 if `lvl'_rotlegume==1 | `lvl'_zerotill==1 

    cap generate ca4=0
    cap replace ca4=1 if `lvl'_cresidue2==1 | `lvl'_mintillage==1 

    cap generate ca5=0
    cap replace ca5=1 if `lvl'_cresidue2==1 | `lvl'_zerotill==1 


    // Crop
    cap generate crop=0
    cap replace crop=1 if `lvl'_ofsp==1  | `lvl'_awassa83==1  |  `lvl'_fieldp==1  | `lvl'_sweetpotato==1  

    cap generate tree=0
    cap replace tree=1 if `lvl'_avocado==1  | `lvl'_papaya==1  | `lvl'_mango==1  

    cap generate animal=0
    cap replace animal=1 if  `lvl'_elepgrass==1  | `lvl'_sesbaniya==1  |  `lvl'_alfalfa==1  | `lvl'_agroind==1 
    
    cap generate breed=0
    cap replace breed=1 if `lvl'_cross==1  | `lvl'_crlr==1  | `lvl'_crsm==1  | `lvl'_crpo==1  | `lvl'_livIA==1 

    cap generate breed2=0
    cap replace breed2=1 if `lvl'_crlr==1  | `lvl'_crsm==1   | `lvl'_livIA==1 

    * psnp
    cap clonevar psnp=`lvl'_psnp
    cap generate psnp2=`lvl'_psnp_any

    *Different combinations of CA practices
    cap generate rotlegume=0
    cap replace rotlegume=1 if `lvl'_rotlegume==1 

    cap generate cresidue=0
    cap replace cresidue=1 if `lvl'_cresidue2==1  

    cap generate mintillage=(`lvl'_mintillage==1)  
    cap generate zerotill=(`lvl'_zerotill==1)  

    cap lab var nrm                "NRM"
    cap lab var ca                 "CA"
    cap lab var crop               "Crop varieties"
    cap lab var tree               "Trees"
    cap lab var animal             "Feed and Forages"
    cap lab var breed              "Breeding"
    cap lab var breed2             "Breeding (excl. poultry)"
    cap lab var psnp               "PSNP"
    cap lab var psnp2              "PSNP (both)"
    cap lab var rotlegume          "Crop rotation with legume"
    cap lab var cresidue           "Crop residue cover" 
    cap lab var mintillage         "Minimum tillage"
    cap lab var zerotill           "Zero tillage"  
    cap lab var ca1                "CA1"
    cap lab var ca2                "CA2"
    cap lab var ca3                "CA3"
    cap lab var ca4                "CA4"
    cap lab var ca5                "CA5"


    local vars nrm ca crop tree animal breed breed2 psnp psnp2 rotlegume cresidue ///
        mintillage zerotill ca1 ca2 ca3 ca4 ca5 

    local vars2  ca crop tree animal breed breed2 psnp psnp2 rotlegume cresidue ///
        mintillage zerotill ca1 ca2 ca3 ca4 ca5


    foreach var of local vars {
        local lbl : variable label `var'

        foreach i of local vars2 {
            local lbl2 : variable label `i'
            cap generate `var'_`i'=(`var'*`i') 
            cap label variable `var'_`i' `" `lbl' & `lbl2'"'
        }
    }

end
  
