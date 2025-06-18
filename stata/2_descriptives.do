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
foreach v of varlist tie own_age own_female own_low_ses own_med_ses own_high_ses own_g* own_score_m* own_score_r*  size {
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

cls
use "dataset_z.dta", clear
keep if nomination
bysort own_id other_id: gen c = _n 
order c
bysort own_id: egen c_max = max(c)
order c_max
tab c_max // unique vs common referrals

ttest other_score_math if c_max != 2, by(area)
ttest other_score_reading if c_max != 2, by(area)
ttest other_gpa if c_max != 2, by(area)
ttest tie if c_max != 2, by(area)
prtest other_low_ses if c_max != 2, by(area)
prtest other_med_ses if c_max != 2, by(area)
prtest other_high_ses if c_max != 2, by(area)

twoway (kdensity other_score_reading if !nomination) (kdensity other_score_reading if nomination)

cls
use "dataset_z.dta", clear

//# referral vs not referred
foreach v of varlist other_score_reading other_score_math other_gpa tie other_low_ses other_med_ses other_high_ses	 {
    use "dataset_z.dta", clear
	drop mean_tie
	keep if treat == 1 & nomination
	bysort own_id: egen mean_`v' = mean(`v')
	bysort own_id: keep if _n == 1
	sum mean_`v', det // summarize baseline
	global mean_`v'_base = r(mean)
	
	use "dataset_z.dta", clear
	drop mean_tie
	keep if treat == 2 & nomination
	bysort own_id: egen mean_`v' = mean(`v')
	bysort own_id: keep if _n == 1
	sum mean_`v', det // summarize bonus
	global mean_`v'_bonus = r(mean)
	
	use "dataset_z.dta", clear
	drop mean_tie
	keep if !nomination
	bysort own_id: egen mean_`v' = mean(`v')
	bysort own_id: keep if _n == 1
	sum mean_`v', det // summarize not referred
	
	use "dataset_z.dta", clear
	drop mean_tie
	keep if nomination
	bysort own_id: egen mean_`v' = mean(`v')
	
	bysort own_id: keep if _n == 1
	qui sum mean_`v', det
    local min = r(min)
    local max = r(max)
    if `min' == 0 & `max' == 1 {
        prtesti 382 ${mean_`v'_base} 352 ${mean_`v'_bonus}
    }
    else {
        ttest mean_`v', by(treat) unequal
    }
}
