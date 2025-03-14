/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 04.02.2025
    Description: clean raw data
*******************************************************************************/

//# preamble
version 18
clear all
macro drop _all
set more off
set scheme s2color, permanently
set maxvar 32767
global graph_opts ///
    graphregion(fcolor(white) lcolor(white)) ///
    bgcolor(white) ///
    plotregion(lcolor(white))

// get a full dataset for standardizing
clear all
cls
use "dataset_reha.dta"
describe *
gsort other_id

// this student only appears in other_id
keep if own_id == 3856
keep if _n == 1

foreach v in gpa score_reading score_math {
	replace own_`v' = other_`v' // rewrite scores 
}
replace other_id = own_id // rewrite id 

save "oneobs.dta", replace
merge 1:m other_id using "dataset_reha.dta" // 1 observation added (own_id == 3856)
rm "oneobs.dta"

// keep first unique occurrence of referred (use to have complete pool)
bysort  other_id : gen counter =_n
keep if counter == 1
keep other*

foreach v of varlist other_gpa other_score_math other_score_reading {
	xtile decile_`v' = `v', nq(10) 
	gen top_`v' = decile_`v' == 10
}

sum top*,det
desc top*, varlist

// this is for other id
keep other_id top*
save "std.dta", replace

clear all
use "dataset_reha.dta"
merge m:1 other_id using "std.dta" // merge top other
drop if other_id == 3856 // extra individual added before needs removal
drop _merge
sort own_id
save "dataset_z.dta", replace

// same 
clear all
use "std.dta", replace
foreach v in gpa score_reading score_math {
	rename top_other_`v' top_own_`v' // rename all
}
rename other_id own_id
keep own_id top_own*
save "std.dta", replace

clear all
use "dataset_z.dta"
bysort  own_id : gen counter =_n
keep if counter == 1
merge 1:1 own_id using "std.dta" // merge top other
keep if tie != . // remove leftover data
drop _merge

clear all
use "dataset_z.dta"
merge m:1 own_id using "std.dta" // merge top own
drop if _merge == 2
drop _merge

save "dataset_z.dta", replace
rm "std.dta"

cls
clear all
use "dataset_z.dta"
// about 23 pcent of referrers are top decile in at least one area 
 tab top_own_score_reading top_own_score_math
bysort  own_id : gen counter =_n
bysort  other_id : gen counter2 =_n

tabstat  top_own_score_reading top_own_score_math if counter == 1 , stat(n mean  semean sd)
tabstat  top_other_score_reading top_other_score_math, stat(n mean  semean sd)
tabstat  top_other_score_reading if area == 1 & nomination, stat(n mean  semean sd)
tabstat  top_other_score_math if area == 2 & nomination, stat(n mean  semean sd)


// Define variables for sample data
global sample_n = 734
global sample_read_mean = 0.1376022
global sample_read_sd = 0.3447169
global sample_math_mean = 0.1294278
global sample_math_sd = 0.3359017

// Define variables for network data
global network_n = 256997
global network_read_mean = 0.0980401
global network_read_sd = 0.2973694
global network_math_mean = 0.092931
global network_math_sd = 0.2903363

// Define variables for referrals data
global referrals_read_n = 673
global referrals_read_mean = 0.1931649
global referrals_read_sd = 0.3950749
global referrals_math_n = 669
global referrals_math_mean = 0.2212257
global referrals_math_sd = 0.4153827

// Run the 6 proportion tests
// 1. Sample vs. Network for Reading
prtesti ${sample_n} ${sample_read_mean} ${network_n} ${network_read_mean}

// 2. Sample vs. Referrals for Reading
prtesti ${sample_n} ${sample_read_mean} ${referrals_read_n} ${referrals_read_mean}

// 3. Network vs. Referrals for Reading
prtesti ${network_n} ${network_read_mean} ${referrals_read_n} ${referrals_read_mean}

// 4. Sample vs. Network for Math
prtesti ${sample_n} ${sample_math_mean} ${network_n} ${network_math_mean}

