* Generate indicators corr_ben

// Theoretical mad values and conformity
// Close conformity — 0.000 to 0.004
// Acceptable conformity — 0.004 to 0.008
// Marginally acceptable conformity — 0.008 to 0.012
// Nonconformity — greater than 0.012
********************************************************************************
local country `1'

********************************************************************************
// Store indicator levels in local indicators_var
frame create corr_ben
frame change corr_ben

import excel "${data}\utility\CRI_components.xlsx", sheet("corr_ben") firstrow clear
keep if country == "`country'"
levelsof var, local(calc_type)
di `calc_type'

if (`calc_type'=="MAD_conformitiy") {

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

}

if (`calc_type'=="MAD") {

levelsof start if level==0, local(start_no_level)
levelsof end if level==0, local(end_no_level)

levelsof start if level==0.5, local(start_mid_level)
levelsof end if level==0.5, local(end_mid_level)

levelsof start if level==1, local(start_hi_level)
levelsof end if level==1, local(end_hi_level)

}

frame change default
frame drop corr_ben
*****************************************************************
// Export variables for Benford calculation
save "${data}/processed/wip.dta", replace

preserve
//     rename //using buyer_id variable
    rename bid_price ca_contract_value //bid price variable
    keep if filter_ok==1 
    keep if !missing(ca_contract_value)
	keep if !missing(buyer_id)
    bys buyer_id: gen count = _N
    keep if count >100
    keep buyer_id ca_contract_value
	order buyer_id ca_contract_value
	export delimited  "${data}/processed/buyers_for_R.csv", replace
	! ${R_path} ${codes_utility}/benford.R ${data_processed}
restore


// use "${data}/processed/buyers_benford.dta"
// rename buyer_id buyer_masterid
// save "${data}/processed/buyers_benford.dta", replace
// 

// Merge Benford variables

use "${data}/processed/wip.dta", clear

cap drop MAD_conformitiy MAD 
merge m:1 buyer_id using "${data}/processed/buyers_benford.dta", keep(1 3) 
drop _m
*****************************************************************
cap drop corr_ben
gen corr_ben = .


if (`calc_type'=="MAD_conformitiy") {

foreach ind_var_level in  `indicators_var_levels_no'{
replace corr_ben = 0  if MAD_conformitiy == "`ind_var_level'"
}

foreach ind_var_level in  `indicators_var_levels_mid'{
replace corr_ben = 0.5  if MAD_conformitiy == "`ind_var_level'"
}

foreach ind_var_level in  `indicators_var_levels_hi'{
replace corr_ben = 1  if MAD_conformitiy == "`ind_var_level'"
}

replace corr_ben = . if missing(MAD_conformitiy)

}
tab corr_ben MAD_conformitiy

if (`calc_type'=="MAD") {


forval x=1/`: list sizeof start_no_level' {
replace corr_ben = 0 if MAD>=`: word `x' of `start_no_level'' &  MAD<=`: word `x' of `end_no_level''
}

forval x=1/`: list sizeof start_mid_level' {
replace corr_ben = 0.5 if MAD>=`: word `x' of `start_mid_level'' &  MAD<=`: word `x' of `end_mid_level''
}

forval x=1/`: list sizeof start_hi_level' {
replace corr_ben = 1 if MAD>=`: word `x' of `start_hi_level'' &  MAD<=`: word `x' of `end_hi_level''
}

// replace corr_ben = 0 if MAD>=`start_no_level' &  MAD<=`end_no_level'
// replace corr_ben = 0.5 if MAD>=`start_mid_level' &  MAD<=`end_mid_level'
// replace corr_ben = 1 if MAD>=`start_hi_level'

replace corr_ben = . if missing(MAD)
}
tabstat MAD, by(corr_ben) stat(min mean max)
********************************************************************************
// Clean up
cap erase "${data}/processed/buyers_benford.dta"
cap erase "${data}/processed/buyers_benford.csv"
cap erase "${data}/processed/buyers_for_R.csv"
cap erase "${data}/processed/wip.dta"
********************************************************************************
*END