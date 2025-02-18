/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 05.02.2025
    Description: descriptives
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

// use sender receiver data here
use "dataset_z.dta"
describe *
gsort own_id other_id

bysort  own_id : gen counter =_n
by own_id : egen size = max(counter)

gen own_low_ses = own_estrato == 1


//# TABLE Sample descriptives
preserve 
keep if counter==1
foreach v of varlist tie own_age own_female own_low_ses z_own* size {
    display _newline
    display as text "=== Test for `v' ===" _newline
    
    // summarize
    summarize `v', det
    local min = r(min)
    local max = r(max)
	global exp_`v'_mean = r(mean)
    global exp_`v'_sd = r(sd)
    
	// test
    if `min' == 0 & `max' == 1 {
        prtest `v', by(treat)
    }
    else {
        ttest `v', by(treat) unequal
    }
}
clear all
restore 

//# TABLE Selection into the experiment descriptives
gen other_low_ses = other_estrato == 1

preserve 
bysort  other_id : gen counter2 =_n
keep if counter2 == 1
drop own* z_own*
rename other_low_ses own_low_ses
rename other_age own_age
rename other_female own_female
rename z_other_gpa z_own_gpa
rename z_other_score_math z_own_score_math
rename z_other_score_reading z_own_score_reading

foreach v of varlist own_age own_female own_low_ses z_own*	 {
    display _newline

    // summarize
    summarize `v', det
	global admin_`v'_mean = r(mean)
    global admin_`v'_sd = r(sd)
   
    // Now we can test using stored values
    if inlist("`v'", "own_female", "own_low_ses") {
        prtesti 4417 ${admin_`v'_mean} 734 ${exp_`v'_mean}
    }
    else {
        ttesti 4417 ${admin_`v'_mean} ${admin_`v'_sd} 734 ${exp_`v'_mean} ${exp_`v'_sd}, unequal
    }
}
restore 


//# TABLE non-referred choice set VS referred
preserve 
keep if area==1 // verbal
foreach v of varlist tie other_age other_female other_low_ses z_other* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
//     ttest `v', by(treat) unequal
}
restore

preserve 
keep if area==2 // math
foreach v of varlist tie other_age other_female other_low_ses z_other* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
// 	ttest `v', by(treat) unequal
// 	tabstat `v' if nomination == 1, stat(mean sd n)

}
restore




// preserve 
// keep if area==1 // verbal
// foreach v of varlist tie* {
//     display _newline
//     display as text "=== T-test for `v' ===" _newline
// //     ttest `v', by(nomination) unequal
// 	ttest `v' if nomination == 1, by(treat) unequal
// // 	tabstat `v' if nomination == 1, stat(mean sd n)
//
// }
// restore
//
// preserve 
// keep if area==2 // math
// foreach v of varlist tie* {
//     display _newline
//     display as text "=== T-test for `v' ===" _newline
// //     ttest `v', by(nomination) unequal
// 	ttest `v' if nomination == 1, by(treat) unequal
// // 	tabstat `v' if nomination == 1, stat(mean sd n)
//
// }
// restore

//# TABLE non-referred choice set VS referred by SES
preserve
keep if area == 1 & treat == 1
// low
tab other_estrato if nomination == 1 & own_estrato == 1
tab other_estrato if  own_estrato == 1
// med
tab other_estrato if nomination == 1 & own_estrato == 2
tab other_estrato if  own_estrato == 2
// high
tab other_estrato if nomination == 1 & own_estrato == 3
tab other_estrato if  own_estrato == 3
restore

preserve
keep if area == 1 & treat == 2
// low
tab other_estrato if nomination == 1 & own_estrato == 1
tab other_estrato if  own_estrato == 1
// med
tab other_estrato if nomination == 1 & own_estrato == 2
tab other_estrato if  own_estrato == 2
// high
tab other_estrato if nomination == 1 & own_estrato == 3
tab other_estrato if  own_estrato == 3
restore

preserve
keep if area == 2 & treat == 1
// low
tab other_estrato if nomination == 1 & own_estrato == 1
tab other_estrato if  own_estrato == 1
// med
tab other_estrato if nomination == 1 & own_estrato == 2
tab other_estrato if  own_estrato == 2
// high
tab other_estrato if nomination == 1 & own_estrato == 3
tab other_estrato if  own_estrato == 3
restore

preserve
keep if area == 2 & treat == 2
// low
tab other_estrato if nomination == 1 & own_estrato == 1
tab other_estrato if  own_estrato == 1
// med
tab other_estrato if nomination == 1 & own_estrato == 2
tab other_estrato if  own_estrato == 2
// high
tab other_estrato if nomination == 1 & own_estrato == 3
tab other_estrato if  own_estrato == 3
restore


//////////// PAST

tabstat other_estrato   if nomination == 1 & own_estrato == 1 & treat == 2, stat(mean sd n)
// ttest other_estrato if own_estrato == 1 & treat == 2, by(nomination) unequal // extra bonus lowers mean strata --> more bias


tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 1, stat(mean sd n)
// ttest other_estrato if own_estrato == 2  & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 2, stat(mean sd n)
// ttest other_estrato if own_estrato == 2  & treat == 2, by(nomination) unequal // treatment randomization issue??


tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 1, stat(mean sd n)
// ttest other_estrato if own_estrato == 3 & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 2, stat(mean sd n)
// ttest other_estrato if own_estrato == 3 & treat == 2, by(nomination) unequal // extra bonus adds noise

restore

ttest tie if nomination == 1  & area == 1, by(treat) unequal
ttest tie_math if  nomination == 1  & area == 1, 	by(treat) unequal
ttest tie_spanish if  nomination == 1  & area == 1,  by(treat) unequal



keep if area==2 // math

tabstat tie*  if nomination == 1, stat(mean sd)
// hist tie if nomination == 1, percent bin(10
tabstat tie* if nomination == 0, stat(mean sd)

// descriptive table


foreach v of varlist tie* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
// 	hist `v', $graph_opts percent bin(10) by(nomination) name(`v', replace)
}

describe *

foreach v of varlist z_other* {
    display _newline
    display as text "=== T-test for `v' ===" _newline
    ttest `v', by(nomination) unequal
	hist `v', $graph_opts percent bin(10) by(nomination) name(`v', replace)
}

tabstat other_estrato   if nomination == 1 & own_estrato == 1 & treat == 1, stat(mean sd n)
ttest other_estrato if own_estrato == 1 & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 1 & treat == 2, stat(mean sd n)
ttest other_estrato if own_estrato == 1 & treat == 2, by(nomination) unequal // extra bonus lowers mean strata --> more bias


tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 1, stat(mean sd n)
ttest other_estrato if own_estrato == 2  & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 2  & treat == 2, stat(mean sd n)
ttest other_estrato if own_estrato == 2  & treat == 2, by(nomination) unequal // treatment randomization issue??


tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 1, stat(mean sd n)
ttest other_estrato if own_estrato == 3 & treat == 1, by(nomination) unequal

tabstat other_estrato   if nomination == 1 & own_estrato == 3 & treat == 2, stat(mean sd n)
ttest other_estrato if own_estrato == 3 & treat == 2, by(nomination) unequal // extra bonus adds noise

