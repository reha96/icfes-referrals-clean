/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 01.04.2025
    Description: figure program fees by ses
*******************************************************************************/
global dpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/stata/"
global fpath "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently


use "${dpath}dataset_z.dta", clear
capture confirm variable avg_sem
if _rc != 0 {
gen avg_sem = 17.5 // Default value for any unlisted program

// Assign program-specific semester credits using the exact label values
replace avg_sem = 18 if own_program == 10  // admin_empresas
replace avg_sem = 18 if own_program == 20  // admin_empresas_virtual
replace avg_sem = 22 if own_program == 30  // admin_empresas_dual
replace avg_sem = 19 if own_program == 40  // admin_turistica
replace avg_sem = 18 if own_program == 50  // cont_publica
replace avg_sem = 18 if own_program == 60  // cont_publica_virtual
replace avg_sem = 18 if own_program == 70  // economia
replace avg_sem = 17 if own_program == 80  // negocios_int
replace avg_sem = 16 if own_program == 90  // seguridad_salud
replace avg_sem = 25 if own_program == 100  // medicina
replace avg_sem = 20 if own_program == 110  // enfermeria
replace avg_sem = 17 if own_program == 120  // psicologia
replace avg_sem = 17.5 if own_program == 130  // est_generales (using default as not in list)
replace avg_sem = 18 if own_program == 140  // artes_audio
replace avg_sem = 18 if own_program == 150  // com_social
replace avg_sem = 20 if own_program == 160  // lic_educacion
replace avg_sem = 16 if own_program == 170  // literat_virtual
replace avg_sem = 16 if own_program == 180  // musica
replace avg_sem = 17 if own_program == 190  // gastronomia
replace avg_sem = 17.5 if own_program == 200  // derecho
replace avg_sem = 17 if own_program == 210  // ing_biomedica
replace avg_sem = 17 if own_program == 220  // ing_mercados
replace avg_sem = 16 if own_program == 230  // ing_sistemas
replace avg_sem = 17 if own_program == 240  // ing_energia
replace avg_sem = 17 if own_program == 250  // ing_financiera
replace avg_sem = 17 if own_program == 260  // ing_industrial
replace avg_sem = 17 if own_program == 270  // ing_mecatronica
replace avg_sem = 17.5 if own_program == 280  // gest_sistem_info (using default as not in list)
replace avg_sem = 17 if own_program == 290  // tecn_dir_comercial
replace avg_sem = 17 if own_program == 300  // tecn_log_mercadeo
replace avg_sem = 17 if own_program == 310  // tecn_seguridad_salud
replace avg_sem = 20 if own_program == 320  // tecn_gest_gastronomica
replace avg_sem = 17 if own_program == 330  // tecn_inv_criminal
replace avg_sem = 17 if own_program == 340  // tecn_reg_farmacia
replace avg_sem = 17.5 if own_program == 350  // tecn_gest_humana (using default as not in list)

// Also assign values for other_program if it exists
    gen other_avg_sem = 17.5
    replace other_avg_sem = 18 if other_program == 10  // admin_empresas
	replace other_avg_sem = 18 if other_program == 20  // admin_empresas_virtual
	replace other_avg_sem = 22 if other_program == 30  // admin_empresas_dual
	replace other_avg_sem = 19 if other_program == 40  // admin_turistica
	replace other_avg_sem = 18 if other_program == 50  // cont_publica
	replace other_avg_sem = 18 if other_program == 60  // cont_publica_virtual
	replace other_avg_sem = 18 if other_program == 70  // economia
	replace other_avg_sem = 17 if other_program == 80  // negocios_int
	replace other_avg_sem = 16 if other_program == 90  // seguridad_salud
	replace other_avg_sem = 25 if other_program == 100  // medicina
	replace other_avg_sem = 20 if other_program == 110  // enfermeria
	replace other_avg_sem = 17 if other_program == 120  // psicologia
	replace other_avg_sem = 17.5 if other_program == 130  // est_generales (using default as not in list)
	replace other_avg_sem = 18 if other_program == 140  // artes_audio
	replace other_avg_sem = 18 if other_program == 150  // com_social
	replace other_avg_sem = 20 if other_program == 160  // lic_educacion
	replace other_avg_sem = 16 if other_program == 170  // literat_virtual
	replace other_avg_sem = 16 if other_program == 180  // musica
	replace other_avg_sem = 17 if other_program == 190  // gastronomia
	replace other_avg_sem = 17.5 if other_program == 200  // derecho
	replace other_avg_sem = 17 if other_program == 210  // ing_biomedica
	replace other_avg_sem = 17 if other_program == 220  // ing_mercados
	replace other_avg_sem = 16 if other_program == 230  // ing_sistemas
	replace other_avg_sem = 17 if other_program == 240  // ing_energia
	replace other_avg_sem = 17 if other_program == 250  // ing_financiera
	replace other_avg_sem = 17 if other_program == 260  // ing_industrial
	replace other_avg_sem = 17 if other_program == 270  // ing_mecatronica
	replace other_avg_sem = 17.5 if other_program == 280  // gest_sistem_info (using default as not in list)
	replace other_avg_sem = 17 if other_program == 290  // tecn_dir_comercial
	replace other_avg_sem = 17 if other_program == 300  // tecn_log_mercadeo
	replace other_avg_sem = 17 if other_program == 310  // tecn_seguridad_salud
	replace other_avg_sem = 20 if other_program == 320  // tecn_gest_gastronomica
	replace other_avg_sem = 17 if other_program == 330  // tecn_inv_criminal
	replace other_avg_sem = 17 if other_program == 340  // tecn_reg_farmacia
	replace other_avg_sem = 17.5 if other_program == 350  // tecn_gest_humana (using default as not in list)
 
save "${dpath}dataset_z.dta", replace
}
// sample
preserve
use "${dpath}dataset_z.dta", clear
sort own_id other_id
bysort own_id: gen counter = _n
keep if counter == 1
collapse (mean) own_fee avg_sem (sem) se=own_fee, by(own_estrato)
forvalues i = 1/3 {
    global fee_mean`i'S = (own_fee[`i']/1000)*(0.240745)*avg_sem[`i']*2
    global fee_se`i'S = (se[`i']/1000)*(0.240745)*avg_sem[`i']*2
    global fee_ci_lower`i'S = (own_fee[`i']/1000)*(0.240745)*avg_sem[`i']*2 - 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']*2
    global fee_ci_upper`i'S = (own_fee[`i']/1000)*(0.240745)*avg_sem[`i']*2 + 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']*2
} 
restore 

