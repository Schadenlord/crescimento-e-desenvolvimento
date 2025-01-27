* This code generates Figure 7 on wage premium and also collects some other statistics on wage premium mentioned in the text.

cap log close
log using "$dir_logs/log_wagepremium.log", replace

use "$dir_data/everpolit_wages_foreventstudy.dta", replace

gen premium_polit=imp_tot_wk_indiv/mean_wage_nonpol
label var premium_polit "wage premium relative to co-workers"

gen premium_polit2=imp_tot_wk_indiv/mean_wage_nonpol_contin
label var premium_polit2 "wage premium relative to continuing co-workers"


// define events:
bys id_soggetto id_impresa: egen Iyr=min(year)
label var Iyr "First year of the employee in the firm"
by id_soggetto : egen aux=min(year) if politician==1
by id_soggetto : egen Iyr_pol=max(aux)
label var Iyr "First year of the employee in the firm"
drop aux


egen indiv_firm_id=group(id_soggetto id_impresa)
tsset indiv_firm_id year


gen switch_to_pol=(year==Iyr_pol & Iyr_pol!=Iyr  & year==Iyr_pol)
by indiv_firm_id: gen timeline=-10 if f10.switch_to_pol==1
by indiv_firm_id: replace timeline=-9 if f9.switch_to_pol==1
by indiv_firm_id: replace timeline=-8 if f8.switch_to_pol==1
by indiv_firm_id: replace timeline=-7 if f7.switch_to_pol==1
by indiv_firm_id: replace timeline=-6 if f6.switch_to_pol==1
by indiv_firm_id: replace timeline=-5 if f5.switch_to_pol==1
by indiv_firm_id: replace timeline=-4 if f4.switch_to_pol==1
by indiv_firm_id: replace timeline=-3 if f3.switch_to_pol==1
by indiv_firm_id: replace timeline=-2 if f2.switch_to_pol==1
by indiv_firm_id: replace timeline=-1 if f.switch_to_pol==1
by indiv_firm_id: replace timeline=0 if switch_to_pol==1
by indiv_firm_id: replace timeline=1 if l.switch_to_pol==1
by indiv_firm_id: replace timeline=2 if l2.switch_to_pol==1
by indiv_firm_id: replace timeline=3 if l3.switch_to_pol==1
by indiv_firm_id: replace timeline=4 if l4.switch_to_pol==1
by indiv_firm_id: replace timeline=5 if l5.switch_to_pol==1
by indiv_firm_id: replace timeline=6 if l6.switch_to_pol==1
by indiv_firm_id: replace timeline=7 if l7.switch_to_pol==1
by indiv_firm_id: replace timeline=8 if l8.switch_to_pol==1
by indiv_firm_id: replace timeline=9 if l9.switch_to_pol==1
by indiv_firm_id: replace timeline=10 if l10.switch_to_pol==1


keep if timeline!=.

//check that those firms are present year before politics
by indiv_firm_id: egen test=max(timeline==-1)
drop if test==0 // drop if not present in time -1 -- we need before-event presence
by indiv_firm_id: egen test2=max(timeline==0)
tab test2 // just checking that everyone has an event. True by definition and is ok.
by indiv_firm_id: egen test3=max(timeline==1)
drop if test3==0 // drop if not present in time +1 -- we need after-event presence

drop if year==1993 // truncation in defining continuing coworkers

// define event time dummies
forvalues i=1/10{
gen t_p`i' =( timeline==`i')
tab t_p`i'
}
forvalues i=1/10 {
gen t_m`i' =( timeline==-`i')
tab t_m`i'
}
gen t_0 =( timeline==0)
tab t_0


* Figure 7: Benchmark plot with politician premium relative to all co-workers

//ommited group at t=-1
areg premium_polit t_m10 t_m9 t_m8 t_m7 t_m6 t_m5 t_m4 t_m3 t_m2 t_0 t_p1- t_p10 i.year, absorb(age) r
estimates save "$dir_ster/premium_polit_event.ster", replace
coefplot , drop(_cons *year* *age* t_m10 t_p10 ) vertical title("Wage Premium")

// now, create a nice-looking plot out of these coefficients

preserve
matrix result_matrix = e(b)\vecdiag(e(V))
matrix rownames result_matrix = premium_polit_b premium_polit_v
matrix regresults = nullmat(regresults)\result_matrix

matrix list regresults
svmat regresults

keep regresults*
drop if _n>2


xpose, clear
drop if _n>20
rename v1 coeff
rename v2 var

gen timeline=.

forvalue i=-10/-2 {

replace timeline=`i' if _n==`i'+11
}

forvalue i=0/10 {

replace timeline=`i' if _n==`i'+10
}

// add observation with the ommitted group
expand 2 in 1
replace coeff=0 if _n==21
replace var=0 if _n==21
replace timeline=-1 if _n==21

sort timeline
// done with data organization


// now, plot
generate high= coeff + 1.96*sqrt(var)
generate low= coeff - 1.96*sqrt(var)

replace coeff=coeff*100
replace high=high*100
replace low=low*100


gen upper=6
gen lower=-2
gen test=1 if timeline<=1 & timeline>=-1


twoway (rarea upper lower timeline if test==1, color(gs15) lwidth(medium) fintensity(49) ) ///
(line high coeff low timeline if timeline>-10 & timeline<10, ///
clcolor(gs13 red gs13) clpattern(dash solid dash) lwidth(medium medthick medium) ///
xtitle("Timeline") ytitle("Within-firm Wage Premium, %") ///
xscale(range(-10 10)) legend(off) graphregion(color(white))) ///
(scatter coeff timeline if timeline>-10 & timeline<10, color(brown)) 
graph export "$dir_figures/Figure 7_wagepremium.pdf", replace


restore





************************
* Additional plot for wage premium relative to stable co-workers from previous year.
areg premium_polit2 t_m10 t_m9 t_m8 t_m7 t_m6 t_m5 t_m4 t_m3 t_m2 t_0 t_p1- t_p10 i.year, absorb(age) r
estimates save "$dir_ster/premium_polit2_event.ster", replace
coefplot , drop(_cons *year* *age* t_m10 t_p10 ) vertical title("Wage Premium")




************************
* Some stats reported on politicians wage premium relative to coworkers of the same gender and job type (white-collar or blue-collar)

use "$dir_data/nowconn_firms_workers_wages.dta", clear

gsort id_soggetto id_impresa year -imp_tot_wk_indiv
by  id_soggetto id_impresa year: keep if _n==1

winsor2 imp_tot_wk_indiv imp_tot_wk_indiv_v2, cut(0.1 99.9) replace

* stats for any politician
preserve

collapse imp_tot_wk_indiv, by( politician female white_collar id_impresa year) 

