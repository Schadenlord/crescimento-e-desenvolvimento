* This do-file generates Cox survival results in Table VI


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


