
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
