/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure scores by tie strength and SES
*******************************************************************************/


clear all
set more off
graph drop _all

use "reading.dta", clear
preserve
twoway (lpolyci z_other_score_reading z_tie if own_estrato==1 & z_tie <=5, degree(1) bwidth(1) lcolor("255 99 132") lwidth(thick) ///
        ciplot(rline) clpattern(dash) clcolor("255 99 132")) ///
       (lpolyci z_other_score_reading z_tie if own_estrato==2 & z_tie <=5, degree(1) bwidth(1) lcolor("54 162 235") lwidth(thick) ///
        ciplot(rline) clpattern(dash) clcolor("54 162 235")) ///
       (lpolyci z_other_score_reading z_tie if own_estrato==3 & z_tie <=5, degree(1) bwidth(1) lcolor("75 192 112") lwidth(thick) ///
        ciplot(rline) clpattern(dash) clcolor("75 192 112")), ///
       ylabel(-0.25(0.25)1, grid) ///
       xlabel(-1(1)5) ///
       ytitle("Reading z-score") ///
       xtitle("Tie Strength z-score") ///
       legend(ring(0) pos(11) rows(3) order(1 "Low" 3 "Middle" 5 "High") region(lcolor(none))) ///
       title("Reading") ///
       graphregion(color(white)) bgcolor(white) ///
       name(reading, replace)  nodraw
       
// graph export "tie_reading_by_ses.png", replace width(2000) height(1500)
restore

use "math.dta", clear
preserve
twoway (lpolyci z_other_score_math z_tie if own_estrato==1 & z_tie <=5, degree(1) bwidth(1) lcolor("255 99 132") lwidth(thick) ///
        ciplot(rline) clpattern(dash) clcolor("255 99 132")) ///
       (lpolyci z_other_score_math z_tie if own_estrato==2 & z_tie <=5, degree(1) bwidth(1) lcolor("54 162 235") lwidth(thick) ///
        ciplot(rline) clpattern(dash) clcolor("54 162 235")) ///
       (lpolyci z_other_score_math z_tie if own_estrato==3 & z_tie <=5, degree(1) bwidth(1) lcolor("75 192 112") lwidth(thick) ///
        ciplot(rline) clpattern(dash) clcolor("75 192 112")), ///
       ylabel(-0.25(0.25)1, grid) ///
       xlabel(-1(1)5) ///
       ytitle("Math z-score") ///
       xtitle("Tie Strength z-score") ///
       legend(ring(0) pos(11) rows(3) order(1 "Low" 3 "Middle" 5 "High") region(lcolor(none))) ///
       title("Math") ///
       graphregion(color(white)) bgcolor(white) ///
       name(math, replace) nodraw
       
// graph export "tie_math_by_ses.png", replace width(2000) height(1500)
restore

graph combine reading math, ///
      graphregion(color(white)) ///
      rows(1) ///
      name(tie_combined, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/tie_combined.png", replace   
