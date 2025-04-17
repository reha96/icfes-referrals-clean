/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 01.04.2025
    Description: figure program fees by ses
*******************************************************************************/

global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

// sample
preserve
use "${dpath}dataset_z.dta",clear
sort own_id other_id
bysort own_id: gen counter = _n
keep if counter == 1
collapse (mean) own_fee (sem) se=own_fee, by(own_estrato)
forvalues i = 1/3 {
    global fee_mean`i'S = (own_fee[`i']/1000)*(0.240745)*17.5
	global fee_se`i'S = (se[`i']/1000)*(0.240745)*17.5
	global fee_ci_lower`i'S = (own_fee[`i']/1000)*(0.240745)*17.5 - 1.96*(se[`i']/1000)*(0.240745)*17.5
    global fee_ci_upper`i'S = (own_fee[`i']/1000)*(0.240745)*17.5 + 1.96*(se[`i']/1000)*(0.240745)*17.5
} 
restore 

// admin
preserve
use "dataset_z.dta",clear
sort own_id other_id
bysort other_id: gen counter = _n
keep if counter == 1
collapse (mean) other_fee (sd) sd_fee=other_fee (count) n=other_fee (semean) se=other_fee, by(own_estrato)
forvalues i = 1/3 {
    global fee_mean`i'A = (other_fee[`i']/1000)*(0.240745)*17.5
	global fee_se`i'A = (se[`i']/1000)*(0.240745)*17.5
	global fee_ci_lower`i'A = (other_fee[`i']/1000)*(0.240745)*17.5 - 1.96*(se[`i']/1000)*(0.240745)*17.5
    global fee_ci_upper`i'A = (other_fee[`i']/1000)*(0.240745)*17.5 + 1.96*(se[`i']/1000)*(0.240745)*17.5
} 
restore 

use "dataset_z.dta",clear
sort own_id other_id
bysort own_id: gen counter = _n

collapse (mean) other_fee (sd) sd_fee=other_fee (count) n=other_fee (semean) se=other_fee, by(own_estrato)

forvalues i = 1/3 {
    global fee_mean`i' = (other_fee[`i']/1000)*(0.240745)*17.5
    global fee_sd`i' = (sd_fee[`i']/1000)*(0.240745)*17.5
    global fee_n`i' = n[`i']
    global fee_se`i' = (se[`i']/1000)*(0.240745)*17.5
    global fee_ci_lower`i' = (other_fee[`i']/1000)*(0.240745)*17.5 - 1.96*(se[`i']/1000)*(0.240745)*17.5
    global fee_ci_upper`i' = (other_fee[`i']/1000)*(0.240745)*17.5 + 1.96*(se[`i']/1000)*(0.240745)*17.5
}

clear
set obs 3
gen own_estrato = _n
gen xpos = _n

gen fee = .
gen feeA = .
gen feeS = .
gen se = .
gen ci_lowerS = .
gen ci_upperS = .

replace fee = ${fee_mean1} if own_estrato == 1
replace fee = ${fee_mean2} if own_estrato == 2
replace fee = ${fee_mean3} if own_estrato == 3

replace feeA = ${fee_mean1A} if own_estrato == 1
replace feeA = ${fee_mean2A} if own_estrato == 2
replace feeA = ${fee_mean3A} if own_estrato == 3

replace feeS = ${fee_mean1S} if own_estrato == 1
replace feeS = ${fee_mean2S} if own_estrato == 2
replace feeS = ${fee_mean3S} if own_estrato == 3


replace ci_lowerS = ${fee_ci_lower1S} if own_estrato == 1
replace ci_lowerS = ${fee_ci_lower2S} if own_estrato == 2
replace ci_lowerS = ${fee_ci_lower3S} if own_estrato == 3

replace ci_upperS = ${fee_ci_upper1S} if own_estrato == 1
replace ci_upperS = ${fee_ci_upper2S} if own_estrato == 2
replace ci_upperS = ${fee_ci_upper3S} if own_estrato == 3

label define estrato_lab 1 "Low" 2 "Middle" 3 "High"
label values own_estrato estrato_lab

twoway (bar feeS xpos, barwidth(0.5) fcolor(gs10) lcolor(gs4)) ///
       (rcap ci_upperS ci_lowerS xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(1500(100)2200, angle(0) format(%9.0f) grid gmax gmin) ///
       ytitle("Fee (in Dollars)") ///
       xtitle("") ///
       title("Program Fees by SES") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(fee_by_ses, replace)
       
graph export "${fpath}fee_by_ses.png", replace
