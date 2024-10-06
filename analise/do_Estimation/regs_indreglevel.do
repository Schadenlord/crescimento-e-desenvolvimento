
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