// admin
preserve
use "${dpath}dataset_z.dta", clear
sort own_id other_id
bysort other_id: gen counter = _n
keep if counter == 1
collapse (mean) other_fee other_avg_sem (sd) sd_fee=other_fee (count) n=other_fee (semean) se=other_fee, by(other_estrato)
forvalues i = 1/3 {
    global fee_mean`i'A = (other_fee[`i']/1000)*(0.240745)*other_avg_sem[`i']*2
    global fee_se`i'A = (se[`i']/1000)*(0.240745)*other_avg_sem[`i']*2
    global fee_ci_lower`i'A = (other_fee[`i']/1000)*(0.240745)*other_avg_sem[`i']*2 - 1.96*(se[`i']/1000)*(0.240745)*other_avg_sem[`i']*2
    global fee_ci_upper`i'A = (other_fee[`i']/1000)*(0.240745)*other_avg_sem[`i']*2 + 1.96*(se[`i']/1000)*(0.240745)*other_avg_sem[`i']*2
} 
restore 


clear
set obs 3
gen own_estrato = _n
gen xpos = _n
gen feeA = .
gen feeS = .
gen ci_lowerS = .
gen ci_upperS = .
gen ci_lowerA = .
gen ci_upperA = .
replace feeA = ${fee_mean1A} if own_estrato == 1
replace feeA = ${fee_mean2A} if own_estrato == 2
replace feeA = ${fee_mean3A} if own_estrato == 3
replace feeS = ${fee_mean1S} if own_estrato == 1
replace feeS = ${fee_mean2S} if own_estrato == 2
replace feeS = ${fee_mean3S} if own_estrato == 3
replace ci_lowerS = ${fee_ci_lower1S} if own_estrato == 1
replace ci_lowerS = ${fee_ci_lower2S} if own_estrato == 2
replace ci_lowerS = ${fee_ci_lower3S} if own_estrato == 3
replace ci_upperS = ${fee_ci_upper1S} if own_estrato == 1
replace ci_upperS = ${fee_ci_upper2S} if own_estrato == 2
replace ci_upperS = ${fee_ci_upper3S} if own_estrato == 3
replace ci_lowerA = ${fee_ci_lower1A} if own_estrato == 1
replace ci_lowerA = ${fee_ci_lower2A} if own_estrato == 2
replace ci_lowerA = ${fee_ci_lower3A} if own_estrato == 3
replace ci_upperA = ${fee_ci_upper1A} if own_estrato == 1
replace ci_upperA = ${fee_ci_upper2A} if own_estrato == 2
replace ci_upperA = ${fee_ci_upper3A} if own_estrato == 3


twoway (bar feeA xpos, barwidth(0.5) fcolor(gs10) lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(3000(500)5000, angle(0) format(%9.0f) grid gmax gmin) ///
       ytitle("Yearly fee (USD)") ///
       xtitle("") ///
       title("Average yearly fees by SES") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(fee_by_ses, replace)
       
graph export "${fpath}fee_by_ses.png", replace


// by share of high-SES in program
use "${dpath}dataset_z.dta", clear
bysort other_id: gen counter = _n
keep if counter == 1
replace other_fee = (other_fee/1000)*(0.240745)*avg_sem*2
collapse (mean) other_fee other_avg_sem (count) n=other_fee, by(other_program)

egen med = median(other_fee)
egen lqt = pctile(other_fee), p(25)
egen uqt = pctile(other_fee), p(75)
egen iqr = iqr(other_fee)
egen mean = mean(other_fee)
gen ypos = -0.5
gen l = other_fee if(other_fee >= lqt-1.5*iqr)
egen ls = min(l)
gen u = other_fee if(other_fee <= uqt+1.5*iqr)
egen us = max(u)

twoway (histogram other_fee, frequency fcolor(gs10) bins(10) lcolor(gs4) lwidth(thin)) ///
      (rbar lqt uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.25)) ///
      (rbar med uqt ypos, horiz fcolor(gs10) lcolor(gs4) barw(.25)) ///
      (rspike lqt ls ypos, horiz lcolor(gs4)) ///
      (rspike uqt us ypos, horiz lcolor(gs4)) ///
      (rcap ls ls ypos, horiz msize(*1) lcolor(gs4)) ///
      (rcap us us ypos, horiz msize(*1) lcolor(gs4)) ///
      (scatter ypos mean, msymbol(o) msize(*.5) fcolor(gs4) mcolor(gs4)) ///
      (pcarrowi 2.5 6000 1.5 6085, lwidth(medthick) color(dknavy) msize(2) barbsize(0) mcolor(navy)) ///
      , ///
      xlabel(1000(1000)7000, angle(0) format(%9.0f) gmax gmin) ///
      ylabel(0(2)10, gmax angle(0)) ///
      ytitle("Frequency of programs") ///
      xtitle("Yearly fee (USD)") ///
      title("Programs by yearly fee") ///
      legend(off) ///
      text(2.8 6000 "Medicine", color(dknavy)) ///
      graphregion(color(white)) bgcolor(white) ///
      name(fees_with_boxplot, replace)

graph export "${fpath}fees_with_boxplot.png", replace

// highses share
clear all
use "${dpath}dataset_z.dta", clear
bysort other_id: gen counter = _n
keep if counter == 1
replace other_fee = (other_fee/1000)*(0.240745)*other_avg_sem*2

gen fee_category = .
replace fee_category = 1 if other_fee < 1500
replace fee_category = 2 if other_fee >= 1500 & other_fee < 2500
replace fee_category = 3 if other_fee >= 2500 & other_fee < 3500
replace fee_category = 4 if other_fee >= 3500 & other_fee < 4500
replace fee_category = 5 if other_fee >= 4500 & other_fee < 5500
replace fee_category = 6 if other_fee >= 5500 

proportion fee_category if other_estrato == 3
matrix high = r(table)

proportion fee_category if other_estrato == 2
matrix mid = r(table)

proportion fee_category if other_estrato == 1
matrix low = r(table)

collapse (mean) other_fee, by(fee_category)

gen prop_low = .
gen prop_mid = .
gen prop_high = .
forvalues i = 1/`=_N' {
	replace prop_low = low[1,`i']*100 in `i'
	replace prop_mid = mid[1,`i']*100 in `i'
	replace prop_high = high[1,`i']*100 in `i'
}

// Create position variables for side-by-side bars
gen xpos_low = fee_category - 0.25
gen xpos_mid = fee_category
gen xpos_high = fee_category + 0.25

// Create the side-by-side bar chart
twoway (bar prop_low xpos_low, barwidth(0.25) fcolor(gs8) lcolor(gs4)) ///
		(bar prop_mid xpos_mid, barwidth(0.25) fcolor(gs11) lcolor(gs4)) ///
		(bar prop_high xpos_high, barwidth(0.25) fcolor(gs14) lcolor(gs4)) ///
       , ///
       ylabel(0(10)50, angle(0) grid gmax gmin) ///
       xlabel(1 "1200-1500" 2 "1500-2500" 3 "2500-3500" 4 "3500-4500" 5 "4500-5500" 6 "5500+", angle(0) labsize(small)) ///
       ytitle("Percent share") ///
       xtitle("Yearly fee (USD)") ///
       title("Student distribution by program fee") ///
       legend(order(1 "Low-SES" 2 "Mid-SES" 3 "High-SES") ring(0) pos(12) rows(1) region(lcolor(none))) ///
       graphregion(color(white)) bgcolor(white) ///
       name(ses_distribution_by_fees, replace)

// Export the graph
graph export "${fpath}ses_distribution_by_fees.png", replace

ksmirnov prop_low = prop_mid
ksmirnov prop_low = prop_high
ksmirnov prop_mid = prop_high


