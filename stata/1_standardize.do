/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 10.03.2025
    Description: standardize raw data
*******************************************************************************/

//# preamble
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
	
// get a full dataset for standardizing
clear all
cls
use "dataset_reha.dta"
describe *
gsort own_id

gen own_low_ses = own_estrato == 1
gen own_med_ses = own_estrato == 2
gen own_high_ses = own_estrato == 3
gen other_low_ses = other_estrato == 1
gen other_med_ses = other_estrato == 2
gen other_high_ses = other_estrato == 3


gen own_fee = .
label values own_fee
levelsof own_program, local(program_values)
foreach val of local program_values {
    local program_name : label programalbl `val'
    
    /* Set fees based on program name */
    if "`program_name'" == "admin_empresas" replace own_fee = 472550 if own_program == `val'
    else if "`program_name'" == "admin_empresas_virtual" replace own_fee = 173190 if own_program == `val'
    else if "`program_name'" == "admin_empresas_dual" replace own_fee = 472550 if own_program == `val'
    else if "`program_name'" == "admin_turistica" replace own_fee = 397470 if own_program == `val'
    else if "`program_name'" == "cont_publica" replace own_fee = 220820 if own_program == `val'
    else if "`program_name'" == "cont_publica_virtual" replace own_fee = 173190 if own_program == `val'
    else if "`program_name'" == "economia" replace own_fee = 311570 if own_program == `val'
    else if "`program_name'" == "negocios_int" replace own_fee = 420660 if own_program == `val'
    else if "`program_name'" == "seguridad_salud" replace own_fee = 229650 if own_program == `val'
    else if "`program_name'" == "medicina" replace own_fee = 569830 if own_program == `val'
    else if "`program_name'" == "enfermeria" replace own_fee = 370970 if own_program == `val'
    else if "`program_name'" == "psicologia" replace own_fee = 453610 if own_program == `val'
    else if "`program_name'" == "artes_audio" replace own_fee = 497940 if own_program == `val'
    else if "`program_name'" == "com_social" replace own_fee = 472550 if own_program == `val'
    else if "`program_name'" == "lic_educacion" replace own_fee = 229650 if own_program == `val'
    else if "`program_name'" == "literat_virtual" replace own_fee = 285440 if own_program == `val'
    else if "`program_name'" == "musica" replace own_fee = 388640 if own_program == `val'
    else if "`program_name'" == "gastronomia" replace own_fee = 550580 if own_program == `val'
    else if "`program_name'" == "derecho" replace own_fee = 370970 if own_program == `val'
    else if "`program_name'" == "ing_biomedica" replace own_fee = 491320 if own_program == `val'
    else if "`program_name'" == "ing_mercados" replace own_fee = 350660 if own_program == `val'
    else if "`program_name'" == "ing_sistemas" replace own_fee = 427280 if own_program == `val'
    else if "`program_name'" == "ing_energia" replace own_fee = 410720 if own_program == `val'
    else if "`program_name'" == "ing_financiera" replace own_fee = 377600 if own_program == `val'
    else if "`program_name'" == "ing_industrial" replace own_fee = 424430 if own_program == `val'
    else if "`program_name'" == "ing_mecatronica" replace own_fee = 446050 if own_program == `val'
    else if "`program_name'" == "tecn_log_mercadeo" replace own_fee = 147530 if own_program == `val'
    else if "`program_name'" == "tecn_seguridad_salud" replace own_fee = 165710 if own_program == `val'
    else if "`program_name'" == "tecn_gest_gastronomica" replace own_fee = 220230 if own_program == `val'
    else if "`program_name'" == "tecn_inv_criminal" replace own_fee = 163570 if own_program == `val'
    else if "`program_name'" == "tecn_reg_farmacia" replace own_fee = 184950 if own_program == `val'
    else if "`program_name'" == "tecn_dir_comercial" replace own_fee = 147530 if own_program == `val'
}

gen other_fee = .
label values other_fee
levelsof other_program, local(program_values)
foreach val of local program_values {
    local program_name : label programalbl `val'
    
    /* Set fees based on program name */
    if "`program_name'" == "admin_empresas" replace other_fee = 472550 if other_program == `val'
    else if "`program_name'" == "admin_empresas_virtual" replace other_fee = 173190 if other_program == `val'
    else if "`program_name'" == "admin_empresas_dual" replace other_fee = 472550 if other_program == `val'
    else if "`program_name'" == "admin_turistica" replace other_fee = 397470 if other_program == `val'
    else if "`program_name'" == "cont_publica" replace other_fee = 220820 if other_program == `val'
    else if "`program_name'" == "cont_publica_virtual" replace other_fee = 173190 if other_program == `val'
    else if "`program_name'" == "economia" replace other_fee = 311570 if other_program == `val'
    else if "`program_name'" == "negocios_int" replace other_fee = 420660 if other_program == `val'
    else if "`program_name'" == "seguridad_salud" replace other_fee = 229650 if other_program == `val'
    else if "`program_name'" == "medicina" replace other_fee = 569830 if other_program == `val'
    else if "`program_name'" == "enfermeria" replace other_fee = 370970 if other_program == `val'
    else if "`program_name'" == "psicologia" replace other_fee = 453610 if other_program == `val'
    else if "`program_name'" == "artes_audio" replace other_fee = 497940 if other_program == `val'
    else if "`program_name'" == "com_social" replace other_fee = 472550 if other_program == `val'
    else if "`program_name'" == "lic_educacion" replace other_fee = 229650 if other_program == `val'
    else if "`program_name'" == "literat_virtual" replace other_fee = 285440 if other_program == `val'
    else if "`program_name'" == "musica" replace other_fee = 388640 if other_program == `val'
    else if "`program_name'" == "gastronomia" replace other_fee = 550580 if other_program == `val'
    else if "`program_name'" == "derecho" replace other_fee = 370970 if other_program == `val'
    else if "`program_name'" == "ing_biomedica" replace other_fee = 491320 if other_program == `val'
    else if "`program_name'" == "ing_mercados" replace other_fee = 350660 if other_program == `val'
    else if "`program_name'" == "ing_sistemas" replace other_fee = 427280 if other_program == `val'
    else if "`program_name'" == "ing_energia" replace other_fee = 410720 if other_program == `val'
    else if "`program_name'" == "ing_financiera" replace other_fee = 377600 if other_program == `val'
    else if "`program_name'" == "ing_industrial" replace other_fee = 424430 if other_program == `val'
    else if "`program_name'" == "ing_mecatronica" replace other_fee = 446050 if other_program == `val'
    else if "`program_name'" == "tecn_log_mercadeo" replace other_fee = 147530 if other_program == `val'
    else if "`program_name'" == "tecn_seguridad_salud" replace other_fee = 165710 if other_program == `val'
    else if "`program_name'" == "tecn_gest_gastronomica" replace other_fee = 220230 if other_program == `val'
    else if "`program_name'" == "tecn_inv_criminal" replace other_fee = 163570 if other_program == `val'
    else if "`program_name'" == "tecn_reg_farmacia" replace other_fee = 184950 if other_program == `val'
    else if "`program_name'" == "tecn_dir_comercial" replace other_fee = 147530 if other_program == `val'
}

