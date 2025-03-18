/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure baseline referral rates and perfomance by SES
*******************************************************************************/

clear all
use "dataset_z.dta"

//# rates
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

//# performance
preserve
use "reading.dta", clear
keep if area == 1 & treat == 1
tabstat z_other_score_reading if nomination == 1, by(own_estrato) stat(mean sd semean n) save
matrix reading_stats_low = r(Stat1)
global reading_z_low = reading_stats_low[1,1]
global reading_se_low = reading_stats_low[3,1]
global reading_n_low = reading_stats_low[4,1]

matrix reading_stats_middle = r(Stat2)
global reading_z_middle = reading_stats_middle[1,1]
global reading_se_middle = reading_stats_middle[3,1]
global reading_n_middle = reading_stats_middle[4,1]

matrix reading_stats_high = r(Stat3)
global reading_z_high = reading_stats_high[1,1]
global reading_se_high = reading_stats_high[3,1]
global reading_n_high = reading_stats_high[4,1]
restore

preserve
use "math.dta", clear
keep if area == 2 & treat == 1
tabstat z_other_score_math if nomination == 1, by(own_estrato) stat(mean sd semean n) save
matrix math_stats_low = r(Stat1)
global math_z_low = math_stats_low[1,1]
global math_se_low = math_stats_low[3,1]
global math_n_low = math_stats_low[4,1]

matrix math_stats_middle = r(Stat2)
global math_z_middle = math_stats_middle[1,1]
global math_se_middle = math_stats_middle[3,1]
global math_n_middle = math_stats_middle[4,1]

matrix math_stats_high = r(Stat3)
global math_z_high = math_stats_high[1,1]
global math_se_high = math_stats_high[3,1]
global math_n_high = math_stats_high[4,1]
restore

ttesti ${reading_n_low} ${reading_z_low} ${reading_stats_low[2,1]} ${reading_n_middle} ${reading_z_middle} ${reading_stats_middle[2,1]}
ttesti ${reading_n_low} ${reading_z_low} ${reading_stats_low[2,1]} ${reading_n_high} ${reading_z_high} ${reading_stats_high[2,1]}
ttesti ${reading_n_middle} ${reading_z_middle} ${reading_stats_middle[2,1]} ${reading_n_high} ${reading_z_high} ${reading_stats_high[2,1]}

ttesti ${math_n_low} ${math_z_low} ${math_stats_low[2,1]} ${math_n_middle} ${math_z_middle} ${math_stats_middle[2,1]}
ttesti ${math_n_low} ${math_z_low} ${math_stats_low[2,1]} ${math_n_high} ${math_z_high} ${math_stats_high[2,1]}
ttesti ${math_n_middle} ${math_z_middle} ${math_stats_middle[2,1]} ${math_n_high} ${math_z_high} ${math_stats_high[2,1]}

preserve
clear
set obs 6
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1
gen zscore = .
gen se = .
gen ci_lower = .
gen ci_upper = .

replace zscore = ${reading_z_low} if own_ses==1 & subject==1
replace zscore = ${reading_z_middle} if own_ses==2 & subject==1
replace zscore = ${reading_z_high} if own_ses==3 & subject==1
replace se = ${reading_se_low} if own_ses==1 & subject==1
replace se = ${reading_se_middle} if own_ses==2 & subject==1
replace se = ${reading_se_high} if own_ses==3 & subject==1

replace zscore = ${math_z_low} if own_ses==1 & subject==2
replace zscore = ${math_z_middle} if own_ses==2 & subject==2
replace zscore = ${math_z_high} if own_ses==3 & subject==2
replace se = ${math_se_low} if own_ses==1 & subject==2
replace se = ${math_se_middle} if own_ses==2 & subject==2
replace se = ${math_se_high} if own_ses==3 & subject==2

replace ci_lower = zscore - 1.96*se
replace ci_upper = zscore + 1.96*se

gen pos = .
replace pos = 1 if own_ses==1 & subject==1
replace pos = 2 if own_ses==1 & subject==2
replace pos = 4 if own_ses==2 & subject==1
replace pos = 5 if own_ses==2 & subject==2
replace pos = 7 if own_ses==3 & subject==1
replace pos = 8 if own_ses==3 & subject==2

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label define subj_lab 1 "Reading" 2 "Math"
label values subject subj_lab

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
