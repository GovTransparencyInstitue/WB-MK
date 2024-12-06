* Generate indicators corr_nocft
local country `1'

********************************************************************************
// Store indicator levels in local indicators_var

frame create corr_nocft
frame change corr_nocft

import excel "${data}\utility\CRI_components.xlsx", sheet("corr_nocft") firstrow clear
keep if country == "`country'"

local indicators_var
local ind_var
levelsof var, local(indicators_var)
levelsof interacted, local(interaction)
global interaction_cond `interaction'

frame change default
frame drop corr_nocft
********************************************************************************
// Assign indicator

cap drop corr_nocft
gen corr_nocft = 0

foreach ind_var in  `indicators_var'{

if inlist("`ind_var'","tender_publications_firstcallfor","notice_url") replace corr_nocft = 1 if missing(`ind_var')
if inlist("`ind_var'","submp") replace corr_nocft = 1 if submp <=0 | submp==.

}

if (regex("$interaction_cond","=") | regex("$interaction_cond","inlist")) {
cap drop corr_nocft2
gen corr_nocft2=0
replace corr_nocft2 = corr_nocft if $interaction_cond
cap drop corr_nocft
rename corr_nocft2 corr_nocft
}

********************************************************************************
*END