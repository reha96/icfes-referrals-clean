// *****************************************************************************
//                              Job Referrals                                  
// *****************************************************************************

use data_fullnet_gender.dta, clear
keep if area==2
gen gender_sample = treat <= 2 & neighbor == 1

distinct own_id
distinct own_id if treat < .
distinct own_id if treat <= 2
distinct own_id if gender_sample == 1
gen stem = own_ing==1 | own_program==70

collapse (count) degree=tie (mean) avgtie=tie other_female, by(own_id own_semester own_female gender_sample stem)

// Sum stats for network
sum degree avgtie own_female other_female stem own_semester
tab own_female gender_sample, co chi

// # ties 
preserve
replace own_semester = min(own_semester, 10)
collapse degree avgtie, by(own_semester)

graph set window fontface "Calibri Light"
twoway (area degree own_semester, sort fcolor("116 30 102 %80") lcolor("116 30 102")) (line avgtie own_semester, sort yaxis(2) lcolor("93 156 160") lwidth(thick)), ytitle(# of connections) ytitle(, size(large)) yscale(noline) ylabel(0(50)300, angle(horizontal) tlcolor(gs12) tlength(zero) grid glpattern(solid) glwidth(thin) glcolor(gs12) gmin gmax) ytitle(# of classes per connection, axis(2)) ytitle(, size(large) axis(2)) yscale(noline axis(2)) ylabel(0(1)6, angle(horizontal) tlcolor(gs12) tlength(zero) axis(2)) xtitle(# of semesters) xtitle(, size(large)) xscale(noline) xlabel(2(2)10, noticks nogrid) legend(order(1 "# of connections" 2 "# classes per connection") row(1) position(6) size(large) region(fcolor(none) lcolor(none))) name(netdegree, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\netdegree.png, as(png) replace
restore

sum degree
sum degree if gender_sample==1


// Fraction of female connections by gender
ttest other_female, by(own_female)
cohend other_female own_female 

ttest other_female if gender_sample==1, by(own_female)
cohend other_female own_female if gender_sample==1

gen other_female_g = int(other_female * 20 - 0.001) * 5
preserve
contract own_female other_female_g
egen totgen = total(_freq), by(own_female)
gen perfem = _freq/ totgen
gen xaxis = other_female_g + (own_female - 0.5) * 1.5

graph set window fontface "Calibri Light"
twoway (bar perfem xaxis if own_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(3)) (bar perfem xaxis if own_female==0, fcolor("244 189 133") lcolor(none) barwidth(3)), ytitle("") yscale(noline) ylabel(0(.05).2, angle(horizontal) tlcolor(gs12) tlength(zero) grid glpattern(solid) glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(Fraction of female connections) xtitle(, size(large) margin(top)) xscale(noline) xlabel(0(10)100, labsize(medium) noticks nogrid) legend(order(1 "Women" 2 "Men") row(1) position(6) size(large) region(fcolor(none) lcolor(none))) name(femhist, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_fracfem.png, as(png) replace
restore

preserve
contract own_female other_female_g stem
egen totgen = total(_freq), by(own_female stem)
gen perfem = _freq/ totgen
gen xaxis = other_female_g + (own_female - 0.5) * 1.5
graph set window fontface "Calibri Light"
twoway (bar perfem xaxis if own_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(3)) (bar perfem xaxis if own_female==0, fcolor("244 189 133") lcolor(none) barwidth(3)) if stem==0, ytitle("") yscale(noline) ylabel(0(.1).4, angle(horizontal) tlcolor(gs12) tlength(zero) grid glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(Fraction of female connections) xtitle(, size(large) margin(top)) xscale(noline) xlabel(0(10)100, labsize(medium) noticks) legend(order(1 "Women" 2 "Men") size(large) region(fcolor(none) lcolor(none))) name(femhist_nostem, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_fracfem_nostem.png, as(png) replace
twoway (bar perfem xaxis if own_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(3)) (bar perfem xaxis if own_female==0, fcolor("244 189 133") lcolor(none) barwidth(3)) if stem==1, ytitle("") yscale(noline) ylabel(0(.1).4, angle(horizontal) tlcolor(gs12) tlength(zero) grid glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(Fraction of female connections) xtitle(, size(large) margin(top)) xscale(noline) xlabel(0(10)100, labsize(medium) noticks) legend(order(1 "Women" 2 "Men") size(large) region(fcolor(none) lcolor(none))) name(femhist_stem, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_fracfem_stem.png, as(png) replace
restore

ttest other_female if stem!=1, by(own_female)
cohend other_female own_female if stem!=1
ttest other_female if stem==1, by(own_female)
cohend other_female own_female if stem==1

// classes per tie (tie strengh)

ttest avgtie, by(own_female)
cohend avgtie own_female 
ttest avgtie if gender_sample==1, by(own_female)
cohend avgtie own_female if gender_sample==1

centile avgtie, c(3 97)
gen avgtie_g = cond(avgtie > r(c_2), r(c_2), avgtie)
replace avgtie_g = int(avgtie_g * 2 - 0.00001) * .5
preserve
contract own_female avgtie_g
egen totgen = total(_freq), by(own_female)
gen perfem = _freq/ totgen
gen xaxis = avgtie_g + (own_female - 0.5) * .15
graph set window fontface "Calibri Light"
twoway (bar perfem xaxis if own_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(.3)) (bar perfem xaxis if own_female==0, fcolor("244 189 133") lcolor(none) barwidth(.3)), ytitle("") yscale(noline) ylabel(0(.05).25, angle(horizontal) tlcolor(gs12) tlength(zero) grid glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(Average # of classes per connection) xtitle(, size(large) margin(top)) xscale(noline) xlabel(1(1)12, labsize(medium) noticks) legend(order(1 "Women" 2 "Men") size(large) region(fcolor(none) lcolor(none))) name(tiehist, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_avgtie.png, as(png) replace
restore

// degree

ttest degree, by(own_female)
cohend degree own_female 
ttest degree if gender_sample==1, by(own_female)
cohend degree own_female if gender_sample==1

centile degree, c(3 97)
gen degree_g = cond(degree > r(c_2), r(c_2), degree)
replace degree_g = int(degree_g / 20 - 0.001) * 20
preserve
contract own_female degree_g
egen totgen = total(_freq), by(own_female)
gen perfem = _freq/ totgen
gen xaxis = degree_g + (own_female - 0.5) * 5
graph set window fontface "Calibri Light"
twoway (bar perfem xaxis if own_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(10)) (bar perfem xaxis if own_female==0, fcolor("244 189 133") lcolor(none) barwidth(10)), ytitle("") yscale(noline) ylabel(0(.03).15, angle(horizontal) tlcolor(gs12) tlength(zero) grid glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(# of connections) xtitle(, size(large) margin(top)) xscale(noline) xlabel(0(40)320, labsize(medium) noticks) legend(order(1 "Women" 2 "Men") size(large) region(fcolor(none) lcolor(none))) name(degreehist, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_degreehist.png, as(png) replace
restore

// Exam scores

use data_fullnet_gender.dta, clear
gen gender_sample = treat <= 2 & neighbor == 1

bysort other_id area: gen id_count=_n
keep if id_count==1

ttest other_score if area==1, by(other_female)
cohend other_score other_female if area==1

ttest other_score if area==2, by(other_female)
cohend other_score other_female if area==2

gen score_g = int(other_score * .2 - 0.001) * 5

contract other_female score_g area
egen totgen = total(_freq), by(other_female area)
gen perfem = _freq/ totgen
gen xaxis = score_g + (other_female - 0.5) * 1.5
graph set window fontface "Calibri Light"
twoway (bar perfem xaxis if other_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(3)) (bar perfem xaxis if other_female==0, fcolor("244 189 133") lcolor(none) barwidth(3)) if area==1, ytitle("") yscale(noline) ylabel(0(.05).25, angle(horizontal) tlcolor(gs12) tlength(zero) grid glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(Score in reading exam) xtitle(, size(large) margin(top)) xscale(noline) xlabel(10(10)100, labsize(medium) noticks) legend(order(1 "Women" 2 "Men") size(large) region(fcolor(none) lcolor(none))) name(femscore_read, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_score_read.png, as(png) replace
twoway (bar perfem xaxis if other_female==1, sort fcolor("165 229 230") lcolor(none) barwidth(3)) (bar perfem xaxis if other_female==0, fcolor("244 189 133") lcolor(none) barwidth(3)) if area==2, ytitle("") yscale(noline) ylabel(0(.05).25, angle(horizontal) tlcolor(gs12) tlength(zero) grid glwidth(thin) glcolor(gs12) gmin gmax format(%9.2f)) xtitle(Score in math exam) xtitle(, size(large) margin(top)) xscale(noline) xlabel(10(10)100, labsize(medium) noticks) legend(order(1 "Women" 2 "Men") size(large) region(fcolor(none) lcolor(none))) name(femscore_math, replace) xsize(10) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white)) plotregion(margin(bargraph))
graph export Figures\hist_score_math.png, as(png) replace

use data_fullnet_gender.dta, clear
gen gender_sample = treat <= 2 & neighbor == 1
keep if gender_sample == 1

bysort other_id area: gen id_count=_n
keep if id_count==1

ttest other_score if area==1, by(other_female)
cohend other_score other_female if area==1

ttest other_score if area==2, by(other_female)
cohend other_score other_female if area==2

// Referrals scores

use data_referrals_gender.dta, clear

gen stem = own_ing==1 | own_program==70
egen count_otherid = rank(own_id), by(other_id area) unique
egen count_id = rank(other_id), by(own_id area) unique

egen avgscore = mean(other_score), by(own_id area)
egen sdscore = sd(other_score), by(own_id area)

sum avgscore if count_id == 1 & area == 1
local avgt = r(mean)
sum sdscore if count_id == 1 & area == 1
local sdt = r(mean)
gen score_std = (other_score - `avgt') / `sdt' if area == 1
sum avgscore if count_id == 1 & area == 2
local avgt = r(mean)
sum sdscore if count_id == 1 & area == 2
local sdt = r(mean)
replace score_std = (other_score - `avgt') / `sdt' if area == 2

egen avgtie = mean(tie), by(own_id area)
egen sdtie = sd(tie), by(own_id area)

sum avgtie if count_id == 1 & area == 1
local avgt = r(mean)
sum sdtie if count_id == 1 & area == 1
local sdt = r(mean)
gen tie_std = (tie - `avgt') / `sdt' if area == 1
sum avgtie if count_id == 1 & area == 2
local avgt = r(mean)
sum sdtie if count_id == 1 & area == 2
local sdt = r(mean)
replace tie_std = (tie - `avgt') / `sdt' if area == 2

foreach var in other_score tie score_std tie_std other_female {
	gen `var'1 = `var' if nomination == 1
	gen `var'0 = `var' if nomination == 0
}

collapse other_score1 other_score0 tie1 tie0 score_std1 score_std0 tie_std1 tie_std0 other_female1 other_female0 other_female, by(own_id stem area treat)

expand 2, gen(catg)
// replace catg = catg * (1 + stem)
replace catg = catg * (1 + treat)

collapse (mean) other_score1 other_score0 tie1 tie0 score_std1 score_std0 tie_std1 tie_std0 other_female1 other_female0 other_female (sd) other_female_sd=other_female (sem) other_score_se1=other_score1 other_score_se0=other_score0 tie_se1=tie1 tie_se0=tie0 score_std_se1=score_std1 score_std_se0=score_std0 tie_std_se1=tie_std1 tie_std_se0=tie_std0 other_female_se1=other_female1 other_female_se0=other_female0 (count) obs=own_id, by(area catg)

gen other_female_std1 = (other_female1 - other_female) / other_female_sd
gen other_female_std0 = (other_female0 - other_female) / other_female_sd
gen other_female_std_se1 = other_female_se1 / other_female_sd
gen other_female_std_se0 = other_female_se0 / other_female_sd
drop other_female other_female_sd
reshape long other_score tie score_std tie_std other_female other_score_se tie_se score_std_se tie_std_se other_female_se other_female_std other_female_std_se, i(area catg) j(referred)

foreach var in other_score tie score_std tie_std other_female other_female_std {
	gen `var'_ll = `var' - `var'_se * invnormal(.975)
	gen `var'_ul = `var' + `var'_se * invnormal(.975)
}

// la def catlbl 0 "All" 1 "Not STEM" 2 "STEM"
la def catlbl 0 "All" 2 "No bonus" 3 "Bonus"
la val catg catlbl

// Math
graph set window fontface "Calibri Light"
twoway (bar other_score referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_score_ll other_score_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==2 & catg==0, ytitle("") yscale(noline) ylabel(55(5)75, labsize(vlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Exam score, size(vhuge) color(black)) legend(off) name(bar_score, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_score_math.png, as(png) replace

twoway (bar tie referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap tie_ll tie_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==2 & catg==0, ytitle("") yscale(noline) ylabel(0(4)16, labsize(vlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Tie strengh, size(vhuge) color(black)) legend(off) name(bar_tie, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_tie_math.png, as(png) replace

twoway (bar other_female referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_female_ll other_female_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==2 & catg==0, ytitle("") yscale(noline) ylabel(0.3(0.1)0.7, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Fraction women, size(vhuge) color(black)) legend(off) name(bar_female, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_female_math.png, as(png) replace

twoway (bar score_std referred, sort fcolor("244 189 133") lcolor(none) barwidth(0.8)) (rcap score_std_ll score_std_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==2 & catg==0, ytitle("") yscale(noline) ylabel(-0.5(0.5)3, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Exam score, size(vhuge) color(black)) legend(off) name(bar_score_std, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_scorestd_math.png, as(png) replace

twoway (bar tie_std referred, sort fcolor("244 189 133") lcolor(none) barwidth(0.8)) (rcap tie_std_ll tie_std_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==2 & catg==0, ytitle("") yscale(noline) ylabel(-0.5(0.5)3, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Tie strengh, size(vhuge) color(black)) legend(off) name(bar_tie_std, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_tiestd_math.png, as(png) replace

twoway (bar other_female_std referred, sort fcolor("244 189 133") lcolor(none) barwidth(0.8)) (rcap other_female_std_ll other_female_std_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==2 & catg==0, ytitle("") yscale(noline) ylabel(-3(0.5)0.5, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Fraction women, size(vhuge) color(black)) legend(off) name(bar_female_std, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_femalestd_math.png, as(png) replace

// Stem vs not stem
twoway (bar other_score referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_score_ll other_score_ul referred, sort lcolor("116 30 102") lwidth(medthick)) if area==2 & catg>0, ytitle("") yscale(noline) ylabel(50(5)80, labsize(medlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(medlarge) tlcolor(white) tlength(zero) nogrid) by(, title(Exam score, size(vlarge) color(black)) note("")) by(, legend(off)) name(bar_score_stem, replace) xsize(6) ysize(6) by(, graphregion(margin(small) fcolor(white) lcolor(white))) by(catg, rows(1)) subtitle(, size(large) nobox)
// graph export Figures\bar_score_math_stem.png, as(png) replace

twoway (bar tie referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap tie_ll tie_ul referred, sort lcolor("116 30 102") lwidth(medthick)) if area==2 & catg>0, ytitle("") yscale(noline) ylabel(0(3)18, labsize(medlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(medlarge) tlcolor(white) tlength(zero) nogrid) by(, title(Tie strengh, size(vlarge) color(black)) note("")) by(, legend(off)) name(bar_tie_stem, replace) xsize(6) ysize(6) by(, graphregion(margin(small) fcolor(white) lcolor(white))) by(catg, rows(1)) subtitle(, size(large) nobox)
// graph export Figures\bar_tie_math_stem.png, as(png) replace

twoway (bar other_female referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_female_ll other_female_ul referred, sort lcolor("116 30 102") lwidth(medthick)) if area==2 & catg>0, ytitle("") yscale(noline) ylabel(0.1(0.1)0.7, labsize(medlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(medlarge) tlcolor(white) tlength(zero) nogrid) by(, title(Fraction women, size(vlarge) color(black)) note("")) by(, legend(off)) name(bar_female_stem, replace) xsize(6) ysize(6) by(, graphregion(margin(small) fcolor(white) lcolor(white))) by(catg, rows(1)) subtitle(, size(large) nobox)
// graph export Figures\bar_female_math_stem.png, as(png) replace


// Verbal
graph set window fontface "Calibri Light"
twoway (bar other_score referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_score_ll other_score_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==1 & catg==0, ytitle("") yscale(noline) ylabel(55(5)75, labsize(vlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Exam score, size(vhuge) color(black)) legend(off) name(bar_score, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_score_verbal.png, as(png) replace

twoway (bar tie referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap tie_ll tie_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==1 & catg==0, ytitle("") yscale(noline) ylabel(0(4)16, labsize(vlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Tie strengh, size(vhuge) color(black)) legend(off) name(bar_tie, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_tie_verbal.png, as(png) replace

twoway (bar other_female referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_female_ll other_female_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==1 & catg==0, ytitle("") yscale(noline) ylabel(0.3(0.1)0.7, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Fraction women, size(vhuge) color(black)) legend(off) name(bar_female, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_female_verbal.png, as(png) replace

twoway (bar score_std referred, sort fcolor("244 189 133") lcolor(none) barwidth(0.8)) (rcap score_std_ll score_std_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==1 & catg==0, ytitle("") yscale(noline) ylabel(-0.5(0.5)3, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Exam score, size(vhuge) color(black)) legend(off) name(bar_score_std, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_scorestd_verbal.png, as(png) replace

twoway (bar tie_std referred, sort fcolor("244 189 133") lcolor(none) barwidth(0.8)) (rcap tie_std_ll tie_std_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==1 & catg==0, ytitle("") yscale(noline) ylabel(-0.5(0.5)3, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Tie strengh, size(vhuge) color(black)) legend(off) name(bar_tie_std, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_tiestd_verbal.png, as(png) replace

twoway (bar other_female_std referred, sort fcolor("244 189 133") lcolor(none) barwidth(0.8)) (rcap other_female_std_ll other_female_std_ul referred, sort lcolor("116 30 102") lwidth(thick)) if area==1 & catg==0, ytitle("") yscale(noline) ylabel(-3(0.5)0.5, labsize(vlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(huge) noticks) title(Fraction women, size(vhuge) color(black)) legend(off) name(bar_female_std, replace) xsize(3) ysize(6) graphregion(margin(small) fcolor(white) lcolor(white))
graph export Figures\bar_femalestd_verbal.png, as(png) replace

// Stem vs not stem
twoway (bar other_score referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_score_ll other_score_ul referred, sort lcolor("116 30 102") lwidth(medthick)) if area==1 & catg>0, ytitle("") yscale(noline) ylabel(50(5)80, labsize(medlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(medlarge) tlcolor(white) tlength(zero) nogrid) by(, title(Exam score, size(vlarge) color(black)) note("")) by(, legend(off)) name(bar_score_stem, replace) xsize(6) ysize(6) by(, graphregion(margin(small) fcolor(white) lcolor(white))) by(catg, rows(1)) subtitle(, size(large) nobox)
// graph export Figures\bar_score_verbal_stem.png, as(png) replace

twoway (bar tie referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap tie_ll tie_ul referred, sort lcolor("116 30 102") lwidth(medthick)) if area==1 & catg>0, ytitle("") yscale(noline) ylabel(0(3)18, labsize(medlarge) angle(horizontal) format(%9.0f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(medlarge) tlcolor(white) tlength(zero) nogrid) by(, title(Tie strengh, size(vlarge) color(black)) note("")) by(, legend(off)) name(bar_tie_stem, replace) xsize(6) ysize(6) by(, graphregion(margin(small) fcolor(white) lcolor(white))) by(catg, rows(1)) subtitle(, size(large) nobox)
// graph export Figures\bar_tie_verbal_stem.png, as(png) replace

twoway (bar other_female referred, sort fcolor("165 229 230") lcolor(none) barwidth(0.8)) (rcap other_female_ll other_female_ul referred, sort lcolor("116 30 102") lwidth(medthick)) if area==1 & catg>0, ytitle("") yscale(noline) ylabel(0.1(0.1)0.7, labsize(medlarge) angle(horizontal) format(%9.1f) tlcolor(gs12) tlength(zero) glwidth(thin) glcolor(gs12) glpattern(solid) gmin gmax) xtitle("") xscale(range(-0.7 1.7)) xscale(noline) xlabel(0 `""Not" "referred""' 1 "Referred", labsize(medlarge) tlcolor(white) tlength(zero) nogrid) by(, title(Fraction women, size(vlarge) color(black)) note("")) by(, legend(off)) name(bar_female_stem, replace) xsize(6) ysize(6) by(, graphregion(margin(small) fcolor(white) lcolor(white))) by(catg, rows(1)) subtitle(, size(large) nobox)
// graph export Figures\bar_female_verbal_stem.png, as(png) replace


use data_referrals_gender.dta, clear

gen stem = own_ing==1 | own_program==70
egen count_otherid = rank(own_id), by(other_id area) unique
egen count_id = rank(other_id), by(own_id area) unique

egen avgscore = mean(other_score), by(own_id area)
egen sdscore = sd(other_score), by(own_id area)

sum avgscore if count_id == 1 & area == 1
local avgt = r(mean)
sum sdscore if count_id == 1 & area == 1
local sdt = r(mean)
gen score_std = (other_score - `avgt') / `sdt' if area == 1
sum avgscore if count_id == 1 & area == 2
local avgt = r(mean)
sum sdscore if count_id == 1 & area == 2
local sdt = r(mean)
replace score_std = (other_score - `avgt') / `sdt' if area == 2

egen avgtie = mean(tie), by(own_id area)
egen sdtie = sd(tie), by(own_id area)

sum avgtie if count_id == 1 & area == 1
local avgt = r(mean)
sum sdtie if count_id == 1 & area == 1
local sdt = r(mean)
gen tie_std = (tie - `avgt') / `sdt' if area == 1
sum avgtie if count_id == 1 & area == 2
local avgt = r(mean)
sum sdtie if count_id == 1 & area == 2
local sdt = r(mean)
replace tie_std = (tie - `avgt') / `sdt' if area == 2


