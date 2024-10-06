* This file produces Appendix Figure C5 - Distribution of the Share of Winning Politicians across Firms, conditional on having any seat

use "$dir_data/data_RD.dta", clear

gen numberwinners=nmwin_t_1
replace numberwinners=0 if numberwinners==.
gen numberlosers=nmlost_t_1
replace numberlosers=0 if numberlosers==.
gen tot=numberwinners+numberlosers

gen share_w=numberwinners/tot
hist share_w if margin_spread2<=0.1, frac ytitle("Percent of firms") xtitle("Share of winning politicians") 
graph save "$dir_figures/Figure_C5.gph" replace 
graph export "$dir_figures/Figure_C5.pdf", replace