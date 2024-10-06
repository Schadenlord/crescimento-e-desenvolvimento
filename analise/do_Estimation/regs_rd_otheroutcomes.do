* This do-file peoduces additional RD results for other outcomes
* Appenxid Table C.4.


cap log close

clear all

log using "$dir_logs/regs_RD_otheroutcomes.log", text replace

use "$dir_data\data_RD.dta", clear

  preserve
gen win_dummy=1 if nmwin_t_1!=.
replace win_dummy=0 if nmlost_t_1!=.

tab win_dummy


sum margin_spread1,d
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



*global myvars growth_VA growth_TFP_t  EFD_t growth_invest_t
*su $myvars, d

//code similar to benchmark regs_RD and regs_RD_stay_t
// for t-growth variables
qui rd growth_L_t margin, mbw(100) 
 local IK=`e(w)'
	cap drop weights
    gen weights = .
    replace weights = (1 - abs(margin/`IK')) if margin<=`IK' & margin>=-`IK'
	reghdfe growth_VA_t  win_dummy margin margin_pos age_t_1 logL_t logVA_t [aw = weights] if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
    estimates store col1
	reghdfe growth_TFP_t  win_dummy margin margin_pos age_t_1 logL_t logVA_t [aw = weights] if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
    estimates store col2
	reghdfe EFD_t  win_dummy margin margin_pos age_t_1 logL_t logVA_t [aw = weights] if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
    estimates store col3
	reghdfe growth_invest_t  win_dummy margin margin_pos age_t_1 logL_t logVA_t [aw = weights] if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
    estimates store col4

	restore
	
// for t+1-growth variables. Recall that t+1-growth variables are from t+1 to the t+2 period. Need to condition on election winners staying in the firm as in stayers-analysis earlier (RD_regs_stay_t).
	
   preserve
gen win_dummy=1 if nmwin_t_1!=.
replace win_dummy=0 if nmlost_t_1!=.
tab win_dummy, mi


drop if win_dummy!=0 & win_dummy!=1
tab win_dummy, mi

gen win_dummy2=win_dummy
replace win_dummy2=. if win_dummy==1 & nmwin_t==. //these condition on having a politician in t
replace win_dummy2=. if win_dummy==0 & nmlost_t==.

tab win_dummy win_dummy2, mi

drop if win_dummy2!=0 & win_dummy2!=1

gen win_dummy3=win_dummy2

/* Discard casese when there are no winning politicians in t+1 */
replace win_dummy3=. if win_dummy3==1 & nmwin_tp1==.
drop if win_dummy3!=0 & win_dummy3!=1

// rename windummy so as to run the same code as in the main RD program
replace win_dummy=win_dummy3
drop win_dummy2 win_dummy3

gen margin= margin_spread1 if win_dummy==1
replace margin= -margin_spread1 if win_dummy==0

gen margin2=margin^2
gen margin3=margin^3
gen margin4=margin^4

gen margin_pos=margin*win_dummy
gen margin2_pos=margin2*win_dummy
gen margin3_pos=margin3*win_dummy
gen margin4_pos=margin4*win_dummy
qui rd growth_L_t margin, mbw(100) 
 local IK=`e(w)'	
cap drop weights
    gen weights = .
    replace weights = (1 - abs(margin/`IK')) if margin<=`IK' & margin>=-`IK'
	reghdfe growth_VA_tp1  win_dummy margin margin_pos age_t_1 logL_t logVA_t  [aw = weights] if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)	
	estimates store col5

    restore

esttab col1 col5 col2 col3 col4 using "$dir_tables\TableC4_otheroutcomes.tex", keep (win_dummy) replace fragment booktabs label se nocons starlevels(* 0.10 ** 0.05 *** 0.01)  gaps lines mtitles("VA growth(t)" "VA growth(t+1)" "TFP growth(t)" "EFD(t)" "invest(t)")

	

log close
