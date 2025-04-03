/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure overlaid referral perfomance by SES
*******************************************************************************/

preserve
use "reading.dta", clear
keep if area == 1
tabstat other_score_reading, by(own_estrato) stat(mean sd semean n) save
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
use "reading.dta", clear
keep if area == 1 & nomination
tabstat other_score_reading, by(own_estrato) stat(mean sd semean n) save
matrix reading_stats_low = r(Stat1)
global reading_z_lowR = reading_stats_low[1,1]
global reading_se_lowR = reading_stats_low[3,1]
global reading_n_lowR = reading_stats_low[4,1]

matrix reading_stats_middle = r(Stat2)
global reading_z_middleR = reading_stats_middle[1,1]
global reading_se_middleR = reading_stats_middle[3,1]
global reading_n_middleR = reading_stats_middle[4,1]

matrix reading_stats_high = r(Stat3)
global reading_z_highR = reading_stats_high[1,1]
global reading_se_highR = reading_stats_high[3,1]
global reading_n_highR = reading_stats_high[4,1]
restore


preserve
use "math.dta", clear
keep if area == 2
tabstat other_score_math, by(own_estrato) stat(mean sd semean n) save
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

preserve
use "math.dta", clear
keep if area == 2 & nomination
tabstat other_score_math, by(own_estrato) stat(mean sd semean n) save
matrix math_stats_low = r(Stat1)
global math_z_lowR = math_stats_low[1,1]
global math_se_lowR = math_stats_low[3,1]
global math_n_lowR = math_stats_low[4,1]

matrix math_stats_middle = r(Stat2)
global math_z_middleR = math_stats_middle[1,1]
global math_se_middleR = math_stats_middle[3,1]
global math_n_middleR = math_stats_middle[4,1]

matrix math_stats_high = r(Stat3)
global math_z_highR = math_stats_high[1,1]
global math_se_highR = math_stats_high[3,1]
global math_n_highR = math_stats_high[4,1]
restore


clear
set obs 6
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1
gen zscore = .
gen se = .
gen ci_lower = .
gen ci_upper = .
gen zscoreR = .
gen seR = .
gen ci_lowerR = .
gen ci_upperR = .


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

replace zscoreR = ${reading_z_lowR} if own_ses==1 & subject==1
replace zscoreR = ${reading_z_middleR} if own_ses==2 & subject==1
replace zscoreR = ${reading_z_highR} if own_ses==3 & subject==1
replace seR = ${reading_se_lowR} if own_ses==1 & subject==1
replace seR = ${reading_se_middleR} if own_ses==2 & subject==1
replace seR = ${reading_se_highR} if own_ses==3 & subject==1

replace zscoreR = ${math_z_lowR} if own_ses==1 & subject==2
replace zscoreR = ${math_z_middleR} if own_ses==2 & subject==2
replace zscoreR = ${math_z_highR} if own_ses==3 & subject==2
replace seR = ${math_se_lowR} if own_ses==1 & subject==2
replace seR = ${math_se_middleR} if own_ses==2 & subject==2
replace seR = ${math_se_highR} if own_ses==3 & subject==2

replace ci_lowerR = zscoreR - 1.96*seR
replace ci_upperR = zscoreR + 1.96*seR


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

twoway (bar zscoreR pos if subject==1, barwidth(0.8) color("130 202 157")) ///
      (bar zscoreR pos if subject==2, barwidth(0.8) color("136 132 216")) ///
	  (rcap ci_upperR ci_lowerR pos if subject==1, lcolor(gs4)) ///
	  (rcap ci_upperR ci_lowerR pos if subject==2, lcolor(gs4)) ///
	  (scatter zscore pos, mcolor(gs4) lcolor(none)), ///
      xlabel(1.5 "Low" 4.5 "Middle" 7.5 "High") ///
      ylabel(50(5)80, angle(0)) ///
      ytitle("Score") ///
      xtitle("") ///
      title("Referral Performance by SES") ///
      legend(order(1 "Reading" 2 "Math" 5 "Network") ring(0) pos(12) rows(1) region(lcolor(none))) ///
      graphregion(color(white)) bgcolor(white) ///
      name(referral_performance, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/overlaid_referral_performance.png", ///
   replace
