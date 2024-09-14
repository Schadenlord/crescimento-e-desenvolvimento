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

