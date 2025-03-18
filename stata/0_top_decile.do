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
