/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 31.03.2025
    Description: figure scores by tie strength and SES (line with CIs)
*******************************************************************************/
clear all
set more off
graph drop _all

// For Reading scores
use "reading.dta", clear
preserve

// Generate discrete z_tie categories rounded to nearest integer 
gen z_tie_discrete = round(z_tie)
keep if z_tie_discrete >= -1 & z_tie_discrete <= 5

collapse (mean) mean_score=z_other_score_reading ///
         (sd) sd_score=z_other_score_reading ///
         (count) n=z_other_score_reading, ///
         by(own_estrato z_tie_discrete)

gen ci_lower = mean_score - invttail(n-1,0.025)*(sd_score/sqrt(n))
gen ci_upper = mean_score + invttail(n-1,0.025)*(sd_score/sqrt(n))

twoway (rcap ci_lower ci_upper z_tie_discrete if own_estrato==1, lcolor("255 99 132") lpattern(line)) ///
       (connected mean_score z_tie_discrete if own_estrato==1, lcolor("255 99 132") lwidth(thick) mcolor("255 99 132") msymbol(circle) msize(medium)) ///
       (rcap ci_lower ci_upper z_tie_discrete if own_estrato==2, lcolor("54 162 235") lpattern(line)) ///
       (connected mean_score z_tie_discrete if own_estrato==2, lcolor("54 162 235") lwidth(thick) mcolor("54 162 235") msymbol(circle) msize(medium)) ///
       (rcap ci_lower ci_upper z_tie_discrete if own_estrato==3, lcolor("75 192 112") lpattern(line)) ///
       (connected mean_score z_tie_discrete if own_estrato==3, lcolor("75 192 112") lwidth(thick) mcolor("75 192 112") msymbol(circle) msize(medium)), ///
       ylabel(-0.25(0.25)1, grid) ///
       xlabel(-1(1)5) ///
       ytitle("Reading z-score") ///
       xtitle("Tie Strength z-score") ///
       legend(ring(0) pos(11) rows(3) order(2 "Low" 4 "Middle" 6 "High") region(lcolor(none))) ///
       title("Reading") ///
       graphregion(color(white)) bgcolor(white) ///
       name(reading, replace) nodraw
restore

// For Math scores 
use "math.dta", clear
preserve

gen z_tie_discrete = round(z_tie)
keep if z_tie_discrete >= -1 & z_tie_discrete <= 5

collapse (mean) mean_score=z_other_score_math ///
         (sd) sd_score=z_other_score_math ///
         (count) n=z_other_score_math, ///
         by(own_estrato z_tie_discrete)

gen ci_lower = mean_score - invttail(n-1,0.025)*(sd_score/sqrt(n))
gen ci_upper = mean_score + invttail(n-1,0.025)*(sd_score/sqrt(n))

twoway (rcap ci_lower ci_upper z_tie_discrete if own_estrato==1, lcolor("255 99 132") lpattern(line)) ///
       (connected mean_score z_tie_discrete if own_estrato==1, lcolor("255 99 132") lwidth(thick) mcolor("255 99 132") msymbol(circle) msize(medium)) ///
       (rcap ci_lower ci_upper z_tie_discrete if own_estrato==2, lcolor("54 162 235") lpattern(line)) ///
       (connected mean_score z_tie_discrete if own_estrato==2, lcolor("54 162 235") lwidth(thick) mcolor("54 162 235") msymbol(circle) msize(medium)) ///
       (rcap ci_lower ci_upper z_tie_discrete if own_estrato==3, lcolor("75 192 112") lpattern(line)) ///
       (connected mean_score z_tie_discrete if own_estrato==3, lcolor("75 192 112") lwidth(thick) mcolor("75 192 112") msymbol(circle) msize(medium)), ///
       ylabel(-0.25(0.25)1, grid) ///
       xlabel(-1(1)5) ///
       ytitle("Math z-score") ///
       xtitle("Tie Strength z-score") ///
       legend(ring(0) pos(11) rows(3) order(2 "Low" 4 "Middle" 6 "High") region(lcolor(none))) ///
       title("Math") ///
       graphregion(color(white)) bgcolor(white) ///
       name(math, replace) nodraw
restore

graph combine reading math, ///
      graphregion(color(white)) ///
      rows(1) ///
      name(tie_combined, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/reading.png", replace
