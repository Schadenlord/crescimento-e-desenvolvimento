
use "$dir_data/data_reelection_incumbent.dta", clear

 
keep if reelection==1 | loser_previnc==1  //first, need to keep only elections where previous incumbent party/coalition is running for election again and is among two top contestants in the current election.
drop if margin_spread>0.2


gen margin_bins_01=.  //midpoints of bins
 quietly forval i = 120(-1)1 {
	replace margin_bins_01=-0.1+0.01*`i'-0.005 if margin_spread <= -0.1+0.01*`i' & margin_spread>=-0.1+0.01*(`i'-1)
 }
replace margin_bins_01=0.005 if margin_spread==0


collapse (mean) mean=reelection (sd) sd=reelection (count) n=reelection, by( margin_bins_01)
generate hireelection =  mean+ invttail(n-1,0.025)*(sd / sqrt(n))
generate lowreelection =  mean- invttail(n-1,0.025)*(sd/ sqrt(n))


line  hi mean low margin_bins_01 , clcolor(colorgs15 red colorgs15) clpattern( dash solid dash) ///
lwidth( thin medthick thin) yline(0.5, lwidth(thick) lcolor(gs9)) ///
 xtitle("Margin of victory") ytitle("Probability of re-election") ///
legend(off) graphregion(color(white))
graph export "$dir_figures/Figure_4_reelection.pdf", replace