sort id_impresa year female white_collar politician
by id_impresa year female white_collar: gen premium_pol=imp_tot_wk_indiv[2]/imp_tot_wk_indiv[1]

by id_impresa year female white_collar: drop if _n==2
drop if prem==.


collapse  (mean)  premium_all_mean=premium_pol (sd) premium_all_sd=premium_pol (median)  premium_all_med=premium_pol  (count) premium_all_n=premium_pol, by (white_collar female) 

list

restore


* stats for province-level and regional politicians:


foreach var of varlist politician_region politician_prov      {
preserve
drop if politician==1 &  `var'!=1  //leave only specific polits and non-polits 

collapse imp_tot_wk_indiv, by( politician female white_collar id_impresa year) 

sort id_impresa year female white_collar politician
by id_impresa year female white_collar: gen premium_pol=imp_tot_wk_indiv[2]/imp_tot_wk_indiv[1]

by id_impresa year female white_collar: drop if _n==2
drop if prem==.


collapse  (mean)  premium_`var'_mean=premium_pol (sd) premium_`var'_sd=premium_pol  (median)  premium_`var'_med=premium_pol  (count) premium_`var'_n=premium_pol, by (white_collar female) 

list
restore
}


cap log close





* This do-file produces Appendix Table D.1 and Appendix Figure D.1.
* list of sectors with bureacracy indices and mean connections.
* and polit connections.


clear all
use "$dir_data/factiva_bur_conn.dta"

*export Appendix Table D1
gsort -share_conn
texsave * using "$dir_tables\TabD1.tex", replace

*plot Appendix Figure D.1
binscatter share_conn gov_bur_index1 ,  ///
graphregion(color(white)) legend(off) xtitle("Bureaucracy Index 1") ytitle("Share of connected firms")
graph export "$dir_figures/FigureD1_a.pdf",  replace


binscatter share_conn gov_bur_index2 ,  ///
graphregion(color(white)) legend(off) xtitle("Bureaucracy Index 2") ytitle("Share of connected firms")
graph export "$dir_figures/FigureD1_b.pdf", replace

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
* Do-file to get Table III Statistics on Local Politicians
 
clear all 

use "$dir_data/data_polticians_short.dta", clear

count
distinct codice_fiscale

tab cat_area
tab cat_pos


matrix sumstat = J(7, 1,.)

count if cat_area==3
matrix sumstat[1,1]=r(N)/_N*100

count if cat_area==2
matrix sumstat[2,1]=r(N)/_N*100

count if cat_area==1
matrix sumstat[3,1]=r(N)/_N*100 


count if cat_pos==1 | cat_pos==2
matrix sumstat[4,1]=r(N)/_N*100

count if cat_pos==3
matrix sumstat[5,1]=r(N)/_N*100

count if cat_pos==4
matrix sumstat[6,1]=r(N)/_N*100

sum maj
matrix sumstat[7,1]=r(mean)*100

matrix list sumstat


cd "$dir_tables"
frmttable using "TabIII_sumstat_polits", tex fragment nocenter plain hlines(110000001) statmat(sumstat) sdec(2) sfmt(fc) replace /// 
rtitles( "Region" \ "Province" \ "Municipalty" \ ///
"Mayor, President, Vice-mayor, Vice-president" \ "Executve councilor" \ "Council member" \ "Majorty") ///
ctitles("Position" "Percent")


* This do-file produces Appendix Figure D.2.

clear all

use "$dir_data/data_govdep_conn.dta", clear

binscatter share_conn dep_govt ,  ///
graphregion(color(white)) legend(off) xtitle("Government Dependence Index 1") ytitle("Share of connected firms")
graph export "$dir_figures/FigD2_a.pdf", replace


binscatter share_conn dep_govt_CP ,  ///
graphregion(color(white)) legend(off) xtitle("Government Dependence Index 2") ytitle("Share of connected firms")
graph export "$dir_figures/FigD2_b.pdf", replace




*This code generates Table IV: Summary Statistics of the Matched Firm-Level Datasummary


clear all
scalar drop _all

use "$dir_data/firmdata_stats.dta", clear

global VarsToSummarize = "employment_march	av_pay_wk	growth_empl_smooth	tot_assets_defl	growth_VA	growth_LP	growth_TFP	npat_yr	npat_famsize_yr	npat_ncit5_yr	conn_d	conn_high_d	conn_maj_d	npolit_cf_mis	npolit_maj_mis	npolit_high_cf_mis"


// Sample All firms

putexcel set "$dir_tables/TabIV_sumstats_firmlevel", replace
putexcel A1="Sample All Firms"

putexcel A2="Variable"
putexcel B2="Mean"
putexcel C2="Median"
putexcel D2="St dev"


local j=2

count
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


count if conn_d ==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa if everconn==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


foreach var in $VarsToSummarize {

sum `var', d
local j=`j'+1

putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel A`j'="`var'"
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(mean)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel C`j'=`r(p50)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel D`j'=`r(sd)'
}

local j=`j'+2
putexcel A`j'="Sample Balance Sheet"


***************
// Sample with non-missing Balance Sheet

keep if merge_inpsbs==3

count
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


count if conn_d ==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa if everconn==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


foreach var in $VarsToSummarize {

sum `var', d
local j=`j'+1

putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel A`j'="`var'"
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(mean)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel C`j'=`r(p50)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel D`j'=`r(sd)'
}


* the excel output is manually converted to tex file to obtain the appearance as in the paper



* This program produces Appendix Table B.4 on Characteristics of Politicians and Non-Politician Employees

clear all


use "$dir_data/nowconn_firms_workers_wages.dta", replace


sum white_collar if politician == 1
scalar wcollar_pol=r(mean)

sum white_collar if politician == 0
scalar wcollar_nonpol=r(mean)

sum full_time if politician == 1
scalar ftime_pol=r(mean)

sum full_time if politician == 0
scalar ftime_nonpol=r(mean)

sum female if politician == 1
scalar fem_pol=r(mean)

sum female if politician == 0
scalar fem_nonpol=r(mean)

sum imp_tot_wk_indiv_v2 if politician == 1
scalar wkwage_pol=r(mean)

sum imp_tot_wk_indiv_v2 if politician == 0
scalar wkwage_nonpol=r(mean)

sum age if politician == 1
scalar age_pol=r(mean)

sum age if politician == 0
scalar age_nonpol=r(mean)

count if politician == 1
scalar count_pol=r(N)

count if politician == 0
scalar count_nonpol=r(N)



scalar list _all
matrix sumstats = J(6,2,.)

matrix sumstats[1,1]=wcollar_pol
matrix sumstats[2,1]=ftime_pol
matrix sumstats[3,1]=wkwage_pol
matrix sumstats[4,1]=age_pol
matrix sumstats[5,1]=fem_pol
matrix sumstats[6,1]=count_pol