// 5. Sample vs. Referrals for Math
prtesti ${sample_n} ${sample_math_mean} ${referrals_math_n} ${referrals_math_mean}

// 6. Network vs. Referrals for Math
prtesti ${network_n} ${network_math_mean} ${referrals_math_n} ${referrals_math_mean}

// Create a dataset for visualization with consistent bar spacing
preserve
clear
set obs 6
// Create systematic data structure
gen id = _n
gen group = .
gen subject = .
gen xpos = .
gen pct_top = .  // Will now store percentage values (0-100)
gen se = .       // Will now store percentage-scale standard errors
// Define group names, values, and sample sizes
local group_names `""Sample" "Network" "Referrals""'
local group_n "734 256997 671"
// Define subject names and corresponding values
local subj_names `""Reading" "Math""'
// Reading values for each group (converted to percentages)
local read_vals "13.76022 9.80401 19.31649"
local read_se "1.27237 0.05866 1.5229"
// Math values for each group (converted to percentages)
local math_vals "12.94278 9.2931 22.12257"
local math_se "1.23984 0.05727 1.60596"
// Fill in data systematically using loops with consistent spacing
local row = 1
forvalues g = 1/3 {
    forvalues s = 1/2 {
        // Set group and subject
        replace group = `g' if id == `row'
        replace subject = `s' if id == `row'
        
        // Use the same spacing pattern as your SES graph
        // Calculate base position for each group
        local base_pos = (`g'-1)*1.5 + 1
        
        // Set x-position with same spacing pattern (subject 1 = Math, subject 2 = Reading)
        if `s' == 1 {  // Math (second position)
            replace xpos = `base_pos' + 0.5 if id == `row'
        }
        else {  // Reading (first position)
            replace xpos = `base_pos' if id == `row'
        }
        
        // Set values based on subject
        if `s' == 1 { // Math
            local val_index = `g'
            local val : word `val_index' of `math_vals'
            local se_val : word `val_index' of `math_se'
            replace pct_top = `val' if id == `row'
            replace se = `se_val' if id == `row'
        }
        else { // Reading
            local val_index = `g'
            local val : word `val_index' of `read_vals'
            local se_val : word `val_index' of `read_se'
            replace pct_top = `val' if id == `row'
            replace se = `se_val' if id == `row'
        }
        
        local row = `row' + 1
    }
}
// Calculate confidence intervals (using percentage scale)
gen ci_lower = pct_top - 1.96*se
gen ci_upper = pct_top + 1.96*se
// List the data to verify it's correctly set up
list, clean
// Set up plotting commands systematically with consistent order
local bar_cmds ""
// Add Reading bars first (subject==2)
forvalues g = 1/3 {
    local bar_cmds `"`bar_cmds' (bar pct_top xpos if group==`g' & subject==2, barw(0.45) color("130 202 157"))"'
}
// Add Math bars second (subject==1)
forvalues g = 1/3 {
    local bar_cmds `"`bar_cmds' (bar pct_top xpos if group==`g' & subject==1, barw(0.45) color("136 132 216"))"'
}
// Create x-axis labels with consistent spacing
local xlabel ""
forvalues g = 1/3 {
    local base_pos = (`g'-1)*1.5 + 1
    local pos = `base_pos' + 0.25
    local name : word `g' of `group_names'
    local xlabel `"`xlabel' `pos' "`name'""'
}
// Create the graph using the systematically generated commands
twoway `bar_cmds' ///
       (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
       , ///
       xlabel(`xlabel', labsize(medium)) ///
       ylabel(0(5)25, angle(0) ) ///  // Changed to 0-30 by 5
       ytitle("Percent") ///         // Changed to "Percent"
       xtitle("") ///
       title("Top Decile Share") ///
       legend(order(1 "Reading" 4 "Math") ring(0) pos(11) rows(2) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 4.5)) ///
       name(top_decile_comparison, replace)
// Export the graph with fixed dimensions
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/top_decile_comparison.png", replace
restore
