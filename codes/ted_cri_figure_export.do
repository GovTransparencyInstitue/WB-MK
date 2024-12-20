frame change default
frame create CRI_yearly
frame change CRI_yearly

use  "${data_processed}/TED_yearly_CRI_w_MK_update.dta", clear


keep if inlist(country,"MD", "LU", "FR", "DE", "NL") | ///
inlist(country,"FI", "LV", "ES", "EE", "HU") | ///
inlist(country,"CH", "RO", "SE", "MK", "CY") | ///
inlist(country,"PT", "IE", "DK", "BE", "IS") | ///
inlist(country,"UK", "MT", "AT", "IT", "NO") | ///
inlist(country,"CZ", "SI", "HR", "PL", "LT") | ///
inlist(country,"BG", "SK")  

tab country

frame change CRI_yearly
cap frame drop CRI_average
frame copy CRI_yearly CRI_average
frame change CRI_average
collapse (mean) cri corr_singleb , by (country)
do "${codes_utility}/iso-to-country.do" country
replace country = "United Kingdom" if country =="UK"
replace country = "Moldova" if country =="Moldova (the Republic of)"
replace country = "Netherlands" if country =="Netherlands (the)"

drop if missing(cri)

set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox


cap drop corr_singleb_per
gen corr_singleb_per = corr_singleb*100

// graph hbar (mean) corr_singleb_per,  over(country, sort((mean) corr_singleb) lab(labsize(small) angle()))  ytitle(Single bidding) blabel(,format(%-12.0fc)) 

graph hbar (mean) corr_singleb_per, ///
    over(country, sort((mean) corr_singleb) lab(labsize(small) angle())) /// 
    ytitle("Single bidding (%)") /// Add y-axis title
    blabel(, format(%-12.0fc) /// Add labels with commas and format
	) 

// graph export "${output_figures}/MK_TED_sb_update2.png", as(png) replace	
graph export "${output_figures}/MK_TED_sb_update2_smtime.png", as(png) width(3000) height(1800) replace	
