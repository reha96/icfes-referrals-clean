/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 02.04.2025
    Description: overlaid figure network admin sample performance by SES
*******************************************************************************/

clear all
foreach ses in low middle high {
    foreach type in math read {
        global `type'_`ses' = ""
        global `type'_`ses'_sd = ""
        global `type'_`ses'_n = ""
    }
}

use math.dta, clear

foreach ses in 1 2 3 {
    local ses_label = cond(`ses'==1, "low", cond(`ses'==2, "middle", "high"))
    
    preserve 
    keep if own_estrato == `ses'
    
    tabstat other_score_math, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global math_`ses_label'_n = stats[1,1]
    global math_`ses_label' = stats[2,1]
    global math_`ses_label'_sd = stats[3,1]
    
    restore 
	
    preserve
	drop counter
	bysort other_id: gen counter = _n
	keep if counter == 1
	keep if other_estrato == `ses'
    
    tabstat other_score_math, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global math_`ses_label'_nA = stats[1,1]
    global math_`ses_label'A = stats[2,1]
    global math_`ses_label'_sdA = stats[3,1]
    restore
	
	preserve
	drop counter
	bysort own_id: gen counter = _n
	keep if counter == 1
	keep if own_estrato == `ses'
    
    tabstat own_score_math, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global math_`ses_label'_nS = stats[1,1]
    global math_`ses_label'S = stats[2,1]
    global math_`ses_label'_sdS = stats[3,1]
    restore
    }

use reading.dta, clear

foreach ses in 1 2 3 {
    local ses_label = cond(`ses'==1, "low", cond(`ses'==2, "middle", "high"))
    
    preserve 
    keep if own_estrato == `ses'
    
    tabstat other_score_reading, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global read_`ses_label'_n = stats[1,1]
    global read_`ses_label' = stats[2,1]
    global read_`ses_label'_sd = stats[3,1]
    
    restore
	
	preserve
	drop counter
	bysort other_id: gen counter = _n
	keep if counter == 1
	keep if other_estrato == `ses'
    
    tabstat other_score_reading, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global read_`ses_label'_nA = stats[1,1]
    global read_`ses_label'A = stats[2,1]
    global read_`ses_label'_sdA = stats[3,1] 
    restore
	
	preserve
	drop counter
	bysort own_id: gen counter = _n
	keep if counter == 1
	keep if own_estrato == `ses'
    
    tabstat own_score_reading, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global read_`ses_label'_nS = stats[1,1]
    global read_`ses_label'S = stats[2,1]
    global read_`ses_label'_sdS = stats[3,1]
    restore
}

preserve
clear
set obs 3
gen ses = _n  // 1=low, 2=middle, 3=high
gen xpos = _n - 0.125  // Position for sample bars
gen xpos2 = _n + 0.125  // Position for network bars
gen score_sample = .  // Sample scores
gen score_network = .  // Network scores
gen se_sample = .  // Standard errors for sample
gen se_network = .  // Standard errors for network

local r = 1
foreach ses in low middle high {
    local ses_num = cond("`ses'"=="low", 1, cond("`ses'"=="middle", 2, 3))

    replace score_sample = ${read_`ses'S} if ses==`ses_num'
    replace score_network = ${read_`ses'} if ses==`ses_num'
    
    replace se_sample = ${read_`ses'_sdS}/sqrt(${read_`ses'_nS}) if ses==`ses_num'
    replace se_network = ${read_`ses'_sd}/sqrt(${read_`ses'_n}) if ses==`ses_num'
    
    local r = `r' + 1
}

gen ci_lower_sample = score_sample - 1.96*se_sample
gen ci_upper_sample = score_sample + 1.96*se_sample
gen ci_lower_network = score_network - 1.96*se_network
gen ci_upper_network = score_network + 1.96*se_network

twoway (bar score_sample xpos, barw(0.25) fcolor(gs8) lcolor(gs4)) ///
		(bar score_network xpos2, barw(0.25) fcolor(gs14) lcolor(gs4)) ///
       (rcap ci_upper_network ci_lower_network xpos2, lcolor(gs4)) ///
	   (rcap ci_upper_sample ci_lower_sample xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(50(5)80, angle(0) grid gmin gmax) ///
       ytitle("Reading Score") ///
       xtitle("") ///
       title("Reading Performance") ///
       legend(order(1 "Sample" 2 "Network") ring(0) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(ses_reading_scores, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_reading_scores.png", replace
restore

preserve
clear
set obs 3
gen ses = _n  // 1=low, 2=middle, 3=high
gen xpos = _n - 0.125  // Position for sample bars
gen xpos2 = _n + 0.125  // Position for network bars
gen score_sample = .  // Sample scores
gen score_network = .  // Network scores
gen se_sample = .  // Standard errors for sample
gen se_network = .  // Standard errors for network

local r = 1
foreach ses in low middle high {
    local ses_num = cond("`ses'"=="low", 1, cond("`ses'"=="middle", 2, 3))

    replace score_sample = ${math_`ses'S} if ses==`ses_num'
    replace score_network = ${math_`ses'} if ses==`ses_num'
    
    replace se_sample = ${math_`ses'_sdS}/sqrt(${math_`ses'_nS}) if ses==`ses_num'
    replace se_network = ${math_`ses'_sd}/sqrt(${math_`ses'_n}) if ses==`ses_num'
    
    local r = `r' + 1
}

gen ci_lower_sample = score_sample - 1.96*se_sample
gen ci_upper_sample = score_sample + 1.96*se_sample
gen ci_lower_network = score_network - 1.96*se_network
gen ci_upper_network = score_network + 1.96*se_network


twoway 	(bar score_sample xpos, barw(0.25) fcolor(gs8) lcolor(gs4)) ///
		(bar score_network xpos2, barw(0.25) fcolor(gs14) lcolor(gs4)) ///
       (rcap ci_upper_network ci_lower_network xpos2, lcolor(gs4)) ///
	   (rcap ci_upper_sample ci_lower_sample xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(50(5)80, angle(0) grid gmin gmax) ///
       ytitle("Math Score") ///
       xtitle("") ///
       title("Math Performance") ///
       legend(order(1 "Sample" 2 "Network") ring(0) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(ses_math_scores, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_math_scores.png", replace
restore
