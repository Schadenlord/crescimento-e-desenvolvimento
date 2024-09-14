* This do-file produces the main RD results:
* Table VII TableVIII TableIX 
* Figure5 a&b  Figure6  FigureC4 a&b

*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
* RD tables
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~


cap log close

clear all

log using "$dir_logs/regs_RD.log", text replace


use "$dir_data\data_RD.dta", clear
gen win_dummy=1 if nmwin_t_1!=.
replace win_dummy=0 if nmlost_t_1!=.


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



//side note: for equivalence of methods btw below regression and rd and rdrobust, see auxiliary do-file examples_rd_method.do
qui rd growth_L_t margin, mbw(100) 
 local IK=`e(w)' // IK bandwidth

 
* Table VII: benchmark RD (linear fit, triangular kernel)

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



esttab col1 col2 col3 col4 using "$dir_tables\TableVII_RD.tex", replace fragment booktabs label se nocons drop(*margin* _cons) ///
starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines  ///
nomtitles



* Table VIII, panel a, uniform kernel function


reg growth_L_t  win_dummy margin margin_pos   ///
if margin<=`IK' & margin>=-`IK', r
estimates store col1


reghdfe growth_L_t  win_dummy margin margin_pos age_t_1 logL_t   ///
if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col2


reg growth_LP_t  win_dummy margin margin_pos  ///
if margin<=`IK' & margin>=-`IK', r
estimates store col3


reghdfe growth_LP_t  win_dummy margin margin_pos age_t_1 logL_t  ///
if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col4



esttab col1 col2 col3 col4 using "$dir_tables\TableVIII_panel_a_uniform.tex", replace fragment booktabs label se nocons drop(*margin* _cons) ///
starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines  ///
nomtitles


* Table VIII, panel b, quadratic polynomial


cap drop weights
gen weights = .
replace weights = (1 - abs(margin/ `IK')) if margin<=`IK' & margin>=-`IK'

reg growth_L_t  win_dummy margin margin_pos margin2 margin2_pos [aw = weights]  ///
if margin<=`IK' & margin>=-`IK', r
estimates store col1


reghdfe growth_L_t  win_dummy margin margin_pos margin2 margin2_pos age_t_1 logL_t  [aw = weights] ///
if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col2


reg growth_LP_t  win_dummy margin margin_pos margin2 margin2_pos [aw = weights]  ///
if margin<=`IK' & margin>=-`IK', r
estimates store col3


reghdfe growth_LP_t  win_dummy margin margin_pos margin2 margin2_pos age_t_1 logL_t  [aw = weights] ///
if margin<=`IK' & margin>=-`IK', vce(robust)  absorb(i.year i.prov_num)
estimates store col4


esttab col1 col2 col3 col4 using "$dir_tables\TableVIII_panel_b_quadratic.tex", replace fragment booktabs label se nocons drop(*margin* _cons) ///
starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines  ///
nomtitles


* Table VIII, panel c, 20% margin of victory 

cap drop weights
gen weights = .
replace weights = (1 - abs(margin/ .2)) if margin<=0.2 & margin>=-0.2

reg growth_L_t  win_dummy margin margin_pos [aw = weights]  ///
if margin<=0.2 & margin>=-0.2, r
estimates store col1


reghdfe growth_L_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] ///
if margin<=0.2 & margin>=-0.2, vce(robust)  absorb(i.year i.prov_num)
estimates store col2


reg growth_LP_t  win_dummy margin margin_pos [aw = weights]  ///
if margin<=0.2 & margin>=-0.2, r
estimates store col3


reghdfe growth_LP_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] ///
if margin<=0.2 & margin>=-0.2, vce(robust)  absorb(i.year i.prov_num)
estimates store col4



esttab col1 col2 col3 col4 using "$dir_tables\TableVIII_panel_c_margin20.tex", replace fragment booktabs label se nocons drop(*margin* _cons) ///
starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines  ///
nomtitles


* Table VIII, panel c, 10% margin of victory 

cap drop weights
gen weights = .
replace weights = (1 - abs(margin/ .1)) if margin<=0.1 & margin>=-0.1

reg growth_L_t  win_dummy margin margin_pos [aw = weights]  ///
if margin<=0.1 & margin>=-0.1, r
estimates store col1


reghdfe growth_L_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] ///
if margin<=0.1 & margin>=-0.1, vce(robust)  absorb(i.year i.prov_num)
estimates store col2


reg growth_LP_t  win_dummy margin margin_pos [aw = weights]  ///
if margin<=0.1 & margin>=-0.1, r
estimates store col3


reghdfe growth_LP_t  win_dummy margin margin_pos age_t_1 logL_t  [aw = weights] ///
if margin<=0.1 & margin>=-0.1, vce(robust)  absorb(i.year i.prov_num)
estimates store col4



esttab col1 col2 col3 col4 using "$dir_tables\TableVIII_panel_d_margin10.tex", replace fragment booktabs label se nocons drop(*margin* _cons) ///
starlevels(* 0.10 ** 0.05 *** 0.01) gaps lines  ///
nomtitles



*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
* Table IX: Balancing tests
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~


gen east_dummy=( geoarea=="NORD-EST")
gen west_dummy=( geoarea=="NORD-OVEST")
gen north_dummy=(geoarea=="NORD-OVEST" | geoarea=="NORD-EST")
gen centro_dummy=( geoarea=="CENTRO")
gen southisl_dummy=( geoarea=="SUD" | geoarea=="ISOLE")



// same RD design for each variable. Our baseline table.
foreach var of varlist  logL_t_1 logVA_t_1 logassets_t_1  ///
logintang_t_1 logLP_t_1 logprof_t_1  ///
 growth_L_t_1 growth_LP_t_1 age_t_1 centro_dummy north_dummy {
qui rd `var' margin, mbw(100) 
 local IK=`e(w)' // IK bandwidth

 
cap drop weights
gen weights = .
replace weights = (1 - abs(margin/`IK')) if margin<=`IK' & margin>=-`IK'

qui reg `var'  win_dummy margin margin_pos [aw = weights]  ///
if margin<=`IK' & margin>=-`IK', r
estimates store `var'_col1


}

esttab  logL_t_1_col1 logVA_t_1_col1  logassets_t_1_col1  logintang_t_1_col1 logLP_t_1_col1  logprof_t_1_col1   ///
growth_L_t_1_col1 growth_LP_t_1_col1 age_t_1_col1 centro_dummy_col1 north_dummy_col1  using "$dir_tables/TableIX_balancing_test.tex", replace se keep(win_dummy) starlevels(* 0.1 ** 0.05 *** 0.01)




*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~
* Figures 5a, 5b, 6a and 6b; Appendix Figures C4a, C4b
*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~

keep if  margin>=-.2 & margin<=.2


//create different bins
// m - how wide the margin is.
// b - bin width. 

// Generating Figures 5a and 5b

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
graph save "$dir_figures/Figure5_`var'.gph", replace
graph export "$dir_figures/Figure5_`var'.pdf", replace



}
 
restore 
}
		
}		

// Generating Figures 6a and 6b

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

 
foreach var of varlist growth_L_t_1 growth_LP_t_1   {


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
graph save "$dir_figures/Figure6_`var'.gph", replace
graph export "$dir_figures/Figure6_`var'.pdf", replace



}
 
restore 
}
		
}	


// Generating Appendix Figures C4a and C4b

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
graph save "$dir_figures/FigureC4_`var'.gph", replace
graph export "$dir_figures/FigureC4_`var'.pdf", replace


}
 
restore 
}
		
}		

log close
