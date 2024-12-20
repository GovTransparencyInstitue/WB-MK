/*
Project Title: MK - Entity IDs
Author: Aly Abdou & Klea Ibrahimi
Date: 7th October 2022

Description: This project generates entity ids for the MK data
*/
clear all
cap program drop _all

**# Initialize Project folder
init_project "Folder_path" "MK_WB"

**# Load Global Macros
// cd "C:/Ourfolders/Aly/MK_WB"
do "./codes/utility/config_macros.do"
macro list

use "${data}/processed/MK_202212_processed.dta", replace

**# CRI validation

foreach var in  corr_singleb corr_ben corr_decp corr_subm corr_proc taxhav3{
gen y`var' = `var'
replace y`var' = y`var'*2
replace y`var' = 9 if missing(`var')
tab y`var' 
}

global controls i.cvalue10 i.anb_type i.ca_type i.anb_location i.year i.market_id
global options vce(robust)
global sub_sample filter_ok 

foreach var in corr_ben corr_decp corr_subm corr_proc taxhav3{
global dep_vars i.y`var'
logit corr_singleb $dep_vars $controls if $sub_sample, $options
}

logit corr_singleb ycorr_decp $controls if $sub_sample, $options

sum w_ycsh4 if  $sub_sample
di `r(mean)'
gen yw_ycsh4= w_ycsh4
replace  yw_ycsh4 = `r(mean)' if missing(w_ycsh4)

logit corr_singleb yw_ycsh4 $controls if $sub_sample, $options

global dep_vars yw_ycsh4 i.ycorr_ben i.ytaxhav3 i.ycorr_decp  i.ycorr_subm i.ycorr_proc
logit corr_singleb $dep_vars $controls if $sub_sample, $options

cap drop ycorr_ben ycorr_decp ycorr_subm ycorr_proc ytaxhav3 yw_ycsh4

// do "${codes}/figures_paper.do" 

**# Descriptive Tables and Figure + comparison with previous dataset
do "${codes}/descriptives.do" 
do "${codes}/figures_paper.do" 
do "${codes}/figures_corruption_risks.do" 

**# Cost of corruption risks calculation
do "${codes}/coc_calculations.do" 

**# Filter the data in the same way as TED to create a comparable CRI
do "${codes}/ted_cri_figure_export.do" 

