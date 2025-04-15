/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 15.04.2025
    Description: figure score premium
*******************************************************************************/

global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently


use "${dpath}cmb_tmp.dta", clear
sort own_id
list in 1/6

preserve
egen med = median(score_premium)
egen lqt = pctile(score_premium), p(25)
egen uqt = pctile(score_premium), p(75)
egen iqr = iqr(score_premium)
egen mean = mean(score_premium)
gen ypos = -.75
gen l = score_premium if(score_premium >= lqt-1.5*iqr)
egen ls = min(l)
gen u = score_premium if(score_premium <= uqt+1.5*iqr)
egen us = max(u)

twoway (histogram score_premium, percent fcolor(gs10) bins(20) lcolor(gs4) lwidth(thin)) ///
		rbar lqt uqt ypos , horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
	   rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
       rspike lqt ls ypos, horiz  lcolor(gs4) || ///
       rspike uqt us ypos, horiz lcolor(gs4) || ///
       rcap ls ls ypos,  horiz msize(*1) lcolor(gs4) || ///
       rcap us us ypos,  horiz msize(*1) lcolor(gs4)|| ///
       scatter ypos mean , msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) legend(off) ///
      , ///
      xlabel(-40(10)40) ///
      ylabel(0(5)20, angle(0)) ///
      ytitle("Percent") ///
      xtitle("") ///
      title("Score Premium") ///
      graphregion(color(white)) bgcolor(white) ///
      name(score_premium, replace)
graph export "${fpath}score_premium.png", replace
restore


// by SES
use "${dpath}cmb_tmp.dta", clear
sort own_id
collapse (mean) score_premium (sd) sd=score_premium (count) n=score_premium (semean) se=score_premium, by(own_estrato)
list in 1/3

forvalues i = 1/3 {
    global mean`i' = score_premium[`i']
    global sd`i' = sd[`i']
    global n`i' = n[`i']
    global se`i' = se[`i']
    global ci_lower`i' = score_premium[`i'] - 1.96*se[`i']
    global ci_upper`i' = score_premium[`i'] + 1.96*se[`i']
}

// ttest meaningless cause every individual is observed twice!!
// ttesti $n1 $mean1 $sd1 $n2 $mean2 $sd2, unequal // low vs mid 
// ttesti $n1 $mean1 $sd1 $n3 $mean3 $sd3, unequal // low vs high *
// ttesti $n2 $mean2 $sd2 $n3 $mean3 $sd3, unequal // mid vs high **

clear
set obs 3
gen own_estrato = _n
gen xpos = _n

gen mean = .
gen ci_lower = .
gen ci_upper = .

replace mean = ${mean1} if own_estrato == 1
replace mean = ${mean2} if own_estrato == 2
replace mean = ${mean3} if own_estrato == 3

replace ci_lower = ${ci_lower1} if own_estrato == 1
replace ci_lower = ${ci_lower2} if own_estrato == 2
replace ci_lower = ${ci_lower3} if own_estrato == 3

replace ci_upper = ${ci_upper1} if own_estrato == 1
replace ci_upper = ${ci_upper2} if own_estrato == 2
replace ci_upper = ${ci_upper3} if own_estrato == 3


twoway (bar mean xpos, barwidth(0.5) fcolor(gs10) lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High", noticks) ///
       ylabel(0(2)10, angle(0) format(%9.0f) grid gmin gmax) ///
       ytitle("Score Premium") ///
       xtitle("") ///
       title("Score Premium by SES") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(sp_byses, replace)
       
graph export "${fpath}sp_byses.png", replace
