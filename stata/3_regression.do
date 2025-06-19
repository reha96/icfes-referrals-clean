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
	

// Create a combined dataset
clear all
use "reading.dta", clear
append using "math.dta"
order own_id area
sort own_id area

// Create interaction variables
gen scoreXtie = z_other_score_reading * z_tie if area == 1
replace scoreXtie = z_other_score_math * z_tie if area == 2

gen scoreXgpa = z_other_score_reading * z_other_gpa if area == 1
replace scoreXgpa = z_other_score_math * z_other_gpa if area == 2

// Create a composite score variable for simplicity in models
gen z_other_score = z_other_score_reading if area == 1
replace z_other_score = z_other_score_math if area == 2

// Other interaction variables
gen scoreXtieXses = scoreXtie * other_estrato
gen gpaXtie = z_other_gpa * z_tie
gen scoreXlses = z_other_score * other_low_ses

gen same_low = (other_low_ses==own_low_ses)
gen same_med = (other_med_ses==own_med_ses)
gen same_high = (other_high_ses==own_high_ses)
gen same_program = (other_program==own_program) // no need to add it in the model? its contibution is very small (though sig.) compared to z_tie
gen same_semester = (other_semester==own_semester) 

gen tieXprogram = same_program * z_tie

// Create a new group variable combining the subject area and person ID
egen area_id = group(own_id area)

save "appended.dta", replace

use "appended.dta", clear
// Run models
preserve
keep if nomination == 1
anova z_other_score treat
anova z_tie treat
restore


// cls
// eststo clear
// eststo reg1: clogit nomination ib(2).other_estrato  tie, group(area_id) vce(cluster own_id)
// eststo reg2: clogit nomination ib(2).other_estrato  tie_class, group(area_id) vce(cluster own_id)
// eststo reg3: clogit nomination ib(2).other_estrato  tie_period, group(area_id) vce(cluster own_id)
// eststo reg4: clogit nomination ib(2).other_estrato  tie_class_period, group(area_id) vce(cluster own_id)
// esttab reg*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 


cls
eststo clear
eststo reg0: clogit nomination ib(2).other_estrato ib(0).same_program, group(area_id) vce(cluster own_id)
eststo reg1: clogit nomination ib(2).other_estrato  z_tie, group(area_id) vce(cluster own_id)
eststo reg2: clogit nomination ib(2).other_estrato z_tie ib(1).same_program, group(area_id) vce(cluster own_id)
esttab reg*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
eststo reg3: qui clogit nomination ib(2).other_estrato z_tie ib(0).same_program z_other_score, group(area_id) vce(cluster own_id)





