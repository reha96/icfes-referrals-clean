/*******************************************************************************
   Project: icfes referrals 
   Author: Reha Tuncer
   Date: 13.05.2025
   Description: figure correlation of scores by tie
*******************************************************************************/
global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

clear all
set obs 30
gen tie_threshold = _n
gen correlation = .
gen se = .
gen n = .
gen prop_same = .
gen prop_sameUP = .
gen prop_sameLOW = .
gen connsUP = .
gen connsLOW = .
gen prop_lses = .
gen prop_mses = .
gen prop_hses = .
gen conns = .

tempfile temp2
save `temp2'

forvalues t = 1/30 {
   use "${dpath}reading.dta", clear
   append using "${dpath}math.dta"

   gen same_program = own_program == other_program
   gen same_ses = own_estrato == other_estrato
   keep if tie >= `t'

   bysort own_id: gen _t = _n
   by own_id: egen size = max(_t)
   drop _t
   replace size = size/2
   qui sum size
   local conns = r(mean)
   local connsUP = r(mean) + invnormal(0.975) * r(sd)/sqrt(r(N))
   local connsLOW = r(mean) - invnormal(0.975) * r(sd)/sqrt(r(N))
   
   bysort own_id: egen ind_prop_same = mean(same_program)
   bysort own_id: egen ind_prop_same_ses = mean(same_ses)
   bysort own_id: keep if _n == 1
   
   sum ind_prop_same
   local prop_same = r(mean)
   local prop_sameUP = r(mean) + invnormal(0.975) * r(sd)/sqrt(r(N))
   local prop_sameLOW = r(mean) - invnormal(0.975) * r(sd)/sqrt(r(N))
   
   sum ind_prop_same_ses if own_estrato == 1
   local prop_lses = cond(r(N) > 0, r(mean), .)
   
   sum ind_prop_same_ses if own_estrato == 2
   local prop_mses = cond(r(N) > 0, r(mean), .)
   
   sum ind_prop_same_ses if own_estrato == 3
   local prop_hses = cond(r(N) > 0, r(mean), .)
   
   quietly corr own_score other_score
   local corr_val = r(rho)
   local n_obs = r(N)
   
   if missing(`corr_val') {
       local corr_val = .
       local se_z = .
   }
   else {
       local z = 0.5 * ln((1 + `corr_val') / (1 - `corr_val'))
       local se_z = 1 / sqrt(`n_obs' - 3)
   } 
   
   preserve
   use `temp2', clear
   replace correlation = `corr_val' in `t'
   replace se = `se_z' in `t'
   replace n = `n_obs' in `t'
   replace prop_same = `prop_same' in `t'
   replace prop_sameUP = `prop_sameUP' in `t'
   replace prop_sameLOW = `prop_sameLOW' in `t'
   replace prop_lses = `prop_lses' in `t'
   replace prop_mses = `prop_mses' in `t'
   replace prop_hses = `prop_hses' in `t'
   replace conns = `conns' in `t'
   replace connsUP = `conns' in `t'
   replace connsLOW = `conns' in `t'
   save `temp2', replace
   restore
}

use `temp2', clear
gen upper = correlation + invnormal(0.975) * se
gen lower = correlation - invnormal(0.975) * se


twoway (scatter correlation tie_threshold, mcolor(gs8) msize(medium)) ///
      (qfit correlation tie_threshold, lcolor(dknavy) lwidth(medthick)) ///
      (rarea upper lower tie_threshold, color(gs4%20) lcolor(%0)), ///
      xlabel(0(5)30, grid) ylabel(, angle(0) grid) ///
      title("Own score and network correlation by courses taken") ///
      xtitle("Courses taken together") ///
      ytitle("Correlation") ///
      legend(off) ///
      graphregion(color(white)) bgcolor(white) ///
      name(correlation_plot, replace)
graph export "${fpath}score_correlation_by_tie.png", replace


twoway (connected prop_same tie_threshold if tie_threshold<20, lcolor(dknavy) mcolor(dknavy) msize(medium)) ///
		(rarea prop_sameUP prop_sameLOW tie_threshold if tie_threshold<20, color(gs4%20) lcolor(%0)) ///
      , ///
      xlabel(0(5)20, gmax gmin) ///
	  ylabel(, angle(0) grid) ///
      title("Connections within the same program") ///
      xtitle("Courses taken together") ///
      ytitle("Proportion same program") ///
      legend(off) ///
      graphregion(color(white)) bgcolor(white) ///
      name(share_same_program_by_tie, replace)  
graph export "${fpath}share_same_program_by_tie.png", replace
	   
	   
twoway (connected prop_lses tie_threshold if tie_threshold<20, lcolor(dknavy) mcolor(dknavy) msize(medium)) ///
	(connected prop_mses tie_threshold if tie_threshold<20, lcolor(orange) mcolor(orange) msize(medium)) ///
	(connected prop_hses tie_threshold if tie_threshold<20, lcolor(red) mcolor(red) msize(medium)) ///
      , ///
      xlabel(0(5)20, gmax gmin) ///
	  ylabel(.2(.1).6, angle(0) grid) ///
      title("Same-SES connections by courses taken together") ///
      xtitle("Courses taken together") ///
      ytitle("Proportion same-SES") ///
	  legend(order(1 "Low" 2 "Middle" 3 "High") ring(0) pos(12) rows(1) region(lcolor(none))) ///
      graphregion(color(white)) bgcolor(white) ///
      name(share_same_ses_by_tie, replace)  
graph export "${fpath}share_same_ses_by_tie.png", replace	   
	   
twoway (connected conns tie_threshold if tie_threshold<20, lcolor(dknavy) mcolor(dknavy) msize(medium)) ///
	(rarea connsUP connsLOW tie_threshold if tie_threshold<20, color(gs4%20) lcolor(%0)) ///
	  , ///
      xlabel(0(5)20, gmax gmin) ///
	  ylabel(0(25)250, angle(0) grid gmax) ///
      title("Connections by courses taken together") ///
      xtitle("Courses taken together") ///
      ytitle("Average connections") ///
	  legend(off) ///
      graphregion(color(white)) bgcolor(white) ///
      name(conns_by_tie, replace)  
graph export "${fpath}conns_by_tie.png", replace	   
	 