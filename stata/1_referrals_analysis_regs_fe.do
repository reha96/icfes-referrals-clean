// *****************************************************************************
//                              Job Referrals                                  
// *****************************************************************************
clear all

cls
use data_referrals_gender.dta, clear
drop if other_score == .
gen stem = own_ing==1 | own_program==70

// One area at a time
keep if area == 1
egen count_otherid = rank(own_id), by(other_id) unique
egen count_id = rank(other_id), by(own_id) unique

// sum other_score if count_otherid == 1 
// gen score_std = (other_score - r(mean)) / r(sd)

egen avgscore = mean(other_score), by(own_id)
egen sdscore = sd(other_score), by(own_id)

sum avgscore if count_id == 1
local avgt = r(mean)
sum sdscore if count_id == 1
local sdt = r(mean)
gen score_std = (other_score - `avgt') / `sdt'

egen avgtie = mean(tie), by(own_id)
egen sdtie = sd(tie), by(own_id)

sum avgtie if count_id == 1
local avgt = r(mean)
sum sdtie if count_id == 1
local sdt = r(mean)
gen tie_std = (tie - `avgt') / `sdt'

// ******************
// Basic regressions
// ******************
gen femXscore = (other_female == 1) * score_std
gen maleXscore = (other_female == 0) * score_std
gen femXtie = (other_female == 1) * tie_std
gen maleXtie = (other_female == 0) * tie_std
gen scoreXtie = score_std * tie_std
gen femXscoreXtie = (other_female == 1) * scoreXtie
gen maleXscoreXtie = (other_female == 0) * scoreXtie

eststo clear

// Basic regressions
  eststo est1: clogit nomination other_female, group(own_id) vce(cluster own_id)
  eststo est2: clogit nomination other_female score_std tie_std, group(own_id) vce(cluster own_id)
  eststo est3: clogit nomination other_female score_std tie_std scoreXtie, group(own_id) vce(cluster own_id)

// Graph prediction of basic model (est3)
preserve
keep nomination scoreXtie other_female score_std tie_std own_id maleXscoreXtie femXscoreXtie maleXscore femXscore maleXtie femXtie
append using prediction_nogender.dta
predict probrefer, pc1
replace probrefer = probrefer * 100
replace tie_std = tie_std * 2 // multiply by 2 since the by graph command needs integers
la def tie_std_lbl 0 "Few classes" 3 "Some classes" 6 "Many classes"
la val tie_std tie_std_lbl
keep if nomination==.
collapse probrefer, by(score_std other_female tie_std)
graph set window fontface "Calibri Light"
twoway (line probrefer score_std if other_female==0, sort lcolor(ebblue) lwidth(thick)) (line probrefer score_std if other_female==1, sort lcolor(orange_red) lwidth(thick) lpattern(solid)) if (score_std>=-0.5 & score_std<=2.5), ytitle("Probability") ytitle(, size(medlarge)) yscale(noline) ylabel(0(1)4, labsize(medlarge) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(noline) xlabel(0 "Average" 1 "Very good" 2 "Exceptional", labsize(medlarge) nogrid) by(, note("")) by(, legend(off)) name(prefer_basic, replace) xsize(10) ysize(4.5) by(tie_std, rows(1) noiytick noixtick) subtitle(, size(vlarge) nobox)
restore

// ************************************
// Interaction with other gender
// ************************************
  eststo est6: clogit nomination other_female maleXscore femXscore maleXtie femXtie, group(own_id) vce(cluster own_id)
	test femXscore = maleXscore
	test femXtie = maleXtie
  eststo est7: clogit nomination other_female maleXscore femXscore maleXtie femXtie maleXscoreXtie femXscoreXtie, group(own_id) vce(cluster own_id)
	test femXscore = maleXscore
	test femXtie = maleXtie
	test femXscoreXtie = maleXscoreXtie

// Graph prediction of model with interaction with other gender (est7)
preserve
keep nomination scoreXtie other_female score_std tie_std own_id maleXscoreXtie femXscoreXtie maleXscore femXscore maleXtie femXtie
append using prediction_nogender.dta
predict probrefer, pc1
replace probrefer = probrefer * 100
replace tie_std = tie_std * 2 // multiply by 2 since the by graph command needs integers
la def tie_std_lbl 0 "Few classes" 3 "Some classes" 6 "Many classes"
la val tie_std tie_std_lbl
keep if nomination==.
collapse probrefer, by(score_std other_female tie_std)
graph set window fontface "Calibri Light"
twoway (line probrefer score_std if other_female==0, sort lcolor(ebblue) lwidth(thick)) (line probrefer score_std if other_female==1, sort lcolor(orange_red) lwidth(thick) lpattern(solid)) if (score_std>=-0.5 & score_std<=2.5), ytitle("Probability") ytitle(, size(medlarge)) yscale(noline) ylabel(0(1)4, labsize(medlarge) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(noline) xlabel(0 "Average" 1 "Very good" 2 "Exceptional", labsize(medlarge) nogrid) by(, note("")) by(, legend(off)) name(prefer_othergender, replace) xsize(10) ysize(4.5) by(tie_std, rows(1) noiytick noixtick) subtitle(, size(vlarge) nobox)
restore


// Effect by gender of nominator

foreach x in 0 1{
  frames copy default dataset`x'
  frames change dataset`x'
  keep if own_female==`x'

  eststo est8`x': clogit nomination other_female maleXscore femXscore maleXtie femXtie maleXscoreXtie femXscoreXtie, group(own_id) vce(cluster own_id)
  test femXscore = maleXscore
  test femXtie = maleXtie
  test femXscoreXtie = maleXscoreXtie

  keep nomination scoreXtie other_female score_std tie_std own_id maleXscoreXtie femXscoreXtie maleXscore femXscore maleXtie femXtie own_female
  append using prediction_gender.dta
  keep if own_female==`x'
  predict probrefer, pc1
}
save dataset1.dta, replace
frames change dataset0
append using dataset1.dta
erase dataset1.dta

preserve
replace probrefer = probrefer * 100
keep if nomination==.
collapse probrefer, by(score_std other_female tie_std own_female)
graph set window fontface "Calibri Light"
twoway (line probrefer score_std if other_female==0, sort lcolor(ebblue) lwidth(thick)) (line probrefer score_std if other_female==1, sort lcolor(orange_red) lwidth(thick) lpattern(solid)) if (score_std>=-0.5 & score_std<=2.5) & tie_std==3, ytitle("Probability") ytitle(, size(medlarge)) yscale(noline) ylabel(0(1)4, labsize(medlarge) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(noline) xlabel(0 "Average" 1 "Very good" 2 "Exceptional", labsize(medlarge) nogrid) by(, note("")) by(, legend(off)) name(prefer_otherowngender, replace) xsize(7) ysize(4.5) by(own_female, rows(1) noiytick noixtick) subtitle(, size(vlarge) nobox)
restore

frames change default

esttab est1 est2 est3, cells(b(star fmt(3)) se(par fmt(3))) star(+ 0.10 * 0.05 ** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) replace nodep nomti label ty 
esttab est2 est6 est3 est7, cells(b(star fmt(3)) se(par fmt(3))) star(+ 0.10 * 0.05 ** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) replace nodep nomti label ty 
esttab est7 est80 est81, cells(b(star fmt(3)) se(par fmt(3))) star(+ 0.10 * 0.05 ** 0.01) scalars("N Obs." "N_clust Ind." "chi2 Chi-test") sfmt(0 0 2) replace nodep nomti label ty 

