/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 05.02.2025
    Description: descriptives
*******************************************************************************/

//# preamble
cls
version 18
clear all
macro drop _all
set more off
set scheme s2color, permanently
set maxvar 32767
global graph_opts ///
    graphregion(fcolor(white) lcolor(white)) ///
    bgcolor(white) ///
    plotregion(lcolor(white))
	
// use sender receiver data here
use "dataset_z.dta", clear
describe *
gsort own_id other_id

bysort  own_id : gen counter =_n
by own_id : egen size = max(counter)
replace size = size/2 // average connections per network (verbal+math)/2


//# TABLE Sample descriptives
preserve 
keep if counter==1
foreach v of varlist z_tie own_age own_female own_low_ses own_med_ses own_high_ses own_g* own_score_m* own_score_r*  size {
    display _newline
    display as text "=== Test for `v' ===" _newline
    
    // summarize
    summarize `v', det
    local min = r(min)
    local max = r(max)
	global exp_`v'_mean = r(mean)
    global exp_`v'_sd = r(sd)
    
	// test
    if `min' == 0 & `max' == 1 {
        prtest `v', by(treat)
    }
    else {
        ttest `v', by(treat) unequal
    }
}
clear all
restore 

//# TABLE Selection into the experiment descriptives
gen other_low_ses = other_estrato == 1
gen other_med_ses = other_estrato == 2
gen other_high_ses = other_estrato == 3

preserve 
bysort  other_id : gen counter2 =_n
keep if counter2 == 1
drop own*
rename other_low_ses own_low_ses
rename other_med_ses own_med_ses
rename other_high_ses own_high_ses
rename other_age own_age
rename other_female own_female
rename other_gpa own_gpa
rename other_score_math own_score_math
rename other_score_reading own_score_reading

