* RDD regression for politicians who are newly elected vs the ones with experience
* Do-file produces Appendix Table C5.

cap log close

clear all

log using "$dir_logs/regs_RD_new_old_pols.log", text replace

foreach name in oldpol newpol  {

use "$dir_data/data_RD.dta", clear
gen oldpol=(mwin_polits_exper_t<2)  // for convenience, they are defined in the opposite way and then the drop command is appropriate
gen newpol=(mwin_polits_exper_t>=2) if mwin_polits_exper_t!=.

drop if `name'==1  


gen win_dummy=1 if nmwin_t_1!=.
replace win_dummy=0 if nmlost_t_1!=.


sum margin_spread1, d
gen margin= margin_spread1 if win_dummy==1
replace margin= -margin_spread1 if win_dummy==0


drop if win_dummy!=0 & win_dummy!=1

 gen margin2=margin^2
 gen margin3=margin^3
 gen margin4=margin^4


 gen margin_pos=margin*win_dummy
 gen margin2_pos=margin2*win_dummy
 gen margin3_pos=margin3*win_dummy
 gen margin4_pos=margin4*win_dummy
 
 

//side note: for equivalence of methods btw below regression and rd and rdrobust, see auxiliary do-file PC_EXAMPLES_RD_METHOD.do*
qui rd growth_L_t margin
local IK =`e(w)'

cap drop weights
gen weights = .
replace weights = (1 - abs(margin/`IK')) if margin<=`IK' & margin>=-`IK'

reg growth_L_t  win_dummy margin margin_pos [aw = weights] if margin<=`IK' & margin>=-`IK', r
estimates store col1


reghdfe growth_L_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col2

esttab col1 col2  using "$dir_tables\TableC5_`name'.tex", replace fragment booktabs label se nocons drop(*margin* _cons)  starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines   nomtitles


}

log close