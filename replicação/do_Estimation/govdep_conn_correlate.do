
* This do-file produces Appendix Figure D.2.

clear all

use "$dir_data/data_govdep_conn.dta", clear

binscatter share_conn dep_govt ,  ///
graphregion(color(white)) legend(off) xtitle("Government Dependence Index 1") ytitle("Share of connected firms")
graph export "$dir_figures/FigD2_a.pdf", replace


binscatter share_conn dep_govt_CP ,  ///
graphregion(color(white)) legend(off) xtitle("Government Dependence Index 2") ytitle("Share of connected firms")
graph export "$dir_figures/FigD2_b.pdf", replace




