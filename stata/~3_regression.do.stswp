/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 18.03.2025
    Description: regression
*******************************************************************************/

//# preamble
cls
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
	


// is there a treatment effect > very small / No
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
    keep if nomination
    eststo tie_`i':reg z_tie i.treat, vce(cluster own_id)
    eststo score_`i':reg z_other_score_`i' i.treat, vce(cluster own_id)
    restore
}
cls
esttab tie_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab score_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 


// is there a SES bias > not against low-SES, yes to high-SES 
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	
	// create vars
	gen scoreXtie = z_other_score_`i' * z_tie
	gen scoreXgpa = z_other_score_`i' * z_other_gpa
	gen scoreXtieXses = scoreXtie * other_estrato

	gen gpaXtie = z_other_gpa * z_tie
	gen scoreXlses = z_other_score_`i' * other_low_ses
	gen scoreXtieXgpa = scoreXtie * z_other_gpa

	gen same_low = (other_low_ses==own_low_ses)
	gen same_med = (other_med_ses==own_med_ses)
	gen same_high = (other_high_ses==own_high_ses)

    eststo `i'_1: clogit nomination i.other_estrato, group(own_id) vce(cluster own_id)
    eststo `i'_2: clogit nomination i.other_estrato z_other_score_`i' z_tie, group(own_id) vce(cluster own_id)
	eststo `i'_3: clogit nomination i.other_estrato z_other_score_`i' z_tie scoreXtie, group(own_id) vce(cluster own_id)
    restore
}
cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

// is there a SES bias use binary low-SES > no bias for or against low-SES
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	
	// create vars
	gen scoreXtie = z_other_score_`i' * z_tie
	gen scoreXgpa = z_other_score_`i' * z_other_gpa
	gen scoreXtieXses = scoreXtie * other_estrato

	gen gpaXtie = z_other_gpa * z_tie
	gen scoreXlses = z_other_score_`i' * other_low_ses
	gen scoreXtieXgpa = scoreXtie * z_other_gpa

	gen same_low = (other_low_ses==own_low_ses)
	gen same_med = (other_med_ses==own_med_ses)
	gen same_high = (other_high_ses==own_high_ses)

    eststo `i'_1: clogit nomination i.other_low_ses, group(own_id) vce(cluster own_id)
    eststo `i'_2: clogit nomination i.other_low_ses z_other_score_`i' z_tie, group(own_id) vce(cluster own_id)
	eststo `i'_3: clogit nomination i.other_low_ses z_other_score_`i' z_tie scoreXtie, group(own_id) vce(cluster own_id)
    restore
}
cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

// does GPA predict referrals > yes, better than exam scores
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	
	// create vars
	gen scoreXtie = z_other_score_`i' * z_tie
	gen scoreXgpa = z_other_score_`i' * z_other_gpa
	gen scoreXtieXses = scoreXtie * other_estrato

	gen gpaXtie = z_other_gpa * z_tie
	gen scoreXlses = z_other_score_`i' * other_low_ses
	gen scoreXtieXgpa = scoreXtie * z_other_gpa

	gen same_low = (other_low_ses==own_low_ses)
	gen same_med = (other_med_ses==own_med_ses)
	gen same_high = (other_high_ses==own_high_ses)

    eststo `i'_1: clogit nomination z_other_gpa, group(own_id) vce(cluster own_id)
    eststo `i'_2: clogit nomination z_other_gpa z_other_score_`i' z_tie, group(own_id) vce(cluster own_id)
	eststo `i'_3: clogit nomination z_other_gpa z_other_score_`i' z_tie scoreXtie, group(own_id) vce(cluster own_id)
	eststo `i'_4: clogit nomination z_other_gpa z_other_score_`i' z_tie scoreXtie scoreXgpa gpaXtie scoreXtieXgpa, group(own_id) vce(cluster own_id)
    restore
}
cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

use "dataset_z.dta",clear
corr other_gpa other_score_reading other_score_math // low-correlation with other
clear all



