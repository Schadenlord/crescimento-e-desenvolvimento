* Paper: Connecting to Power: Political Connections, Innovation, and Firm Dynamics
* Authors: Ufuk Akcigit, Salome Baslandze, and Francesca Lotti
* October 2022


/* This program has all the do-files for estimation
*/

ssc install binscatter
ssc install egenmore
ssc install texsave

* Path structure. To run, change to local directory owndir

local owndir = "\18338_Data_and_Programs\Data_Programs" //to run the full program, put the complete path to the archived folder on the INPS server.

global dir_data = "`owndir'/Data"
global dir_tables = "`owndir'/Results/Tables"
global dir_figures = "`owndir'/Results/Figures"
global dir_data_interm = "`owndir'/Data_interm"
global dir_ster= "`owndir'/Results/Sters"
global dir_logs= "`owndir'/Results/Logs"
global dir_do_construction = "`owndir'/do_Data_Construction"
global dir_do_estimation = "`owndir'/do_Estimation"

set matsize 10000





 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table III Statistics on Local Politicians
do sumstats_politicians_all.do
/* Input: $dir_data/data_politicians_short.dta
Output: $dir_tables/TableIII_sumstats_polits.tex
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table IV Summary Statistics of the Matched Firm-Level Data
do stats_firmlevel.do // data summary stats (1993-2014)

/* Input: $dir_data/firmdata_stats.dta
Output: $dir_tables/TabIV_sumstats_firmlevel.xls
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Figure 3: Leadership Paradox: Market rank, Innovation, and Political connections
* Appendix Table C1: MARKET RANK, INNOVATION, AND POLITICAL CONNECTION
* Appendix Figure C.1.—LEADERSHIP PARADOX; ALTERNATIVE INNOVATION AND CONNECTION MEASURES
* Appendix Figure C.2.—Market Rank, Innovation, and Political Connection, with an Alternative Definition of Market Rank
* Appendix Figure C.3.—Market Rank, Innovation, and Political Connection, with Quality-adjusted Patent Intensity
do innov_conn_rank.do

/* Input: $dir_data/firmdata_rankanalysis.dta"  
Output:  $dir_tables/"$dir_tables/TabC1_innovconn_rank.tex".tex 
Fig3_part_patents_intensity_rank
Fig3_part_polits_intensity_rank
FigC1_part_intang_intensity_rank
FigC1_part_majpolits_intensity_rank
FigC2_intang_intensity_VArank
FigC2_majpolits_intensity_VArank
FigC2_patents_intensity_VArank
FigC2_polits_intensity_VArank
FigC3_patents_citadj_intensity_rank
FigC3_patents_famadj_intensity_rank

*/
  


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table V: POLITICAL CONNECTIONS AND MEASURES OF FIRM GROWTH
* Appendix Table C.2: POLITICAL CONNECTIONS AND GROWTH IN SIZE VERSUS PRODUCTIVITY. OTHER OUTCOMES
do regs_firm_level.do 

/* Input: $dir_data/firmdata_growthregs.dta"  
Output:  "$dir_tables/TabV_growthfirmlevel.tex"
         "$dir_tables/TabC2_growthfirmlevel.tex"
ster files in "$dir_ster
*/
				  
				  

 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
*Table VI: COX SURVIVAL ANALYSIS
do regs_survival.do

/* Input: $dir_data/data_cox.dta
Output:  "$dir_tables/TabVI_Cox.tex"
ster files in "$dir_ster
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* FIGURE 4.—PROBABILITY OF RE-ELECTION AGAINST THE MARGIN OF VICTORY
do reelection_prob.do 
/* Input: "$dir_data/data_reelection_incumbent.dta"
Output:  "$dir_figures/Figure_4_reelection.pdf"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* TABLE VII EMPLOYMENT AND PRODUCTIVITY GROWTH AFTER ELECTION. RD ESTIMATES.
* TABLE VIII EMPLOYMENT AND PRODUCTIVITY GROWTH AFTER ELECTION. RD ROBUSTNESS
* TABLE IX BALANCING TESTS
* FIGURE 5.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION (a, b)
* FIGURE 6.—PRE-TRENDS IN EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH BEFORE ELECTION
* APPENDIX FIGURE C.4.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION. 20% MARGIN OF VICTORY SAMPLE (a, b)
do regs_figs_rd.do 

/* Input: "$dir_data/data_rd.dta"
Output:  
Tables --
"$dir_tables/TableVII_RD.tex"
"$dir_tables/TableVIII_panel_a_uniform.tex"
"$dir_tables/TableVIII_panel_b_quadratic.tex"
"$dir_tables/TableVIII_panel_c_margin20.tex"
"$dir_tables/TableVIII_panel_d_margin10.tex"
"$dir_tables/TableIX_balancing_test.tex"

Figures --
"$dir_figures/Figure5_growth_L_t"  
"$dir_figures/Figure5_growth_LP_t" 
"$dir_figures/Figure6_growth_L_t_1"   
"$dir_figures/Figure6_growth_LP_t_1"
"$dir_figures/FigureC4_growth_L_t"  
"$dir_figures/FigureC4_growth_LP_t"
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX Table C.3.—Market Rank, Innovation, and Political Connection, with Quality-adjusted Patent Intensity
* FIGURE 5.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION (c, d)
* APPENDIX FIGURE C.4.—EMPLOYMENT AND LABOR PRODUCTIVITY GROWTH AFTER ELECTION. 20% MARGIN OF VICTORY SAMPLE (c, d)
do regs_rd_stay_t.do 

/* Input: "$dir_data/data_rd.dta"
Output:  
Tables --
"$dir_tables/TableC3_RD_stay_t.tex"

Figures --
"$dir_figures/Fgure5_stay_t_growth_L_t" XX correct name
"$dir_figures/Fgure5_stay_t_growth_LP_t" 
"$dir_figures/FgureC4_stay_t_growth_L_t" XX correct name
"$dir_figures/FgureC4_stay_t_growth_LP_t" 
*/
  
  
 

 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Figure 7: WITHIN-FIRM WAGE PREMIUM BEFORE AND AFTER BECOMING A POLITICIAN