forvalues ses = 1/3 {
    preserve		
		keep if own_estrato == `ses'
		eststo program`ses': clogit nomination ib(2).other_estrato z_other_score z_tie  same_program, group(area_id) vce(cluster own_id)
		eststo base`ses': clogit nomination ib(2).other_estrato z_other_score z_tie  , group(area_id) vce(cluster own_id)
		test 1.other_estrato = 2.other_estrato = 3.other_estrato // *** only for low-SES
		test 1.other_estrato = 3.other_estrato // *** only for low-SES
	restore
}
esttab program* base*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty // high-SES bias gone!




test 1.other_estrato = 2.other_estrato = 3.other_estrato // **

preserve
keep if treat == 1
eststo reg4: clogit nomination ib(2).other_estrato z_other_score z_tie scoreXtie, group(area_id) vce(cluster own_id)
restore
preserve
keep if treat == 2
eststo reg5: clogit nomination ib(2).other_estrato z_other_score z_tie scoreXtie, group(area_id) vce(cluster own_id)
restore

esttab reg3 reg4 reg5, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty // high-SES bias gone!

coefplot ///
    (reg4, offset(0) mcolor(blue) ciopts(color(blue) lwidth(medium))) ///
	(reg5, offset(0) mcolor(red) ciopts(color(red) lwidth(medium))), ///
    coeflabels(z_tie = "Courses taken" ///
              z_other_score = "Score" ///
			  scoreXtie = "Score x Courses taken" ///
              _cons = "Dep. Var. mean") ///
    msymbol(D) msize(medium) ///
    xlabel(-1(.5)1) /// 
    xline(0, lcolor(gs8) lpattern(dash) lwidth(thick)) ///
    legend(order(2 "Baseline" 4 "Bonus" ) pos(12) rows(1) size(small) subtitle("Treatment") region(lcolor(none))) ///
    $graph_opts name(res1, replace) 
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/res1.png", ///
    as(png) replace	

// SECOND GRAPH


forvalues ses = 1/3 {
    preserve		
		keep if treat == 1
		keep if own_estrato == `ses'
		eststo base`ses': clogit nomination ib(2).other_estrato z_other_score z_tie  scoreXtie, group(area_id) vce(cluster own_id)
	restore
}

forvalues ses = 1/3 {
    preserve		
		keep if treat == 2
		keep if own_estrato == `ses'
		eststo bonus`ses': clogit nomination ib(2).other_estrato z_other_score z_tie  scoreXtie, group(area_id) vce(cluster own_id)
	restore
}
cls
esttab base1 bonus1, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty // fixed effects
esttab base2 bonus2, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty // fixed effects
esttab base3 bonus3, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty // fixed effects
cls

// esttab b11 b21 b31, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
// esttab b12 b22 b32, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 
// esttab b13 b23 b33, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

cls
esttab b31 b32 b33, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty // fixed effects

coefplot ///
    (b31, offset(0.22) mcolor(dknavy) mlabcolor(dknavy) ciopts(color(dknavy) lwidth(thick))) ///
	(b32, offset(0.0) mcolor(orange) mlabcolor(orange) ciopts(color(orange) lwidth(thick))) ///
	(b33, offset(-0.22) mcolor(red) mlabcolor(red) ciopts(color(red) lwidth(thick))), ///
    coeflabels(z_tie = "Courses taken" ///
              z_other_score = "Score" ///
			  scoreXtie = "Score x Courses taken" ///
			  1.other_estrato = "Referral is Low-SES" ///
			  3.other_estrato = "Referral is High-SES" ///
              _cons = "Dep. Var. mean") ///
    msymbol(D) msize(medium) ///
    xlabel(-1(.5)1) /// 
    xline(0, lcolor(gs8) lpattern(dash) lwidth(thick)) ///
    legend(order(2 "Low" 4 "Middle" 6 "High") pos(12) rows(1) size(small) subtitle("Referrer SES") region(lcolor(none))) ///
    $graph_opts name(res1bis, replace) 
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/res1bis.png", ///
    as(png) replace	

// // labels if needed
// 		 mlabposition(3) ///
//      mlabel(cond(@pval<.01, "***",   ///
//             cond(@pval<.05, "**",    ///
//             cond(@pval<.1, "*", "")))) ///	
	
keep if nomination == 1
gen score_premium = (other_score - mean_other_score_reading) if area == 1
replace score_premium = (other_score - mean_other_score_math) if area == 2

// 
egen meanSP = mean(score_premium)
egen sdSP = sd(score_premium)
gen z_SP = (score_premium - meanSP) / sdSP

gen delta_own_belief = own_belief - own_score
gen delta_other_belief = other_belief - other_score

// own belief
egen meanOB = mean(delta_own_belief)
egen sdOB = sd(delta_own_belief)
gen z_OB = (delta_own_belief - meanOB) / sdOB

// nominee belief
egen meanNB = mean(delta_other_belief)
egen sdNB = sd(delta_other_belief)
gen z_NB = (delta_other_belief - meanNB) / sdNB 

// own score
egen meanOS = mean(own_score)
egen sdOS = sd(own_score)
gen z_OS = (own_score - meanOS) / sdOS


// 
est clear
// did treatment change outcomes?
eststo t0: reg score_premium  i.treat, vce(cluster own_id) // ref score - network av - no
eststo t0b: reg other_score i.treat, vce(cluster own_id) // ref score - no
eststo t0b2: reg other_score i.treat##c.tie, vce(cluster own_id) // ref score - no treatXtie
eststo t1: reg tie  i.treat, vce(cluster own_id) // courses taken - no
eststo t2: reg delta_own_belief  i.treat, vce(cluster own_id) // 
eststo t3: reg delta_other_belief i.treat, vce(cluster own_id) // 

est clear
eststo d0: reg z_SP  ib(2).own_estrato, vce(cluster own_id)
eststo d1: reg z_SP  ib(2).own_estrato z_OS z_OB z_NB, vce(cluster own_id)
test 1.own_estrato = 2.own_estrato = 3.own_estrato // p > .1
eststo d2: reg z_SP  ib(2).own_estrato z_OS z_OB z_NB i.treat z_tie i.area  , vce(cluster own_id)
cls
esttab d*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 

coefplot ///
	(d1, offset(0) mcolor(gs4) ciopts(color(gs4) lwidth(thick))), ///
    coeflabels(z_OS = "Own Score" ///
              z_OB = "Own Belief" ///
			  z_NB = "Other Belief" ///
              _cons = "Dep. Var. mean") ///
    msymbol(D) msize(vlarge) ///
    xlabel(-1(.5)1) /// 
		 mlabposition(1) ///
     mlabel(cond(@pval<.01, "***",   ///
            cond(@pval<.05, "**",    ///
            cond(@pval<.1, "*", ""))))) ///
    xline(0, lcolor(gs8) lpattern(dash) lwidth(thick)) ///
    legend(off) ///
    $graph_opts name(res2, replace) 
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/res2.png", ///
    as(png) replace	
	
// Model 1: SES × Referrer Score interaction
eststo int_score: reg z_SP ib(2).own_estrato##c.z_OS z_OB z_NB , vce(cluster own_id)

// Model 2: SES × Own Belief Difference interaction
eststo int_own: reg z_SP ib(2).own_estrato##c.z_OB z_OS z_NB , vce(cluster own_id)

// Model 3: SES × Nominee Belief Difference interaction
eststo int_nom: reg z_SP ib(2).own_estrato##c.z_NB z_OS z_OB , vce(cluster own_id)

eststo int_all: reg z_SP ib(2).own_estrato##c.z_NB ib(2).own_estrato##c.z_OS ib(2).own_estrato##c.z_OB , vce(cluster own_id)
// Test if z_NB effect is equal across all SES groups
test 1.own_estrato#c.z_NB = 2.own_estrato#c.z_NB = 3.own_estrato#c.z_NB // p > .1

// Test if z_OS effect is equal across all SES groups
test 1.own_estrato#c.z_OS = 2.own_estrato#c.z_OS = 3.own_estrato#c.z_OS // *

// Test if z_OB effect is equal across all SES groups
test 1.own_estrato#c.z_OB = 2.own_estrato#c.z_OB = 3.own_estrato#c.z_OB // *

test 1.own_estrato = 2.own_estrato = 3.own_estrato // p > .1


// Regression with SES as categorical predictor
reg z_SP ib(2).own_estrato, vce(cluster own_id)
test 1.own_estrato = 2.own_estrato = 3.own_estrato

reg z_OB ib(2).own_estrato, vce(cluster own_id)
test 1.own_estrato = 2.own_estrato = 3.own_estrato

reg z_NB ib(2).own_estrato, vce(cluster own_id)
test 1.own_estrato = 2.own_estrato = 3.own_estrato


cls
esttab int*, cells(b(star fmt(3)) se(par fmt(3))) star(* 0.10 ** 0.05 *** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) nodep nomti label ty 





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
	,	xlabel(-75(25)50) ytitle("Score Premium") title("Score Premium and Nominee Belief accuracy") graphregion(color(white)) bgcolor(white) name(score_premium, replace) legend(off)  xtitle("")
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/score_premium_qfit.png", replace
	restore
	
	
	
use "${path}cmb_tmp.dta", clear
preserve
keep if delta_own_belief >-50 
egen med = median(delta_own_belief)
egen lqt = pctile(delta_own_belief), p(25)
egen uqt = pctile(delta_own_belief), p(75)
egen iqr = iqr(delta_own_belief)
egen mean = mean(delta_own_belief)
gen ypos = -11
gen l = delta_own_belief if(delta_own_belief >= lqt-1.5*iqr)
egen ls = min(l)
gen u = delta_own_belief if(delta_own_belief <= uqt+1.5*iqr)
egen us = max(u)
twoway (qfitci score_premium delta_own_belief if delta_own_belief >-10 & delta_own_belief < 10, lcolor(gs4) bcolor(gs12) alwidth(none)) ///
		rbar lqt uqt ypos , horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
	   rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.5) || ///
       rspike lqt ls ypos, horiz  lcolor(gs4) || ///
       rspike uqt us ypos, horiz lcolor(gs4) || ///
       rcap ls ls ypos,  horiz msize(*1) lcolor(gs4) || ///
       rcap us us ypos,  horiz msize(*1) lcolor(gs4)|| ///
	   scatter ypos mean , msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4) legend(off) ///
	,	xlabel(-50(10)50) ytitle("Score Premium") title("Score Premium and Own Belief accuracy") graphregion(color(white)) bgcolor(white) name(score_premium, replace) legend(off)  xtitle("")
graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/ob_qfit.png", replace
restore
	