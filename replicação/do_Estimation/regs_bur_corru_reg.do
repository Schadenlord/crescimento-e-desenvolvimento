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





