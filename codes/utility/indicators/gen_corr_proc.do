* Generate indicators corr_proc
local country `1'

********************************************************************************
// Store indicator levels in local indicators_var
frame create corr_proc
frame change corr_proc

local country "MK"

import excel "${data}\utility\CRI_components.xlsx", sheet("corr_proc") firstrow clear
keep if country == "`country'"

local indicators_var_levels_no
local indicators_var_levels_mid
local indicators_var_levels_hi

local ind_var

preserve
	drop if missing(var_levels_no)
	levelsof var_levels_no, local(indicators_var_levels_no)
restore

preserve
	drop if missing(var_levels_mid)
	levelsof var_levels_mid, local(indicators_var_levels_mid)
restore

preserve
	drop if missing(var_levels_hi)
	levelsof var_levels_hi, local(indicators_var_levels_hi)
restore


frame change default
frame drop corr_proc
********************************************************************************
// Assign indicator

gen ca_prodecure = tender_natproctype
replace ca_prodecure = "NA" if missing(tender_nationalproceduretype)


cap drop corr_proc
gen corr_proc = .

foreach ind_var_level in  `indicators_var_levels_no'{
replace corr_proc = 0  if ca_prodecure == "`ind_var_level'"
}

foreach ind_var_level in  `indicators_var_levels_mid'{
replace corr_proc = 0.5  if ca_prodecure == "`ind_var_level'"
}

foreach ind_var_level in  `indicators_var_levels_hi'{
replace corr_proc = 1  if ca_prodecure == "`ind_var_level'"
}

cap drop ca_prodecure
********************************************************************************
*END