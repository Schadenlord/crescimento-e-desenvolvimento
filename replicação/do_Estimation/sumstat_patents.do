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

