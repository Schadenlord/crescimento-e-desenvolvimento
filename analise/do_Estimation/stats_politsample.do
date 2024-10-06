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

*The table is slightly reformatted manually in latex to get the visual appearance as in the paper