label variable own_fee "UNAB 2025 fee per credit for own program (COP)"
label variable other_fee "UNAB 2025 fee per credit for other program (COP)"


bysort own_id: gen counter =_n // first occurrence

// Standardize scores within each own_id's network
foreach v of varlist tie {
    egen mean_`v' = mean(`v'), by(own_id)
    egen sd_`v' = sd(`v'), by(own_id)
	
	sum mean_`v' if counter == 1
	local avgt = r(mean)
	
	sum sd_`v' if counter == 1
	local sdt = r(mean)
	gen z_`v' = (`v' - `avgt') / `sdt'
}

drop counter
save "dataset_z.dta", replace

/***
// // network sizes differ slightly
// bysort own_id: gen r_counter =_n if  area == 1
// bysort own_id: gen m_counter =_n if  area == 2
// bysort own_id: egen net_size_r = max(r_counter) if area == 1
// bysort own_id: egen net_size_m = max(m_counter) if area == 2
//
// bysort own_id: egen __t = max(net_size_r)
// replace   net_size_r = __t
// drop __t
//
// bysort own_id: egen __t = max(net_size_m)
// replace   net_size_m = __t
// drop __t
//
// gen diff = net_size_m - net_size_r
// tab diff
// hist diff, bin(10) percent
//
// gen nom_r = nomination & area == 1
// gen nom_m = nomination & area == 2
// tab nom_r nom_m
***/

use "dataset_z.dta", clear

// table for reading and math referrers
preserve 
keep if nomination
bysort own_id: gen counter =_n // first occurrence

bysort own_id: egen __t = max(counter)
replace   counter = __t
drop __t
tab area counter
restore

// standardize
keep if area == 1
bysort own_id: gen counter =_n // first occurrence
foreach v of varlist other_gpa other_score_reading other_score_math  {
    egen mean_`v' = mean(`v'), by(own_id)
    egen sd_`v' = sd(`v'), by(own_id)
	
	sum mean_`v' if counter == 1
	local avgt = r(mean)
	
	sum sd_`v' if counter == 1
	local sdt = r(mean)
	gen z_`v' = (`v' - `avgt') / `sdt'
}

cls
tabstat z_other_gpa z_other_score_reading z_other_score_math z_tie, stat(mean sd semean n)

//# TABLE non-referred choice set VS referred VERBAL

tabstat z_other_gpa z_other_score_reading z_other_score_math z_tie other_low_ses other_med_ses other_high_ses other_female other_age if !nomination, stat(mean sd semean n)
tabstat z_other_gpa z_other_score_reading z_other_score_math z_tie other_low_ses other_med_ses other_high_ses other_female other_age if nomination, stat(mean sd semean n)
save "reading.dta", replace



clear all
cls
use "dataset_z.dta"

keep if area == 2
bysort own_id: gen counter =_n // first occurrence

// Standardize scores within each own_id's network
foreach v of varlist other_gpa other_score_reading other_score_math  {
    egen mean_`v' = mean(`v'), by(own_id)
    egen sd_`v' = sd(`v'), by(own_id)
	
	sum mean_`v' if counter == 1
	local avgt = r(mean)
	
	sum sd_`v' if counter == 1
	local sdt = r(mean)
	gen z_`v' = (`v' - `avgt') / `sdt'
}
cls
//# TABLE non-referred choice set VS referred MATH
tabstat z_other_gpa z_other_score_reading z_other_score_math  other_low_ses other_med_ses other_high_ses other_female other_age if !nomination, stat(mean sd semean n)
tabstat z_other_gpa z_other_score_reading z_other_score_math  other_low_ses other_med_ses other_high_ses other_female other_age if nomination, stat(mean sd semean n)
save "math.dta", replace
