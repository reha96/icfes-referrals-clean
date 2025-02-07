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
use "dataset_reha.dta"
describe *
gsort other_id

keep if own_id == 3856
keep if _n == 1

foreach v in gpa score_reading score_math {
	replace own_`v' = other_`v'
}
replace other_id = own_id

save "oneobs.dta", replace
merge 1:m other_id using "dataset_reha.dta" // 1 observation added (own_id == 3856)
rm "oneobs.dta"

// keep first unique occurrence of referred (use to have complete pool)
bysort  other_id : gen counter =_n
keep if counter == 1
keep other*

// standardize 
foreach v of varlist other_gpa other_score_reading other_score_math {
	sum `v'
	global `v'_mean = r(mean)
	global `v'_std = r(sd)
	gen z_`v' = (`v' - $`v'_mean)/$`v'_std
}

keep other_id z*
save "std.dta", replace

clear all
use "dataset_reha.dta"
bysort  own_id : gen counter =_n
keep if counter == 1
keep own* treat tie
rename own_id other_id
merge 1:1 other_id using "std.dta" // own scores are standardized 
drop _merge
rename other_id own_id 
rename z_other_gpa z_own_gpa
rename z_other_score_math z_own_score_math
rename z_other_score_reading z_own_score_reading

// check if all good
sum z_own_gpa z_own_score_math z_own_score_reading, det
corr own_gpa z_own_gpa own_score_math z_own_score_math own_score_reading z_own_score_reading

// descriptives of nominators/referrers
foreach v of varlist tie own_age own_female own_estrato z_own* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
	ttest `v' if own_female != ., by(treat) unequal
}

// save 4418 participant's std scores
keep own_id z*
save "own.dta", replace

// merge with own score
use "dataset_reha.dta"
merge m:1 own_id using "own.dta" // own scores are standardized 
drop _merge
save "dataset_z.dta", replace

// merge with others' score
use "dataset_z.dta"
merge m:1 other_id using "std.dta" // own scores are standardized 
drop if other_id == 3856 // extra individual added before needs removal
drop _merge

// labels
label variable z_own_gpa "Own GPA (z-score)"
label variable z_own_score_reading "Own Reading Score (z-score)"  
label variable z_own_score_math "Own Math Score (z-score)"
label variable z_other_gpa "Other GPA (z-score)"
label variable z_other_score_reading "Other Reading Score (z-score)"
label variable z_other_score_math "Other Math Score (z-score)"

save "dataset_z.dta", replace
rm "own.dta" 
rm "std.dta"

