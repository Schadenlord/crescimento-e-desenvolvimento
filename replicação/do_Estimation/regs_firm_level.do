
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