matrix sumstats[1,2]=wcollar_nonpol
matrix sumstats[2,2]=ftime_nonpol
matrix sumstats[3,2]=wkwage_nonpol
matrix sumstats[4,2]=age_nonpol
matrix sumstats[5,2]=fem_nonpol
matrix sumstats[6,2]=count_nonpol

matrix list sumstats

cd "$dir_tables"
frmttable using "TabB4_pol_nonpol_stats.tex", tex fragment nocenter statman(sumstats) sdec(2) sfmt(fc) replace ///
rtitles("White-collar" \ "Full-time" \ "Wages" \ "Age" \ "Female" \ "Observations") ///
ctitles("Variables" "Politicians" "Non-politicians")
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

log close* This do-file generates Cox survival results in Table VI


clear all


use "$dir_data/data_cox.dta", replace

sort id_impresa year
gen survival_dummy=(year!=yr_exit)
label var survival_dummy "Dummy=1 if survives to next year (even with a gap)"

gen died=(year==yr_exit)

stset year, failure(died) id(id_impresa) origin(yr_entry)


stcox conn_d logempl logmarket_share i.year i.ateco_1d, nohr iter (20) efron
estimates save "$dir_ster/cox_conn_dster", replace
estadd local Controls  = "Yes"
est store m1

stcox conn_d conn_maj_d logempl logmarket_share i.year i.ateco_1d, nohr iter (20)  efron
estimates save "$dir_ster/cox_connmaj_dster", replace
estadd local Controls  = "Yes"
est store m2

stcox conn_d conn_high_d logempl logmarket_share i.year i.ateco_1d, nohr iter (20) efron
estimates save "$dir_ster/cox_connhigh_dster", replace
estadd local Controls  = "Yes"
est store m3


esttab m1 m2 m3 using  "$dir_tables/TabVI_Cox.tex" , replace drop(*year *ateco* logempl logmarket_share) t(2) b(3) coeflabels(conn_d "Connection" conn_maj_d "Connection major" conn_high_d "Connection high-rank" ) ///
nonotes gaps lines  se star(* 0.10 ** 0.05 *** 0.01)  ///
stat(Controls N, labels("Other controls & Year, Industry FE" "Observations"))


* Paper: Connecting to Power: Political Connections, Innovation, and Firm Dynamics
* Authors: Ufuk Akcigit, Salome Baslandze, and Francesca Lotti
* October 2022


/* This program has all the do-files for estimation
*/

ssc install binscatter
ssc install egenmore
ssc install texsave

* Path structure. To run, change to local directory owndir

local owndir = "\18338_Data_and_Programs\Data_Programs" //to run the full program, put the complete path to the archived folder on the INPS server.

global dir_data = "`owndir'/Data"
global dir_tables = "`owndir'/Results/Tables"
global dir_figures = "`owndir'/Results/Figures"
global dir_data_interm = "`owndir'/Data_interm"
global dir_ster= "`owndir'/Results/Sters"
global dir_logs= "`owndir'/Results/Logs"
global dir_do_construction = "`owndir'/do_Data_Construction"
global dir_do_estimation = "`owndir'/do_Estimation"

set matsize 10000





 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table III Statistics on Local Politicians
do sumstats_politicians_all.do
/* Input: $dir_data/data_politicians_short.dta
Output: $dir_tables/TableIII_sumstats_polits.tex
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table IV Summary Statistics of the Matched Firm-Level Data
do stats_firmlevel.do // data summary stats (1993-2014)

/* Input: $dir_data/firmdata_stats.dta
Output: $dir_tables/TabIV_sumstats_firmlevel.xls
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Figure 3: Leadership Paradox: Market rank, Innovation, and Political connections
* Appendix Table C1: MARKET RANK, INNOVATION, AND POLITICAL CONNECTION
* Appendix Figure C.1.—LEADERSHIP PARADOX; ALTERNATIVE INNOVATION AND CONNECTION MEASURES
* Appendix Figure C.2.—Market Rank, Innovation, and Political Connection, with an Alternative Definition of Market Rank
* Appendix Figure C.3.—Market Rank, Innovation, and Political Connection, with Quality-adjusted Patent Intensity
do innov_conn_rank.do

/* Input: $dir_data/firmdata_rankanalysis.dta"  
Output:  $dir_tables/"$dir_tables/TabC1_innovconn_rank.tex".tex 
Fig3_part_patents_intensity_rank
Fig3_part_polits_intensity_rank
FigC1_part_intang_intensity_rank
FigC1_part_majpolits_intensity_rank
FigC2_intang_intensity_VArank
FigC2_majpolits_intensity_VArank
FigC2_patents_intensity_VArank
FigC2_polits_intensity_VArank
FigC3_patents_citadj_intensity_rank
FigC3_patents_famadj_intensity_rank

*/
  


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table V: POLITICAL CONNECTIONS AND MEASURES OF FIRM GROWTH
* Appendix Table C.2: POLITICAL CONNECTIONS AND GROWTH IN SIZE VERSUS PRODUCTIVITY. OTHER OUTCOMES
do regs_firm_level.do 

/* Input: $dir_data/firmdata_growthregs.dta"  
Output:  "$dir_tables/TabV_growthfirmlevel.tex"
         "$dir_tables/TabC2_growthfirmlevel.tex"
ster files in "$dir_ster
*/
				  
				  

 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
*Table VI: COX SURVIVAL ANALYSIS
do regs_survival.do

