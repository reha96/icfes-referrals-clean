/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 31.07.2025
    Description: figure appendix hist performance at exam	
*******************************************************************************/

global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

use "${dpath}dataset_z.dta", clear
bysort other_id: keep if _n == 1

preserve	
// Calculate box plot statistics for both variables
foreach var in other_score_math other_score_reading {
    egen med_`var' = median(`var')
    egen lqt_`var' = pctile(`var'), p(25)
    egen uqt_`var' = pctile(`var'), p(75)
    egen iqr_`var' = iqr(`var')
    egen mean_`var' = mean(`var')
    gen l_`var' = `var' if(`var' >= lqt_`var'-1.5*iqr_`var')
    egen ls_`var' = min(l_`var')
    gen u_`var' = `var' if(`var' <= uqt_`var'+1.5*iqr_`var')
    egen us_`var' = max(u_`var')
}

// Set positions for box plots
gen ypos_math = -1.5
gen ypos_reading = -1.5

// Math Score Histogram with Box Plot
sum other_score_math
local min_math = r(min)
local max_math = r(max)
local n_math = r(N)
local bins = 20
local width_math = (`max_math'-`min_math')/`bins'
    
twoway  (histogram other_score_math, percent start(`min_math') width(`width_math') ///
         fcolor(gs11) lcolor(gs4) lwidth(thin)) ///
       || rbar lqt_other_score_math uqt_other_score_math ypos_math, horiz ///
          fcolor(gs11) lcolor(gs4) barw(1) ///
       || rbar med_other_score_math uqt_other_score_math ypos_math, horiz ///
          fcolor(gs11) lcolor(gs4) barw(1) ///
       || rspike lqt_other_score_math ls_other_score_math ypos_math, horiz lcolor(gs4) ///
       || rspike uqt_other_score_math us_other_score_math ypos_math, horiz lcolor(gs4) ///
       || rcap ls_other_score_math ls_other_score_math ypos_math, horiz msize(*1) lcolor(gs4) ///
       || rcap us_other_score_math us_other_score_math ypos_math, horiz msize(*1) lcolor(gs4) ///
       || scatter ypos_math mean_other_score_math, msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) ///
       , xlabel(0(20)100) ///
         ylabel(0(5)25, gmax angle(0)) ///
         ytitle("Percent") ///
         xtitle("Score") ///
         title("Distribution of Math Scores") ///
         legend(off) ///
         graphregion(color(white)) bgcolor(white) ///
         name(math_hist, replace)
		  
graph export "${fpath}math_hist.png", replace

// Reading Score Histogram with Box Plot
sum other_score_reading
local min_reading = r(min)
local max_reading = r(max)
local n_reading = r(N)
local width_reading = (`max_reading'-`min_reading')/`bins'
    
twoway  (histogram other_score_reading, percent start(`min_reading') width(`width_reading') ///
         fcolor(gs11) lcolor(gs4) lwidth(thin)) ///
       || rbar lqt_other_score_reading uqt_other_score_reading ypos_reading, horiz ///
          fcolor(gs11) lcolor(gs4) barw(1) ///
       || rbar med_other_score_reading uqt_other_score_reading ypos_reading, horiz ///
          fcolor(gs11) lcolor(gs4) barw(1) ///
       || rspike lqt_other_score_reading ls_other_score_reading ypos_reading, horiz lcolor(gs4) ///
       || rspike uqt_other_score_reading us_other_score_reading ypos_reading, horiz lcolor(gs4) ///
       || rcap ls_other_score_reading ls_other_score_reading ypos_reading, horiz msize(*1) lcolor(gs4) ///
       || rcap us_other_score_reading us_other_score_reading ypos_reading, horiz msize(*1) lcolor(gs4) ///
       || scatter ypos_reading mean_other_score_reading, msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) ///
       , xlabel(0(20)100) ///
         ylabel(0(5)25, gmax angle(0)) ///
         ytitle("Percent") ///
         xtitle("Score") ///
         title("Distribution of Reading Scores") ///
         legend(off) ///
         graphregion(color(white)) bgcolor(white) ///
         name(reading_hist, replace)
		  
graph export "${fpath}reading_hist.png", replace
restore
