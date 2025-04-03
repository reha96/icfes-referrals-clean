/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 01.04.2025
    Description: figure connections and classes together
*******************************************************************************/

global lowSES "255 99 132"    // Pink/red for low SES
global medSES "54 162 235"    // Blue for medium SES
global highSES "75 192 112"   // Green for high SES
global reading "130 202 157" 
global math "136 132 216"
global path "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently


use "dataset_z.dta",clear
sort own_id other_id
bysort own_id: gen counter = _n
bysort own_id: egen connections = max(counter)
replace connections = connections/2
keep if counter == 1

collapse (mean) connections (sd) sd_conn=connections (count) n=connections (semean) se=connections, by(own_estrato)

forvalues i = 1/3 {
    global conn_mean`i' = connections[`i']
    global conn_sd`i' = sd_conn[`i']
    global conn_n`i' = n[`i']
    global conn_se`i' = se[`i']
    global conn_ci_lower`i' = connections[`i'] - 1.96*se[`i']
    global conn_ci_upper`i' = connections[`i'] + 1.96*se[`i']
}

clear
set obs 3
gen own_estrato = _n
gen xpos = _n

gen connections = .
gen se = .
gen ci_lower = .
gen ci_upper = .

replace connections = ${conn_mean1} if own_estrato == 1
replace connections = ${conn_mean2} if own_estrato == 2
replace connections = ${conn_mean3} if own_estrato == 3

replace se = ${conn_se1} if own_estrato == 1
replace se = ${conn_se2} if own_estrato == 2
replace se = ${conn_se3} if own_estrato == 3

replace ci_lower = ${conn_ci_lower1} if own_estrato == 1
replace ci_lower = ${conn_ci_lower2} if own_estrato == 2
replace ci_lower = ${conn_ci_lower3} if own_estrato == 3

replace ci_upper = ${conn_ci_upper1} if own_estrato == 1
replace ci_upper = ${conn_ci_upper2} if own_estrato == 2
replace ci_upper = ${conn_ci_upper3} if own_estrato == 3

label define estrato_lab 1 "Low" 2 "Middle" 3 "High"
label values own_estrato estrato_lab

twoway (bar connections xpos, barwidth(0.7) color("${lowSES}")) ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High", noticks) ///
       ylabel(0(50)250, angle(0) format(%9.0f) grid gmin gmax) ///
       ytitle("Connections") ///
       xtitle("") ///
       title("Network Connections by SES") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(connections_by_ses, replace)
       
graph export "${path}connections_by_ses.png", replace
