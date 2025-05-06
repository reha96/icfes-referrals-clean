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
capture confirm variable other_program
if _rc == 0 {
    // Do the same replacements for other_program
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
 
}

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
    global fee_mean`i'S = (own_fee[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_se`i'S = (se[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_ci_lower`i'S = (own_fee[`i']/1000)*(0.240745)*avg_sem[`i'] - 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_ci_upper`i'S = (own_fee[`i']/1000)*(0.240745)*avg_sem[`i'] + 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']
} 
restore 

// admin
preserve
use "${dpath}dataset_z.dta", clear
sort own_id other_id
bysort other_id: gen counter = _n
keep if counter == 1
collapse (mean) other_fee avg_sem (sd) sd_fee=other_fee (count) n=other_fee (semean) se=other_fee, by(own_estrato)
forvalues i = 1/3 {
    global fee_mean`i'A = (other_fee[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_se`i'A = (se[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_ci_lower`i'A = (other_fee[`i']/1000)*(0.240745)*avg_sem[`i'] - 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_ci_upper`i'A = (other_fee[`i']/1000)*(0.240745)*avg_sem[`i'] + 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']
} 
restore 

use "${dpath}dataset_z.dta", clear
sort own_id other_id
bysort own_id: gen counter = _n
collapse (mean) other_fee avg_sem (sd) sd_fee=other_fee (count) n=other_fee (semean) se=other_fee, by(own_estrato)
forvalues i = 1/3 {
    global fee_mean`i' = (other_fee[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_sd`i' = (sd_fee[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_n`i' = n[`i']
    global fee_se`i' = (se[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_ci_lower`i' = (other_fee[`i']/1000)*(0.240745)*avg_sem[`i'] - 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']
    global fee_ci_upper`i' = (other_fee[`i']/1000)*(0.240745)*avg_sem[`i'] + 1.96*(se[`i']/1000)*(0.240745)*avg_sem[`i']
}

clear
set obs 3
gen own_estrato = _n
gen xpos = _n
gen fee = .
gen feeA = .
gen feeS = .
gen se = .
gen ci_lowerS = .
gen ci_upperS = .
gen ci_lowerA = .
gen ci_upperA = .
replace fee = ${fee_mean1} if own_estrato == 1
replace fee = ${fee_mean2} if own_estrato == 2
replace fee = ${fee_mean3} if own_estrato == 3
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



label define estrato_lab 1 "Low" 2 "Middle" 3 "High"
label values own_estrato estrato_lab
twoway (bar feeS xpos, barwidth(0.5) fcolor(gs10) lcolor(gs4)) ///
       (rcap ci_upperS ci_lowerS xpos, lcolor(gs4)) ///
       , ///
       xlabel(1 "Low" 2 "Middle" 3 "High") ///
       ylabel(1000(350)2500, angle(0) format(%9.0f) grid gmax gmin) ///
       ytitle("Yearly fee (USD)") ///
       xtitle("") ///
       title("Program Fees by SES") ///
       legend(off) ///
       graphregion(color(white)) bgcolor(white) ///
       xscale(range(0.5 3.5)) ///
       name(fee_by_ses, replace)
       
graph export "${fpath}fee_by_ses.png", replace