/* Input: $dir_data/data_cox.dta
Output:  "$dir_tables/TabVI_Cox.tex"
ster files in "$dir_ster
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* FIGURE 4.—PROBABILITY OF RE-ELECTION AGAINST THE MARGIN OF VICTORY
do reelection_prob.do 
/* Input: "$dir_data/data_reelection_incumbent.dta"
Output:  "$dir_figures/Figure_4_reelection.pdf"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* TABLE VII EMPLOYMENT AND PRODUCTIVITY GROWTH AFTER ELECTION. RD ESTIMATES.
* TABLE VIII EMPLOYMENT AND PRODUCTIVITY GROWTH AFTER ELECTION. RD ROBUSTNESS
* TABLE IX BALANCING TESTS
* FIGURE 5.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION (a, b)
* FIGURE 6.—PRE-TRENDS IN EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH BEFORE ELECTION
* APPENDIX FIGURE C.4.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION. 20% MARGIN OF VICTORY SAMPLE (a, b)
do regs_figs_rd.do 

/* Input: "$dir_data/data_rd.dta"
Output:  
Tables --
"$dir_tables/TableVII_RD.tex"
"$dir_tables/TableVIII_panel_a_uniform.tex"
"$dir_tables/TableVIII_panel_b_quadratic.tex"
"$dir_tables/TableVIII_panel_c_margin20.tex"
"$dir_tables/TableVIII_panel_d_margin10.tex"
"$dir_tables/TableIX_balancing_test.tex"

Figures --
"$dir_figures/Figure5_growth_L_t"  
"$dir_figures/Figure5_growth_LP_t" 
"$dir_figures/Figure6_growth_L_t_1"   
"$dir_figures/Figure6_growth_LP_t_1"
"$dir_figures/FigureC4_growth_L_t"  
"$dir_figures/FigureC4_growth_LP_t"
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX Table C.3.—Market Rank, Innovation, and Political Connection, with Quality-adjusted Patent Intensity
* FIGURE 5.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION (c, d)
* APPENDIX FIGURE C.4.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION. 20% MARGIN OF VICTORY SAMPLE (c, d)
do regs_rd_stay_t.do 

/* Input: "$dir_data/data_rd.dta"
Output:  
Tables --
"$dir_tables/TableC3_RD_stay_t.tex"

Figures --
"$dir_figures/Fgure5_stay_t_growth_L_t" XX correct name
"$dir_figures/Fgure5_stay_t_growth_LP_t" 
"$dir_figures/FgureC4_stay_t_growth_L_t" XX correct name
"$dir_figures/FgureC4_stay_t_growth_LP_t" 
*/
  
  
 

 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Figure 7: WITHIN-FIRM WAGE PREMIUM BEFORE AND AFTER BECOMING A POLITICIAN
do wagepremium.do

/* Input: "$dir_data/everpolit_wages_foreventstudy.dta" and also "$dir_data/nowconn_firms_workers_wages.dta" for stats
Output:  "$dir_figures/Figure 7_wagepremium.pdf" 
ster files in "$dir_ster"
stats in log file "$dir_logs/log_wagepremium.log"
*/
	  



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table X: POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS
* Table C.6: POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS. TRADABLE VS NON-TRADABLE 
* Table C.7: POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS. MANUFACTURING VS NON-MANUFACTURING
do regs_indreglevel.do

/* Input: $dir_data/data_indreg.dta
Output:  "$dir_tables/TabX_indreglevel.tex"      -- Table X
         "$dir_tables/TabC_indreglevel_trad.tex" -- Table C.6
		 "$dir_tables/TabC_indreglevel_mnfg.tex" -- Table C.7
ster files in "$dir_ster
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
                        * Appendix Files*
 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table B.1 Cross-Correlations of Various Patent Quality Measures
* Appendix Table B.2 Statistics on Patent Quality for Italian Patents (1990-2014)
do sumstat_patents.do 

/* Input: $dir_data/patents_ITfirms.dta
Output:  $dir_tables/TabB1_corr_patents.tex $dir_tables/TabB2_sumstat_patents.tex
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table B.3 Statistics on Local Politicians Employed in the Private Sector
do stats_politsample.do 

/* Input: $dir_data/pol_qualifica.dta  "$dir_data/politsID_sample_8514.dta" 
Output:  $dir_tables/TabB3_politsample_matched_stats.tex 
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table B.4 Characteristics of Politicians and Non-Politician Workers
do stats_polits_nonpolits.do 

/* Input: $dir_data/nowconn_firms_workers_wages.dta  
Output:  $dir_tables/TabB4_pol_nonpol_stats.tex 
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX TABLE C.4 RD ESTIMATES FOR OTHER OUTCOMES
do regs_rd_otheroutcomes.do

/* Input: "$dir_data/data_RD.dta"
Output:  
"$dir_tables/TableC4_otheroutcomes.tex"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX TABLE C.5 EMPLOYMENT GROWTH AFTER ELECTION. RDD FOR NEWLY ELECTED AND EXISTING POLITICIANS
do regs_rd_new_old_pols.do
/* Input: "$dir_data/data_RD.dta"
Output:  
"$dir_tables/TableC5_oldpol.tex"
"$dir_tables/TableC5_newpol.tex"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Figure C.5 DISTRIBUTION OF THE SHARE OF WINNING POLITICIANS ACROSS FIRMS, CONDITIONAL ON GETTING ANY SEAT
do distrib_winlose_elec.do 

/* Input: "$dir_data/data_RD.dta"
Output:  "$dir_figures/Figure_C5.pdf"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table C.9 CONNECTIONS AND ENTRY. CROSS-BORDER ANALYSIS
do regs_crossborder_analysis.do

/* Input: $dir_data/data_crossborder.dta
Output:  "$dir_tables/TabC9_PanelA_crossborder.tex"  "$dir_tables/TabC9_PanelB_crossborder.tex"
ster files in "$dir_ster
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX TABLE D.1.— POLITICAL CONNECTIONS AND BUREAUCRACY INDEX ACROSS INDUSTRIES
* APPENDIX FIGURE D.1.— BUREAUCRACY AND CONNECTIONS ACROSS INDUSTRIES
do descr_factiva_bur_conn.do 
/* Input: $dir_data/factiva_bur_conn.dta
Output:  
 "$dir_figures/FigureD1_a.pdf" 
 "$dir_figures/FigureD1_2.pdf"
 "$dir_tables/TabD1.tex"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX FIGURE D.2.— GOVERNMENT DEPENDENCE AND CONNECTIONS ACROSS INDUSTRIES
do govdep_conn_correlate.do
/* Input: $dir_data/data_govdep_conn.dta
Output:  
 "$dir_figures/FigureD2_a.pdf" 
 "$dir_figures/FigureD2_b.pdf"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
*APPENDIX TABLE D.2.— POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS. BUREAUCRACY, REGULATION, AND INSTITUTIONAL DEFICIENCY INDEXES 
do regs_bur_corru_reg.do


/* Input: "$dir_data/data_corruregbur_conn.dta"
Output:  "$dir_tables\TableD2_panel_bur.tex" 
"$dir_tables\TableD2_panel_corru.tex"
"$dir_tables\TableD2_panel_regu.tex"

*/


*This code generates Appendix Table D2, Panels A, B, C.

cap log close

log using "$dir_logs/regs_bur_corru_reg.log", replace

use "$dir_data/data_corruregbur_conn.dta", replace
 
*generate interactions
 
//single interactions
gen sh_nfirm_conn_bur_q75 = share_numfirm_conn*bur_q75
gen sh_inc_conn_bur_q75 = share_incumb_conn*bur_q75


//double interactions
gen sh_nfirm_conn_corru_bur_q75 = share_numfirm_conn*corru_bur_q75
gen sh_inc_conn_corru_bur_q75 = share_incumb_conn*corru_bur_q75

gen sh_nfirm_conn_regu_bur_q75 = share_numfirm_conn*regu_bur_q75
gen sh_inc_conn_regu_bur_q75 = share_incumb_conn*regu_bur_q75


