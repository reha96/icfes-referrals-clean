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
global path = "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global graph_opts ///
    graphregion(fcolor(white) lcolor(white)) ///
    bgcolor(white) ///
    plotregion(lcolor(white))
	


// is there a treatment effect > very small / No
eststo clear
foreach i in math reading {
    preserve
    use "${path}`i'.dta", clear
    keep if nomination
    eststo tie_`i':reg z_tie i.treat, vce(cluster own_id)
    eststo score_`i':reg z_other_score_`i' i.treat, vce(cluster own_id)
    restore
}
esttab tie_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab score_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 


//# is there a SES bias > not against low-SES, yes to high-SES 
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

    eststo `i'_1: clogit nomination ib(2).other_estrato, group(own_id) vce(cluster own_id)
    eststo `i'_2: clogit nomination ib(2).other_estrato z_other_score_`i' z_tie, group(own_id) vce(cluster own_id)
	eststo `i'_3: clogit nomination ib(2).other_estrato z_other_score_`i' z_tie scoreXtie, group(own_id) vce(cluster own_id)
    restore
}
cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

//# is there a SES bias use binary low-SES > no bias for or against low-SES
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

//# does GPA predict referrals > yes, better than exam scores
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
    corr z_other_gpa z_other_score_`i'  // low-correlation with other
	restore
}
cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

//# is there by SES low-SES bias > high-SES at 10 pcent
eststo clear
forvalues ses = 1/3 {
    preserve
		foreach i in math reading {
			use "`i'.dta", clear			
			keep if own_estrato == `ses'
		//  gen homophily = (own_estrato==other_estrato)
			gen scoreXtie = z_other_score_`i' * z_tie
			eststo `i'_`ses': clogit nomination ib(2).other_estrato z_other_score_`i' z_tie  scoreXtie, group(own_id) vce(cluster own_id)		
 			eststo binary_`i'_`ses': clogit nomination i.other_low_ses z_other_score_`i' z_tie   scoreXtie, group(own_id) vce(cluster own_id)		
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

//# is there by low-SES vs other low-SES bias ?
eststo clear
forvalues ses = 0/1 {
    preserve
		foreach i in math reading {
			use "`i'.dta", clear			
			keep if own_low_ses == `ses'
			gen scoreXtie = z_other_score_`i' * z_tie
			eststo `i'_`ses': clogit nomination i.other_low_ses z_other_score_`i' z_tie  scoreXtie, group(own_id) vce(cluster own_id)				
		}
	restore
}

cls
esttab reading_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math_*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 


//# are low-SES better referrers controlling for network > NO, but network average matters
eststo clear
foreach i in math reading {
    preserve
    use "`i'.dta", clear
	keep if nomination == 1
    eststo `i': reg other_score_`i' ib(2).own_estrato mean_other_score_`i' sd_other_score_`i'
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



//# is there in performance homophily (high performance - high performance) > significant but meaningless compared to the effect of network
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


//# who has better network? > controlling for own scores, for every level of z-tie that matters, higher SES have better networks on average!
eststo clear
forvalues x = 1/4 {
    foreach i in math reading {
        preserve
        use "`i'.dta", clear
        
        // Filter by tie strength
        keep if z_tie >= `x'
        
        // Calculate average network score for each referrer
        collapse (mean) other_score_`i' other_gpa own_gpa own_score_`i' own_low_ses, by(own_id)
        sum *, det
        // Run regression
        //eststo `i'_tie`x': reg other_score_`i'  i.own_estrato
		gen gpaXlses = own_gpa * own_low_ses
// 		eststo `i'_tie`x'_own: reg other_score_`i' own_score_`i' i.own_low_ses
		eststo `i'_tie`x'_own_gpa: reg other_gpa own_gpa i.own_low_ses
        restore
    }
}
cls
esttab reading*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
esttab math*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 



//# accuracy premium 1: 

use "${path}math.dta", clear
keep if nomination == 1
gen score_premium = (other_score_math - mean_other_score_math)
drop other_score
rename sd_other_score_math sd_other_score
rename other_score_math other_score
gen delta_own_belief = own_belief - own_score
gen delta_other_belief = other_belief - other_score
keep own_id score_premium own_score own_belief other_belief area treat own_estrato tie sd_other_score delta* other_score
list in 1/6
save "${path}math_tmp.dta", replace

use "${path}reading.dta", clear
keep if nomination == 1
gen score_premium = (other_score_reading - mean_other_score_reading)
drop other_score
rename other_score_reading other_score
rename sd_other_score_reading sd_other_score
gen delta_own_belief = own_belief - own_score
gen delta_other_belief = other_belief - other_score
keep own_id score_premium own_score own_belief other_belief area treat own_estrato tie sd_other_score delta*  other_score
list in 1/6
save "${path}reading_tmp.dta", replace

