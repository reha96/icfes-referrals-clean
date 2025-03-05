/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 05.02.2025
    Description: descriptives
*******************************************************************************/

//# preamble
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
use "dataset_z.dta"
describe *
gsort own_id other_id

bysort  own_id : gen counter =_n
by own_id : egen size = max(counter)

gen own_low_ses = own_estrato == 1


//# TABLE Sample descriptives
preserve 
keep if counter==1
foreach v of varlist tie own_age own_female own_low_ses z_own* size {
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


preserve 
bysort  other_id : gen counter2 =_n
keep if counter2 == 1
drop own* z_own*
rename other_low_ses own_low_ses
rename other_age own_age
rename other_female own_female
rename z_other_gpa z_own_gpa
rename z_other_score_math z_own_score_math
rename z_other_score_reading z_own_score_reading

foreach v of varlist own_age own_female own_low_ses z_own*	 {
    display _newline

    // summarize
    summarize `v', det
	global admin_`v'_mean = r(mean)
    global admin_`v'_sd = r(sd)
   
    // Now we can test using stored values
    if inlist("`v'", "own_female", "own_low_ses") {
        prtesti 4417 ${admin_`v'_mean} 734 ${exp_`v'_mean}
    }
    else {
        ttesti 4417 ${admin_`v'_mean} ${admin_`v'_sd} 734 ${exp_`v'_mean} ${exp_`v'_sd}, unequal
    }
}
restore 


//# TABLE non-referred choice set VS referred
preserve 
keep if area==1 // verbal
foreach v of varlist tie other_age other_female other_low_ses z_other* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
//     ttest `v', by(treat) unequal
}
restore

preserve 
keep if area==2 // math
foreach v of varlist tie other_age other_female other_low_ses z_other* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
// 	ttest `v', by(treat) unequal
// 	tabstat `v' if nomination == 1, stat(mean sd n)

}
restore


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
preserve 
clear

// Create data structure - 9 observations for 3 own_SES × 3 other_SES
set obs 9
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen ref_rate = .

// Fill in referral rates (percentages)
// Low SES (own_ses = 1)
replace ref_rate = (142/300) * 100 if own_ses==1 & other_ses==1  // Low-Low: 47.33%
replace ref_rate = (143/300) * 100 if own_ses==1 & other_ses==2  // Low-Middle: 47.67%
replace ref_rate = (15/300) * 100 if own_ses==1 & other_ses==3   // Low-High: 5%

// Middle SES (own_ses = 2)
replace ref_rate = (107/338) * 100 if own_ses==2 & other_ses==1  // Middle-Low: 31.66%
replace ref_rate = (197/338) * 100 if own_ses==2 & other_ses==2  // Middle-Middle: 58.28%
replace ref_rate = (34/338) * 100 if own_ses==2 & other_ses==3   // Middle-High: 10.06%

// High SES (own_ses = 3)
replace ref_rate = (7/61) * 100 if own_ses==3 & other_ses==1     // High-Low: 11.48%
replace ref_rate = (43/61) * 100 if own_ses==3 & other_ses==2    // High-Middle: 70.49%
replace ref_rate = (11/61) * 100 if own_ses==3 & other_ses==3    // High-High: 18.03%

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the graph
graph bar ref_rate, over(other_ses) over(own_ses) ///
    asyvars ///
    bar(1, color("255 99 132")) ///
    bar(2, color("54 162 235")) ///
    bar(3, color("75 192 112")) ///
    ylabel(0(20)80, angle(0)) ///
    ytitle("Share (%)") ///
    title("Baseline Referral Rates by SES") ///
    legend(ring(0) pos(11) rows(3) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(baseline_rates, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/baseline_rates.png", ///
    replace
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
keep if treat == 2
// low
tab other_estrato if nomination == 1 & own_estrato == 1
tab other_estrato if nomination == 0 & own_estrato == 1
// med
tab other_estrato if nomination == 1 & own_estrato == 2
tab other_estrato if nomination == 0 & own_estrato == 2
// high
tab other_estrato if nomination == 1 & own_estrato == 3
tab other_estrato if nomination == 0 & own_estrato == 3
restore

////////////////////////////////
// Create dataset for treatment effects
preserve
clear
set obs 9

// Generate categories
gen own_ses = .
gen other_ses = .
gen effect = .

// Fill in data
// Low SES nominators
replace own_ses = 1 in 1/3
replace other_ses = 1 in 1
replace other_ses = 2 in 2
replace other_ses = 3 in 3
replace effect = 5.77 in 1    // Low-Low
replace effect = -8.91 in 2   // Low-Middle
replace effect = 3.14 in 3    // Low-High

// Middle SES nominators
replace own_ses = 2 in 4/6
replace other_ses = 1 in 4
replace other_ses = 2 in 5
replace other_ses = 3 in 6
replace effect = 0.56 in 4    // Middle-Low
replace effect = -6.30 in 5   // Middle-Middle
replace effect = 5.75 in 6    // Middle-High

// High SES nominators
replace own_ses = 3 in 7/9
replace other_ses = 1 in 7
replace other_ses = 2 in 8
replace other_ses = 3 in 9
replace effect = 6.38 in 7    // High-Low
replace effect = -16.92 in 8  // High-Middle
replace effect = 10.54 in 9   // High-High

// Label variables
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create graph
graph bar effect, over(other_ses) over(own_ses) asyvars ///
	bar(1, color("255 99 132")) ///    // Vibrant coral/raspberry
	bar(2, color("54 162 235")) ///    // Vibrant blue
	bar(3, color("75 192 112")) ///    // Vibrant green
    ylabel(-20(5)15, angle(0)) ///
    ytitle("Δ share (p.p.)") ///
    title("Treatment Effect on Referral Rates by SES") ///
    legend(ring(0) pos(7) rows(3) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(ses_treatment_effects, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_treatment_effects.png", ///
    replace
// Add note
notes: "Note: Bars show difference in referral rates between bonus and baseline groups."
restore
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
tabstat tie if own_estrato == 1, by(other_estrato) stat(mean sd semean)
tabstat tie if own_estrato == 2, by(other_estrato) stat(mean sd semean)
tabstat tie if own_estrato == 3, by(other_estrato) stat(mean sd semean)

preserve 
clear
// Create data structure
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen tie_strength = .

// Fill in average tie strengths from your new data
// For Low SES (own_ses = 1)
replace tie_strength = 3.583182 if own_ses==1 & other_ses==1  // Low-Low
replace tie_strength = 3.043574 if own_ses==1 & other_ses==2  // Low-Middle
replace tie_strength = 2.9399 if own_ses==1 & other_ses==3  // Low-High

// For Middle SES (own_ses = 2)
replace tie_strength = 3.060132 if own_ses==2 & other_ses==1  // Middle-Low
replace tie_strength = 3.091597 if own_ses==2 & other_ses==2  // Middle-Middle
replace tie_strength = 3.32336 if own_ses==2 & other_ses==3  // Middle-High

// For High SES (own_ses = 3)
replace tie_strength = 3.08935 if own_ses==3 & other_ses==1  // High-Low
replace tie_strength = 3.821398 if own_ses==3 & other_ses==2  // High-Middle
replace tie_strength = 4.883577 if own_ses==3 & other_ses==3  // High-High

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
    title("Tie Strength by SES") ///
    graphregion(color(white)) bgcolor(white) ///
    name(ses_tie_strength, replace)
    
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_tie_strength.png", replace
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

//# TABLE SES by SES
preserve
proportion other_estrato if own_estrato == 1
proportion other_estrato if own_estrato == 2
proportion other_estrato if own_estrato == 3

* Compare Low SES peer connections across own SES groups
prtesti 110142 .364829 127088 .3219029    // Low vs Middle (Low SES peers)
prtesti 110142 .364829 19767 .2683766      // Low vs High (Low SES peers)
prtesti 127088 .3219029 19767 .2683766    // Middle vs High (Low SES peers)

* Compare Middle SES peer connections across own SES groups
prtesti 110142 .5013256 127088 .5210956   // Low vs Middle (Middle SES peers)
prtesti 110142 .5013256 19767 .5347802    // Low vs High (Middle SES peers)
prtesti 127088 .5210956 19767 .5347802    // Middle vs High (Middle SES peers)

* Compare High SES peer connections across own SES groups
prtesti 110142 .1338454 127088 .1570014   // Low vs Middle (High SES peers)
prtesti 110142 .1338454 19767 .1968432    // Low vs High (High SES peers)
prtesti 127088 .1570014 19767 .1968432    // Middle vs High (High SES peers)
clear
// Create data structure
set obs 9  // 3 own_SES × 3 other_SES
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen proportion = .

// Fill in proportions based on your data
// For Low SES (own_ses = 1)
replace proportion = 0.364829*100 if own_ses==1 & other_ses==1  // Low-Low
replace proportion = 0.5013256*100 if own_ses==1 & other_ses==2  // Low-Middle
replace proportion = 0.1338454*100 if own_ses==1 & other_ses==3  // Low-High

// For Middle SES (own_ses = 2)
replace proportion = 0.3219029*100 if own_ses==2 & other_ses==1  // Middle-Low
replace proportion = 0.5210956*100 if own_ses==2 & other_ses==2  // Middle-Middle
replace proportion = 0.1570014*100 if own_ses==2 & other_ses==3  // Middle-High

// For High SES (own_ses = 3)
replace proportion = 0.2683766*100 if own_ses==3 & other_ses==1  // High-Low
replace proportion = 0.5347802*100 if own_ses==3 & other_ses==2  // High-Middle
replace proportion = 0.1968432*100 if own_ses==3 & other_ses==3  // High-High

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create the graph
graph bar proportion, over(other_ses) over(own_ses) ///
    asyvars ///
    bar(1, color("255 99 132")) ///    // Vibrant coral for Low SES others
    bar(2, color("54 162 235")) ///    // Vibrant blue for Middle SES others
    bar(3, color("75 192 112")) ///    // Vibrant green for High SES others
    legend(ring(0) pos(12) rows(1) region(lcolor(none))) ///
    ylabel(0(10)60, angle(0)) ///
    ytitle("Percent") ///
    title("Availability by SES") ///
    graphregion(color(white)) bgcolor(white) ///
    name(ses_distribution, replace)
    
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_distribution.png", replace
restore

//# TABLE performance by SES
preserve
keep if area == 1 & treat == 1
// low
tabstat z_other_score_reading if nomination == 1 & own_estrato == 1, stat(mean sd n)
// med
tabstat z_other_score_reading if nomination == 1 & own_estrato == 2, stat(mean sd n)
// high
tabstat z_other_score_reading if nomination == 1 & own_estrato == 3, stat(mean sd n)
restore
preserve
keep if area == 2 & treat == 1
// low
tabstat z_other_score_math if nomination == 1 & own_estrato == 1, stat(mean sd n)
// med
tabstat z_other_score_math if nomination == 1 & own_estrato == 2, stat(mean sd n)
// high
tabstat z_other_score_math if nomination == 1 & own_estrato == 3, stat(mean sd n)
restore


preserve 
clear

// Create data structure
// 6 observations: 3 SES groups × 2 subjects
set obs 6
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1
gen zscore = .

// Fill in z-scores
// Reading (subject = 1)
replace zscore = 0.6438231 if own_ses==1 & subject==1  // Low SES
replace zscore = 0.5514151 if own_ses==2 & subject==1  // Middle SES
replace zscore = 0.7054749 if own_ses==3 & subject==1  // High SES

// Math (subject = 2)
replace zscore = 0.560113 if own_ses==1 & subject==2   // Low SES
replace zscore = 0.6825202 if own_ses==2 & subject==2  // Middle SES
replace zscore = 0.9213258 if own_ses==3 & subject==2  // High SES

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label define subj_lab 1 "Reading" 2 "Math"
label values subject subj_lab

// Create the graph
graph bar zscore, over(subject) over(own_ses) ///
   asyvars ///
   bar(2, color("136 132 216")) ///    // Math (purple)
   bar(1, color("130 202 157")) ///    // Reading (green)
   ylabel(0(0.2)1, angle(0)) ///
   ytitle("z-score") ///
   title("Baseline Performance of Referrals by SES") ///
   legend(ring(0) pos(11) rows(2) region(lcolor(none))) ///
   graphregion(color(white)) bgcolor(white) ///
   name(baseline_performance, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/baseline_performance.png", ///
    replace
restore


preserve
keep if area == 1 & treat == 2
// low
tabstat z_other_score_reading if nomination == 1 & own_estrato == 1, stat(mean sd n)
// med
tabstat z_other_score_reading if nomination == 1 & own_estrato == 2, stat(mean sd n)
// high
tabstat z_other_score_reading if nomination == 1 & own_estrato == 3, stat(mean sd n)
restore

preserve
keep if area == 2 & treat == 2
// low
tabstat z_other_score_math if nomination == 1 & own_estrato == 1, stat(mean sd n)
// med
tabstat z_other_score_math if nomination == 1 & own_estrato == 2, stat(mean sd n)
// high
tabstat z_other_score_math if nomination == 1 & own_estrato == 3, stat(mean sd n)
restore

//plot
preserve 
clear

// Create data structure
// 6 observations: 3 SES groups × 2 subjects
set obs 6
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1
gen score_diff = .

// Calculate differences (bonus - baseline)
// Reading (subject = 1)
replace score_diff = 0.3830033 - 0.6438231 if own_ses==1 & subject==1  // Low SES
replace score_diff = 0.5094302 - 0.5514151 if own_ses==2 & subject==1  // Middle SES
replace score_diff = 0.8200843 - 0.7054749 if own_ses==3 & subject==1  // High SES

// Math (subject = 2)
replace score_diff = 0.4825038 - 0.560113 if own_ses==1 & subject==2   // Low SES
replace score_diff = 0.6470942 - 0.6825202 if own_ses==2 & subject==2  // Middle SES
replace score_diff = 0.8363814 - 0.9213258 if own_ses==3 & subject==2  // High SES

// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label define subj_lab 1 "Reading" 2 "Math"
label values subject subj_lab

// Create the graph
graph bar score_diff, over(subject) over(own_ses) ///
    asyvars ///
    bar(2, color("136 132 216")) ///    // Math (purple, similar to our React chart)
    bar(1, color("130 202 157")) ///    // Reading (green, similar to our React chart)
    ylabel(-0.3(0.1)0.2, angle(0)) ///
    ytitle("Δ z-score (Bonus - Baseline)") ///
    title("Treatment Effect on Referral Performance by SES") ///
    legend(ring(0) pos(11) rows(2) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(treatment_effect, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/treatment_effect.png", ///
    replace
restore





//# TABLE share in top deciles by SES
tab other_estrato if top_z_other_score_math & own_estrato == 1
tab other_estrato if top_z_other_score_reading & own_estrato == 1

tab other_estrato if top_z_other_score_math & own_estrato == 2
tab other_estrato if top_z_other_score_reading & own_estrato == 2

tab other_estrato if top_z_other_score_math & own_estrato == 3
tab other_estrato if top_z_other_score_reading & own_estrato == 3







//# figure tie difference

preserve
keep if treat == 1 
tabstat tie if nomination & own_estrato == 1 & other_estrato == 1, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 1 & other_estrato == 2, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 1 & other_estrato == 3, stat(n mean sd semean)

tabstat tie if nomination & own_estrato == 2 & other_estrato == 1, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 2 & other_estrato == 2, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 2 & other_estrato == 3, stat(n mean sd semean)

tabstat tie if nomination & own_estrato == 3 & other_estrato == 1, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 3 & other_estrato == 2, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 3 & other_estrato == 3, stat(n mean sd semean)
restore

preserve
keep if treat == 2 
tabstat tie if nomination & own_estrato == 1 & other_estrato == 1, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 1 & other_estrato == 2, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 1 & other_estrato == 3, stat(n mean sd semean)

tabstat tie if nomination & own_estrato == 2 & other_estrato == 1, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 2 & other_estrato == 2, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 2 & other_estrato == 3, stat(n mean sd semean)

tabstat tie if nomination & own_estrato == 3 & other_estrato == 1, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 3 & other_estrato == 2, stat(n mean sd semean)
tabstat tie if nomination & own_estrato == 3 & other_estrato == 3, stat(n mean sd semean)
restore

// Make sure we're working with original dataset
preserve 

// Create baseline ties graph
clear
set obs 9

// Generate categories
gen own_ses = .
gen other_ses = .
gen ties = .

// Fill in baseline data
// Low SES nominators
replace own_ses = 1 in 1/3
replace other_ses = 1 in 1
replace other_ses = 2 in 2
replace other_ses = 3 in 3
replace ties = 15.55634 in 1    // Low-Low
replace ties = 13.34965 in 2    // Low-Middle
replace ties = 7.866667 in 3    // Low-High

// Middle SES nominators
replace own_ses = 2 in 4/6
replace other_ses = 1 in 4
replace other_ses = 2 in 5
replace other_ses = 3 in 6
replace ties = 15.08411 in 4    // Middle-Low
replace ties = 13.35025 in 5    // Middle-Middle
replace ties = 12.67647 in 6    // Middle-High

// High SES nominators
replace own_ses = 3 in 7/9
replace other_ses = 1 in 7
replace other_ses = 2 in 8
replace other_ses = 3 in 9
replace ties = 12.42857 in 7    // High-Low
replace ties = 14.06977 in 8    // High-Middle
replace ties = 20.54545 in 9    // High-High

// Label variables
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create baseline graph
graph bar ties, over(other_ses) over(own_ses) asyvars ///
    bar(1, color("255 99 132")) ///    // Vibrant coral for Low SES others
    bar(2, color("54 162 235")) ///    // Vibrant blue for Middle SES others
    bar(3, color("75 192 112")) ///    // Vibrant green for High SES others
    ylabel(0(5)25, angle(0)) ///
    ytitle("Average Number of Ties") ///
    title("Referral Ties by SES at Baseline") ///
    legend(ring(0) pos(11) rows(3) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(baseline_ties, replace)
	graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/baseline_ties.png", ///
    replace

restore

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






preserve

bysort  other_id : gen counter2 =_n
keep if counter2 == 1

ttest z_other_score_math == z_other_score_reading if other_estrato == 1 // For Low SES
ttest z_other_score_math == z_other_score_reading if other_estrato == 2 // For Middle SES
ttest z_other_score_math == z_other_score_reading if other_estrato == 3 // For High SES

restore

preserve
clear
set obs 6  // 3 SES groups × 2 subjects
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1  // 1 = Math, 2 = Reading
gen z_score = .
// Fill in z-scores from your data
// For Low SES (own_ses = 1)
replace z_score = 0.1749664 if own_ses==1 & subject==1  // Low SES - Math
replace z_score = 0.1295962 if own_ses==1 & subject==2  // Low SES - Reading
// For Middle SES (own_ses = 2)
replace z_score = 0.220885 if own_ses==2 & subject==1  // Middle SES - Math
replace z_score = 0.1880923 if own_ses==2 & subject==2  // Middle SES - Reading
// For High SES (own_ses = 3)
replace z_score = 0.2582253 if own_ses==3 & subject==1  // High SES - Math
replace z_score = 0.2314877 if own_ses==3 & subject==2  // High SES - Reading
// Label the groups
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label define subj_lab 1 "Math" 2 "Reading"
label values subject subj_lab
// Create the graph
graph bar z_score, over(subject) over(own_ses) ///
    asyvars ///
    bar(1, color("136 132 216")) ///    // Purple for Math
    bar(2, color("130 202 157")) ///    // Green for Reading
    ylabel(0(0.05)0.30, angle(0)) ///
    ytitle("z-score") ///
    title("Peer Performance by Student SES") ///
    legend(ring(0) pos(11) rows(2) region(lcolor(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(ses_zscore, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_peer_performance.png", replace
restore


// //# bar chart
// preserve 
// clear
//
// // Create the data in "long" format
// set obs 12  // 3 SES groups × 4 metrics
// gen ses = ceil(_n/4)
// gen metric = mod(_n-1, 4) + 1  // 1=Availability, 2=Top Decile, 3=Baseline, 4=Bonus
// gen value = .
//
// // Fill in values
// replace value = 39.8 if ses==1 & metric==1  // Low-SES availability
// replace value = 31 if ses==1 & metric==2    // Low-SES top decile
// replace value = 47 if ses==1 & metric==3    // Low-SES baseline
// replace value = 53 if ses==1 & metric==4    // Low-SES bonus
//
// replace value = 43.8 if ses==2 & metric==1  // Middle-SES availability
// replace value = 45 if ses==2 & metric==2    // Middle-SES top decile
// replace value = 58 if ses==2 & metric==3    // Middle-SES baseline
// replace value = 52 if ses==2 & metric==4    // Middle-SES bonus
//
// replace value = 28.2 if ses==3 & metric==1  // High-SES availability
// replace value = 24 if ses==3 & metric==2    // High-SES top decile
// replace value = 18 if ses==3 & metric==3    // High-SES baseline
// replace value = 29 if ses==3 & metric==4    // High-SES bonus
//
// // Label the groups
// label define ses_lab 1 "Low-SES" 2 "Middle-SES" 3 "High-SES"
// label values ses ses_lab
//
// // Create the graph
// graph bar value, over(metric, relabel(1 "Availability" 2 "Top Decile" 3 "Baseline Referrals" 4 "Bonus Referrals")) over(ses) ///
//     asyvars ///    // This is key - tells STATA to treat each y-variable separately
//     bar(1, color("215 189 189")) ///    // Availability
//     bar(2, color("198 219 239")) ///    // Top Decile
//     bar(3, color("169 209 142")) ///    // Baseline
//     bar(4, color("255 242 204")) ///    // Bonus
//     legend(ring(0) pos(2) rows(4) region(lcolor(none))) ///
//     ylabel(0(10)60, angle(0)) ///
//     ytitle("Percent") ///
//     title("Representation by SES Group") ///
//     graphregion(color(white)) bgcolor(white) ///
//     name(ses_shares, replace)
//
// restore
//


// preserve 
// keep if area==1 // verbal
// foreach v of varlist tie* {
//     display _newline
//     display as text "=== T-test for `v' ===" _newline
// //     ttest `v', by(nomination) unequal
// 	ttest `v' if nomination == 1, by(treat) unequal
// // 	tabstat `v' if nomination == 1, stat(mean sd n)
//
// }
// restore
//
// preserve 
// keep if area==2 // math
// foreach v of varlist tie* {
//     display _newline
//     display as text "=== T-test for `v' ===" _newline
// //     ttest `v', by(nomination) unequal
// 	ttest `v' if nomination == 1, by(treat) unequal
// // 	tabstat `v' if nomination == 1, stat(mean sd n)
//
// }
// restore




// //# TABLE non-referred choice set VS referred by SES
// preserve
// keep if area == 1 & treat == 1
// // low
// tab other_estrato if nomination == 1 & own_estrato == 1
// tab other_estrato if  own_estrato == 1
// // med
// tab other_estrato if nomination == 1 & own_estrato == 2
// tab other_estrato if  own_estrato == 2
// // high
// tab other_estrato if nomination == 1 & own_estrato == 3
// tab other_estrato if  own_estrato == 3
// restore
//
// preserve
// keep if area == 1 & treat == 2
// // low
// tab other_estrato if nomination == 1 & own_estrato == 1
// tab other_estrato if  own_estrato == 1
// // med
// tab other_estrato if nomination == 1 & own_estrato == 2
// tab other_estrato if  own_estrato == 2
// // high
// tab other_estrato if nomination == 1 & own_estrato == 3
// tab other_estrato if  own_estrato == 3
// restore
//
// preserve
// keep if area == 2 & treat == 1
// // low
// tab other_estrato if nomination == 1 & own_estrato == 1
// tab other_estrato if  own_estrato == 1
// // med
// tab other_estrato if nomination == 1 & own_estrato == 2
// tab other_estrato if  own_estrato == 2
// // high
// tab other_estrato if nomination == 1 & own_estrato == 3
// tab other_estrato if  own_estrato == 3
// restore
//
// preserve
// keep if area == 2 & treat == 2
// // low
// tab other_estrato if nomination == 1 & own_estrato == 1
// tab other_estrato if  own_estrato == 1
// // med
// tab other_estrato if nomination == 1 & own_estrato == 2
// tab other_estrato if  own_estrato == 2
// // high
// tab other_estrato if nomination == 1 & own_estrato == 3
// tab other_estrato if  own_estrato == 3
// restore


//////////// PAST

tabstat other_estrato   if nomination == 1 & own_estrato == 1 & treat == 2, stat(mean sd n)
// ttest other_estrato if own_estrato == 1 & treat == 2, by(nomination) unequal // extra bonus lowers mean strata --> more bias


tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 1, stat(mean sd n)
// ttest other_estrato if own_estrato == 2  & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 2, stat(mean sd n)
// ttest other_estrato if own_estrato == 2  & treat == 2, by(nomination) unequal // treatment randomization issue??


tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 1, stat(mean sd n)
// ttest other_estrato if own_estrato == 3 & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 2, stat(mean sd n)
// ttest other_estrato if own_estrato == 3 & treat == 2, by(nomination) unequal // extra bonus adds noise

restore

ttest tie if nomination == 1  & area == 1, by(treat) unequal
ttest tie_math if  nomination == 1  & area == 1, 	by(treat) unequal
ttest tie_spanish if  nomination == 1  & area == 1,  by(treat) unequal



keep if area==2 // math

tabstat tie*  if nomination == 1, stat(mean sd)
// hist tie if nomination == 1, percent bin(10
tabstat tie* if nomination == 0, stat(mean sd)

// descriptive table


foreach v of varlist tie* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
// 	hist `v', $graph_opts percent bin(10) by(nomination) name(`v', replace)
}

describe *

foreach v of varlist z_other* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
	hist `v', $graph_opts percent bin(10) by(nomination) name(`v', replace)
}

tabstat other_estrato   if nomination == 1 & own_estrato == 1 & treat == 1, stat(mean sd n)
ttest other_estrato if own_estrato == 1 & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 1 & treat == 2, stat(mean sd n)
ttest other_estrato if own_estrato == 1 & treat == 2, by(nomination) unequal // extra bonus lowers mean strata --> more bias


tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 1, stat(mean sd n)
ttest other_estrato if own_estrato == 2  & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 2, stat(mean sd n)
ttest other_estrato if own_estrato == 2  & treat == 2, by(nomination) unequal // treatment randomization issue??


tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 1, stat(mean sd n)
ttest other_estrato if own_estrato == 3 & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 2, stat(mean sd n)
ttest other_estrato if own_estrato == 3 & treat == 2, by(nomination) unequal // extra bonus adds noise

