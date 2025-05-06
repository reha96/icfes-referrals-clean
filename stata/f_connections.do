/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 01.04.2025
    Description: figure connections and classes together
*******************************************************************************/

global lowSES "255 99 132"    // Pink/red for low SES
global medSES "54 162 235"    // Blue for medium SES
global highSES "75 192 112"   // Green for high SES
global reading "130 202 157" 
global math "136 132 216"
global path "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

use "dataset_z.dta", clear

bysort own_id: gen counter =_n
bysort own_id: egen connections = max(counter)
replace connections = connections/2 // networks are repeated for math and reading
sort own_id other_id
keep if counter == 1

collapse (mean) connections mean_tie, by(own_semester)
twoway (area connections own_semester, color(gs10)) ///
       (line mean_tie own_semester, yaxis(2) lcolor(dknavy) lwidth(medthick)), ///
       xlabel(1(2)11, nogrid) ///
       ylabel(0(50)300, angle(0) grid gmin ) ///
       ylabel(0(2)10, angle(0) axis(2)) ///
       ytitle("Connections") ///
       ytitle("Courses taken", axis(2)) ///
       xtitle("Semesters") ///
       legend(order(1 "Connections" 2 "Courses taken") ///
              ring(0) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       name(connection_tie, replace)

graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/connections.png", replace