append using "${path}math_tmp.dta"
save "${path}cmb_tmp.dta", replace
rm "${path}math_tmp.dta" 
rm "${path}reading_tmp.dta"

use "${path}cmb_tmp.dta", clear
sort own_id
list in 1/6

gen own_low_ses = (own_estrato == 1)
ttest delta_other_belief, by(own_low_ses)
ttest delta_own_belief, by(own_low_ses)

eststo clear
eststo cmb1: reg score_premium own_score  own_belief other_belief, vce(cluster own_id)
eststo cmb2: reg score_premium own_score  own_belief other_belief i.treat, vce(cluster own_id)  
eststo cmb3: reg score_premium own_score  own_belief other_belief tie sd_other_score i.area i.treat ib(2).own_estrato  , vce(cluster own_id)

est clear
use "${path}cmb_tmp.dta", clear
gen t = 0
replace t = 1 if treat == 2
gen tretXscore = own_score * t
gen tretXbown = delta_own_belief * t
gen tretXbother =  delta_other_belief * t
eststo d1: reg score_premium own_score  delta_own_belief delta_other_belief i.t, vce(cluster own_id)
eststo d2: reg score_premium own_score  delta_own_belief delta_other_belief i.t tie sd_other_score i.area ib(2).own_estrato  , vce(cluster own_id)
eststo d3: reg score_premium own_score  delta_own_belief delta_other_belief i.t tretXbother tretXbown tretXscore tie sd_other_score i.area ib(2).own_estrato  , vce(cluster own_id)

cls
esttab d*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

use "${path}cmb_tmp.dta", clear

twoway (qfitci score_premium delta_own_belief if delta_own_belief >= -50 & delta_own_belief <= 50) (qfitci score_premium delta_other_belief if delta_other_belief >= -50 & delta_other_belief <= 50)



eststo cmb3: reg score_premium own_score own_belief other_belief 
quietly margins, at(own_belief=(0(25)100)) vsquish
matrix own_belief_margins = r(b)'
matrix own_belief_at = (0, 25, 50, 75, 100)'
svmat own_belief_margins
svmat own_belief_at

quietly margins, at(other_belief=(0(25)100)) vsquish
matrix other_belief_margins = r(b)'
matrix other_belief_at = (0, 25, 50, 75, 100)'
svmat other_belief_margins
svmat other_belief_at

twoway (line own_belief_margins1 own_belief_at1, lcolor("136 132 216") lwidth(thick)) ///
       (line other_belief_margins1 other_belief_at1, lcolor("130 202 157") lwidth(thick)), ///
       title("Effects of Beliefs on Score Premium", size(medium)) ///
       ytitle("Linear Prediction") ///
       xtitle("Beliefs") ///
       xlabel(0(25)100) ///
       legend(order(1 "Own" 2 "Nominee") ring(0) pos(4) rows(2) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       name(combined_beliefs_twoway, replace)


preserve
use "${path}cmb_tmp.dta", clear
eststo cmb4: reg score_premium own_score delta_own_belief delta_other_belief
quietly margins, at(delta_own_belief=(-25(5)25)) vsquish
matrix delta_own_margins = r(b)'
matrix delta_own_at = (-25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25)'
svmat delta_own_margins
svmat delta_own_at

marginsplot

quietly margins, at(delta_other_belief=(-25(5)25)) vsquish
matrix delta_other_margins = r(b)'
matrix delta_other_at = (-25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25)'
svmat delta_other_margins
svmat delta_other_at
marginsplot

twoway (line delta_own_margins1 delta_own_at1, lcolor("136 132 216") lwidth(thick)) ///
       (line delta_other_margins1 delta_other_at1, lcolor("130 202 157") lwidth(thick)), ///
       title("Effects of Belief Discrepancies on Score Premium", size(medium)) ///
       ytitle("Linear Prediction") ///
       xtitle("Δ Belief") ///
       xlabel(-25(5)25) ///
       legend(order(1 "Own score" 2 "Nominee score") ring(1) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       name(combined_delta_twoway, replace)
restore


preserve
egen med = median(delta_other_belief)
egen lqt = pctile(delta_other_belief), p(25)
egen uqt = pctile(delta_other_belief), p(75)
egen iqr = iqr(delta_other_belief)
egen mean = mean(delta_other_belief)
gen ypos = -11
gen l = delta_other_belief if(delta_other_belief >= lqt-1.5*iqr)
egen ls = min(l)
gen u = delta_other_belief if(delta_other_belief <= uqt+1.5*iqr)
egen us = max(u)
twoway (qfitci score_premium delta_other_belief, lcolor(gs4) bcolor(gs12) alwidth(none)) ///
		rbar lqt uqt ypos , horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
	   rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
       rspike lqt ls ypos, horiz  lcolor(gs4) || ///
       rspike uqt us ypos, horiz lcolor(gs4) || ///
       rcap ls ls ypos,  horiz msize(*1) lcolor(gs4) || ///
       rcap us us ypos,  horiz msize(*1) lcolor(gs4)|| ///
	   scatter ypos mean , msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) legend(off) ///
	,	xlabel(-75(25)50) ytitle("Score Premium") title("Δ Nominee Belief Quadratic Fit") graphregion(color(white)) bgcolor(white) name(score_premium, replace) legend(off)  xtitle("")
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/score_premium_qfit.png", replace
	restore

preserve
egen med = median(own_score)
egen lqt = pctile(own_score), p(25)
egen uqt = pctile(own_score), p(75)
egen iqr = iqr(own_score)
egen mean = mean(own_score)
gen ypos = -11
gen l = own_score if(own_score >= lqt-1.5*iqr)
egen ls = min(l)
gen u = own_score if(own_score <= uqt+1.5*iqr)
egen us = max(u)
twoway (qfitci score_premium own_score, lcolor(gs4) bcolor(gs12) alwidth(none)) ///
		rbar lqt uqt ypos , horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
	   rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
       rspike lqt ls ypos, horiz  lcolor(gs4) || ///
       rspike uqt us ypos, horiz lcolor(gs4) || ///
       rcap ls ls ypos,  horiz msize(*1) lcolor(gs4) || ///
       rcap us us ypos,  horiz msize(*1) lcolor(gs4)|| ///
	   scatter ypos mean , msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) legend(off) ///
	,	xlabel(25(25)100) ytitle("Score Premium") title("Own Score Fit") graphregion(color(white)) bgcolor(white) name(score_premium, replace) legend(off)  xtitle("")
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/own_score_qfit.png", replace
	restore
	   	
