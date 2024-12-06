* Generate indicators corr_subm
local country `1'
local country MK

********************************************************************************
// Store indicator levels in local indicators_var
frame create corr_subm
frame change corr_subm

import excel "${data}\utility\CRI_components.xlsx", sheet("corr_subm") firstrow clear

foreach var in start end level{
destring `var', replace
}

keep if country == "`country'"
levelsof start if level==0, local(start_no_level)
levelsof end if level==0, local(end_no_level)

levelsof start if level==0.5, local(start_mid_level)
levelsof end if level==0.5, local(end_mid_level)

levelsof start if level==1, local(start_hi_level)
levelsof end if level==1, local(end_hi_level)

levelsof level if missing== "Yes" , local(missing_level)

frame change default
frame drop corr_subm
********************************************************************************
// Assign indicator

cap drop submp
gen submp = bid_deadline - first_cft_pub
label var submp "Advertisement period, days"
replace submp=. if submp<=0
replace submp=. if submp>365 //cap submission period to 1 year


cap drop corr_subm
gen corr_subm = .

di `start_no_level'
di `end_no_level'
replace corr_subm = 0 if submp>=`start_no_level' &  submp<=`end_no_level'

forval x=1/`: list sizeof start_mid_level' {
replace corr_subm = 0.5 if submp>=`: word `x' of `start_mid_level'' &  submp<=`: word `x' of `end_mid_level''
}

forval x=1/`: list sizeof start_hi_level' {
replace corr_subm = 1 if submp>=`: word `x' of `start_hi_level'' &  submp<=`: word `x' of `end_hi_level''
}

if inlist("`country'","MT") replace corr_subm = 1 if corr_subm==0.5


if !inlist("`missing_level'","") replace corr_subm = `missing_level' if missing(submp)

tabstat submp, by(corr_subm) stat(min mean max)
********************************************************************************
*END