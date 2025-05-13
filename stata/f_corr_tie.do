/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 13.05.2025
    Description: figure correlation of scores by tie
*******************************************************************************/

global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

clear
set obs 30
gen tie_threshold = _n
gen correlation = .
gen se = .
gen n = .
tempfile temp2
save `temp2'

forvalues t = 1/30 {
    use "reading.dta", clear
    append using "math.dta"
    keep if tie >= `t'
    
    quietly corr own_score other_score
    local corr_val = r(rho)
    local n_obs = r(N)
    
    local z = 0.5 * ln((1 + `corr_val') / (1 - `corr_val')) // fisher transform
    local se_z = 1 / sqrt(`n_obs' - 3) // se for CI's
    
    qui {
        preserve
        use `temp2', clear
        replace correlation = `corr_val' in `t'
        replace se = `se_z' in `t'
        replace n = `n_obs' in `t'
        save `temp2', replace
        restore
    }
}

use `temp2', clear
gen upper = correlation + invnormal(0.975) * se
gen lower = correlation - invnormal(0.975) * se

twoway (scatter correlation tie_threshold, mcolor(gs8) msize(medium)) ///
       (qfit correlation tie_threshold, lcolor(dknavy) lwidth(medthick)) ///
       (rarea upper lower tie_threshold, color(gs4%20) lcolor(%0)), ///
       xlabel(0(5)30, grid) ylabel(, grid) ///
       title("Own score and network correlation by courses taken") ///
       xtitle("Courses taken together") ///
       ytitle("Correlation") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white)
	   
// Save the graph
graph export "${fpath}score_correlation_by_tie.png", replace
