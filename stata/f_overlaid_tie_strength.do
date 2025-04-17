/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: overlaid figure tie strength by SES
*******************************************************************************/

clear all
use "dataset_z.dta"
tabstat tie if own_estrato == 1, by(other_estrato) stat(mean sd semean)
tabstat tie if own_estrato == 2, by(other_estrato) stat(mean sd semean)
tabstat tie if own_estrato == 3, by(other_estrato) stat(mean sd semean)
 
// First calculate means and store them in globals
foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly summ tie if own_estrato == `own' & other_estrato == `other'
        global mean_`own'_`other' = r(mean)
        global se_`own'_`other' = r(sd)/sqrt(r(N))
        global n_`own'_`other' = r(N)
		quietly summ tie if own_estrato == `own' & other_estrato == `other' & nomination
        global mean_`own'_`other'n = r(mean)
        global se_`own'_`other'n = r(sd)/sqrt(r(N))
        global n_`own'_`other'n = r(N)
    }
}

// Create visualization dataset
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
gen tie_strength = .
gen se = .
gen tie_strengthn = .
gen sen = .

// Low SES (own_ses = 1)
replace tie_strength = ${mean_1_1} if own_ses == 1 & other_ses == 1
replace tie_strength = ${mean_1_2} if own_ses == 1 & other_ses == 2
replace tie_strength = ${mean_1_3} if own_ses == 1 & other_ses == 3
replace se = ${se_1_1} if own_ses == 1 & other_ses == 1
replace se = ${se_1_2} if own_ses == 1 & other_ses == 2
replace se = ${se_1_3} if own_ses == 1 & other_ses == 3
replace tie_strengthn = ${mean_1_1n} if own_ses == 1 & other_ses == 1
replace tie_strengthn = ${mean_1_2n} if own_ses == 1 & other_ses == 2
replace tie_strengthn = ${mean_1_3n} if own_ses == 1 & other_ses == 3
replace sen = ${se_1_1n} if own_ses == 1 & other_ses == 1
replace sen = ${se_1_2n} if own_ses == 1 & other_ses == 2
replace sen = ${se_1_3n} if own_ses == 1 & other_ses == 3

// Middle SES (own_ses = 2)
replace tie_strength = ${mean_2_1} if own_ses == 2 & other_ses == 1
replace tie_strength = ${mean_2_2} if own_ses == 2 & other_ses == 2
replace tie_strength = ${mean_2_3} if own_ses == 2 & other_ses == 3
replace se = ${se_2_1} if own_ses == 2 & other_ses == 1
replace se = ${se_2_2} if own_ses == 2 & other_ses == 2
replace se = ${se_2_3} if own_ses == 2 & other_ses == 3
replace tie_strengthn = ${mean_2_1n} if own_ses == 2 & other_ses == 1
replace tie_strengthn = ${mean_2_2n} if own_ses == 2 & other_ses == 2
replace tie_strengthn = ${mean_2_3n} if own_ses == 2 & other_ses == 3
replace sen = ${se_2_1n} if own_ses == 2 & other_ses == 1
replace sen = ${se_2_2n} if own_ses == 2 & other_ses == 2
replace sen = ${se_2_3n} if own_ses == 2 & other_ses == 3

// High SES (own_ses = 3)
replace tie_strength = ${mean_3_1} if own_ses == 3 & other_ses == 1
replace tie_strength = ${mean_3_2} if own_ses == 3 & other_ses == 2
replace tie_strength = ${mean_3_3} if own_ses == 3 & other_ses == 3
replace se = ${se_3_1} if own_ses == 3 & other_ses == 1
replace se = ${se_3_2} if own_ses == 3 & other_ses == 2
replace se = ${se_3_3} if own_ses == 3 & other_ses == 3
replace tie_strengthn = ${mean_3_1n} if own_ses == 3 & other_ses == 1
replace tie_strengthn = ${mean_3_2n} if own_ses == 3 & other_ses == 2
replace tie_strengthn = ${mean_3_3n} if own_ses == 3 & other_ses == 3
replace sen = ${se_3_1n} if own_ses == 3 & other_ses == 1
replace sen = ${se_3_2n} if own_ses == 3 & other_ses == 2
replace sen = ${se_3_3n} if own_ses == 3 & other_ses == 3


// Calculate 95% confidence intervals
gen ci_lower = tie_strength - 1.96*se
gen ci_upper = tie_strength + 1.96*se
gen ci_lowern = tie_strengthn - 1.96*sen
gen ci_uppern = tie_strengthn + 1.96*sen


replace tie_strengthn = ((tie_strengthn - tie_strength)/tie_strength)



// Create the twoway bar graph with confidence intervals
twoway (bar tie_strengthn xpos if other_ses == 1, barw(0.3) fcolor(gs6) lcolor(gs4)) ///
       (bar tie_strengthn xpos if other_ses == 2, barw(0.3) fcolor(gs10) lcolor(gs4)) ///
       (bar tie_strengthn xpos if other_ses == 3, barw(0.3) fcolor(gs14) lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2.5 "Middle" 4 "High") ///
       ylabel(0(1)5, angle(0) format(%9.0f) grid gmin gmax) ///
       ytitle("Fold increase (x100)") ///
       xtitle("") ///
       title("Referral tie strength compared to network average") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 4.5)) ///
       name(tie_strength, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/overlaid_tie_strength.png", replace