(qfitci score_premium own_score, bcolor(navy%20) alwidth(none)) ///	   

	   
vioplot score_premium, horiz
histogram score_premium, percent bins(20)


preserve
egen med = median(score_premium)
egen lqt = pctile(score_premium), p(25)
egen uqt = pctile(score_premium), p(75)
egen iqr = iqr(score_premium)
egen mean = mean(score_premium)
gen ypos = -.75
gen l = score_premium if(score_premium >= lqt-1.5*iqr)
egen ls = min(l)
gen u = score_premium if(score_premium <= uqt+1.5*iqr)
egen us = max(u)

twoway (histogram score_premium, percent fcolor(gs10) bins(20) lcolor(gs4) lwidth(thin)) ///
		rbar lqt uqt ypos , horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
	   rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
       rspike lqt ls ypos, horiz  lcolor(gs4) || ///
       rspike uqt us ypos, horiz lcolor(gs4) || ///
       rcap ls ls ypos,  horiz msize(*1) lcolor(gs4) || ///
       rcap us us ypos,  horiz msize(*1) lcolor(gs4)|| ///
       scatter ypos mean , msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) legend(off) ///
      , ///
      xlabel(-40(10)40) ///
      ylabel(0(5)20, angle(0)) ///
      ytitle("Percent") ///
      xtitle("") ///
      title("Score Premium") ///
      graphregion(color(white)) bgcolor(white) ///
      name(score_premium, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/score_premium.png", replace
restore

preserve
egen med = median(delta_other_belief)
egen lqt = pctile(delta_other_belief), p(25)
egen uqt = pctile(delta_other_belief), p(75)
egen iqr = iqr(delta_other_belief)
egen mean = mean(delta_other_belief)
gen ypos = -.75
gen l = delta_other_belief if(delta_other_belief >= lqt-1.5*iqr)
egen ls = min(l)
gen u = delta_other_belief if(delta_other_belief <= uqt+1.5*iqr)
egen us = max(u)

twoway (histogram delta_other_belief, percent fcolor(gs10) bins(20) lcolor(gs4) lwidth(thin)) ///
      		rbar lqt uqt ypos , horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
	   rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
       rspike lqt ls ypos, horiz  lcolor(gs4) || ///
       rspike uqt us ypos, horiz lcolor(gs4) || ///
       rcap ls ls ypos,  horiz msize(*1) lcolor(gs4) || ///
       rcap us us ypos,  horiz msize(*1) lcolor(gs4)|| ///
	    (pcarrowi 12.5 45 12.5 65, lwidth(medthick) color(navy) msize(2) barbsize(0) mcolor(navy)) ///
       (pcarrowi 12.5 -45 12.5 -65, lwidth(medthick) color(navy) msize(2) barbsize(0) mcolor(navy)) ///
       scatter ypos mean , msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) legend(off)  text(13.5 55 "Overestimation") text(13.5 -55 "Underestimation") ///
      , ///
      xlabel(-80(20)80) ///
      ylabel(0(5)20, gmax angle(0)) ///
      ytitle("Percent") ///
      xtitle("") ///
      title("Δ Nominee Belief") ///
      graphregion(color(white)) bgcolor(white) ///
      name(other_belief, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/other_belief.png", replace
restore

preserve
egen med = median(delta_own_belief)
egen lqt = pctile(delta_own_belief), p(25)
egen uqt = pctile(delta_own_belief), p(75)
egen iqr = iqr(delta_own_belief)
egen mean = mean(delta_own_belief)
gen ypos = -.75
gen l = delta_own_belief if(delta_own_belief >= lqt-1.5*iqr)
egen ls = min(l)
gen u = delta_own_belief if(delta_own_belief <= uqt+1.5*iqr)
egen us = max(u)

twoway (histogram delta_own_belief, percent fcolor(gs10) bins(20) lcolor(gs4) lwidth(thin)) ///
       (rbar lqt uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5))  ///
       (rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5))  ///
       (rspike lqt ls ypos, horiz lcolor(gs4))  ///
       (rspike uqt us ypos, horiz lcolor(gs4))  ///
       (rcap ls ls ypos, horiz msize(*1) lcolor(gs4))  ///
       (rcap us us ypos, horiz msize(*1) lcolor(gs4))  ///
       (scatter ypos mean, msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) text(13.5 55 "Overestimation") text(13.5 -55 "Underestimation")) ///
       (pcarrowi 12.5 45 12.5 65, lwidth(medthick) color(navy) msize(2) barbsize(0) mcolor(navy)) ///
       (pcarrowi 12.5 -45 12.5 -65, lwidth(medthick) color(navy) msize(2) barbsize(0) mcolor(navy)) ///
		, /// 
       xlabel(-100(20)80) ///
       ylabel(0(5)20, angle(0) gmax) ///
       ytitle("Percent") ///
       xtitle("") ///
       legend(off) ///
       title("Δ Own Belief") ///
       graphregion(color(white)) bgcolor(white) ///
       name(own_belief, replace)
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/own_belief.png", replace
restore