*Appendix Table D2, Panel A

reghdfe growth_l share_numfirm_conn sh_nfirm_conn_bur_q75 [aw=numfirm_reg_ind_yr], absorb(year region ateco_07_2d)
			estimates store col1
		 
reghdfe entry_rate share_incumb_conn sh_inc_conn_bur_q75 [aw=numfirm_reg_ind_yr], absorb(year region ateco_07_2d)
			estimates store col2
			
reghdfe share_conn_entr share_incumb_conn sh_inc_conn_bur_q75 [aw=numfirm_reg_ind_yr], absorb(year region ateco_07_2d)
			estimates store col3
			
			
esttab col1 col2 col3 using "$dir_tables\TableD2_panel_bur.tex" , replace star(* 0.10 ** 0.05 *** 0.01) drop(_cons) se
	
	


//to export table in a better formatting, make some variable name change.
cap drop share_conn_regr
gen share_conn_regr=.

*Appendix Table D2, Panel B and Panel C
foreach name1 in corru regu   {
cap drop  share_conn_high_`name1'
cap drop high_`name1'

gen share_conn_high_`name1'=.
gen high_`name1'=.

replace share_conn_regr=share_numfirm_conn
replace share_conn_high_`name1'=sh_nfirm_conn_`name1'_bur_q75
replace high_`name1'=`name1'_bur_q75

	reghdfe growth_l share_conn_regr share_conn_high_`name1' high_`name1' [aw=numfirm_reg_ind_yr], absorb(year region ateco_07_2d)
			estimates store col1

replace share_conn_regr=share_incumb_conn
replace share_conn_high_`name1'=sh_inc_conn_`name1'_bur_q75


	reghdfe entry_rate share_conn_regr share_conn_high_`name1' high_`name1' [aw=numfirm_reg_ind_yr], absorb(year region ateco_07_2d)
			estimates store col2
			
	reghdfe share_conn_entr share_conn_regr share_conn_high_`name1' high_`name1' [aw=numfirm_reg_ind_yr], absorb(year region ateco_07_2d)
			estimates store col3
			
			
esttab col1 col2 col3 using "$dir_tables\TableD2_panel_`name1'.tex" , replace star(* 0.10 ** 0.05 *** 0.01) drop(_cons) se
	

est drop _all
}



cap log close






* This code generates industry and region-level regressions in Table X, Table C.6 and Table C.7.

clear all


use "$dir_data/data_indreg.dta", replace 


*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---
*---*---*---    Generate Table X -- benchmark industry-region level regressions   *---*---*--- 
*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---
rename logLP_reg_ind_yr logLP

