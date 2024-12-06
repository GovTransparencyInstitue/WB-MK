* Generate indicators corr_singleb
local country `1'

********************************************************************************
// Store indicator levels in local indicators_var

frame create corr_singleb
frame change corr_singleb

import excel "${data}\utility\CRI_components.xlsx", sheet("corr_singleb") firstrow clear
keep if country == "`country'"
local indicators_var
local ind_var
levelsof var, local(indicators_vars)

frame change default
frame drop corr_singleb
********************************************************************************
// Assign indicator

cap drop corr_singleb
gen corr_singleb = 0
foreach ind_var in  `indicators_vars'{

replace corr_singleb = 1 if `ind_var'==1
replace corr_singleb = . if missing(`ind_var')

}