use "${path}cmb_tmp.dta", clear
tabstat delta_other_belief delta_own_belief score_premium, by(own_estrato) stat(mean semean)

use "${path}dataset_z.dta", clear
bysort other_id: gen c = _n
keep if c == 1
proportion  other_program
proportion  other_program if other_estrato == 3
proportion other_program other_estrato
collapse (count) n=other_program , by(other_estrato)
forvalues i = 1/3 {    
    global n`i' = n[`i']

} 

// preserve
// use "${path}cmb_tmp.dta", clear
// collapse (mean) mean=delta_other_belief (sd) sd=delta_other_belief (count) n=delta_other_belief (semean) se=delta_other_belief, by(own_estrato)
// forvalues i = 1/3 {
//     global mean`i' = mean[`i']
//     global sd`i' = sd[`i']
//     global n`i' = n[`i']
//     global se`i' = se[`i']
//     global ci_lower`i' = mean[`i'] - 1.96*se[`i']
//     global ci_upper`i' = mean[`i'] + 1.96*se[`i']
// } 
// clear
// set obs 3
// gen own_estrato = _n
// gen xpos = _n
//
// gen fee = .
// gen se = .
// gen ci_lower = .
// gen ci_upper = .
//
// replace fee = ${mean1} if own_estrato == 1
// replace fee = ${mean2} if own_estrato == 2
// replace fee = ${mean3} if own_estrato == 3
//
// replace se = ${se1} if own_estrato == 1
// replace se = ${se2} if own_estrato == 2
// replace se = ${se3} if own_estrato == 3
//
// replace ci_lower = ${ci_lower1} if own_estrato == 1
// replace ci_lower = ${ci_lower2} if own_estrato == 2
// replace ci_lower = ${ci_lower3} if own_estrato == 3
//
// replace ci_upper = ${ci_upper1} if own_estrato == 1
// replace ci_upper = ${ci_upper2} if own_estrato == 2
// replace ci_upper = ${ci_upper3} if own_estrato == 3
//
// label define estrato_lab 1 "Low" 2 "Middle" 3 "High"
// label values own_estrato estrato_lab
//
// twoway (bar fee xpos, barwidth(0.7) color("${lowSES}")) ///
//        (rcap ci_upper ci_lower xpos, lcolor(gs4)) ///
//        , ///
//        xlabel(1 "Low" 2 "Middle" 3 "High", noticks) ///
//        ylabel(-2(1)8, angle(0) format(%9.0f) grid gmin) ///
//        ytitle("Score Premium") ///
//        xtitle("") ///
//        title("Δ Nominee Belief") ///
//        legend(off) ///
//        graphregion(color(white)) bgcolor(white) ///
//        xscale(range(0.5 3.5)) ///
//        name(deltaown_by_ses, replace)
//       
// //graph export "${path}fee_by_ses.png", replace
// restore
