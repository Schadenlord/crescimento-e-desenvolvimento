*This code generates Table IV: Summary Statistics of the Matched Firm-Level Datasummary


clear all
scalar drop _all

use "$dir_data/firmdata_stats.dta", clear

global VarsToSummarize = "employment_march	av_pay_wk	growth_empl_smooth	tot_assets_defl	growth_VA	growth_LP	growth_TFP	npat_yr	npat_famsize_yr	npat_ncit5_yr	conn_d	conn_high_d	conn_maj_d	npolit_cf_mis	npolit_maj_mis	npolit_high_cf_mis"


// Sample All firms

putexcel set "$dir_tables/TabIV_sumstats_firmlevel", replace
putexcel A1="Sample All Firms"

putexcel A2="Variable"
putexcel B2="Mean"
putexcel C2="Median"
putexcel D2="St dev"


local j=2

count
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


count if conn_d ==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa if everconn==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


foreach var in $VarsToSummarize {

sum `var', d
local j=`j'+1

putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel A`j'="`var'"
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(mean)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel C`j'=`r(p50)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel D`j'=`r(sd)'
}

local j=`j'+2
putexcel A`j'="Sample Balance Sheet"


***************
// Sample with non-missing Balance Sheet

keep if merge_inpsbs==3

count
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


count if conn_d ==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(N)'
local j=`j'+1

distinct id_impresa if everconn==1
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(ndistinct)'
local j=`j'+1


foreach var in $VarsToSummarize {

sum `var', d
local j=`j'+1

putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel A`j'="`var'"
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel B`j'=`r(mean)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel C`j'=`r(p50)'
putexcel set "$dir_tables/TabIV_sumstats_firmlevel", modify
putexcel D`j'=`r(sd)'
}


* the excel output is manually converted to tex file to obtain the appearance as in the paper


