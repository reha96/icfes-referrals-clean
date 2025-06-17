/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 29.04.2025
    Description: figure referrals overall
*******************************************************************************/

global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

use "${dpath}dataset_z.dta", clear
sort own_id other_id

preserve
keep if nomination

bysort own_id: egen p_low = mean(other_estrato == 1)
bysort own_id: egen p_middle = mean(other_estrato == 2)
bysort own_id: egen p_high = mean(other_estrato == 3)

collapse (mean) p_low p_middle p_high ///
         (sem) se_low=p_low se_middle=p_middle se_high=p_high ///
		 (sd) sd_low=p_low sd_middle=p_middle sd_high=p_high ///
         (count) n=p_low

global prop_low = p_low[1]
global prop_middle = p_middle[1]
global prop_high = p_high[1]
global se_low = se_low[1]*100
global se_middle = se_middle[1]*100
global se_high = se_high[1]*100
global sd_low = sd_low[1]
global sd_middle = sd_middle[1]
global sd_high = sd_high[1]
global n1 = n[1]
restore

bysort own_id: egen p_lowA = mean(other_estrato == 1)
bysort own_id: egen p_middleA = mean(other_estrato == 2)
bysort own_id: egen p_highA = mean(other_estrato == 3)
bysort own_id: keep if _n == 1
collapse (mean) p_lowA p_middleA p_highA ///
         (sem) se_lowA=p_lowA se_middleA=p_middleA se_highA=p_highA ///
		 (sd) sd_lowA=p_lowA sd_middleA=p_middleA sd_highA=p_highA ///
         (count) n=p_lowA
global prop_lowA = p_lowA[1]
global prop_middleA = p_middleA[1]
global prop_highA = p_highA[1]
global se_lowA = se_lowA[1]*100
global se_middleA = se_middleA[1]*100
global se_highA = se_highA[1]*100
global sd_lowA = sd_lowA[1]
global sd_middleA = sd_middleA[1]
global sd_highA = sd_highA[1]
global n2 = n[1]


cls
ttesti ${n1} ${prop_low} ${sd_low} ${n2} ${prop_lowA} ${sd_lowA} , unequal
ttesti ${n1} ${prop_middle} ${sd_middle} ${n2} ${prop_middleA} ${sd_middleA} , unequal
ttesti ${n1} ${prop_high} ${sd_high} ${n2} ${prop_highA} ${sd_highA} , unequal


clear
set obs 3
gen own_estrato = _n
gen xpos = _n - 0.15
gen xpos2 = _n + 0.15

gen rateN = .
gen rateA = .
gen ci_lowerN = .
gen ci_upperN = .
gen ci_lowerA = .
gen ci_upperA = .

replace rateA = ${prop_lowA}*100 if own_estrato == 1
replace rateA = ${prop_middleA}*100 if own_estrato == 2
replace rateA = ${prop_highA}*100 if own_estrato == 3

replace rateN = ${prop_low}*100 if own_estrato == 1
replace rateN = ${prop_middle}*100 if own_estrato == 2
replace rateN = ${prop_high}*100 if own_estrato == 3

replace ci_lowerN = rateN - 1.96*${se_low} if own_estrato == 1
replace ci_lowerN = rateN - 1.96*${se_middle} if own_estrato == 2
replace ci_lowerN = rateN - 1.96*${se_high} if own_estrato == 3

replace ci_upperN = rateN + 1.96*${se_low} if own_estrato == 1
replace ci_upperN = rateN + 1.96*${se_middle} if own_estrato == 2
replace ci_upperN = rateN + 1.96*${se_high} if own_estrato == 3

replace ci_lowerA = rateA - 1.96*${se_lowA} if own_estrato == 1
replace ci_lowerA = rateA - 1.96*${se_middleA} if own_estrato == 2
replace ci_lowerA = rateA - 1.96*${se_highA} if own_estrato == 3

replace ci_upperA = rateA + 1.96*${se_lowA} if own_estrato == 1
replace ci_upperA = rateA + 1.96*${se_middleA} if own_estrato == 2
replace ci_upperA = rateA + 1.96*${se_highA} if own_estrato == 3

twoway (bar rateA xpos, barwidth(0.3) fcolor(gs8) lcolor(gs4)) ///
	   (rcap ci_upperA ci_lowerA xpos, lcolor(gs4)) ///
	   (bar rateN xpos2, barwidth(0.3) fcolor(gs14) lcolor(gs4)) ///
       (rcap ci_upperN ci_lowerN xpos2, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(0(10)80, angle(0) format(%9.0f) grid gmax gmin) ///
       ytitle("Percent") ///
       xtitle("") ///
       title("Referral rates compared to network shares") ///
       legend(order(1 "Network" 3 "Referral") ///
              ring(0) pos(12) rows(1) region(lcolor(none)) ) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(fee_by_ses, replace)
	   
graph export "${fpath}all_referral_rates.png", replace

/////////////
cls


