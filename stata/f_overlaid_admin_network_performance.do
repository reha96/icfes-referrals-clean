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
set obs 6

gen ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1

gen xpos = .
replace xpos = 1 if ses == 1 & subject == 2     // Low SES, Reading (now first)
replace xpos = 1.5 if ses == 1 & subject == 1   // Low SES, Math (now second)
replace xpos = 2.5 if ses == 2 & subject == 2   // Middle SES, Reading (now first)
replace xpos = 3 if ses == 2 & subject == 1     // Middle SES, Math (now second)
replace xpos = 4 if ses == 3 & subject == 2     // High SES, Reading (now first)
replace xpos = 4.5 if ses == 3 & subject == 1   // High SES, Math (now second)

gen z_score = .
gen se = .
gen z_scoreA = .
gen z_scoreS = .

local r = 1
foreach ses in low middle high {
    foreach subj in math read {
        local subj_num = cond("`subj'"=="math", 1, 2)
        local ses_num = cond("`ses'"=="low", 1, cond("`ses'"=="middle", 2, 3))
        
        if `r' <= 6 {
            replace z_score = ${`subj'_`ses'} if ses==`ses_num' & subject==`subj_num'
			replace z_scoreA = ${`subj'_`ses'A} if ses==`ses_num' & subject==`subj_num'
			replace z_scoreS = ${`subj'_`ses'S} if ses==`ses_num' & subject==`subj_num'
            replace se = ${`subj'_`ses'_sd}/sqrt(${`subj'_`ses'_n}) if ses==`ses_num' & subject==`subj_num'
        }
        local r = `r' + 1
    }
}

gen ci_lower = z_score - 1.96*se
gen ci_upper = z_score + 1.96*se

twoway (bar z_score xpos if subject==2, barw(0.45) color("130 202 157")) ///  // Reading (now first)
       (bar z_score xpos if subject==1, barw(0.45) color("136 132 216")) ///  // Math (now second)
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
	   (scatter z_scoreA xpos, mcolor(gs4) lcolor(none)) ///
	   (scatter z_scoreS xpos, mcolor(red) lcolor(none) msymbol(+)) ///
       , ///
       xlabel(1.25 "Low" 2.75 "Middle" 4.25 "High") ///
       ylabel(50(5)80, angle(0) grid gmin gmax) ///
       ytitle("Score") ///
       xtitle("") ///
       title("Network Performance by SES") ///
       legend(order(1 "Reading" 2 "Math" 4 "Admin Data" 5 "Sample") ring(0) pos(12) rows(1) region(lcolor(none))) ///  // Update legend order
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 5)) ///
       name(ses_zscore, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/overlaid_network_performance.png", replace
restore