do wagepremium.do

/* Input: "$dir_data/everpolit_wages_foreventstudy.dta" and also "$dir_data/nowconn_firms_workers_wages.dta" for stats
Output:  "$dir_figures/Figure 7_wagepremium.pdf" 
ster files in "$dir_ster"
stats in log file "$dir_logs/log_wagepremium.log"
*/
	  



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Table X: POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS
* Table C.6: POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS. TRADABLE VS NON-TRADABLE 
* Table C.7: POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS. MANUFACTURING VS NON-MANUFACTURING
do regs_indreglevel.do

/* Input: $dir_data/data_indreg.dta
Output:  "$dir_tables/TabX_indreglevel.tex"      -- Table X
         "$dir_tables/TabC_indreglevel_trad.tex" -- Table C.6
		 "$dir_tables/TabC_indreglevel_mnfg.tex" -- Table C.7
ster files in "$dir_ster
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
                        * Appendix Files*
 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table B.1 Cross-Correlations of Various Patent Quality Measures
* Appendix Table B.2 Statistics on Patent Quality for Italian Patents (1990-2014)
do sumstat_patents.do 

/* Input: $dir_data/patents_ITfirms.dta
Output:  $dir_tables/TabB1_corr_patents.tex $dir_tables/TabB2_sumstat_patents.tex
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table B.3 Statistics on Local Politicians Employed in the Private Sector
do stats_politsample.do 

/* Input: $dir_data/pol_qualifica.dta  "$dir_data/politsID_sample_8514.dta" 
Output:  $dir_tables/TabB3_politsample_matched_stats.tex 
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table B.4 Characteristics of Politicians and Non-Politician Workers
do stats_polits_nonpolits.do 

/* Input: $dir_data/nowconn_firms_workers_wages.dta  
Output:  $dir_tables/TabB4_pol_nonpol_stats.tex 
*/



 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX TABLE C.4 RD ESTIMATES FOR OTHER OUTCOMES
do regs_rd_otheroutcomes.do

/* Input: "$dir_data/data_RD.dta"
Output:  
"$dir_tables/TableC4_otheroutcomes.tex"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX TABLE C.5 EMPLOYMENT GROWTH AFTER ELECTION. RDD FOR NEWLY ELECTED AND EXISTING POLITICIANS
do regs_rd_new_old_pols.do
/* Input: "$dir_data/data_RD.dta"
Output:  
"$dir_tables/TableC5_oldpol.tex"
"$dir_tables/TableC5_newpol.tex"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Figure C.5 DISTRIBUTION OF THE SHARE OF WINNING POLITICIANS ACROSS FIRMS, CONDITIONAL ON GETTING ANY SEAT
do distrib_winlose_elec.do 

/* Input: "$dir_data/data_RD.dta"
Output:  "$dir_figures/Figure_C5.pdf"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* Appendix Table C.9 CONNECTIONS AND ENTRY. CROSS-BORDER ANALYSIS
do regs_crossborder_analysis.do

/* Input: $dir_data/data_crossborder.dta
Output:  "$dir_tables/TabC9_PanelA_crossborder.tex"  "$dir_tables/TabC9_PanelB_crossborder.tex"
ster files in "$dir_ster
*/




 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX TABLE D.1.— POLITICAL CONNECTIONS AND BUREAUCRACY INDEX ACROSS INDUSTRIES
* APPENDIX FIGURE D.1.— BUREAUCRACY AND CONNECTIONS ACROSS INDUSTRIES
do descr_factiva_bur_conn.do 
/* Input: $dir_data/factiva_bur_conn.dta
Output:  
 "$dir_figures/FigureD1_a.pdf" 
 "$dir_figures/FigureD1_2.pdf"
 "$dir_tables/TabD1.tex"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
* APPENDIX FIGURE D.2.— GOVERNMENT DEPENDENCE AND CONNECTIONS ACROSS INDUSTRIES
do govdep_conn_correlate.do
/* Input: $dir_data/data_govdep_conn.dta
Output:  
 "$dir_figures/FigureD2_a.pdf" 
 "$dir_figures/FigureD2_b.pdf"
*/


 *===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===*===
*APPENDIX TABLE D.2.— POLITICAL CONNECTIONS AND INDUSTRY DYNAMICS. BUREAUCRACY, REGULATION, AND INSTITUTIONAL DEFICIENCY INDEXES 
do regs_bur_corru_reg.do


/* Input: "$dir_data/data_corruregbur_conn.dta"
Output:  "$dir_tables\TableD2_panel_bur.tex" 
"$dir_tables\TableD2_panel_corru.tex"
"$dir_tables\TableD2_panel_regu.tex"

*/


