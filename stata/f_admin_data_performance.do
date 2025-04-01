/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure admin performance by SES
*******************************************************************************/

global lowSES "255 99 132"
global medSES "54 162 235"
global highSES "75 192 112"
global reading "130 202 157" 
global math "136 132 216"
global path "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

clear all
foreach ses in low middle high {
    foreach type in math reading {
        global `type'_admin_`ses' = ""
        global `type'_admin_`ses'_sd = ""
        global `type'_admin_`ses'_n = ""
            }
}

// Load data and calculate statistics
foreach i in score_math score_reading {
    local type = cond("`i'"=="score_math", "math", "reading")
    
    // Admin data
    use "dataset_z.dta", clear
    bysort other_id: gen counter = _n
    keep if counter == 1
    
    foreach ses in 1 2 3 {
        local ses_label = cond(`ses'==1, "low", cond(`ses'==2, "middle", "high"))
        
        preserve
        keep if own_estrato == `ses'
        
        tabstat other_`i', stat(n mean sd) save
        matrix stats = r(StatTotal)
        
        global `type'_admin_`ses_label'_n = stats[1,1]
        global `type'_admin_`ses_label' = stats[2,1]
        global `type'_admin_`ses_label'_sd = stats[3,1]
        
        restore
    }
}

// Create Admin Performance graph
preserve
clear
set obs 6

gen ses = ceil(_n/2)
gen subject = mod(_n-1, 2) + 1

gen xpos = .
replace xpos = 1 if ses == 1 & subject == 2     // Low SES, Reading (first)
replace xpos = 1.5 if ses == 1 & subject == 1   // Low SES, Math (second)
replace xpos = 2.5 if ses == 2 & subject == 2   // Middle SES, Reading
replace xpos = 3 if ses == 2 & subject == 1     // Middle SES, Math
replace xpos = 4 if ses == 3 & subject == 2     // High SES, Reading
replace xpos = 4.5 if ses == 3 & subject == 1   // High SES, Math

gen score = .
gen se = .

local r = 1
foreach ses in low middle high {
    foreach subj in math reading {
        local subj_num = cond("`subj'"=="math", 1, 2)
        local ses_num = cond("`ses'"=="low", 1, cond("`ses'"=="middle", 2, 3))
        
        if `r' <= 6 {
            replace score = ${`subj'_admin_`ses'} if ses==`ses_num' & subject==`subj_num'
            replace se = ${`subj'_admin_`ses'_sd}/sqrt(${`subj'_admin_`ses'_n}) if ses==`ses_num' & subject==`subj_num'
        }
        local r = `r' + 1
    }
}

gen ci_lower = score - 1.96*se
gen ci_upper = score + 1.96*se

twoway (bar score xpos if subject==2, barw(0.45) color("130 202 157")) ///  // Reading (first)
       (bar score xpos if subject==1, barw(0.45) color("136 132 216")) ///  // Math (second)
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(1.25 "Low" 2.75 "Middle" 4.25 "High") ///
       ylabel(50(5)80, angle(0)) ///
       ytitle("Score") ///
       xtitle("") ///
       title("Admin Data Performance by SES") ///
       legend(order(1 "Reading" 2 "Math") ring(0) pos(11) rows(2) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 5)) ///
       name(admin_performance, replace)

graph export "./admin_data_performance.png", replace
restore