foreach v of varlist own_age own_female own_low_ses own_med_ses own_high_ses own_gpa own_score_math own_score_reading	 {
    display _newline

    // summarize
    summarize `v', det
	global admin_`v'_mean = r(mean)
    global admin_`v'_sd = r(sd)
   
    // Now we can test using stored values
    if inlist("`v'", "own_female", "own_low_ses", "own_med_ses", "own_high_ses") {
        prtesti 4417 ${admin_`v'_mean} 734 ${exp_`v'_mean}
    }
    else {
        ttesti 4417 ${admin_`v'_mean} ${admin_`v'_sd} 734 ${exp_`v'_mean} ${exp_`v'_sd}, unequal
    }
}
restore 






/// load STD datasets

//# TABLE non-referred choice set VS referred by SES
preserve
keep if treat == 1
// low
tab other_estrato if nomination == 1 & own_estrato == 1
tab other_estrato if  nomination == 0 & own_estrato == 1
// med
tab other_estrato if nomination == 1 & own_estrato == 2
tab other_estrato if nomination == 0 & own_estrato == 2
// high
tab other_estrato if nomination == 1 & own_estrato == 3
tab other_estrato if nomination == 0 & own_estrato == 3
restore

// plot
// Calculate referral proportions by SES and store statistics
foreach own in low middle high {
    foreach other in low middle high {
        global prop_`own'_`other' = ""
        global se_`own'_`other' = ""
    }
}

preserve
keep if treat == 1

// Low SES own group
keep if own_estrato == 1 & nomination
proportion other_estrato
matrix props_low = r(table)
global prop_low_low = props_low[1,1]
global prop_low_middle = props_low[1,2]
global prop_low_high = props_low[1,3]
global se_low_low = props_low[2,1]
global se_low_middle = props_low[2,2]
global se_low_high = props_low[2,3]
tabstat other_estrato, stat(n) save
matrix stats = r(StatTotal)
global n_low = stats[1,1]
restore

preserve
keep if treat == 1
// Middle SES own group
keep if own_estrato == 2 & nomination
proportion other_estrato
matrix props_middle = r(table)
global prop_middle_low = props_middle[1,1]
global prop_middle_middle = props_middle[1,2]
global prop_middle_high = props_middle[1,3]
global se_middle_low = props_middle[2,1]
global se_middle_middle = props_middle[2,2]
global se_middle_high = props_middle[2,3]
tabstat other_estrato, stat(n) save
matrix stats = r(StatTotal)
global n_middle = stats[1,1]
restore

preserve
keep if treat == 1
// High SES own group
keep if own_estrato == 3 & nomination
proportion other_estrato
matrix props_high = r(table)
global prop_high_low = props_high[1,1]
global prop_high_middle = props_high[1,2]
global prop_high_high = props_high[1,3]
global se_high_low = props_high[2,1]
global se_high_middle = props_high[2,2]
global se_high_high = props_high[2,3]
tabstat other_estrato, stat(n) save
matrix stats = r(StatTotal)
global n_high = stats[1,1]
restore

// Run significance tests between SES groups
// Compare Low SES peer connections across own SES groups
prtesti ${n_low} ${prop_low_low} ${n_middle} ${prop_middle_low}    // Low vs Middle (Low SES peers)
prtesti ${n_low} ${prop_low_low} ${n_high} ${prop_high_low}      // Low vs High (Low SES peers)
prtesti ${n_middle} ${prop_middle_low} ${n_high} ${prop_high_low}    // Middle vs High (Low SES peers)

// Compare Middle SES peer connections across own SES groups
prtesti ${n_low} ${prop_low_middle} ${n_middle} ${prop_middle_middle}   // Low vs Middle (Middle SES peers)
prtesti ${n_low} ${prop_low_middle} ${n_high} ${prop_high_middle}    // Low vs High (Middle SES peers)
prtesti ${n_middle} ${prop_middle_middle} ${n_high} ${prop_high_middle}    // Middle vs High (Middle SES peers)

// Compare High SES peer connections across own SES groups
prtesti ${n_low} ${prop_low_high} ${n_middle} ${prop_middle_high}   // Low vs Middle (High SES peers)
prtesti ${n_low} ${prop_low_high} ${n_high} ${prop_high_high}    // Low vs High (High SES peers)
prtesti ${n_middle} ${prop_middle_high} ${n_high} ${prop_high_high}    // Middle vs High (High SES peers)

// Create visualization dataset with confidence intervals
preserve
clear
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

// Set x-positions for each bar
replace xpos = 0.7 if own_ses == 1 & other_ses == 1  // Low-Low
replace xpos = 1.0 if own_ses == 1 & other_ses == 2  // Low-Middle
replace xpos = 1.3 if own_ses == 1 & other_ses == 3  // Low-High

replace xpos = 2.2 if own_ses == 2 & other_ses == 1  // Middle-Low
replace xpos = 2.5 if own_ses == 2 & other_ses == 2  // Middle-Middle
replace xpos = 2.8 if own_ses == 2 & other_ses == 3  // Middle-High

replace xpos = 3.7 if own_ses == 3 & other_ses == 1  // High-Low
replace xpos = 4.0 if own_ses == 3 & other_ses == 2  // High-Middle
replace xpos = 4.3 if own_ses == 3 & other_ses == 3  // High-High

// Fill in the proportions and standard errors
gen proportion = .
gen se = .

// Low SES (own_ses = 1)
replace proportion = ${prop_low_low} if own_ses == 1 & other_ses == 1
replace proportion = ${prop_low_middle} if own_ses == 1 & other_ses == 2
replace proportion = ${prop_low_high} if own_ses == 1 & other_ses == 3
replace se = ${se_low_low} if own_ses == 1 & other_ses == 1
replace se = ${se_low_middle} if own_ses == 1 & other_ses == 2
replace se = ${se_low_high} if own_ses == 1 & other_ses == 3

// Middle SES (own_ses = 2)
replace proportion = ${prop_middle_low} if own_ses == 2 & other_ses == 1
replace proportion = ${prop_middle_middle} if own_ses == 2 & other_ses == 2
replace proportion = ${prop_middle_high} if own_ses == 2 & other_ses == 3
replace se = ${se_middle_low} if own_ses == 2 & other_ses == 1
replace se = ${se_middle_middle} if own_ses == 2 & other_ses == 2
replace se = ${se_middle_high} if own_ses == 2 & other_ses == 3

// High SES (own_ses = 3)
replace proportion = ${prop_high_low} if own_ses == 3 & other_ses == 1
replace proportion = ${prop_high_middle} if own_ses == 3 & other_ses == 2
replace proportion = ${prop_high_high} if own_ses == 3 & other_ses == 3
replace se = ${se_high_low} if own_ses == 3 & other_ses == 1
replace se = ${se_high_middle} if own_ses == 3 & other_ses == 2
replace se = ${se_high_high} if own_ses == 3 & other_ses == 3

// Multiply all proportions and standard errors by 100 for percentages
replace proportion = proportion * 100
replace se = se * 100

// Calculate 95% confidence intervals
gen ci_lower = proportion - 1.96*se
gen ci_upper = proportion + 1.96*se

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the twoway bar graph with confidence intervals
twoway (bar proportion xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar proportion xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar proportion xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2.5 "Middle" 4 "High") ///
       ylabel(0(10)80, angle(0) format(%9.0f)) ///
       ytitle("Percent") ///
       xtitle("") ///
       title("Baseline Referral Rates by SES") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(11) rows(3) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 4.5)) ///
	   xsize(6) ysize(5) ///
       name(ses_referral_distribution, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_referral_distribution.png", replace
restore

preserve 
clear

// Create data structure - 9 observations for 3 own_SES × 3 other_SES
set obs 9
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen ref_diff = .

// Calculate referral rate differences (nominated - non-nominated)
// Low SES (own_ses = 1)
replace ref_diff = (142/300 - 21738/60235) * 100 if own_ses==1 & other_ses==1  // Low-Low
replace ref_diff = (143/300 - 30451/60235) * 100 if own_ses==1 & other_ses==2  // Low-Middle
replace ref_diff = (15/300 - 8046/60235) * 100 if own_ses==1 & other_ses==3    // Low-High

// Middle SES (own_ses = 2)
replace ref_diff = (107/338 - 19390/62563) * 100 if own_ses==2 & other_ses==1  // Middle-Low
replace ref_diff = (197/338 - 32955/62563) * 100 if own_ses==2 & other_ses==2  // Middle-Middle
replace ref_diff = (34/338 - 10218/62563) * 100 if own_ses==2 & other_ses==3   // Middle-High

// High SES (own_ses = 3)
replace ref_diff = (7/61 - 2443/8979) * 100 if own_ses==3 & other_ses==1      // High-Low
replace ref_diff = (43/61 - 4732/8979) * 100 if own_ses==3 & other_ses==2     // High-Middle
replace ref_diff = (11/61 - 1804/8979) * 100 if own_ses==3 & other_ses==3     // High-High

// Label the groups
label define ses_lab 1 "Low-SES" 2 "Middle-SES" 3 "High-SES"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the graph
graph bar ref_diff, over(other_ses) over(own_ses) ///
    asyvars ///
    bar(1, color("255 99 132")) ///
    bar(2, color("54 162 235")) ///
    bar(3, color("75 192 112")) ///
    ylabel(-20(10)20, angle(0)) ///
    ytitle("Δ share (p.p.)") ///
    title("Baseline Referral Rate Differences by SES") ///
    legend(ring(0) pos(2) rows(3) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(referral_rates, replace)

restore


preserve
use "dataset_z.dta", clear
cls
keep if treat == 1
proportion other_estrato if nomination == 1 & own_estrato == 1
proportion other_estrato if nomination == 1 & own_estrato == 2
proportion other_estrato if nomination == 1 & own_estrato == 3
restore

preserve
use "dataset_z.dta", clear
keep if treat == 2
proportion other_estrato if nomination == 1 & own_estrato == 1
proportion other_estrato if nomination == 1 & own_estrato == 2
proportion other_estrato if nomination == 1 & own_estrato == 3
restore

cls
// low
prtesti 300 .4733333 258 .5310078
prtesti 300 .4766667  258 .3875969 // **
prtesti 300 .05 258 .0813953
// med
prtesti 338 .316568 329 .3221884 
prtesti 338 .5828402 329 .5197568 
prtesti 338 .1005917 329 .1580547 // **
// high
prtesti 61 .1147541 56 .1785714 // vs low
prtesti 61 .704918 56 .5357143 // vs med **
prtesti 61 .1803279 56 .2857143 // vs high


////////////////////////////////
// Create dataset for treatment effects
preserve
clear
set obs 9  // 3 own_SES × 3 other_SES groups
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

// Set x-positions for each bar group
replace xpos = 0.7 if own_ses == 1 & other_ses == 1  // Low-Low
replace xpos = 1.0 if own_ses == 1 & other_ses == 2  // Low-Middle
replace xpos = 1.3 if own_ses == 1 & other_ses == 3  // Low-High

replace xpos = 1.7 if own_ses == 2 & other_ses == 1  // Middle-Low
replace xpos = 2.0 if own_ses == 2 & other_ses == 2  // Middle-Middle
replace xpos = 2.3 if own_ses == 2 & other_ses == 3  // Middle-High

replace xpos = 2.7 if own_ses == 3 & other_ses == 1  // High-Low
replace xpos = 3.0 if own_ses == 3 & other_ses == 2  // High-Middle
replace xpos = 3.3 if own_ses == 3 & other_ses == 3  // High-High

// Treatment effects (Bonus - Baseline) in percentage points
gen effect = .

// Adding baseline and bonus proportions and SEs (all multiplied by 100)
gen prop_baseline = .
gen se_baseline = .
gen prop_bonus = .
gen se_bonus = .

// Low SES referrers (own_ses = 1)
// Low-Low
replace prop_baseline = 47.33 if own_ses == 1 & other_ses == 1
replace se_baseline = 2.88 if own_ses == 1 & other_ses == 1
replace prop_bonus = 53.10 if own_ses == 1 & other_ses == 1
replace se_bonus = 3.11 if own_ses == 1 & other_ses == 1

// Low-Middle
replace prop_baseline = 47.67 if own_ses == 1 & other_ses == 2
replace se_baseline = 2.88 if own_ses == 1 & other_ses == 2
replace prop_bonus = 38.76 if own_ses == 1 & other_ses == 2
replace se_bonus = 3.03 if own_ses == 1 & other_ses == 2

// Low-High
replace prop_baseline = 5.00 if own_ses == 1 & other_ses == 3
replace se_baseline = 1.26 if own_ses == 1 & other_ses == 3
replace prop_bonus = 8.14 if own_ses == 1 & other_ses == 3
replace se_bonus = 1.70 if own_ses == 1 & other_ses == 3

// Middle SES referrers (own_ses = 2)
// Middle-Low
replace prop_baseline = 31.66 if own_ses == 2 & other_ses == 1
replace se_baseline = 2.53 if own_ses == 2 & other_ses == 1
replace prop_bonus = 32.22 if own_ses == 2 & other_ses == 1
replace se_bonus = 2.58 if own_ses == 2 & other_ses == 1

// Middle-Middle
replace prop_baseline = 58.28 if own_ses == 2 & other_ses == 2
replace se_baseline = 2.68 if own_ses == 2 & other_ses == 2
replace prop_bonus = 51.98 if own_ses == 2 & other_ses == 2
replace se_bonus = 2.75 if own_ses == 2 & other_ses == 2

// Middle-High
replace prop_baseline = 10.06 if own_ses == 2 & other_ses == 3
replace se_baseline = 1.64 if own_ses == 2 & other_ses == 3
replace prop_bonus = 15.81 if own_ses == 2 & other_ses == 3
replace se_bonus = 2.01 if own_ses == 2 & other_ses == 3

// High SES referrers (own_ses = 3)
// High-Low
replace prop_baseline = 11.48 if own_ses == 3 & other_ses == 1
replace se_baseline = 4.08 if own_ses == 3 & other_ses == 1
replace prop_bonus = 17.86 if own_ses == 3 & other_ses == 1
replace se_bonus = 5.12 if own_ses == 3 & other_ses == 1

// High-Middle
replace prop_baseline = 70.49 if own_ses == 3 & other_ses == 2
replace se_baseline = 5.84 if own_ses == 3 & other_ses == 2
replace prop_bonus = 53.57 if own_ses == 3 & other_ses == 2
replace se_bonus = 6.66 if own_ses == 3 & other_ses == 2

// High-High
replace prop_baseline = 18.03 if own_ses == 3 & other_ses == 3
replace se_baseline = 4.92 if own_ses == 3 & other_ses == 3
replace prop_bonus = 28.57 if own_ses == 3 & other_ses == 3
replace se_bonus = 6.04 if own_ses == 3 & other_ses == 3

// Calculate treatment effects
replace effect = prop_bonus - prop_baseline

// Calculate standard error of the difference and confidence intervals
gen se_diff = sqrt(se_bonus^2 + se_baseline^2)
gen ci_lower = effect - 1.96*se_diff
gen ci_upper = effect + 1.96*se_diff

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the twoway bar graph with confidence intervals
twoway (bar effect xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar effect xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar effect xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap ci_upper ci_lower xpos if other_ses == 1, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 2, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 3, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(-50(10)50, angle(0) format(%9.0f)) ///
       ytitle("Δ share (p.p.)") ///
       xtitle("") ///
       title("Treatment Effect on Referral Rates by SES") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(1) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(ses_treatment_effect, replace)
restore
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_treatment_effects.png", replace

////////////////////////////////


//# TABLE share in top decile by SES
preserve 
bysort  other_id : gen counter2 =_n
keep if counter2 == 1
sum other_estrato, det

// tab other_estrato if top_z_other_gpa
proportion other_estrato if top_z_other_score_math
proportion other_estrato if top_z_other_score_reading
tab other_estrato if top_z_other_score_math
tab other_estrato if top_z_other_score_reading

prtest top_z_other_score_math == top_z_other_score_reading if other_estrato == 1 // For Low SES
prtest top_z_other_score_math == top_z_other_score_reading if other_estrato == 2 // For Middle SES
prtest top_z_other_score_math == top_z_other_score_reading if other_estrato == 3 // For High SES

restore

// plotting 
preserve 
clear
// Create the data in "long" format
set obs 6  // 3 strata × 2 metrics (math and reading)
gen strata = ceil(_n/2)
gen metric = mod(_n-1, 2) + 1  // 1=Math, 2=Reading
gen value = .

// Fill in values
// Math scores
replace value = 31.83 if strata==1 & metric==1  // Low strata math
replace value = 44.51 if strata==2 & metric==1  // Middle strata math
replace value = 23.66 if strata==3 & metric==1  // High strata math

// Reading scores
replace value = 30.13 if strata==1 & metric==2  // Low strata reading
replace value = 45.97 if strata==2 & metric==2  // Middle strata reading
replace value = 23.90 if strata==3 & metric==2  // High strata reading

// Label the groups
label define strata_lab 1 "Low" 2 "Middle" 3 "High"
label values strata strata_lab

// Create the graph
graph bar value, over(metric, relabel(1 "Math" 2 "Reading")) over(strata) ///
    asyvars ///
    bar(1, color("136 132 216")) ///    // Math (purple, similar to our React chart)
    bar(2, color("130 202 157")) ///    // Reading (green, similar to our React chart)
    legend(ring(0) pos(2) rows(2) region(lcolor(none))) ///
    ylabel(0(10)50, angle(0)) ///
    ytitle("Percent") ///
    title("Top Decile Share by SES") ///
    graphregion(color(white)) bgcolor(white) ///
    name(strata_scores, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/strata_scores.png", ///
    replace
restore

///
// First part: Get the percentages and CIs
preserve 
bysort other_id : gen counter2 = _n
keep if counter2 == 1

// Store math proportions and CIs
proportion other_estrato if top_z_other_score_math
matrix math = r(table)
// Store reading proportions and CIs
proportion other_estrato if top_z_other_score_reading
matrix reading = r(table)

// Create a simple dataset with all values
restore
preserve
clear

// Create a more straightforward dataset structure
set obs 6  // We just need 6 obs for the 6 data points
gen strata = ceil(_n/2)  // Will give 1,1,2,2,3,3
gen metric = mod(_n-1, 2) + 1  // Will give 1,2,1,2,1,2 (math/reading)
gen is_math = (metric == 1)  // Indicator for math
gen value = .
gen ci_lower = .
gen ci_upper = .

// Fill in all values at once
forvalues i = 1/3 {
    // Math values and CIs
    replace value = math[1,`i']*100 if strata==`i' & metric==1
    replace ci_lower = math[5,`i']*100 if strata==`i' & metric==1
    replace ci_upper = math[6,`i']*100 if strata==`i' & metric==1
    
    // Reading values and CIs
    replace value = reading[1,`i']*100 if strata==`i' & metric==2
    replace ci_lower = reading[5,`i']*100 if strata==`i' & metric==2
    replace ci_upper = reading[6,`i']*100 if strata==`i' & metric==2
}

// Generate bar positions
gen xpos = 0
replace xpos = 1 if strata==1 & metric==1  // Low SES, Math
replace xpos = 2 if strata==1 & metric==2  // Low SES, Reading
replace xpos = 4 if strata==2 & metric==1  // Middle SES, Math
replace xpos = 5 if strata==2 & metric==2  // Middle SES, Reading
replace xpos = 7 if strata==3 & metric==1  // High SES, Math
replace xpos = 8 if strata==3 & metric==2  // High SES, Reading

// Create a single twoway graph with both bars and error bars
twoway (bar value xpos if is_math, color("136 132 216") barwidth(1)) ///
       (bar value xpos if !is_math, color("130 202 157") barwidth(1)) ///
       (rcap ci_upper ci_lower xpos, color(black)), ///
       xlabel(1.5 "Low" 4.5 "Middle" 7.5 "High", noticks) ///
       ylabel(0(10)50, angle(0)) ///
	   xtitle("") ///
       ytitle("Percent") ///
       title("Top Decile Math and Reading Scores by SES") ///
       legend(order(1 "Math" 2 "Reading") ring(0) pos(2) rows(2) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0 9)) ///  // Ensure all bars are visible
       name(strata_scores, replace)

// Export the graph
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/strata_scores_with_ci.png", ///
    replace
restore
//

//# TABLE
tab other_estrato if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 1
tab other_estrato if !(top_z_other_score_math | top_z_other_score_reading) & own_estrato == 1

tab other_estrato if  (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 2
tab other_estrato if !(top_z_other_score_math | top_z_other_score_reading) & own_estrato == 2

tab other_estrato if  (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 3
tab other_estrato if !(top_z_other_score_math | top_z_other_score_reading) & own_estrato == 3

preserve
proportion other_estrato if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 1
proportion other_estrato if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 2
proportion other_estrato if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 3

**# Bookmark #1
//////////////////////////// HERE WORK
* Compare Low SES peer connections across own SES groups
prtesti 40183 0.179653 40910 0.185627 // Low vs Middle (Low SES peers)
prtesti 40183 0.179653 5305 0.187936 // Low vs High (Low SES peers)
prtesti 40910 0.185627 5305 0.187936 // Middle vs High (Low SES peers)

* Compare Middle SES peer connections across own SES groups
prtesti 55217 0.133564 66225 0.142695 // Low vs Middle (Middle SES peers)
prtesti 55217 0.133564 10571 0.146722 // Low vs High (Middle SES peers)
prtesti 66225 0.142695 10571 0.146722 // Middle vs High (Middle SES peers)

* Compare High SES peer connections across own SES groups
prtesti 14742 0.209741 19953 0.221821 // Low vs Middle (High SES peers)
prtesti 14742 0.209741 3891 0.248008 // Low vs High (High SES peers)
prtesti 19953 0.221821 3891 0.248008 // Middle vs High (High SES peers)
clear

// plot
preserve 
clear

// Create data structure
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen share = .

// Calculate shares for Low SES (own_ses = 1)
replace share = 100 * (7219 / (7219 + 32964)) if own_ses==1 & other_ses==1  // Low-Low
replace share = 100 * (7375 / (7375 + 47842)) if own_ses==1 & other_ses==2  // Low-Middle
replace share = 100 * (3092 / (3092 + 11650)) if own_ses==1 & other_ses==3  // Low-High

// Calculate shares for Middle SES (own_ses = 2)
replace share = 100 * (7594 / (7594 + 33316)) if own_ses==2 & other_ses==1  // Middle-Low
replace share = 100 * (9450 / (9450 + 56775)) if own_ses==2 & other_ses==2  // Middle-Middle
replace share = 100 * (4426 / (4426 + 15527)) if own_ses==2 & other_ses==3  // Middle-High

// Calculate shares for High SES (own_ses = 3)
replace share = 100 * (997 / (997 + 4308)) if own_ses==3 & other_ses==1    // High-Low
replace share = 100 * (1551 / (1551 + 9020)) if own_ses==3 & other_ses==2  // High-Middle
replace share = 100 * (965 / (965 + 2926)) if own_ses==3 & other_ses==3    // High-High

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the graph
graph bar share, over(other_ses) over(own_ses) ///
    asyvars ///
	bar(1, color("255 99 132")) ///    // Vibrant coral/raspberry
	bar(2, color("54 162 235")) ///    // Vibrant blue
	bar(3, color("75 192 112")) ///    // Vibrant green
    legend(ring(0) pos(2) rows(3) region(lcolor(none))) ///
    ylabel(0(10)60, angle(0)) ///
    ytitle("Top Decile Performers (%)") ///
    title("Availability of Top Decile Performers by SES") ///
    graphregion(color(white)) bgcolor(white) ///
    name(ses_top_shares, replace)
		graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_top_shares.png", ///
    replace
restore


//# TABLE
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 1 & other_estrato == 1
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 1 & other_estrato == 2
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 1 & other_estrato == 3

tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 2 & other_estrato == 1
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 2 & other_estrato == 2
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 2 & other_estrato == 3

tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 3 & other_estrato == 1
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 3 & other_estrato == 2
tabstat tie if (top_z_other_score_math | top_z_other_score_reading) & own_estrato == 3 & other_estrato == 3

preserve 
clear
// Create data structure
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen tie_strength = .

// Fill in average tie strengths
// For Low SES (own_ses = 1)
replace tie_strength = 3.710486 if own_ses==1 & other_ses==1  // Low-Low
replace tie_strength = 3.695593 if own_ses==1 & other_ses==2  // Low-Middle
replace tie_strength = 3.673997 if own_ses==1 & other_ses==3  // Low-High

// For Middle SES (own_ses = 2)
replace tie_strength = 3.414538 if own_ses==2 & other_ses==1  // Middle-Low
replace tie_strength = 3.779788 if own_ses==2 & other_ses==2  // Middle-Middle
replace tie_strength = 4.281066 if own_ses==2 & other_ses==3  // Middle-High

// For High SES (own_ses = 3)
replace tie_strength = 3.307924 if own_ses==3 & other_ses==1  // High-Low
replace tie_strength = 4.866538 if own_ses==3 & other_ses==2  // High-Middle
replace tie_strength = 5.981347 if own_ses==3 & other_ses==3  // High-High

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the graph
graph bar tie_strength, over(other_ses) over(own_ses) ///
    asyvars ///
    bar(1, color("255 99 132")) ///    // Vibrant coral for Low SES others
    bar(2, color("54 162 235")) ///    // Vibrant blue for Middle SES others
    bar(3, color("75 192 112")) ///    // Vibrant green for High SES others
    legend(ring(0) pos(11) rows(3) region(lcolor(none))) ///
    ylabel(0(1)6, angle(0)) ///
    ytitle("# Classes Together") ///
    title("Top Decile Performer Tie Strength by SES") ///
    graphregion(color(white)) bgcolor(white) ///
    name(ses_tie_strength, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_top_tie_strength.png", ///
    replace
restore


//# TABLE
tabstat z_tie if own_estrato == 1, by(other_estrato) stat(mean sd semean)
tabstat z_tie if own_estrato == 2, by(other_estrato) stat(mean sd semean)
tabstat z_tie if own_estrato == 3, by(other_estrato) stat(mean sd semean)
 
// First calculate means and store them in globals
foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly summ z_tie if own_estrato == `own' & other_estrato == `other'
        global mean_`own'_`other' = r(mean)
        global se_`own'_`other' = r(sd)/sqrt(r(N))
        global n_`own'_`other' = r(N)
    }
}

// Run t-tests for differences between own SES groups for each other SES level
// Compare Low-Low vs Middle-Low vs High-Low (connections to Low SES peers)
ttest z_tie if (own_estrato==1 | own_estrato==2) & other_estrato==1, by(own_estrato)
ttest z_tie if (own_estrato==1 | own_estrato==3) & other_estrato==1, by(own_estrato)
ttest z_tie if (own_estrato==2 | own_estrato==3) & other_estrato==1, by(own_estrato)

// Compare Low-Middle vs Middle-Middle vs High-Middle (connections to Middle SES peers)
ttest z_tie if (own_estrato==1 | own_estrato==2) & other_estrato==2, by(own_estrato)
ttest z_tie if (own_estrato==1 | own_estrato==3) & other_estrato==2, by(own_estrato)
ttest z_tie if (own_estrato==2 | own_estrato==3) & other_estrato==2, by(own_estrato)

// Compare Low-High vs Middle-High vs High-High (connections to High SES peers)
ttest z_tie if (own_estrato==1 | own_estrato==2) & other_estrato==3, by(own_estrato)
ttest z_tie if (own_estrato==1 | own_estrato==3) & other_estrato==3, by(own_estrato)
ttest z_tie if (own_estrato==2 | own_estrato==3) & other_estrato==3, by(own_estrato)

// Create visualization dataset
preserve
clear
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

// Set x-positions for each bar
replace xpos = 0.7 if own_ses == 1 & other_ses == 1  // Low-Low
replace xpos = 1.0 if own_ses == 1 & other_ses == 2  // Low-Middle
replace xpos = 1.3 if own_ses == 1 & other_ses == 3  // Low-High

replace xpos = 2.2 if own_ses == 2 & other_ses == 1  // Middle-Low
replace xpos = 2.5 if own_ses == 2 & other_ses == 2  // Middle-Middle
replace xpos = 2.8 if own_ses == 2 & other_ses == 3  // Middle-High

replace xpos = 3.7 if own_ses == 3 & other_ses == 1  // High-Low
replace xpos = 4.0 if own_ses == 3 & other_ses == 2  // High-Middle
replace xpos = 4.3 if own_ses == 3 & other_ses == 3  // High-High

// Fill in tie strength values
gen z_tie_strength = .
gen se = .

// Low SES (own_ses = 1)
replace z_tie_strength = ${mean_1_1} if own_ses == 1 & other_ses == 1
replace z_tie_strength = ${mean_1_2} if own_ses == 1 & other_ses == 2
replace z_tie_strength = ${mean_1_3} if own_ses == 1 & other_ses == 3
replace se = ${se_1_1} if own_ses == 1 & other_ses == 1
replace se = ${se_1_2} if own_ses == 1 & other_ses == 2
replace se = ${se_1_3} if own_ses == 1 & other_ses == 3

// Middle SES (own_ses = 2)
replace z_tie_strength = ${mean_2_1} if own_ses == 2 & other_ses == 1
replace z_tie_strength = ${mean_2_2} if own_ses == 2 & other_ses == 2
replace z_tie_strength = ${mean_2_3} if own_ses == 2 & other_ses == 3
replace se = ${se_2_1} if own_ses == 2 & other_ses == 1
replace se = ${se_2_2} if own_ses == 2 & other_ses == 2
replace se = ${se_2_3} if own_ses == 2 & other_ses == 3

// High SES (own_ses = 3)
replace z_tie_strength = ${mean_3_1} if own_ses == 3 & other_ses == 1
replace z_tie_strength = ${mean_3_2} if own_ses == 3 & other_ses == 2
replace z_tie_strength = ${mean_3_3} if own_ses == 3 & other_ses == 3
replace se = ${se_3_1} if own_ses == 3 & other_ses == 1
replace se = ${se_3_2} if own_ses == 3 & other_ses == 2
replace se = ${se_3_3} if own_ses == 3 & other_ses == 3

// Calculate 95% confidence intervals
gen ci_lower = z_tie_strength - 1.96*se
gen ci_upper = z_tie_strength + 1.96*se

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the twoway bar graph with confidence intervals
twoway (bar z_tie_strength xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar z_tie_strength xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar z_tie_strength xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2.5 "Middle" 4 "High") ///
       ylabel(-0.3(0.1)0.3, angle(0) format(%9.2f)) ///
       ytitle("z-score") ///
       xtitle("") ///
       title("Tie Strength by SES") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(11) rows(3) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 4.5)) ///
       name(z_ses_tie_strength, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/z_ses_tie_strength.png", replace
restore


//# TABLE referred by SES
preserve
keep if area == 1 & treat == 1
proportion other_estrato if nomination == 1, over(own_estrato)
restore

preserve
keep if area == 1 & treat == 2
proportion other_estrato if nomination == 1, over(own_estrato)
restore


preserve
keep if area == 2 & treat == 1
proportion other_estrato if nomination == 1, over(own_estrato)
restore

preserve
keep if area == 2 & treat == 2
proportion other_estrato if nomination == 1, over(own_estrato)
restore

//# TABLE/GRAPH SES by SES
foreach own in low middle high {
    foreach other in low middle high {
        global prop_`own'_`other' = ""
        global se_`own'_`other' = ""
    }
}

// Calculate proportions for each SES group connection
use dataset_z.dta, clear
preserve
keep if own_estrato == 1
proportion other_estrato
matrix props_low = r(table)
global prop_low_low = props_low[1,1]
global prop_low_middle = props_low[1,2]
global prop_low_high = props_low[1,3]
global se_low_low = props_low[2,1]
global se_low_middle = props_low[2,2]
global se_low_high = props_low[2,3]
tabstat other_estrato, stat(n) save
matrix stats = r(StatTotal)
global n_low = stats[1,1]
restore

preserve
keep if own_estrato == 2
proportion other_estrato
matrix props_middle = r(table)
global prop_middle_low = props_middle[1,1]
global prop_middle_middle = props_middle[1,2]
global prop_middle_high = props_middle[1,3]
global se_middle_low = props_middle[2,1]
global se_middle_middle = props_middle[2,2]
global se_middle_high = props_middle[2,3]
tabstat other_estrato, stat(n) save
matrix stats = r(StatTotal)
global n_middle = stats[1,1]
restore

preserve
keep if own_estrato == 3
proportion other_estrato
matrix props_high = r(table)
global prop_high_low = props_high[1,1]
global prop_high_middle = props_high[1,2]
global prop_high_high = props_high[1,3]
global se_high_low = props_high[2,1]
global se_high_middle = props_high[2,2]
global se_high_high = props_high[2,3]
tabstat other_estrato, stat(n) save
matrix stats = r(StatTotal)
global n_high = stats[1,1]
restore

// Compare Low SES peer connections across own SES groups
prtesti ${n_low} ${prop_low_low} ${n_middle} ${prop_middle_low}    // Low vs Middle (Low SES peers)
prtesti ${n_low} ${prop_low_low} ${n_high} ${prop_high_low}      // Low vs High (Low SES peers)
prtesti ${n_middle} ${prop_middle_low} ${n_high} ${prop_high_low}    // Middle vs High (Low SES peers)

// Compare Middle SES peer connections across own SES groups
prtesti ${n_low} ${prop_low_middle} ${n_middle} ${prop_middle_middle}   // Low vs Middle (Middle SES peers)
prtesti ${n_low} ${prop_low_middle} ${n_high} ${prop_high_middle}    // Low vs High (Middle SES peers)
prtesti ${n_middle} ${prop_middle_middle} ${n_high} ${prop_high_middle}    // Middle vs High (Middle SES peers)

// Compare High SES peer connections across own SES groups
prtesti ${n_low} ${prop_low_high} ${n_middle} ${prop_middle_high}   // Low vs Middle (High SES peers)
prtesti ${n_low} ${prop_low_high} ${n_high} ${prop_high_high}    // Low vs High (High SES peers)
prtesti ${n_middle} ${prop_middle_high} ${n_high} ${prop_high_high}    // Middle vs High (High SES peers)

// Multiply all proportions and standard errors by 100 for plotting
foreach own in low middle high {
    foreach other in low middle high {
        global prop_`own'_`other' = ${prop_`own'_`other'} * 100
        global se_`own'_`other' = ${se_`own'_`other'} * 100
    }
}
// Create visualization dataset
preserve
clear
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

// Set x-positions for each bar
replace xpos = 0.7 if own_ses == 1 & other_ses == 1  // Low-Low
replace xpos = 1.0 if own_ses == 1 & other_ses == 2  // Low-Middle
replace xpos = 1.3 if own_ses == 1 & other_ses == 3  // Low-High

replace xpos = 2.2 if own_ses == 2 & other_ses == 1  // Middle-Low
replace xpos = 2.5 if own_ses == 2 & other_ses == 2  // Middle-Middle
replace xpos = 2.8 if own_ses == 2 & other_ses == 3  // Middle-High

replace xpos = 3.7 if own_ses == 3 & other_ses == 1  // High-Low
replace xpos = 4.0 if own_ses == 3 & other_ses == 2  // High-Middle
replace xpos = 4.3 if own_ses == 3 & other_ses == 3  // High-High

gen proportion = .
gen se = .

replace proportion = ${prop_low_low} if own_ses == 1 & other_ses == 1
replace proportion = ${prop_low_middle} if own_ses == 1 & other_ses == 2
replace proportion = ${prop_low_high} if own_ses == 1 & other_ses == 3
replace se = ${se_low_low} if own_ses == 1 & other_ses == 1
replace se = ${se_low_middle} if own_ses == 1 & other_ses == 2
replace se = ${se_low_high} if own_ses == 1 & other_ses == 3

replace proportion = ${prop_middle_low} if own_ses == 2 & other_ses == 1
replace proportion = ${prop_middle_middle} if own_ses == 2 & other_ses == 2
replace proportion = ${prop_middle_high} if own_ses == 2 & other_ses == 3
replace se = ${se_middle_low} if own_ses == 2 & other_ses == 1
replace se = ${se_middle_middle} if own_ses == 2 & other_ses == 2
replace se = ${se_middle_high} if own_ses == 2 & other_ses == 3

replace proportion = ${prop_high_low} if own_ses == 3 & other_ses == 1
replace proportion = ${prop_high_middle} if own_ses == 3 & other_ses == 2
replace proportion = ${prop_high_high} if own_ses == 3 & other_ses == 3
replace se = ${se_high_low} if own_ses == 3 & other_ses == 1
replace se = ${se_high_middle} if own_ses == 3 & other_ses == 2
replace se = ${se_high_high} if own_ses == 3 & other_ses == 3

gen ci_lower = proportion - 1.96*se
gen ci_upper = proportion + 1.96*se

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

twoway (bar proportion xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar proportion xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar proportion xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2.5 "Middle" 4 "High") ///
       ylabel(0(10)60, angle(0) format(%9.0f)) ///
       ytitle("Percent") ///
       xtitle("") ///
       title("Availability by SES") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 4.5)) ///
       name(ses_distribution, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_distribution.png", replace
restore

//# TABLE performance by SES
preserve
use "reading.dta", clear
keep if area == 1 & treat == 1
tabstat z_other_score_reading if nomination == 1, by(own_estrato) stat(mean sd semean n)
restore

preserve
use "math.dta", clear
keep if area == 2 & treat == 1
tabstat z_other_score_math if nomination == 1, by(own_estrato) stat(mean sd semean n)
restore


// For Reading Score comparisons
// Low vs Middle
ttesti 147 0.6198732 1.103057 173 0.513949 1.02401

// Low vs High
ttesti 147 0.6198732 1.103057 31 0.6905426 0.8327419

// Middle vs High
ttesti 173 0.513949 1.02401 31 0.6905426 0.8327419

// For Math Score comparisons
// Low vs Middle
ttesti 153 0.5133594 1.291331 165 0.6596438 1.083366

// Low vs High
ttesti 153 0.5133594 1.291331 30 0.9450315 0.8970607

// Middle vs High
ttesti 165 0.6596438 1.083366 30 0.9450315 0.8970607

preserve
clear
// Create data structure with space for confidence intervals
// 6 observations: 3 SES groups × 2 subjects
set obs 6
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1
gen zscore = .
gen se = .  // Standard error
gen ci_lower = .
gen ci_upper = .

// Fill in z-scores and standard errors from your actual data
// Reading (subject = 1)
replace zscore = 0.6198732 if own_ses==1 & subject==1  // Low SES
replace zscore = 0.513949 if own_ses==2 & subject==1   // Middle SES
replace zscore = 0.6905426 if own_ses==3 & subject==1  // High SES
replace se = 0.0909786 if own_ses==1 & subject==1      // Low SES SE
replace se = 0.077854 if own_ses==2 & subject==1       // Middle SES SE
replace se = 0.1495649 if own_ses==3 & subject==1      // High SES SE

// Math (subject = 2)
replace zscore = 0.5133594 if own_ses==1 & subject==2  // Low SES
replace zscore = 0.6596438 if own_ses==2 & subject==2  // Middle SES
replace zscore = 0.9450315 if own_ses==3 & subject==2  // High SES
replace se = 0.1043979 if own_ses==1 & subject==2      // Low SES SE
replace se = 0.0843399 if own_ses==2 & subject==2      // Middle SES SE
replace se = 0.1637801 if own_ses==3 & subject==2      // High SES SE

// Calculate 95% confidence intervals
replace ci_lower = zscore - 1.96*se
replace ci_upper = zscore + 1.96*se

// Create position variable for bars
gen pos = .
replace pos = 1 if own_ses==1 & subject==1  // Low SES, Reading
replace pos = 2 if own_ses==1 & subject==2  // Low SES, Math
replace pos = 4 if own_ses==2 & subject==1  // Middle SES, Reading
replace pos = 5 if own_ses==2 & subject==2  // Middle SES, Math
replace pos = 7 if own_ses==3 & subject==1  // High SES, Reading
replace pos = 8 if own_ses==3 & subject==2  // High SES, Math

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label define subj_lab 1 "Reading" 2 "Math"
label values subject subj_lab

// Create the twoway bar graph with confidence intervals
twoway (bar zscore pos if subject==1, barwidth(0.8) color("130 202 157")) ///
       (bar zscore pos if subject==2, barwidth(0.8) color("136 132 216")) ///
       (rcap ci_upper ci_lower pos, lcolor(gs4)), ///
       xlabel(1.5 "Low" 4.5 "Middle" 7.5 "High") ///
       ylabel(0(0.2)1.2, angle(0)) ///
       ytitle("z-score") ///
	   xtitle("") ///
       title("Baseline Referral Performance") ///
       legend(order(1 "Reading" 2 "Math") ring(0) pos(11) rows(2) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(baseline_performance_ci, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/baseline_performance.png", ///
    replace
restore

// First, make sure both graphs exist in memory and have the same sizing
graph display baseline_performance_ci, xsize(6) ysize(4)
graph display ses_referral_distribution, xsize(6) ysize(4)

// Combine the graphs with consistent sizing
graph combine ses_referral_distribution baseline_performance_ci , ///
    rows(1) ///
    xsize(10) ysize(5) ///
    graphregion(color(white)) ///
    title(" ", size(medium)) ///
    name(combined_ses_graphs, replace)

// Export the combined graph
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/combined_baseline.png", replace

// treatment effect performance
cls
preserve
use "reading.dta", clear
keep if area == 1
tabstat z_other_score_reading if nomination == 1 & own_estrato == 1, by(treat) stat(mean sd n semean)
tabstat z_other_score_reading if nomination == 1 & own_estrato == 2, by(treat) stat(mean sd n semean)
tabstat z_other_score_reading if nomination == 1 & own_estrato == 3, by(treat) stat(mean sd n semean)
cls
ttest z_other_score_reading if nomination == 1 & own_estrato == 1, by(treat)
ttest z_other_score_reading if nomination == 1 & own_estrato == 2, by(treat)
ttest z_other_score_reading if nomination == 1 & own_estrato == 3, by(treat)
restore
preserve
use "math.dta", clear
keep if area == 2
tabstat z_other_score_math if nomination == 1 & own_estrato == 1, by(treat) stat(mean sd n semean)
tabstat z_other_score_math if nomination == 1 & own_estrato == 2, by(treat) stat(mean sd n semean)
tabstat z_other_score_math if nomination == 1 & own_estrato == 3, by(treat) stat(mean sd n semean)
cls
ttest z_other_score_math if nomination == 1 & own_estrato == 1, by(treat)
ttest z_other_score_math if nomination == 1 & own_estrato == 2, by(treat)
ttest z_other_score_math if nomination == 1 & own_estrato == 3, by(treat)
restore

//plot
// Create data structure with 6 observations: 3 SES groups × 2 subjects
preserve 
clear
// Create data structure with 6 observations: 3 SES groups × 2 subjects
set obs 6
gen own_ses = ceil(_n/2)    // SES groups: 1=Low, 2=Middle, 3=High
gen subject = mod(_n-1, 2) + 1  // Subjects: 1=Reading, 2=Math

// Store means and standard errors
gen prop_baseline = .  // Baseline (Performance) means
gen prop_bonus = .     // Bonus (Performance Other) means
gen se_baseline = .    // Standard errors for baseline
gen se_bonus = .       // Standard errors for bonus

// Reading data (subject = 1)
replace prop_baseline = 0.6198732 if own_ses==1 & subject==1  // Low SES
replace prop_bonus = 0.3209043 if own_ses==1 & subject==1
replace se_baseline = 0.0909786 if own_ses==1 & subject==1
replace se_bonus = 0.0972975 if own_ses==1 & subject==1

replace prop_baseline = 0.513949 if own_ses==2 & subject==1   // Middle SES
replace prop_bonus = 0.4658231 if own_ses==2 & subject==1
replace se_baseline = 0.077854 if own_ses==2 & subject==1
replace se_bonus = 0.0676821 if own_ses==2 & subject==1

replace prop_baseline = 0.6905426 if own_ses==3 & subject==1  // High SES
replace prop_bonus = 0.8219155 if own_ses==3 & subject==1
replace se_baseline = 0.1495649 if own_ses==3 & subject==1
replace se_bonus = 0.1604151 if own_ses==3 & subject==1

// Math data (subject = 2)
replace prop_baseline = 0.5133594 if own_ses==1 & subject==2  // Low SES
replace prop_bonus = 0.4206115 if own_ses==1 & subject==2
replace se_baseline = 0.1043979 if own_ses==1 & subject==2
replace se_bonus = 0.1078478 if own_ses==1 & subject==2

replace prop_baseline = 0.6596438 if own_ses==2 & subject==2  // Middle SES
replace prop_bonus = 0.6173074 if own_ses==2 & subject==2
replace se_baseline = 0.0843399 if own_ses==2 & subject==2
replace se_bonus = 0.0772019 if own_ses==2 & subject==2

replace prop_baseline = 0.9450315 if own_ses==3 & subject==2  // High SES
replace prop_bonus = 0.8435176 if own_ses==3 & subject==2
replace se_baseline = 0.1637801 if own_ses==3 & subject==2
replace se_bonus = 0.1292005 if own_ses==3 & subject==2

// For positioning in graph - create x-position
gen xpos = own_ses + (subject==2)*0.25

// Calculate effect (bonus - baseline)
gen effect = prop_bonus - prop_baseline

// Calculate standard error of the difference and confidence intervals
gen se_diff = sqrt(se_bonus^2 + se_baseline^2)
gen ci_lower = effect - 1.96*se_diff
gen ci_upper = effect + 1.96*se_diff

// Label variables
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
gen other_ses = subject  // Using subject as other_ses for the graph
label values other_ses subj_lab
label define subj_lab 1 "Reading" 2 "Math"
label values subject subj_lab

// Create the twoway bar graph with confidence intervals
twoway (bar effect xpos if other_ses == 1, barw(0.25) color("130 202 157")) /// Reading (green)
       (bar effect xpos if other_ses == 2, barw(0.25) color("136 132 216")) /// Math (purple)
       (rcap ci_upper ci_lower xpos if other_ses == 1, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 2, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(-.75(0.25).75, angle(0)) ///
       ytitle("Δ z-score (Bonus - Baseline)") ///
       xtitle("") ///
       title("Treatment Effect on Referral Performance by SES") ///
       legend(order(1 "Reading" 2 "Math") ///
              ring(0) pos(11) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(ses_treatment_effect, replace)
restore
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/treatment_effect.png", ///
    replace





//# TABLE share in top deciles by SES
tab other_estrato if top_z_other_score_math & own_estrato == 1
tab other_estrato if top_z_other_score_reading & own_estrato == 1

tab other_estrato if top_z_other_score_math & own_estrato == 2
tab other_estrato if top_z_other_score_reading & own_estrato == 2

tab other_estrato if top_z_other_score_math & own_estrato == 3
tab other_estrato if top_z_other_score_reading & own_estrato == 3

//# figure tie difference
cls
preserve
use "reading.dta", clear
keep if area == 1 & nomination 
tabstat z_tie if treat == 1 & own_estrato==1, by(other_estrato) stat(mean sd semean n) // return list // local low_ses_mean = r(Stat1)[1,1]
tabstat z_tie if treat == 2 & own_estrato==1, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 1 & own_estrato==2, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 2 & own_estrato==2, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 1 & own_estrato==3, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 2 & own_estrato==3, by(other_estrato) stat(mean sd semean n)
restore

preserve
use "math.dta", clear
keep if area == 2 & nomination 
tabstat z_tie if treat == 1 & own_estrato==1, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 2 & own_estrato==1, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 1 & own_estrato==2, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 2 & own_estrato==2, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 1 & own_estrato==3, by(other_estrato) stat(mean sd semean n)
tabstat z_tie if treat == 2 & own_estrato==3, by(other_estrato) stat(mean sd semean n)
restore

preserve
clear
set obs 9  // 3 own_SES × 3 other_SES groups
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

// Set x-positions for each bar group
replace xpos = 0.7 if own_ses == 1 & other_ses == 1  // Low-Low
replace xpos = 1.0 if own_ses == 1 & other_ses == 2  // Low-Middle
replace xpos = 1.3 if own_ses == 1 & other_ses == 3  // Low-High

replace xpos = 1.7 if own_ses == 2 & other_ses == 1  // Middle-Low
replace xpos = 2.0 if own_ses == 2 & other_ses == 2  // Middle-Middle
replace xpos = 2.3 if own_ses == 2 & other_ses == 3  // Middle-High

replace xpos = 2.7 if own_ses == 3 & other_ses == 1  // High-Low
replace xpos = 3.0 if own_ses == 3 & other_ses == 2  // High-Middle
replace xpos = 3.3 if own_ses == 3 & other_ses == 3  // High-High

// Baseline ties values
gen ties = .
gen se = .

// Low SES nominators (own_ses = 1)
replace ties = 2.955759 if own_ses == 1 & other_ses == 1    // Low-Low (average of reading and math)
replace se = 0.2236 if own_ses == 1 & other_ses == 1
replace ties = 2.395432 if own_ses == 1 & other_ses == 2    // Low-Middle
replace se = 0.1787 if own_ses == 1 & other_ses == 2
replace ties = 1.021267 if own_ses == 1 & other_ses == 3    // Low-High
replace se = 0.4276 if own_ses == 1 & other_ses == 3

// Middle SES nominators (own_ses = 2)
replace ties = 2.844975 if own_ses == 2 & other_ses == 1    // Middle-Low
replace se = 0.2561 if own_ses == 2 & other_ses == 1
replace ties = 2.394261 if own_ses == 2 & other_ses == 2    // Middle-Middle
replace se = 0.1560 if own_ses == 2 & other_ses == 2
replace ties = 2.212285 if own_ses == 2 & other_ses == 3    // Middle-High
replace se = 0.3180 if own_ses == 2 & other_ses == 3

// High SES nominators (own_ses = 3)
replace ties = 2.227168 if own_ses == 3 & other_ses == 1    // High-Low
replace se = 0.6382 if own_ses == 3 & other_ses == 1
replace ties = 2.569927 if own_ses == 3 & other_ses == 2    // High-Middle
replace se = 0.3986 if own_ses == 3 & other_ses == 2
replace ties = 4.231651 if own_ses == 3 & other_ses == 3    // High-High
replace se = 0.8829 if own_ses == 3 & other_ses == 3

// Calculate confidence intervals (95%)
gen ci_lower = ties - 1.96*se
gen ci_upper = ties + 1.96*se

// Label variables
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the twoway bar graph with confidence intervals
twoway (bar ties xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar ties xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar ties xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap ci_upper ci_lower xpos if other_ses == 1, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 2, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 3, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(0(2)8, angle(0)) ///
       ytitle("z-score") ///
       xtitle("") ///
       title("Referral Ties by SES at Baseline") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(1) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(baseline_ties, replace)
restore
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/baseline_ties.png", replace

// Start fresh for treatment effects graph
preserve

clear
set obs 9

// Generate categories again
gen own_ses = .
gen other_ses = .
gen effect = .

// Fill in treatment effect data
// Low SES nominators
replace own_ses = 1 in 1/3
replace other_ses = 1 in 1
replace other_ses = 2 in 2
replace other_ses = 3 in 3
replace effect = 2.15169 in 1     // Low-Low
replace effect = -0.10965 in 2    // Low-Middle
replace effect = 5.46666 in 3     // Low-High

// Middle SES nominators
replace own_ses = 2 in 4/6
replace other_ses = 1 in 4
replace other_ses = 2 in 5
replace other_ses = 3 in 6
replace effect = -0.25392 in 4    // Middle-Low
replace effect = -0.46136 in 5    // Middle-Middle
replace effect = -0.71493 in 6    // Middle-High

// High SES nominators
replace own_ses = 3 in 7/9
replace other_ses = 1 in 7
replace other_ses = 2 in 8
replace other_ses = 3 in 9
replace effect = -0.52857 in 7    // High-Low
replace effect = -2.2031 in 8     // High-Middle
replace effect = -4.85795 in 9    // High-High

// Label variables
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create treatment effects graph
graph bar effect, over(other_ses) over(own_ses) asyvars ///
    bar(1, color("255 99 132")) ///    // Vibrant coral for Low SES others
    bar(2, color("54 162 235")) ///    // Vibrant blue for Middle SES others
    bar(3, color("75 192 112")) ///    // Vibrant green for High SES others
    ylabel(-6(2)6, angle(0)) ///
    ytitle("Δ Ties (Bonus - Baseline)") ///
    title("Treatment Effects on Referral Ties by SES") ///
    legend(ring(0) pos(2) rows(3) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(ties_treatment_effects, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ties_treatment_effects.png", ///
    replace
restore









//# table performance across admin network and sample
use math.dta, clear
cls
preserve
tabstat other_score_math, by(other_estrato) stat(n sd mean semean)
restore
preserve 
bysort  other_id : gen counter2 =_n
keep if counter2 == 1
tabstat other_score_math, by(other_estrato) stat(n sd mean semean)
restore
preserve 
keep if counter == 1
tabstat own_score_math, by(own_estrato) stat(n sd mean semean)
restore

use reading.dta, clear
preserve
tabstat other_score_reading, by(other_estrato) stat(n sd mean semean)
restore
preserve 
bysort  other_id : gen counter2 =_n
keep if counter2 == 1
tabstat other_score_reading, by(other_estrato) stat(n sd mean semean)
restore
preserve 
keep if counter == 1
tabstat own_score_reading, by(own_estrato) stat(n sd mean semean)
restore



//# network performance by SES
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
    
    tabstat z_other_score_math, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global math_`ses_label'_n = stats[1,1]
    global math_`ses_label' = stats[2,1]
    global math_`ses_label'_sd = stats[3,1]
    
    restore 
}

use reading.dta, clear

foreach ses in 1 2 3 {
    local ses_label = cond(`ses'==1, "low", cond(`ses'==2, "middle", "high"))
    
    preserve 
    keep if own_estrato == `ses'
    
    tabstat z_other_score_reading, stat(n mean sd) save
    matrix stats = r(StatTotal)
    
    global read_`ses_label'_n = stats[1,1]
    global read_`ses_label' = stats[2,1]
    global read_`ses_label'_sd = stats[3,1]
    
    restore 
}

ttesti ${math_low_n} ${math_low} ${math_low_sd} ${math_middle_n} ${math_middle} ${math_middle_sd}
ttesti ${math_low_n} ${math_low} ${math_low_sd} ${math_high_n} ${math_high} ${math_high_sd}
ttesti ${math_middle_n} ${math_middle} ${math_middle_sd} ${math_high_n} ${math_high} ${math_high_sd}

ttesti ${read_low_n} ${read_low} ${read_low_sd} ${read_middle_n} ${read_middle} ${read_middle_sd}
ttesti ${read_low_n} ${read_low} ${read_low_sd} ${read_high_n} ${read_high} ${read_high_sd}
ttesti ${read_middle_n} ${read_middle} ${read_middle_sd} ${read_high_n} ${read_high} ${read_high_sd}

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

local r = 1
foreach ses in low middle high {
    foreach subj in math read {
        local subj_num = cond("`subj'"=="math", 1, 2)
        local ses_num = cond("`ses'"=="low", 1, cond("`ses'"=="middle", 2, 3))
        
        if `r' <= 6 {
            replace z_score = ${`subj'_`ses'} if ses==`ses_num' & subject==`subj_num'
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
       , ///
       xlabel(1.25 "Low" 2.75 "Middle" 4.25 "High") ///
       ylabel(0(0.05)0.20, angle(0) format(%9.2f)) ///
       ytitle("z-score") ///
       xtitle("") ///
       title("Network Performance by SES") ///
       legend(order(1 "Reading" 2 "Math") ring(0) pos(11) rows(2) region(lcolor(none))) ///  // Update legend order
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 5)) ///
       name(ses_zscore, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_peer_performance.png", replace
restore