// is there in group homophily (same-ses) > yes for low-SES (moderately strong evidence)
eststo clear
forvalues ses = 1/3 {
    preserve
		foreach i in math reading {
			use "`i'.dta", clear			
			keep if own_estrato == `ses'
			gen homophily = (own_estrato==other_estrato)
			eststo `i'_`ses': clogit nomination i.homophily z_other_score_`i' z_tie  z_other_gpa, group(own_id) vce(cluster own_id)		
			eststo binary_`i'_`ses': clogit nomination i.other_low_ses z_other_score_`i' z_tie  z_other_gpa, group(own_id) vce(cluster own_id)		
		}
	restore
}

cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

// is there low-SES bias in a specific SES group > yes for low-SES (positive)
cls
esttab binary_reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab binary_math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 


// are low-SES better referrers controlling for network > NO, but network average matters
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	keep if nomination == 1
    eststo `i': reg z_other_score_`i' i.own_estrato mean_other_score_`i' sd_other_score_`i'
    restore
}
cls
esttab reading*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

// are binary low-SES better referrers controlling for network > NO, but network average matters
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	keep if nomination == 1
    eststo `i': reg z_other_score_`i' i.own_low_ses mean_other_score_`i' sd_other_score_`i'
    restore
}
cls
esttab reading*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 









eststo clear
eststo r1: qui clogit nomination i.other_low_ses , group(own_id) vce(cluster own_id) or
eststo r2: qui clogit nomination i.other_low_ses  z_other_score_reading z_tie, group(own_id) vce(cluster own_id) or
eststo r3: qui clogit nomination i.other_low_ses  z_other_score_reading z_tie scoreXtie, group(own_id) vce(cluster own_id) or
eststo r4: qui clogit nomination i.other_low_ses  z_other_score_reading z_tie scoreXtie scoreXtieXses , group(own_id) vce(cluster own_id) or
// eststo r5: qui clogit nomination i.other_estrato  z_other_score_reading z_tie scoreXtie z_other_gpa scoreXgpa, group(own_id) vce(cluster own_id) or
// eststo r6: qui clogit nomination i.other_estrato  z_other_score_reading z_tie scoreXtie z_other_gpa scoreXgpa gpaXtie, group(own_id) vce(cluster own_id) or
// eststo r7: qui clogit nomination i.other_estrato  z_other_score_reading z_tie scoreXtie z_other_gpa scoreXgpa gpaXtie scoreXtieXgpa, group(own_id) vce(cluster own_id) or
restore
// math
use "math.dta", clear
preserve

gen scoreXgpa = z_other_score_reading * z_other_gpa
gen scoreXtie = z_other_score_reading * z_tie
gen scoreXtieXses = scoreXtie * other_estrato

gen gpaXtie = z_other_gpa * z_tie
gen scoreXlses = z_other_score_reading * other_low_ses
gen scoreXtieXgpa = scoreXtie * z_other_gpa

gen same_low = (other_low_ses==own_low_ses)
gen same_med = (other_med_ses==own_med_ses)
gen same_high = (other_high_ses==own_high_ses)
// is there a SES bias > NO
eststo m1: qui clogit nomination i.other_low_ses , group(own_id) vce(cluster own_id) or
eststo m2: qui clogit nomination i.other_low_ses  z_other_score_math z_tie, group(own_id) vce(cluster own_id) or
eststo m3: qui clogit nomination i.other_low_ses  z_other_score_math z_tie scoreXtie, group(own_id) vce(cluster own_id) or
eststo m4: qui clogit nomination i.other_low_ses  z_other_score_math z_tie scoreXtie scoreXtieXses , group(own_id) vce(cluster own_id) or
// eststo m5: qui clogit nomination i.other_estrato  z_other_score_math z_tie scoreXtie z_other_gpa scoreXgpa, group(own_id) vce(cluster own_id) or
// eststo m6: qui clogit nomination i.other_estrato  z_other_score_math z_tie scoreXtie z_other_gpa scoreXgpa gpaXtie, group(own_id) vce(cluster own_id) or
// eststo m7: qui clogit nomination i.other_estrato  z_other_score_math z_tie scoreXtie z_other_gpa scoreXgpa gpaXtie scoreXtieXgpa, group(own_id) vce(cluster own_id) or

restore 
// table
cls
esttab r*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab m*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 



// by SES - homophily
forvalues ses = 1/3 {
    preserve
	use "reading.dta", clear
    keep if own_estrato == `ses'
	gen same_ses = (own_estrato==other_estrato)
	eststo rSES`ses': qui clogit nomination i.same_ses  z_other_score_reading z_tie  z_other_gpa, group(own_id) vce(cluster own_id)
    restore
}

forvalues ses = 1/3 {
    preserve
	use "math.dta", clear
    keep if own_estrato == `ses'
	gen same_ses = (own_estrato==other_estrato)
	
	eststo mSES`ses': qui clogit nomination i.same_ses  z_other_score_math z_tie  z_other_gpa, group(own_id) vce(cluster own_id)
    restore
}

esttab mSES*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2)  nodep nomti label ty
esttab rSES*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2)  nodep nomti label ty



