* This do-file produces Appendix Table D.1 and Appendix Figure D.1.
* list of sectors with bureacracy indices and mean connections.
* and polit connections.


clear all
use "$dir_data/factiva_bur_conn.dta"

*export Appendix Table D1
gsort -share_conn
texsave * using "$dir_tables\TabD1.tex", replace

*plot Appendix Figure D.1
binscatter share_conn gov_bur_index1 ,  ///
graphregion(color(white)) legend(off) xtitle("Bureaucracy Index 1") ytitle("Share of connected firms")
graph export "$dir_figures/FigureD1_a.pdf",  replace


binscatter share_conn gov_bur_index2 ,  ///
graphregion(color(white)) legend(off) xtitle("Bureaucracy Index 2") ytitle("Share of connected firms")
graph export "$dir_figures/FigureD1_b.pdf", replace

