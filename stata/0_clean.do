/*******************************************************************************
    Project: icfes referrals 
    Author: Reha Tuncer
    Date: 04.02.2025
    Description: clean raw data
*******************************************************************************/

//# preamble
version 18
clear all
macro drop _all
set more off
set scheme s2color, permanently
set maxvar 32767

// Get the current working directory
use "dataset_reha.dta"
