/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 05.05.2025
    Description: piece-rate illustration
*******************************************************************************/
global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

// Create dataset with the score categories and piece-rates
clear
set obs 5
gen score_cat = _n
gen piece_rate = .
gen xpos = _n

// Define the score ranges
label define score_lab 1 "1-50" 2 "51-65" 3 "66-80" 4 "81-90" 5 "91-100"
label values score_cat score_lab

// Set the piece-rate values based on the chart
replace piece_rate = 0.02 if score_cat == 1  // 1-50 score range
replace piece_rate = 0.12 if score_cat == 2  // 51-65 score range
replace piece_rate = 0.25 if score_cat == 3  // 66-80 score range
replace piece_rate = 0.37 if score_cat == 4  // 81-90 score range
replace piece_rate = 0.62 if score_cat == 5  // 91-100 score range

// Create the bar chart
twoway (bar piece_rate xpos, barwidth(0.8)  fcolor(gs10) lcolor(gs4)) ///
       , ///
       xlabel(1 "1-50" 2 "51-65" 3 "66-80" 4 "81-90" 5 "91-100") ///
       ylabel(0(0.1)0.7, angle(0) format(%9.1f) grid gmin gmax) ///
       ytitle("") ///
       xtitle("") ///
       title("Piece-rate by referral score") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 5.5)) ///
       name(piece_rate_by_score, replace)
       
graph export "${fpath}piece_rate_by_score.png", replace
