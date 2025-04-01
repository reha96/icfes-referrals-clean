/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure treatment referral rates and performance by SES
*******************************************************************************/

//# referral rates
preserve
use "dataset_z.dta", clear
keep if treat == 1
proportion other_estrato if nomination == 1 & own_estrato == 1
matrix tr1_low_props = r(table)
global tr1_low_low = tr1_low_props[1,1]
global tr1_low_middle = tr1_low_props[1,2]
global tr1_low_high = tr1_low_props[1,3]
global tr1_low_low_se = tr1_low_props[2,1]
global tr1_low_middle_se = tr1_low_props[2,2]
global tr1_low_high_se = tr1_low_props[2,3]
global tr1_low_n = e(N)

proportion other_estrato if nomination == 1 & own_estrato == 2
matrix tr1_middle_props = r(table)
global tr1_middle_low = tr1_middle_props[1,1]
global tr1_middle_middle = tr1_middle_props[1,2]
global tr1_middle_high = tr1_middle_props[1,3]
global tr1_middle_low_se = tr1_middle_props[2,1]
global tr1_middle_middle_se = tr1_middle_props[2,2]
global tr1_middle_high_se = tr1_middle_props[2,3]
global tr1_middle_n = e(N)

proportion other_estrato if nomination == 1 & own_estrato == 3
matrix tr1_high_props = r(table)
global tr1_high_low = tr1_high_props[1,1]
global tr1_high_middle = tr1_high_props[1,2]
global tr1_high_high = tr1_high_props[1,3]
global tr1_high_low_se = tr1_high_props[2,1]
global tr1_high_middle_se = tr1_high_props[2,2]
global tr1_high_high_se = tr1_high_props[2,3]
global tr1_high_n = e(N)
restore

preserve
use "dataset_z.dta", clear
keep if treat == 2
proportion other_estrato if nomination == 1 & own_estrato == 1
matrix tr2_low_props = r(table)
global tr2_low_low = tr2_low_props[1,1]
global tr2_low_middle = tr2_low_props[1,2]
global tr2_low_high = tr2_low_props[1,3]
global tr2_low_low_se = tr2_low_props[2,1]
global tr2_low_middle_se = tr2_low_props[2,2]
global tr2_low_high_se = tr2_low_props[2,3]
global tr2_low_n = e(N)

proportion other_estrato if nomination == 1 & own_estrato == 2
matrix tr2_middle_props = r(table)
global tr2_middle_low = tr2_middle_props[1,1]
global tr2_middle_middle = tr2_middle_props[1,2]
global tr2_middle_high = tr2_middle_props[1,3]
global tr2_middle_low_se = tr2_middle_props[2,1]
global tr2_middle_middle_se = tr2_middle_props[2,2]
global tr2_middle_high_se = tr2_middle_props[2,3]
global tr2_middle_n = e(N)

proportion other_estrato if nomination == 1 & own_estrato == 3
matrix tr2_high_props = r(table)
global tr2_high_low = tr2_high_props[1,1]
global tr2_high_middle = tr2_high_props[1,2]
global tr2_high_high = tr2_high_props[1,3]
global tr2_high_low_se = tr2_high_props[2,1]
global tr2_high_middle_se = tr2_high_props[2,2]
global tr2_high_high_se = tr2_high_props[2,3]
global tr2_high_n = e(N)
restore

prtesti ${tr1_low_n} ${tr1_low_low} ${tr2_low_n} ${tr2_low_low}
prtesti ${tr1_low_n} ${tr1_low_middle} ${tr2_low_n} ${tr2_low_middle}
prtesti ${tr1_low_n} ${tr1_low_high} ${tr2_low_n} ${tr2_low_high}

prtesti ${tr1_middle_n} ${tr1_middle_low} ${tr2_middle_n} ${tr2_middle_low}
prtesti ${tr1_middle_n} ${tr1_middle_middle} ${tr2_middle_n} ${tr2_middle_middle}
prtesti ${tr1_middle_n} ${tr1_middle_high} ${tr2_middle_n} ${tr2_middle_high}

prtesti ${tr1_high_n} ${tr1_high_low} ${tr2_high_n} ${tr2_high_low}
prtesti ${tr1_high_n} ${tr1_high_middle} ${tr2_high_n} ${tr2_high_middle}
prtesti ${tr1_high_n} ${tr1_high_high} ${tr2_high_n} ${tr2_high_high}

