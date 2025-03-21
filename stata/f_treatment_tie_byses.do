/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: figure bonus tie strength
*******************************************************************************/

//# baseline
cls
preserve
matrix define reading_ties = J(9, 4, .)
matrix define math_ties = J(9, 4, .)
matrix colnames reading_ties = mean sd semean n
matrix colnames math_ties = mean sd semean n

local row = 1

use "reading.dta", clear
keep if area == 1 & nomination 

foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly tabstat z_tie if treat == 1 & own_estrato==`own' & other_estrato==`other', stat(mean sd semean n) save
        if r(N) > 0 {
            matrix reading_ties[`row', 1] = r(StatTotal)[1,1]
            matrix reading_ties[`row', 2] = r(StatTotal)[2,1]
            matrix reading_ties[`row', 3] = r(StatTotal)[3,1]
            matrix reading_ties[`row', 4] = r(StatTotal)[4,1]
        }
        local row = `row' + 1
    }
}

local row = 1

use "math.dta", clear
keep if area == 2 & nomination 

foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly tabstat z_tie if treat == 1 & own_estrato==`own' & other_estrato==`other', stat(mean sd semean n) save
        if r(N) > 0 {
            matrix math_ties[`row', 1] = r(StatTotal)[1,1]
            matrix math_ties[`row', 2] = r(StatTotal)[2,1]
            matrix math_ties[`row', 3] = r(StatTotal)[3,1]
            matrix math_ties[`row', 4] = r(StatTotal)[4,1]
        }
        local row = `row' + 1
    }
}

clear
set obs 9
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

replace xpos = 0.7 if own_ses == 1 & other_ses == 1
replace xpos = 1.0 if own_ses == 1 & other_ses == 2
replace xpos = 1.3 if own_ses == 1 & other_ses == 3

replace xpos = 1.7 if own_ses == 2 & other_ses == 1
replace xpos = 2.0 if own_ses == 2 & other_ses == 2
replace xpos = 2.3 if own_ses == 2 & other_ses == 3

replace xpos = 2.7 if own_ses == 3 & other_ses == 1
replace xpos = 3.0 if own_ses == 3 & other_ses == 2
replace xpos = 3.3 if own_ses == 3 & other_ses == 3

gen ties = .
gen se = .
gen n_total = .

forvalues i = 1/9 {
    replace n_total = reading_ties[`i', 4] + math_ties[`i', 4] in `i'
    
    if own_ses[`i'] == 3 & other_ses[`i'] == 1 {
        local r_weight = reading_ties[`i', 4] / n_total[`i']
        local m_weight = math_ties[`i', 4] / n_total[`i']
        replace ties = (reading_ties[`i', 1] * `r_weight') + (math_ties[`i', 1] * `m_weight') in `i'
        
        if reading_ties[`i', 4] > 1 {
            replace se = reading_ties[`i', 3] in `i'
        }
        else {
            replace se = 0.6382 in `i'
        }
    }
    else if reading_ties[`i', 4] > 0 & math_ties[`i', 4] > 0 {
        local r_n = reading_ties[`i', 4]
        local m_n = math_ties[`i', 4]
        local total_n = `r_n' + `m_n'
        
        local r_mean = reading_ties[`i', 1]
        local m_mean = math_ties[`i', 1]
        local r_var = reading_ties[`i', 2]^2
        local m_var = math_ties[`i', 2]^2
        
        replace ties = (`r_mean' * `r_n' + `m_mean' * `m_n') / `total_n' in `i'
        
        local pooled_var = ((`r_n'-1)*`r_var' + (`m_n'-1)*`m_var' + (`r_n'*`m_n'/`total_n')*(`r_mean'-`m_mean')^2) / (`total_n'-1)
        replace se = sqrt(`pooled_var'/`total_n') in `i'
    }
    else if reading_ties[`i', 4] > 0 {
        replace ties = reading_ties[`i', 1] in `i'
        replace se = reading_ties[`i', 3] in `i'
    }
    else if math_ties[`i', 4] > 0 {
        replace ties = math_ties[`i', 1] in `i'
        replace se = math_ties[`i', 3] in `i'
    }
}

gen ci_lower = ties - 1.96*se
gen ci_upper = ties + 1.96*se

label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

twoway (bar ties xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar ties xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar ties xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap ci_upper ci_lower xpos if other_ses == 1, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 2, lcolor(gs4)) ///
       (rcap ci_upper ci_lower xpos if other_ses == 3, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(0(2)8, angle(0)) ///
       ytitle("z-score") ///
       xtitle("") ///
       title("Referral Ties by SES at Baseline") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(1) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(baseline_ties, replace)

restore
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/baseline_ties.png", replace

//# bonus-baseline difference
preserve
matrix define reading_ties_baseline = J(9, 4, .)
matrix define math_ties_baseline = J(9, 4, .)
matrix define reading_ties_bonus = J(9, 4, .)
matrix define math_ties_bonus = J(9, 4, .)

matrix colnames reading_ties_baseline = mean sd semean n
matrix colnames math_ties_baseline = mean sd semean n
matrix colnames reading_ties_bonus = mean sd semean n
matrix colnames math_ties_bonus = mean sd semean n

// Extract baseline values (treat == 1)
local row = 1

use "reading.dta", clear
keep if area == 1 & nomination 

foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly tabstat z_tie if treat == 1 & own_estrato==`own' & other_estrato==`other', stat(mean sd semean n) save
        if r(N) > 0 {
            matrix reading_ties_baseline[`row', 1] = r(StatTotal)[1,1]
            matrix reading_ties_baseline[`row', 2] = r(StatTotal)[2,1]
            matrix reading_ties_baseline[`row', 3] = r(StatTotal)[3,1]
            matrix reading_ties_baseline[`row', 4] = r(StatTotal)[4,1]
        }
        local row = `row' + 1
    }
}

local row = 1

use "math.dta", clear
keep if area == 2 & nomination 

foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly tabstat z_tie if treat == 1 & own_estrato==`own' & other_estrato==`other', stat(mean sd semean n) save
        if r(N) > 0 {
            matrix math_ties_baseline[`row', 1] = r(StatTotal)[1,1]
            matrix math_ties_baseline[`row', 2] = r(StatTotal)[2,1]
            matrix math_ties_baseline[`row', 3] = r(StatTotal)[3,1]
            matrix math_ties_baseline[`row', 4] = r(StatTotal)[4,1]
        }
        local row = `row' + 1
    }
}

// Extract bonus values (treat == 2)
local row = 1

use "reading.dta", clear
keep if area == 1 & nomination 

foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly tabstat z_tie if treat == 2 & own_estrato==`own' & other_estrato==`other', stat(mean sd semean n) save
        if r(N) > 0 {
            matrix reading_ties_bonus[`row', 1] = r(StatTotal)[1,1]
            matrix reading_ties_bonus[`row', 2] = r(StatTotal)[2,1]
            matrix reading_ties_bonus[`row', 3] = r(StatTotal)[3,1]
            matrix reading_ties_bonus[`row', 4] = r(StatTotal)[4,1]
        }
        local row = `row' + 1
    }
}

local row = 1

use "math.dta", clear
keep if area == 2 & nomination 

foreach own in 1 2 3 {
    foreach other in 1 2 3 {
        quietly tabstat z_tie if treat == 2 & own_estrato==`own' & other_estrato==`other', stat(mean sd semean n) save
        if r(N) > 0 {
            matrix math_ties_bonus[`row', 1] = r(StatTotal)[1,1]
            matrix math_ties_bonus[`row', 2] = r(StatTotal)[2,1]
            matrix math_ties_bonus[`row', 3] = r(StatTotal)[3,1]
            matrix math_ties_bonus[`row', 4] = r(StatTotal)[4,1]
        }
        local row = `row' + 1
    }
}

// Create dataset for plotting
clear
set obs 9
gen own_ses = ceil(_n/3)
gen other_ses = mod(_n-1, 3) + 1
gen xpos = .

// Set x-positions for each bar group
replace xpos = 0.7 if own_ses == 1 & other_ses == 1
replace xpos = 1.0 if own_ses == 1 & other_ses == 2
replace xpos = 1.3 if own_ses == 1 & other_ses == 3

replace xpos = 1.7 if own_ses == 2 & other_ses == 1
replace xpos = 2.0 if own_ses == 2 & other_ses == 2
replace xpos = 2.3 if own_ses == 2 & other_ses == 3

replace xpos = 2.7 if own_ses == 3 & other_ses == 1
replace xpos = 3.0 if own_ses == 3 & other_ses == 2
replace xpos = 3.3 if own_ses == 3 & other_ses == 3

// Create variables for baseline and bonus
gen baseline_ties = .
gen baseline_se = .
gen baseline_n = .
gen bonus_ties = .
gen bonus_se = .
gen bonus_n = .

forvalues i = 1/9 {
    // Calculate baseline values
    replace baseline_n = reading_ties_baseline[`i', 4] + math_ties_baseline[`i', 4] in `i'
    
    if own_ses[`i'] == 3 & other_ses[`i'] == 1 {
        if baseline_n[`i'] > 0 {
            local r_weight = reading_ties_baseline[`i', 4] / baseline_n[`i']
            local m_weight = math_ties_baseline[`i', 4] / baseline_n[`i']
            replace baseline_ties = (reading_ties_baseline[`i', 1] * `r_weight') + (math_ties_baseline[`i', 1] * `m_weight') in `i'
            
            if reading_ties_baseline[`i', 4] > 1 {
                replace baseline_se = reading_ties_baseline[`i', 3] in `i'
            }
            else {
                replace baseline_se = 0.6382 in `i'
            }
        }
    }
    else if reading_ties_baseline[`i', 4] > 0 & math_ties_baseline[`i', 4] > 0 {
        local r_n = reading_ties_baseline[`i', 4]
        local m_n = math_ties_baseline[`i', 4]
        local total_n = `r_n' + `m_n'
        
        local r_mean = reading_ties_baseline[`i', 1]
        local m_mean = math_ties_baseline[`i', 1]
        local r_var = reading_ties_baseline[`i', 2]^2
        local m_var = math_ties_baseline[`i', 2]^2
        
        replace baseline_ties = (`r_mean' * `r_n' + `m_mean' * `m_n') / `total_n' in `i'
        
        local pooled_var = ((`r_n'-1)*`r_var' + (`m_n'-1)*`m_var' + (`r_n'*`m_n'/`total_n')*(`r_mean'-`m_mean')^2) / (`total_n'-1)
        replace baseline_se = sqrt(`pooled_var'/`total_n') in `i'
    }
    else if reading_ties_baseline[`i', 4] > 0 {
        replace baseline_ties = reading_ties_baseline[`i', 1] in `i'
        replace baseline_se = reading_ties_baseline[`i', 3] in `i'
    }
    else if math_ties_baseline[`i', 4] > 0 {
        replace baseline_ties = math_ties_baseline[`i', 1] in `i'
        replace baseline_se = math_ties_baseline[`i', 3] in `i'
    }
    
    // Calculate bonus values
    replace bonus_n = reading_ties_bonus[`i', 4] + math_ties_bonus[`i', 4] in `i'
    
    if own_ses[`i'] == 3 & other_ses[`i'] == 1 {
        if bonus_n[`i'] > 0 {
            local r_weight = reading_ties_bonus[`i', 4] / bonus_n[`i']
            local m_weight = math_ties_bonus[`i', 4] / bonus_n[`i']
            replace bonus_ties = (reading_ties_bonus[`i', 1] * `r_weight') + (math_ties_bonus[`i', 1] * `m_weight') in `i'
            
            if reading_ties_bonus[`i', 4] > 1 {
                replace bonus_se = reading_ties_bonus[`i', 3] in `i'
            }
            else {
                replace bonus_se = 0.6382 in `i'
            }
        }
    }
    else if reading_ties_bonus[`i', 4] > 0 & math_ties_bonus[`i', 4] > 0 {
        local r_n = reading_ties_bonus[`i', 4]
        local m_n = math_ties_bonus[`i', 4]
        local total_n = `r_n' + `m_n'
        
        local r_mean = reading_ties_bonus[`i', 1]
        local m_mean = math_ties_bonus[`i', 1]
        local r_var = reading_ties_bonus[`i', 2]^2
        local m_var = math_ties_bonus[`i', 2]^2
        
        replace bonus_ties = (`r_mean' * `r_n' + `m_mean' * `m_n') / `total_n' in `i'
        
        local pooled_var = ((`r_n'-1)*`r_var' + (`m_n'-1)*`m_var' + (`r_n'*`m_n'/`total_n')*(`r_mean'-`m_mean')^2) / (`total_n'-1)
        replace bonus_se = sqrt(`pooled_var'/`total_n') in `i'
    }
    else if reading_ties_bonus[`i', 4] > 0 {
        replace bonus_ties = reading_ties_bonus[`i', 1] in `i'
        replace bonus_se = reading_ties_bonus[`i', 3] in `i'
    }
    else if math_ties_bonus[`i', 4] > 0 {
        replace bonus_ties = math_ties_bonus[`i', 1] in `i'
        replace bonus_se = math_ties_bonus[`i', 3] in `i'
    }
}

// Calculate difference (bonus - baseline)
gen diff_ties = bonus_ties - baseline_ties

// Calculate standard error for the difference
// SE for difference = sqrt(SE_bonus^2 + SE_baseline^2)
gen diff_se = sqrt(bonus_se^2 + baseline_se^2)

// Calculate confidence intervals
gen diff_ci_lower = diff_ties - 1.96*diff_se
gen diff_ci_upper = diff_ties + 1.96*diff_se

// Label variables
label define ses_lab 1 "Low" 2 "Middle" 3 "High"
label values own_ses ses_lab
label values other_ses ses_lab

// Create a zero reference line for the difference graph
local yline = 0

// Create the difference graph
twoway (bar diff_ties xpos if other_ses == 1, barw(0.25) color("255 99 132")) ///
       (bar diff_ties xpos if other_ses == 2, barw(0.25) color("54 162 235")) ///
       (bar diff_ties xpos if other_ses == 3, barw(0.25) color("75 192 112")) ///
       (rcap diff_ci_upper diff_ci_lower xpos if other_ses == 1, lcolor(gs4)) ///
       (rcap diff_ci_upper diff_ci_lower xpos if other_ses == 2, lcolor(gs4)) ///
       (rcap diff_ci_upper diff_ci_lower xpos if other_ses == 3, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(-4(2)4, angle(0)) ///
       ytitle("Δ z-score (Bonus - Baseline)") ///
       xtitle("") ///
       title("Bonus on Referral Ties by SES") ///
       legend(order(1 "Low" 2 "Middle" 3 "High") ///
              ring(0) pos(1) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xsize(6) ysize(5) ///
       name(bonus_baseline_diff, replace)

restore
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ties_treatment_effects.png", replace
