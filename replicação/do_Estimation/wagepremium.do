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