foreach var of varlist ///
growth_l logLP share_young share_size1   {


qui reghdfe `var' share_numfirm_conn [aw=numfirm_reg_ind_yr], absorb(i.year i.ateco i.reg_) vce(robust)
estimates save "$dir_ster/`var'_indreg", replace
estimates store `var'_indreg


}

// for entry-related facts, share of incumbments is a more concervative measure than the share of current firms, so use the share of incumbents as control. For ease of outputting tables, make the temporary variable change here.
gen share_numfirm_conn_temp=share_numfirm_conn
replace  share_numfirm_conn = share_incumb_conn

foreach var of varlist ///
entry_rate share_conn_entr  {


qui reghdfe `var' share_numfirm_conn [aw=numfirm_reg_ind_yr], absorb(i.year i.ateco i.reg_) vce(robust)
estimates save "$dir_ster/`var'_indreg_inc", replace
estimates store `var'_indreg_inc


}

// output table.
esttab    growth_l_indreg  logLP_indreg share_young_indreg share_size1_indreg  entry_rate_indreg_inc share_conn_entr_indreg_inc using  "$dir_tables/TabX_indreglevel.tex", replace se drop(_cons) star(* 0.10 ** 0.05 *** 0.01) ///
stat(N, labels("Observations")) mtitle("Growth empl" "Log LP" "Share young" "Share small" "Entry rate" "Share conn. entry") nonumbers collabels(none)


replace share_numfirm_conn = share_numfirm_conn_temp
drop share_numfirm_conn_temp





*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*
*---*---       Generate Tables C.6 and C.7 -- industry-region level regressions, tradable and manufacturing heterogeneity        *---*---*
*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*---*-

// define manufacturing
gen mnfg=((ateco>=10)&(ateco<=33))


// define tradable: industries, whose share of exports are above the median based on the industry-level input-output matrixes
gen trad=0
replace trad=1 if ateco==1 | (ateco>=10)&(ateco<=17) | (ateco>=19)&(ateco<=33) | (ateco>=50)&(ateco<=52) | (ateco>=58)&(ateco<=61) | ateco==65 | ateco==72 | ateco==74 | ateco==75 | ateco==77 | ateco==78 | ateco==79


foreach name in mnfg trad {

//interactions
gen share_numfirm_conn_`name'=share_numfirm_conn*`name'
gen share_incumb_conn_`name'=share_incumb_conn*`name'


foreach var of varlist ///
growth_l logLP share_young share_size1   {


qui reghdfe `var' share_numfirm_conn share_numfirm_conn_`name' [aw=numfirm_reg_ind_yr], absorb(i.year i.ateco_07_2d i.reg_num) vce(robust)
estimates save "$dir_ster/`var'_ir`name'", replace
estimates store `var'_ir`name'


}

// for entry-related facts, share of incumbments is a more concervative measure than the share of current firms. Make the temporary variable change here.
gen share_numfirm_conn_temp=share_numfirm_conn
replace  share_numfirm_conn = share_incumb_conn

gen share_numfirm_conn_`name'_temp=share_numfirm_conn_`name'
replace  share_numfirm_conn_`name' = share_incumb_conn_`name'


foreach var of varlist ///
entry_rate share_conn_entr  {


qui reghdfe `var' share_numfirm_conn share_numfirm_conn_`name' [aw=numfirm_reg_ind_yr], absorb(i.year i.ateco_07_2d i.reg_num) vce(robust)
estimates save "$dir_ster/`var'_ir`name'_inc", replace
estimates store `var'_ir`name'_inc

}


// output tables.
esttab   growth_l_ir`name' logLP_ir`name'  share_young_ir`name' share_size1_ir`name' entry_rate_ir`name'_inc share_conn_entr_ir`name'_inc using  "$dir_tables/TabC_indreglevel_`name'.tex", replace se drop(_cons) star(* 0.10 ** 0.05 *** 0.01) ///
stat(N, labels("Observations")) mtitle("Growth empl" "Log LP" "Share young" "Share small" "Entry rate" "Share conn. entry") nonumbers collabels(none)


replace share_numfirm_conn = share_numfirm_conn_temp
drop share_numfirm_conn_temp

replace share_numfirm_conn_`name' = share_numfirm_conn_`name'_temp
drop share_numfirm_conn_`name'_temp

}

* Do-file to get tables B.1 and B.2 for patent statistics.


ssc install outreg, replace
ssc install corrtex, replace

use "$dir_data/patents_ITfirms.dta", clear

drop codice_fiscale year

duplicates drop

*APPENDIX TABLE B.1 CROSS-CORRELATIONS OF VARIOUS PATENT QUALITY MEASURES

label var docdb_family_size "Fam. size"
label var granted_family "Grant"
label var claims_family "Claims"
label var ncit "Cits"
label var ncit_5yr "5-yr cits"
label var ncit_app "Cits, applicant"
label var ncit_app_5 "5-yr cits, applicant"
corrtex granted_family docdb_family_size claims_family ncit ncit_5yr ncit_app ncit_app_5yr, file("TabB1_corr_patents.tex") ///
title(Cross-correlations of Patent Quality Measures) replace


*APPENDIX TABLE B.2 STATISTICS ON PATENT QUALITY FOR ITALIAN PATENTS (1990-2014)
matrix sumstat = J(7, 1,.)

sum docdb_family_size
matrix sumstat[1,1]=r(mean) 
sum granted_family
matrix sumstat[2,1]=r(mean) 
sum claims_family
matrix sumstat[3,1]=r(mean) 
sum ncit
matrix sumstat[4,1]=r(mean) 
sum ncit_5yr
matrix sumstat[5,1]=r(mean) 
sum ncit_app
matrix sumstat[6,1]=r(mean) 
sum ncit_app_5yr
matrix sumstat[7,1]=r(mean) 

matrix list sumstat

cd "$dir_tables"
frmttable using "TabB2_sumstat_patents", tex fragment nocenter plain hlines(110000001) statmat(sumstat) sdec(2) sfmt(fc) replace /// 
rtitles( "Patent family size" \ "Grant dummy" \ "Number of claims" \ ///
"Citations received" \ "Citations received in 5 yrs" \ "Applicant citations" \ "Applicant citations in 5 yrs") ///
ctitles("Variable" "Average")

* This file produces Appendix Figure C5 - Distribution of the Share of Winning Politicians across Firms, conditional on having any seat

use "$dir_data/data_RD.dta", clear

gen numberwinners=nmwin_t_1
replace numberwinners=0 if numberwinners==.
gen numberlosers=nmlost_t_1
replace numberlosers=0 if numberlosers==.
gen tot=numberwinners+numberlosers

gen share_w=numberwinners/tot
hist share_w if margin_spread2<=0.1, frac ytitle("Percent of firms") xtitle("Share of winning politicians") 
graph save "$dir_figures/Figure_C5.gph" replace 
graph export "$dir_figures/Figure_C5.pdf", replace
*This code generates firm-level regression tables: Table V and Table C.2 

clear all

use "$dir_data/firmdata_growthregs.dta", clear

* Table V
foreach var in  growth_l growth_VA growth_LP growth_TFP   {


qui reghdfe `var' conn_d conn_maj_d logtot_assets  logempl age , cluster(id_impresa_num) absorb(i.year i.ateco_07_2d i.regione_num)
estimates save "$dir_ster/`var'_m1", replace

estadd local YFE  = "Yes"
estadd local RFE  = "Yes"
estadd local IFE  = "Yes"
estadd local FFE  = "No"
estimates store `var'_m1

xtreg `var' conn_d conn_maj_d logtot_assets  logempl age i.year , fe cluster(id_impresa_num)
estimates save "$dir_ster/`var'_m2", replace

estadd local YFE  = "Yes"
estadd local RFE  = "No"
estadd local IFE  = "No"
estadd local FFE  = "Yes"
estimates store `var'_m2

}
esttab  growth_l_m1 growth_l_m2  growth_VA_m1 growth_VA_m2  growth_LP_m1 growth_LP_m2 growth_TFP_m1 growth_TFP_m2  using  "$dir_tables/TabV_growthfirmlevel.tex",  ///
replace keep(conn_d conn_maj_d) b(3) se  star(* 0.10 ** 0.05 *** 0.01) ///
stat(YFE RFE IFE FFE N, labels("Year FE" "Region FE" "Industry FE" "Firm FE" "Observations"))



* Table V -- additional outcomes

qui xtreg growth_profit conn_d  logtot_assets  logempl age i.year , fe cluster(id_impresa_num)
estimates save "$dir_ster/growth_profit_m1", replace
estadd local ASA  = "Yes"
estadd local FFE  = "Yes"
est store m1

qui xtreg growth_l_wh conn_d  logtot_assets  logempl age i.year , fe cluster(id_impresa_num)
estimates save "$dir_ster/growth_l_wh_m2", replace
estadd local ASA  = "Yes"
estadd local FFE  = "Yes"
est store m2

qui xtreg growth_intang conn_d  logtot_assets  logempl age i.year , fe cluster(id_impresa_num)
estimates save "$dir_ster/growth_intang_m3", replace
estadd local ASA  = "Yes"
estadd local FFE  = "Yes"
est store m3

qui xtreg growth_npat_yr_stk conn_d  logtot_assets  logempl age i.year , fe cluster(id_impresa_num)
estimates save "$dir_ster/growth_npat_yr_stk_m4", replace
estadd local ASA  = "Yes"
estadd local FFE  = "Yes"
est store m4


esttab  m1 m2 m3 m4  using  "$dir_tables/TabC2_growthfirmlevel.tex",  replace keep(conn_d) b(4) se  star(* 0.10 ** 0.05 *** 0.01) ///
stat(ASA N, labels("Age, Size, Assets"  "Year FE" "Observations"))



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

use "$dir_data/data_reelection_incumbent.dta", clear

 
keep if reelection==1 | loser_previnc==1  //first, need to keep only elections where previous incumbent party/coalition is running for election again and is among two top contestants in the current election.
drop if margin_spread>0.2


gen margin_bins_01=.  //midpoints of bins
 quietly forval i = 120(-1)1 {
	replace margin_bins_01=-0.1+0.01*`i'-0.005 if margin_spread <= -0.1+0.01*`i' & margin_spread>=-0.1+0.01*(`i'-1)
 }
replace margin_bins_01=0.005 if margin_spread==0


collapse (mean) mean=reelection (sd) sd=reelection (count) n=reelection, by( margin_bins_01)
generate hireelection =  mean+ invttail(n-1,0.025)*(sd / sqrt(n))
generate lowreelection =  mean- invttail(n-1,0.025)*(sd/ sqrt(n))


line  hi mean low margin_bins_01 , clcolor(colorgs15 red colorgs15) clpattern( dash solid dash) ///
lwidth( thin medthick thin) yline(0.5, lwidth(thick) lcolor(gs9)) ///
 xtitle("Margin of victory") ytitle("Probability of re-election") ///
legend(off) graphregion(color(white))
graph export "$dir_figures/Figure_4_reelection.pdf", replace* This code generates figures and the regression table related to the results on innovation and political connections as a function of firm rank.
* It generates plots for Figure 3, Figure C1, Figure C2, Figure C3 and Table C1.

clear all
scalar drop _all


use "$dir_data/firmdata_rankanalysis.dta" , replace


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*  Part 1   *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*First, generate figures*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*** Generate Figures for Figure 3, Figure C1, Figure C3 ***
/*Individual figures are generated here. After exporting these figures from the server, in the paper, these figures are then superimposed to create a better visual appearance for Figure 3 and Figure C1.
*/



preserve

gsort ateco year region -ms_L

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_L)
//sum maxms, d
//some markets are very dispersed and do not have a clear industry leader. So, restrict attention to leaders that have at least 10% of market share (although turns out it does not really matter that much).
drop if maxms<0.1



* Plots for Figure C3

foreach Yvar of varlist  patents_famadj_intensity patents_citadj_intensity {

cap drop res *adj

qui reg `Yvar' rank i.year i.ateco i.regione_num //adjust variables for fixed effects

predict res, res
gen `Yvar'_adj=res+_b[rank]*rank+_b[_cons]
binscatter `Yvar'_adj rank , discrete graphregion(color(white)) ytitle("`Yvar'", size(medium))  xtitle("Firm's market rank", size(medium)) 

graph save "$dir_figures/FigC3_`Yvar'_rank.gph", replace
graph export "$dir_figures/FigC3_`Yvar'_rank.pdf", replace


}


* Figure 3
cap drop res
qui reg polits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen polits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg patents_intensity rank i.year i.ateco i.regione_num
predict res, res
gen patents_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse polits_intensity_adj  patents_intensity_adj, by(rank)

twoway (scatter patents_intensity_adj rank, mc(maroon) m(S) yaxis(2) yscale(r(20 60) axis(2)) ylabel(20 30 40 50 60, axis(2)))  (lfit patents_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Patents intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter polits_intensity_adj rank, mc(navy) m(T) yaxis(1) yscale(r(2.3 2.7) axis(1)) ylabel(2.3 2.4 2.5 2.6 2.7, axis(1)) ) (lfit polits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Patents intensity") lab(3 "Politicians intensity"))

graph save "$dir_figures/Fig3_cross.gph", replace
graph export "$dir_figures/Fig3_cross.pdf", replace

restore


* Figure C1

preserve

gsort ateco year region -ms_L

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_L)

drop if maxms<0.1

cap drop res
qui reg majpolits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen majpolits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg intang_intensity rank i.year i.ateco i.regione_num
predict res, res
gen intang_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse intang_intensity_adj  majpolits_intensity_adj, by(rank)

twoway (scatter intang_intensity_adj rank, mc(maroon) m(S) yaxis(2) )  (lfit intang_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Intangibles intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter majpolits_intensity_adj rank, mc(navy) m(T) yaxis(1)  ) (lfit majpolits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Majority-level politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Intangibles intensity") lab(3 "Majority-level politicians intensity"))

graph save "$dir_figures/FigC1_cross.gph", replace
graph export "$dir_figures/FigC1_cross.pdf", replace

restore



* Figure C2, part 1

preserve

gsort ateco year region -ms_VA

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_VA)

drop if maxms<0.1

cap drop res
qui reg polits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen polits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg patents_intensity rank i.year i.ateco i.regione_num
predict res, res
gen patents_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse polits_intensity_adj  patents_intensity_adj, by(rank)

twoway (scatter patents_intensity_adj rank, mc(maroon) m(S) yaxis(2))  (lfit patents_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Patents intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter polits_intensity_adj rank, mc(navy) m(T) yaxis(1) ) (lfit polits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Patents intensity") lab(3 "Politicians intensity"))

graph save "$dir_figures/FigC2_part1_cross.gph", replace
graph export "$dir_figures/FigC2_part1_cross.pdf", replace

restore



* Figure C2, part 2

preserve

gsort ateco year region -ms_VA

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_VA)

drop if maxms<0.1

cap drop res
qui reg majpolits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen majpolits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg intang_intensity rank i.year i.ateco i.regione_num
predict res, res
gen intang_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse intang_intensity_adj  majpolits_intensity_adj, by(rank)

twoway (scatter intang_intensity_adj rank, mc(maroon) m(S) yaxis(2) )  (lfit intang_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Intangibles intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter majpolits_intensity_adj rank, mc(navy) m(T) yaxis(1)  ) (lfit majpolits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Majority-level politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Intangibles intensity") lab(3 "Majority-level politicians intensity"))

graph save "$dir_figures/FigC2_part2_cross.gph", replace
graph export "$dir_figures/FigC2_part2_cross.pdf", replace

restore




*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*  Part 2   *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*Second, generate regression table *-*-*-*-*-*-*-*-*-*-*-*-*


gsort ateco year region -ms_L

by ateco year region: gen rank=_n

gen rank1=(rank==1)
gen rank2=(rank==2)
gen rank3=(rank==3)
gen rank4=(rank==4)
gen rank5=(rank==5)
gen rank6more=(rank>5)


foreach var of varlist ///
polits_intensity patents_intensity intang_intensity majpolits_intensity {

qui reghdfe `var' rank1 -rank5 logage, absorb(i.year i.ateco i.regione_num)
estimates store rank_`var'

}

esttab  rank_polits_intensity rank_majpolits_intensity rank_intang_intensity rank_patents_intensity  ///
using "$dir_tables/TabC1_innovconn_rank.tex" , replace se  star(* 0.10 ** 0.05 *** 0.01)

* This program produces Appendix Table B.3 on Statistics on Local Politicians Employed in the Private Sector

clear all


// data on occupation codes of politican-employees
use "$dir_data/pol_qualifica.dta", replace
tab qualifica1

gen one=1
collapse (sum) one, by(qualifica)
egen tot=total(one)
gen perc_qualifica= one/tot*100


sum perc_qualifica if qualifica1 == "3"
scalar perc_topmanager=r(mean)

sum perc_qualifica if qualifica1 == "Q"
scalar perc_midmanager=r(mean)

sum perc_qualifica if qualifica1 == "5"
scalar perc_trainee=r(mean)


gen white_collar=(qualifica1=="2" | qualifica1=="3" | qualifica1=="7" | qualifica1=="9" | qualifica1=="P" | qualifica1=="Q")
gen blue_collar=!(qualifica1=="2" | qualifica1=="3" | qualifica1=="7" | qualifica1=="9" | qualifica1=="P" | qualifica1=="Q")
gen other_white_collar=(qualifica1=="2" | qualifica1=="7" | qualifica1=="9" | qualifica1=="P")

bys white_collar: egen totperc=total(perc_qualifica)

su totperc if white_collar==0
scalar perc_bluecollar=r(mean)

bys other_white_collar: egen totperc2=total(perc_qualifica)

su totperc2 if other_white_collar==1
scalar perc_otherwhitecollar=r(mean)


// main politicians sample
use "$dir_data/politsID_sample_8514.dta", replace

count
scalar count=r(N)

distinct id_soggetto
scalar count_polits= r(ndistinct) 

// education
tab indiv_edu

count if indiv_edu!=.
scalar temp=r(N)

count if indiv_edu==0
scalar perc_less_highschool=r(N)/temp*100

count if indiv_edu==1
scalar perc_highschool=r(N)/temp*100

count if indiv_edu==2
scalar perc_uni=r(N)/temp*100

count if indiv_edu==3
scalar perc_post=r(N)/temp*100

sum imp_tot_wk_indiv
scalar wk_wage= r(mean) 

//regional rank
tab indiv_polit_area
count if indiv_polit_area!=.
scalar temp=r(N)

count if indiv_polit_area==1
scalar perc_muni=r(N)/temp*100

count if indiv_polit_area==2
scalar perc_prov=r(N)/temp*100

count if indiv_polit_area==3
scalar perc_reg=r(N)/temp*100


//hierarchical rank
tab indiv_position
count if indiv_position!=.
scalar temp=r(N)

count if indiv_position==1
scalar perc_mayor_pres_vice=r(N)/temp*100

count if indiv_position==2
scalar perc_mayor_pres_vice=perc_mayor_pres_vice+r(N)/temp*100


count if indiv_position==3
scalar perc_exec=r(N)/temp*100

count if indiv_position==4
scalar perc_council=r(N)/temp*100


//majority
tab indiv_in_majority 
count if indiv_in_majority!=.
scalar temp=r(N)

count if indiv_in_majority==1
scalar perc_maj=r(N)/temp*100

scalar drop temp

*****************************************
* Now, report these stats in the table
*****************************************

scalar list _all
matrix sumstats = J(19,1,.)

matrix sumstats[1,1]=count
matrix sumstats[2,1]=count_polits
matrix sumstats[3,1]=perc_topmanager
matrix sumstats[4,1]=perc_midmanager
matrix sumstats[5,1]=perc_otherwhitecollar
matrix sumstats[6,1]=perc_bluecollar
matrix sumstats[7,1]=perc_trainee
matrix sumstats[8,1]=perc_less_highschool
matrix sumstats[9,1]=perc_highschool
matrix sumstats[10,1]=perc_uni
matrix sumstats[11,1]=perc_post
matrix sumstats[12,1]=wk_wage
matrix sumstats[13,1]=perc_reg
matrix sumstats[14,1]=perc_prov
matrix sumstats[15,1]=perc_muni
matrix sumstats[16,1]=perc_mayor_pres_vice
matrix sumstats[17,1]=perc_exec
matrix sumstats[18,1]=perc_council
matrix sumstats[19,1]=perc_maj
matrix list sumstats


cd "$dir_tables"
frmttable using "TabB3_politsample_matched_stats.tex", tex fragment nocenter statman(sumstats) sdec(2) sfmt(fc) replace ///
rtitles("Observations" \ "Distinct politicians" \ "Top management" \ "Middle management" \ "Other white-collar jobs" \ "Blue-collar jobs" \ "Trainee" "< high shool" "University" "Post-graduate" "Average weekly pay" "Region" "Province"  "Municipality" "Mayor, President, Vice-mayor, Vice-president" "Executive councilor" "Council member" "Majority" ) ///
ctitles("Variables" "Statistics")

*The table is slightly reformatted manually in latex to get the visual appearance as in the paper* This do-file peoduces additional RD results for other outcomes
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

* This code generates regressions for cross-border analysis, Table C.8

clear all

use "$dir_data/data_crossborder.dta", replace


gen d_neighbconn_high=lagshare_numfirm_conn_main<lagshare_numfirm_conn_n_me 
label var d_neighbconn_high "neighbors more connected, lag"
gen conn_neighbors_aux=.

 
foreach var of varlist entry_rate_main entry_rate_nconn {
// basic regression
qui reghdfe `var' lagshare_numfirm_conn_main [aw=numfirm_prov_ind_yr_main], absorb(provincia_main ateco year) vce(robust)
estimates save "$dir_ster/`var'_crossborder_m1", replace
est store m1_`var'


// extenstive margin: adding a dummy for neighbors' being more connected than you
qui reghdfe `var' lagshare_numfirm_conn_main  d_neighbconn_high [aw=numfirm_prov_ind_yr_main], absorb(provincia_main ateco year) vce(robust)
estimates save "$dir_ster/`var'_crossborder_m2", replace
est store m2_`var'
		
		
// intensive margin: conditional on neighbors being more connected than you, include intensity of neighbors'connections (mean)
replace conn_neighbors_aux = lagshare_numfirm_conn_n_mx
qui reghdfe `var' lagshare_numfirm_conn_main conn_neighbors_aux if d_neighbconn_high==1 [aw=numfirm_prov_ind_yr_main], absorb(provincia_main ateco year) vce(robust)
estimates save "$dir_ster/`var'_crossborder_m3", replace
est store m3_`var'
		
// intensive margin, different measure of neighbor's connections (max)
replace conn_neighbors_aux = lagshare_numfirm_conn_n_me	
qui reghdfe `var' lagshare_numfirm_conn_main conn_neighbors_aux if d_neighbconn_high==1 [aw=numfirm_prov_ind_yr_main], absorb(provincia_main ateco year) vce(robust)
estimates save "$dir_ster/`var'_crossborder_m4", replace
est store m4_`var'
		
replace conn_neighbors_aux = .	
}

	
	
*Create two panels of Table C.8 into two different tables

*Panel A 
esttab   m1_entry_rate_main   m2_entry_rate_main   m3_entry_rate_main   m4_entry_rate_main using  "$dir_tables/TabC8_PanelA_crossborder.tex", replace se drop(_cons) star(* 0.10 ** 0.05 *** 0.01) ///
stat(N, labels("Observations"))  nonumbers 



*Panel B
esttab m1_entry_rate_nconn_main   m2_entry_rate_nconn_main   m3_entry_rate_nconn_main   m4_entry_rate_nconn_main using  "$dir_tables/TabC8_PanelB_crossborder.tex", replace se drop(_cons) star(* 0.10 ** 0.05 *** 0.01) ///
stat(N, labels("Observations"))  nonumbers 

