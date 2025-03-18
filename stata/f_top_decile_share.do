/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure top decile share
*******************************************************************************/

use "dataset_z.dta", clear
 
bysort own_id : gen counter =_n
tabstat top_own_score_reading top_own_score_math if counter == 1, stat(n mean semean sd) save
matrix sample_stats = r(StatTotal)
global sample_n = sample_stats[1,1]
global sample_read_mean = sample_stats[2,1]
global sample_read_se = sample_stats[3,1]
global sample_read_sd = sample_stats[4,1]
global sample_math_mean = sample_stats[2,2]
global sample_math_se = sample_stats[3,2]
global sample_math_sd = sample_stats[4,2]

tabstat top_other_score_reading top_other_score_math, stat(n mean semean sd) save
matrix network_stats = r(StatTotal)
global network_n = network_stats[1,1]
global network_read_mean = network_stats[2,1]
global network_read_se = network_stats[3,1]
global network_read_sd = network_stats[4,1]
global network_math_mean = network_stats[2,2]
global network_math_se = network_stats[3,2]
global network_math_sd = network_stats[4,2]

tabstat top_other_score_reading if area == 1 & nomination, stat(n mean semean sd) save
matrix referrals_read_stats = r(StatTotal)
global referrals_read_n = referrals_read_stats[1,1]
global referrals_read_mean = referrals_read_stats[2,1]
global referrals_read_se = referrals_read_stats[3,1]
global referrals_read_sd = referrals_read_stats[4,1]

tabstat top_other_score_math if area == 2 & nomination, stat(n mean semean sd) save
matrix referrals_math_stats = r(StatTotal)
global referrals_math_n = referrals_math_stats[1,1]
global referrals_math_mean = referrals_math_stats[2,1]
global referrals_math_se = referrals_math_stats[3,1]
global referrals_math_sd = referrals_math_stats[4,1]

prtesti ${sample_n} ${sample_read_mean} ${network_n} ${network_read_mean}
prtesti ${sample_n} ${sample_read_mean} ${referrals_read_n} ${referrals_read_mean}
prtesti ${network_n} ${network_read_mean} ${referrals_read_n} ${referrals_read_mean}
prtesti ${sample_n} ${sample_math_mean} ${network_n} ${network_math_mean}
prtesti ${sample_n} ${sample_math_mean} ${referrals_math_n} ${referrals_math_mean}
prtesti ${network_n} ${network_math_mean} ${referrals_math_n} ${referrals_math_mean}


preserve
clear
set obs 6
gen id = _n
gen group = .
gen subject = .
gen xpos = .
gen pct_top = .
gen se = .
local group_names `""Sample" "Network" "Referrals""'
local subj_names `""Reading" "Math""'
local row = 1
forvalues g = 1/3 {
    forvalues s = 1/2 {
        replace group = `g' if id == `row'
        replace subject = `s' if id == `row'
        local base_pos = (`g'-1)*1.5 + 1
        if `s' == 1 {
            replace xpos = `base_pos' + 0.5 if id == `row'
        }
        else {
            replace xpos = `base_pos' if id == `row'
        }
        if `s' == 1 {
            if `g' == 1 {
                replace pct_top = ${sample_math_mean} * 100 if id == `row'
                replace se = ${sample_math_se} * 100 if id == `row'
            }
            else if `g' == 2 {
                replace pct_top = ${network_math_mean} * 100 if id == `row'
                replace se = ${network_math_se} * 100 if id == `row'
            }
            else if `g' == 3 {
                replace pct_top = ${referrals_math_mean} * 100 if id == `row'
                replace se = ${referrals_math_se} * 100 if id == `row'
            }
        }
        else {
            if `g' == 1 {
                replace pct_top = ${sample_read_mean} * 100 if id == `row'
                replace se = ${sample_read_se} * 100 if id == `row'
            }
            else if `g' == 2 {
                replace pct_top = ${network_read_mean} * 100 if id == `row'
                replace se = ${network_read_se} * 100 if id == `row'
            }
            else if `g' == 3 {
                replace pct_top = ${referrals_read_mean} * 100 if id == `row'
                replace se = ${referrals_read_se} * 100 if id == `row'
            }
        }
        local row = `row' + 1
    }
}
gen ci_lower = pct_top - 1.96*se
gen ci_upper = pct_top + 1.96*se
list, clean
local bar_cmds ""
forvalues g = 1/3 {
    local bar_cmds `"`bar_cmds' (bar pct_top xpos if group==`g' & subject==2, barw(0.45) color("130 202 157"))"'
}
forvalues g = 1/3 {
    local bar_cmds `"`bar_cmds' (bar pct_top xpos if group==`g' & subject==1, barw(0.45) color("136 132 216"))"'
}
local xlabel ""
forvalues g = 1/3 {
    local base_pos = (`g'-1)*1.5 + 1
    local pos = `base_pos' + 0.25
    local name : word `g' of `group_names'
    local xlabel `"`xlabel' `pos' "`name'""'
}
twoway `bar_cmds' ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(`xlabel', labsize(medium)) ///
       ylabel(0(5)25, angle(0) ) ///
       ytitle("Percent") ///
       xtitle("") ///
       title("Top Decile Share") ///
       legend(order(1 "Reading" 4 "Math") ring(0) pos(11) rows(2) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 4.5)) ///
       name(top_decile_comparison, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/top_decile_comparison.png", replace
restore
