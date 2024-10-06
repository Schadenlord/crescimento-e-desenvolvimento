* This code generates figures and the regression table related to the results on innovation and political connections as a function of firm rank.
* It generates plots for Figure 3, Figure C1, Figure C2, Figure C3 and Table C1.

clear all
scalar drop _all


use "$dir_data/firmdata_rankanalysis.dta" , replace


*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*  Part 1   *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*First, generate figures*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*** Generate Figures for Figure 3, Figure C1, Figure C3 ***
/*Individual figures are generated here. After exporting these figures from the server, in the paper, these figures are then superimposed to create a better visual appearance for Figure 3 and Figure C1.
*/



preserve

gsort ateco year region -ms_L

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_L)
//sum maxms, d
//some markets are very dispersed and do not have a clear industry leader. So, restrict attention to leaders that have at least 10% of market share (although turns out it does not really matter that much).
drop if maxms<0.1



* Plots for Figure C3

foreach Yvar of varlist  patents_famadj_intensity patents_citadj_intensity {

cap drop res *adj

qui reg `Yvar' rank i.year i.ateco i.regione_num //adjust variables for fixed effects

predict res, res
gen `Yvar'_adj=res+_b[rank]*rank+_b[_cons]
binscatter `Yvar'_adj rank , discrete graphregion(color(white)) ytitle("`Yvar'", size(medium))  xtitle("Firm's market rank", size(medium)) 

graph save "$dir_figures/FigC3_`Yvar'_rank.gph", replace
graph export "$dir_figures/FigC3_`Yvar'_rank.pdf", replace


}


* Figure 3
cap drop res
qui reg polits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen polits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg patents_intensity rank i.year i.ateco i.regione_num
predict res, res
gen patents_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse polits_intensity_adj  patents_intensity_adj, by(rank)

twoway (scatter patents_intensity_adj rank, mc(maroon) m(S) yaxis(2) yscale(r(20 60) axis(2)) ylabel(20 30 40 50 60, axis(2)))  (lfit patents_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Patents intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter polits_intensity_adj rank, mc(navy) m(T) yaxis(1) yscale(r(2.3 2.7) axis(1)) ylabel(2.3 2.4 2.5 2.6 2.7, axis(1)) ) (lfit polits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Patents intensity") lab(3 "Politicians intensity"))

graph save "$dir_figures/Fig3_cross.gph", replace
graph export "$dir_figures/Fig3_cross.pdf", replace

restore


* Figure C1

preserve

gsort ateco year region -ms_L

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_L)

drop if maxms<0.1

cap drop res
qui reg majpolits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen majpolits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg intang_intensity rank i.year i.ateco i.regione_num
predict res, res
gen intang_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse intang_intensity_adj  majpolits_intensity_adj, by(rank)

twoway (scatter intang_intensity_adj rank, mc(maroon) m(S) yaxis(2) )  (lfit intang_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Intangibles intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter majpolits_intensity_adj rank, mc(navy) m(T) yaxis(1)  ) (lfit majpolits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Majority-level politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Intangibles intensity") lab(3 "Majority-level politicians intensity"))

graph save "$dir_figures/FigC1_cross.gph", replace
graph export "$dir_figures/FigC1_cross.pdf", replace

restore



* Figure C2, part 1

preserve

gsort ateco year region -ms_VA

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_VA)

drop if maxms<0.1

cap drop res
qui reg polits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen polits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg patents_intensity rank i.year i.ateco i.regione_num
predict res, res
gen patents_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse polits_intensity_adj  patents_intensity_adj, by(rank)

twoway (scatter patents_intensity_adj rank, mc(maroon) m(S) yaxis(2))  (lfit patents_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Patents intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter polits_intensity_adj rank, mc(navy) m(T) yaxis(1) ) (lfit polits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Patents intensity") lab(3 "Politicians intensity"))

graph save "$dir_figures/FigC2_part1_cross.gph", replace
graph export "$dir_figures/FigC2_part1_cross.pdf", replace

restore



* Figure C2, part 2

preserve

gsort ateco year region -ms_VA

by ateco year region: gen rank=_n

drop if rank>20


by ateco year region: egen maxms=max(ms_VA)

drop if maxms<0.1

cap drop res
qui reg majpolits_intensity rank i.year i.ateco i.regione_num
predict res, res
gen majpolits_intensity_adj=res+_b[rank]*rank+_b[_cons]


cap drop res
qui reg intang_intensity rank i.year i.ateco i.regione_num
predict res, res
gen intang_intensity_adj=res+_b[rank]*rank+_b[_cons]

collapse intang_intensity_adj  majpolits_intensity_adj, by(rank)

twoway (scatter intang_intensity_adj rank, mc(maroon) m(S) yaxis(2) )  (lfit intang_intensity_adj rank, lcolor(maroon) lwidth(medthick) yaxis(2) ytitle("Intangibles intensity", axis(2)) xtitle("Firm's market rank", size(medium))   xscale(r(1 20)) xlabel(1 5 10 15 20)  graphregion(color(white)) ) ///
(scatter majpolits_intensity_adj rank, mc(navy) m(T) yaxis(1)  ) (lfit majpolits_intensity_adj rank, lcolor(navy) lwidth(medthick) yaxis(1) ytitle("Majority-level politicians intensity", axis(1))), legend(on order (1 3) lab(1 "Intangibles intensity") lab(3 "Majority-level politicians intensity"))

graph save "$dir_figures/FigC2_part2_cross.gph", replace
graph export "$dir_figures/FigC2_part2_cross.pdf", replace

restore




*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-**-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*  Part 2   *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
*-*-*-*-*-*-*-*-*-*-*-*-*-*Second, generate regression table *-*-*-*-*-*-*-*-*-*-*-*-*


gsort ateco year region -ms_L

by ateco year region: gen rank=_n

gen rank1=(rank==1)
gen rank2=(rank==2)
gen rank3=(rank==3)
gen rank4=(rank==4)
gen rank5=(rank==5)
gen rank6more=(rank>5)


foreach var of varlist ///
polits_intensity patents_intensity intang_intensity majpolits_intensity {

qui reghdfe `var' rank1 -rank5 logage, absorb(i.year i.ateco i.regione_num)
estimates store rank_`var'

}

esttab  rank_polits_intensity rank_majpolits_intensity rank_intang_intensity rank_patents_intensity  ///
using "$dir_tables/TabC1_innovconn_rank.tex" , replace se  star(* 0.10 ** 0.05 *** 0.01)

