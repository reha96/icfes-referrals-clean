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
keep if nomination
corr other_gpa other_score_reading other_score_math // low-correlation with other even for those who were referred
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
    eststo `i': reg other_score_`i' i.own_estrato mean_other_score_`i' sd_other_score_`i'
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



// is there in performance homophily (high performance - high performance) > significant but meaningless compared to the effect of network
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	keep if nomination == 1
	gen own_gpa_norm = (own_gpa / 5) * 100
    eststo `i': reg other_score_`i' own_score_`i' mean_other_score_`i' sd_other_score_`i'
	eststo `i'_gpa: reg other_score_`i' own_score_`i' own_gpa_norm mean_other_score_`i' sd_other_score_`i'
    restore
}
cls
esttab reading*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 


// who has better network? > controlling for own scores, for every level of z-tie that matters, higher SES have better networks on average!
eststo clear
forvalues x = 0/4	{
	foreach i in math reading {
		preserve
		use "`i'.dta", clear
		
			keep if z_tie >= `x'  & nomination

		eststo `i'_tie`x': reghdfe mean_other_score_`i' own_score_`i' i.own_estrato, group(own_id) vce(cluster own_id)		
		restore
		}
	} 
cls
esttab reading*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
