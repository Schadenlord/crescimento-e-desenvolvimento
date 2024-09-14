
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

