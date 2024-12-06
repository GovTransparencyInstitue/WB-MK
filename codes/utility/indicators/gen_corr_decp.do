* Generate indicators corr_decp
local country `1'

********************************************************************************
// Store indicator levels in local indicators_var
frame create corr_decp
frame change corr_decp

import excel "${data}\utility\CRI_components.xlsx", sheet("corr_decp") firstrow clear

keep if country == "`country'"

levelsof start if level==0, local(start_no_level)
levelsof end if level==0, local(end_no_level)

levelsof start if level==0.5, local(start_mid_level)
levelsof end if level==0.5, local(end_mid_level)

levelsof start if level==1, local(start_hi_level)
levelsof end if level==1, local(end_hi_level)

levelsof level if missing== "Yes" , local(missing_level)


frame change default
frame drop corr_decp
********************************************************************************
// Assign indicator

cap drop decp
gen decp= ca_date_combined - bid_deadline
// aw_date
replace decp=0 if decp<0 & decp!=0
replace decp=. if decp>730 //cap at 2 years
lab var decp "Decision period, days"

cap drop corr_decp
gen corr_decp = .


replace corr_decp = 0 if decp>=`start_no_level' &  decp<=`end_no_level'

forval x=1/`: list sizeof start_mid_level' {
replace corr_decp = 0.5 if decp>=`: word `x' of `start_mid_level'' &  decp<=`: word `x' of `end_mid_level''
}

forval x=1/`: list sizeof start_hi_level' {
replace corr_decp = 1 if decp>=`: word `x' of `start_hi_level'' &  decp<=`: word `x' of `end_hi_level''
}


if !inlist("`missing_level'","") replace corr_decp = `missing_level' if missing(decp)

tabstat decp, by(corr_decp) stat(min mean max)
********************************************************************************
*END