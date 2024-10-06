* RD results with stayers, where winning politicians have to be in the firm at least in T+1 (politicians have to be present in t) -- recall that growth variables are from t to t+1.

cap log close

clear all

log using "$dir_logs/regs_RD_stay_t.log", text replace


use "$dir_data\data_RD.dta", clear
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



****************************************************************************************************************
*Table C3
****************************************************************************************************************
qui rd growth_L_t margin, mbw(100) 
 local IK=`e(w)' 
 
cap drop weights
gen weights = .
replace weights = (1 - abs(margin/`IK')) if margin<=`IK' & margin>=-`IK'

reg growth_L_t  win_dummy margin margin_pos [aw = weights]  ///
if margin<=`IK' & margin>=-`IK', r
estimates store col1


reghdfe growth_L_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] ///
if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col2


reg growth_LP_t  win_dummy margin margin_pos [aw = weights]  ///
if margin<=`IK' & margin>=-`IK', r
estimates store col3


reghdfe growth_LP_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] ///
if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col4



esttab col1 col2 col3 col4 using "$dir_tables\TableC3_RD_stay_t.tex", replace fragment booktabs label se nocons drop(*margin* _cons) ///
starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines  ///
nomtitles




*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
* Figure 5 panel c and panel d
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~

keep if  margin>=-.2 & margin<=.2


//create different bins
// m - how wide the margin is.
// b - bin width. 

// Generating Figures 5a and 5B

 foreach m of numlist 10 {
 foreach b of numlist 0.01 {
 
preserve
keep if  margin>=-`m'/100 & margin<=`m'/100

local numbins=2*`m'/`b'/100

 
cap drop marg_`m'_bins_`numbins'
gen marg_`m'_bins_`numbins'=.  //midpoints of bins
quietly forval i = `numbins'(-1)1 {
	replace marg_`m'_bins_`numbins'=-`m'/100+`b'*`i'-`b'/2 if margin <= -`m'/100+`b'*`i' & margin>=-`m'/100+`b'*(`i'-1)
 }

foreach var of varlist growth_L_t  growth_LP_t  {


cap drop yhat*  stderror* int*
cap drop `var'_bins
bys marg_`m'_bins_`numbins': egen `var'_bins=mean(`var')
 
regress `var' win_dummy margin margin2 margin3 margin_pos margin2_pos margin3_pos
quietly predict yhat
quietly predict stderror, stdp
gen intU = -_b[_cons] + yhat + 1.64*stderror
gen intL = -_b[_cons] +  yhat - 1.64*stderror

replace yhat = -_b[_cons] + yhat
replace `var'_bins= -_b[_cons] + `var'_bins
sort margin

twoway rarea intU intL margin if margin>0.002, color(gs13) lwidth(vvthin) lpattern(dash) fintensity(10) ///
|| rarea intU intL margin if margin<-0.002 , color(gs13) lwidth(vvthin) fintensity(10) ///
|| scatter `var'_bins  marg_`m'_bins_`numbins' if margin<-0.002, color(forest_green) msymbol(Oh) msize(medsmall) mlwidth(medium) ///
|| scatter `var'_bins  marg_`m'_bins_`numbins' if margin>0.002, color(forest_green) msymbol(Oh) msize(medsmall) mlwidth(medium) ///
|| line  intU yhat intL margin if margin>0.002, clcolor(gray gs7 gray) clpattern( dash solid dash) lwidth( vvvthin thick vvvthin ) ///
|| line  intU yhat intL margin if margin<-0.002, clcolor(gray gs7 gray) clpattern( dash solid dash) lwidth( vvvthin thick vvvthin ) ///
, xline(0, lwidth(thick) lcolor(black)) graphregion(color(white)) legend(off) xtitle(Victory Margin)
graph save "$dir_figures/Figure5_stay_t_`var'.gph", replace
graph export "$dir_figures/Figure5_stay_t_`var'.pdf", replace



}
 
restore 
}
		
}		




*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
* Figure C4, panel c and panel d
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~

keep if  margin>=-.2 & margin<=.2


//create different bins
// m - how wide the margin is.
// b - bin width. We experiment with 1% and 2% wide bins.


 foreach m of numlist 20 {
 foreach b of numlist 0.02 {
 
preserve
keep if  margin>=-`m'/100 & margin<=`m'/100

local numbins=2*`m'/`b'/100

 
cap drop marg_`m'_bins_`numbins'
gen marg_`m'_bins_`numbins'=.  //midpoints of bins
quietly forval i = `numbins'(-1)1 {
	replace marg_`m'_bins_`numbins'=-`m'/100+`b'*`i'-`b'/2 if margin <= -`m'/100+`b'*`i' & margin>=-`m'/100+`b'*(`i'-1)
 }

foreach var of varlist growth_L_t  growth_LP_t  {


cap drop yhat*  stderror* int*
cap drop `var'_bins
bys marg_`m'_bins_`numbins': egen `var'_bins=mean(`var')
 
regress `var' win_dummy margin margin2 margin3 margin_pos margin2_pos margin3_pos
quietly predict yhat
quietly predict stderror, stdp
gen intU = -_b[_cons] + yhat + 1.64*stderror
gen intL = -_b[_cons] +  yhat - 1.64*stderror

replace yhat = -_b[_cons] + yhat
replace `var'_bins= -_b[_cons] + `var'_bins
sort margin

twoway rarea intU intL margin if margin>0.002, color(gs13) lwidth(vvthin) lpattern(dash) fintensity(10) ///
|| rarea intU intL margin if margin<-0.002 , color(gs13) lwidth(vvthin) fintensity(10) ///
|| scatter `var'_bins  marg_`m'_bins_`numbins' if margin<-0.002, color(forest_green) msymbol(Oh) msize(medsmall) mlwidth(medium) ///
|| scatter `var'_bins  marg_`m'_bins_`numbins' if margin>0.002, color(forest_green) msymbol(Oh) msize(medsmall) mlwidth(medium) ///
|| line  intU yhat intL margin if margin>0.002, clcolor(gray gs7 gray) clpattern( dash solid dash) lwidth( vvvthin thick vvvthin ) ///
|| line  intU yhat intL margin if margin<-0.002, clcolor(gray gs7 gray) clpattern( dash solid dash) lwidth( vvvthin thick vvvthin ) ///
, xline(0, lwidth(thick) lcolor(black)) graphregion(color(white)) legend(off) xtitle(Victory Margin)
graph save "$dir_figures/FigureC4_stay_t_`var'.gph", replace
graph export "$dir_figures/FigureC4_stay_t_`var'.pdf", replace



}
 
restore 
}
		
}

log close
