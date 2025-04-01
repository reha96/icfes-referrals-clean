/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 01.04.2025
    Description: figure perf admin sample network
*******************************************************************************/

global lowSES "255 99 132"    // Pink/red for low SES
global medSES "54 162 235"    // Blue for medium SES
global highSES "75 192 112"   // Green for high SES
global reading "130 202 157" 
global math "136 132 216"
global path "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/"
set scheme s2color, permanently

foreach i in score_math score_reading gpa {
    // Set measure name for graph titles and filenames
    local measure_title = cond("`i'"=="score_reading", "Reading", ///
                             cond("`i'"=="score_math", "Math", "GPA"))
    local measure_filename = lower(subinstr("`measure_title'", " ", "_", .))
    
    // sample
    use "dataset_z.dta", clear
    bysort own_id: gen counter =_n
    keep if counter == 1
    tabstat own_`i', by(own_estrato) stat(mean sd semean n) save
    
    forvalues ses = 1/3 {
        matrix `i'_sample_`ses' = r(Stat`ses')
        global `i'_sample_mean_`ses' = `i'_sample_`ses'[1,1]
        global `i'_sample_sd_`ses' = `i'_sample_`ses'[2,1]
        global `i'_sample_n_`ses' = `i'_sample_`ses'[4,1]
    }
    
    // admin
    use "dataset_z.dta", clear
    bysort other_id: gen counter =_n
    keep if counter == 1
    tabstat other_`i', by(own_estrato) stat(mean sd semean n) save
    
    forvalues ses = 1/3 {
        matrix `i'_admin_`ses' = r(Stat`ses')
        global `i'_admin_mean_`ses' = `i'_admin_`ses'[1,1]
        global `i'_admin_sd_`ses' = `i'_admin_`ses'[2,1]
        global `i'_admin_n_`ses' = `i'_admin_`ses'[4,1]
    }
    
    // network
    use "dataset_z.dta", clear
    tabstat other_`i', by(own_estrato) stat(mean sd semean n) save
    
    forvalues ses = 1/3 {
        matrix `i'_net_`ses' = r(Stat`ses')
        global `i'_net_mean_`ses' = `i'_net_`ses'[1,1]
        global `i'_net_sd_`ses' = `i'_net_`ses'[2,1]
        global `i'_net_n_`ses' = `i'_net_`ses'[4,1]
    }
    
    // Now create the graph within the same loop iteration
    preserve
    clear
    set obs 9
    gen ses = ceil(_n/3)
    gen source = mod(_n-1, 3) + 1
    gen zscore = .
    gen se = .
    gen ci_lower = .
    gen ci_upper = .
    
    // Fill in data for all SES levels and sources
    forvalues s = 1/3 {  // SES levels (1=Low, 2=Middle, 3=High)
        // Admin data
        replace zscore = ${`i'_admin_mean_`s'} if ses==`s' & source==1
        replace se = ${`i'_admin_sd_`s'}/sqrt(${`i'_admin_n_`s'}) if ses==`s' & source==1
        
        // Sample data
        replace zscore = ${`i'_sample_mean_`s'} if ses==`s' & source==2
        replace se = ${`i'_sample_sd_`s'}/sqrt(${`i'_sample_n_`s'}) if ses==`s' & source==2
        
        // Network data
        replace zscore = ${`i'_net_mean_`s'} if ses==`s' & source==3
        replace se = ${`i'_net_sd_`s'}/sqrt(${`i'_net_n_`s'}) if ses==`s' & source==3
    }
    
    // Calculate CI
    replace ci_lower = zscore - 1.96*se
    replace ci_upper = zscore + 1.96*se
    
    // Set positions for bars
    gen pos = .
    // Low SES
    replace pos = 1 if ses==1 & source==1
    replace pos = 2 if ses==1 & source==2
    replace pos = 3 if ses==1 & source==3
    // Middle SES
    replace pos = 5 if ses==2 & source==1
    replace pos = 6 if ses==2 & source==2
    replace pos = 7 if ses==2 & source==3
    // High SES
    replace pos = 9 if ses==3 & source==1
    replace pos = 10 if ses==3 & source==2
    replace pos = 11 if ses==3 & source==3
    
    // Add labels
    label define ses_lab 1 "Low" 2 "Middle" 3 "High"
    label values ses ses_lab
    label define source_lab 1 "Admin" 2 "Sample" 3 "Network"
    label values source source_lab
    
    // Create graph
    twoway (bar zscore pos if source==1, barwidth(0.8) color("${lowSES}")) /// Admin - Purple
           (bar zscore pos if source==2, barwidth(0.8) color("${medSES}")) /// Sample - Green
           (bar zscore pos if source==3, barwidth(0.8) color("${highSES}")) /// Network - Yellow
           (rcap ci_upper ci_lower pos, lcolor(gs4)), ///
           xlabel(2 "Low" 6 "Middle" 10 "High", noticks) ///
           ylabel(, angle(0)) ///
           ytitle("`measure_title'") ///
           xtitle("") ///
           title("`measure_title' by Data Source") ///
           legend(order(1 "Administrative" 2 "Sample" 3 "Network") ring(0) pos(2) rows(1) region(lcolor(none))) ///
           graphregion(color(white)) bgcolor(white) ///
           xsize(8) ysize(5) ///
           name(`i'_comparison, replace)
    
    graph export "/Users/reha.tuncer/Documents/GitHub/icfes-referrals/figures/`measure_filename'_admin_sample_network.png", replace
    restore
}