foreach own in low middle high {
    foreach other in low middle high {
        global tr1_`own'_`other' = ${tr1_`own'_`other'} * 100
        global tr1_`own'_`other'_se = ${tr1_`own'_`other'_se} * 100
        global tr2_`own'_`other' = ${tr2_`own'_`other'} * 100
        global tr2_`own'_`other'_se = ${tr2_`own'_`other'_se} * 100
    }
}

preserve
clear
set obs 9
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

replace xpos = 0.7 if own_ses == 1 & other_ses == 1
replace xpos = 1.0 if own_ses == 1 & other_ses == 2
replace xpos = 1.3 if own_ses == 1 & other_ses == 3

replace xpos = 1.7 if own_ses == 2 & other_ses == 1
replace xpos = 2.0 if own_ses == 2 & other_ses == 2
replace xpos = 2.3 if own_ses == 2 & other_ses == 3

replace xpos = 2.7 if own_ses == 3 & other_ses == 1
replace xpos = 3.0 if own_ses == 3 & other_ses == 2
replace xpos = 3.3 if own_ses == 3 & other_ses == 3

gen effect = .
gen prop_baseline = .
gen se_baseline = .
gen prop_bonus = .
gen se_bonus = .

replace prop_baseline = ${tr1_low_low} if own_ses == 1 & other_ses == 1
replace se_baseline = ${tr1_low_low_se} if own_ses == 1 & other_ses == 1
replace prop_bonus = ${tr2_low_low} if own_ses == 1 & other_ses == 1
replace se_bonus = ${tr2_low_low_se} if own_ses == 1 & other_ses == 1

replace prop_baseline = ${tr1_low_middle} if own_ses == 1 & other_ses == 2
replace se_baseline = ${tr1_low_middle_se} if own_ses == 1 & other_ses == 2
replace prop_bonus = ${tr2_low_middle} if own_ses == 1 & other_ses == 2
replace se_bonus = ${tr2_low_middle_se} if own_ses == 1 & other_ses == 2

replace prop_baseline = ${tr1_low_high} if own_ses == 1 & other_ses == 3
replace se_baseline = ${tr1_low_high_se} if own_ses == 1 & other_ses == 3
replace prop_bonus = ${tr2_low_high} if own_ses == 1 & other_ses == 3
replace se_bonus = ${tr2_low_high_se} if own_ses == 1 & other_ses == 3

replace prop_baseline = ${tr1_middle_low} if own_ses == 2 & other_ses == 1
replace se_baseline = ${tr1_middle_low_se} if own_ses == 2 & other_ses == 1
replace prop_bonus = ${tr2_middle_low} if own_ses == 2 & other_ses == 1
replace se_bonus = ${tr2_middle_low_se} if own_ses == 2 & other_ses == 1

replace prop_baseline = ${tr1_middle_middle} if own_ses == 2 & other_ses == 2
replace se_baseline = ${tr1_middle_middle_se} if own_ses == 2 & other_ses == 2
replace prop_bonus = ${tr2_middle_middle} if own_ses == 2 & other_ses == 2
replace se_bonus = ${tr2_middle_middle_se} if own_ses == 2 & other_ses == 2

replace prop_baseline = ${tr1_middle_high} if own_ses == 2 & other_ses == 3
replace se_baseline = ${tr1_middle_high_se} if own_ses == 2 & other_ses == 3
replace prop_bonus = ${tr2_middle_high} if own_ses == 2 & other_ses == 3
replace se_bonus = ${tr2_middle_high_se} if own_ses == 2 & other_ses == 3

replace prop_baseline = ${tr1_high_low} if own_ses == 3 & other_ses == 1
replace se_baseline = ${tr1_high_low_se} if own_ses == 3 & other_ses == 1
replace prop_bonus = ${tr2_high_low} if own_ses == 3 & other_ses == 1
replace se_bonus = ${tr2_high_low_se} if own_ses == 3 & other_ses == 1

replace prop_baseline = ${tr1_high_middle} if own_ses == 3 & other_ses == 2
replace se_baseline = ${tr1_high_middle_se} if own_ses == 3 & other_ses == 2
replace prop_bonus = ${tr2_high_middle} if own_ses == 3 & other_ses == 2
replace se_bonus = ${tr2_high_middle_se} if own_ses == 3 & other_ses == 2

replace prop_baseline = ${tr1_high_high} if own_ses == 3 & other_ses == 3
replace se_baseline = ${tr1_high_high_se} if own_ses == 3 & other_ses == 3
replace prop_bonus = ${tr2_high_high} if own_ses == 3 & other_ses == 3
replace se_bonus = ${tr2_high_high_se} if own_ses == 3 & other_ses == 3

replace effect = prop_bonus - prop_baseline
gen se_diff = sqrt(se_bonus^2 + se_baseline^2)
gen ci_lower = effect - 1.96*se_diff
gen ci_upper = effect + 1.96*se_diff

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

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
       title("Bonus on Referral Rates by SES") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(1) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(ses_treatment_effect, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ses_treatment_effects.png", replace
restore

//# performance
preserve
use "reading.dta", clear
keep if area == 1

tabstat z_other_score_reading if nomination == 1 & own_estrato == 1 & treat==1, stat(mean sd n semean) save
matrix reading_stats_low_baseline = r(StatTotal)
global reading_z_low_baseline = reading_stats_low_baseline[1,1]
global reading_se_low_baseline = reading_stats_low_baseline[4,1]

tabstat z_other_score_reading if nomination == 1 & own_estrato == 1 & treat==2, stat(mean sd n semean) save
matrix reading_stats_low_bonus = r(StatTotal)
global reading_z_low_bonus = reading_stats_low_bonus[1,1]
global reading_se_low_bonus = reading_stats_low_bonus[4,1]

tabstat z_other_score_reading if nomination == 1 & own_estrato == 2 & treat==1, stat(mean sd n semean) save
matrix reading_stats_middle_baseline = r(StatTotal)
global reading_z_middle_baseline = reading_stats_middle_baseline[1,1]
global reading_se_middle_baseline = reading_stats_middle_baseline[4,1]

tabstat z_other_score_reading if nomination == 1 & own_estrato == 2 & treat==2, stat(mean sd n semean) save
matrix reading_stats_middle_bonus = r(StatTotal)
global reading_z_middle_bonus = reading_stats_middle_bonus[1,1]
global reading_se_middle_bonus = reading_stats_middle_bonus[4,1]

tabstat z_other_score_reading if nomination == 1 & own_estrato == 3 & treat==1, stat(mean sd n semean) save
matrix reading_stats_high_baseline = r(StatTotal)
global reading_z_high_baseline = reading_stats_high_baseline[1,1]
global reading_se_high_baseline = reading_stats_high_baseline[4,1]

tabstat z_other_score_reading if nomination == 1 & own_estrato == 3 & treat==2, stat(mean sd n semean) save
matrix reading_stats_high_bonus = r(StatTotal)
global reading_z_high_bonus = reading_stats_high_bonus[1,1]
global reading_se_high_bonus = reading_stats_high_bonus[4,1]

ttest z_other_score_reading if nomination == 1 & own_estrato == 1, by(treat)
ttest z_other_score_reading if nomination == 1 & own_estrato == 2, by(treat)
ttest z_other_score_reading if nomination == 1 & own_estrato == 3, by(treat)
restore

preserve
use "math.dta", clear
keep if area == 2

tabstat z_other_score_math if nomination == 1 & own_estrato == 1 & treat==1, stat(mean sd n semean) save
matrix math_stats_low_baseline = r(StatTotal)
global math_z_low_baseline = math_stats_low_baseline[1,1]
global math_se_low_baseline = math_stats_low_baseline[4,1]

tabstat z_other_score_math if nomination == 1 & own_estrato == 1 & treat==2, stat(mean sd n semean) save
matrix math_stats_low_bonus = r(StatTotal)
global math_z_low_bonus = math_stats_low_bonus[1,1]
global math_se_low_bonus = math_stats_low_bonus[4,1]

tabstat z_other_score_math if nomination == 1 & own_estrato == 2 & treat==1, stat(mean sd n semean) save
matrix math_stats_middle_baseline = r(StatTotal)
global math_z_middle_baseline = math_stats_middle_baseline[1,1]
global math_se_middle_baseline = math_stats_middle_baseline[4,1]

tabstat z_other_score_math if nomination == 1 & own_estrato == 2 & treat==2, stat(mean sd n semean) save
matrix math_stats_middle_bonus = r(StatTotal)
global math_z_middle_bonus = math_stats_middle_bonus[1,1]
global math_se_middle_bonus = math_stats_middle_bonus[4,1]

tabstat z_other_score_math if nomination == 1 & own_estrato == 3 & treat==1, stat(mean sd n semean) save
matrix math_stats_high_baseline = r(StatTotal)
global math_z_high_baseline = math_stats_high_baseline[1,1]
global math_se_high_baseline = math_stats_high_baseline[4,1]

tabstat z_other_score_math if nomination == 1 & own_estrato == 3 & treat==2, stat(mean sd n semean) save
matrix math_stats_high_bonus = r(StatTotal)
global math_z_high_bonus = math_stats_high_bonus[1,1]
global math_se_high_bonus = math_stats_high_bonus[4,1]

ttest z_other_score_math if nomination == 1 & own_estrato == 1, by(treat)
ttest z_other_score_math if nomination == 1 & own_estrato == 2, by(treat)
ttest z_other_score_math if nomination == 1 & own_estrato == 3, by(treat)
restore

preserve 
clear
set obs 6
gen own_ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1

gen prop_baseline = .
gen prop_bonus = .
gen se_baseline = .
gen se_bonus = .

replace prop_baseline = ${reading_z_low_baseline} if own_ses==1 & subject==1
replace prop_bonus = ${reading_z_low_bonus} if own_ses==1 & subject==1
replace se_baseline = ${reading_se_low_baseline} if own_ses==1 & subject==1
replace se_bonus = ${reading_se_low_bonus} if own_ses==1 & subject==1

replace prop_baseline = ${reading_z_middle_baseline} if own_ses==2 & subject==1
replace prop_bonus = ${reading_z_middle_bonus} if own_ses==2 & subject==1
replace se_baseline = ${reading_se_middle_baseline} if own_ses==2 & subject==1
replace se_bonus = ${reading_se_middle_bonus} if own_ses==2 & subject==1

replace prop_baseline = ${reading_z_high_baseline} if own_ses==3 & subject==1
replace prop_bonus = ${reading_z_high_bonus} if own_ses==3 & subject==1
replace se_baseline = ${reading_se_high_baseline} if own_ses==3 & subject==1
replace se_bonus = ${reading_se_high_bonus} if own_ses==3 & subject==1

replace prop_baseline = ${math_z_low_baseline} if own_ses==1 & subject==2
replace prop_bonus = ${math_z_low_bonus} if own_ses==1 & subject==2
replace se_baseline = ${math_se_low_baseline} if own_ses==1 & subject==2
replace se_bonus = ${math_se_low_bonus} if own_ses==1 & subject==2

replace prop_baseline = ${math_z_middle_baseline} if own_ses==2 & subject==2
replace prop_bonus = ${math_z_middle_bonus} if own_ses==2 & subject==2
replace se_baseline = ${math_se_middle_baseline} if own_ses==2 & subject==2
replace se_bonus = ${math_se_middle_bonus} if own_ses==2 & subject==2

replace prop_baseline = ${math_z_high_baseline} if own_ses==3 & subject==2
replace prop_bonus = ${math_z_high_bonus} if own_ses==3 & subject==2
replace se_baseline = ${math_se_high_baseline} if own_ses==3 & subject==2
replace se_bonus = ${math_se_high_bonus} if own_ses==3 & subject==2

gen xpos = own_ses + (subject==2)*0.25

gen effect = prop_bonus - prop_baseline

gen se_diff = sqrt(se_bonus^2 + se_baseline^2)
gen ci_lower = effect - 1.96*se_diff
gen ci_upper = effect + 1.96*se_diff

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
gen other_ses = subject
label define subj_lab 1 "Reading" 2 "Math"
label values subject subj_lab
label values other_ses subj_lab

twoway (bar effect xpos if subject == 1, barw(0.25) color("130 202 157")) ///
       (bar effect xpos if subject == 2, barw(0.25) color("136 132 216")) ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(-.75(0.25).75, angle(0)) ///
       ytitle("Δ z-score (Bonus - Baseline)") ///
       xtitle("") ///
       title("Bonus on Referral Performance by SES") ///
       legend(order(1 "Reading" 2 "Math") ///
              ring(0) pos(11) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(ses_treatment_effect, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/treatment_effect.png", replace
restore
