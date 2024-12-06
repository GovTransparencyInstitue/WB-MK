// Load processed MK data 22 July 2024
// Aim of the script is to export CRI data using the same filtering as TED data to compare the CRI with other EU countries
frame change default
import delimited using "${data_processed}/MK_202212_processed.csv", encoding(UTF-8) clear 

**# Recreate filter ok (TED)
********************************************************************************
*Remove nonsensical names 

local nonsensical_names ""0.0" "NA" "-" "x" "xx" "xxx" "a" "A" "X" "XX" "---""
foreach var in bidder_name{

foreach nonsensical_name in `nonsensical_names'{
replace `var' = ustrregexra(`var',"^`nonsensical_name'$","", 1)
}
replace `var' = "" if `var'=="."
}

ren filter_ok filter_ok_main
********************************************************************************
* Generate main filter_ok_ted

// cap drop filter_ok_ted
cap gen filter_ok_ted_ted = 0
********************************************************************************
* Valid contract not missing name or any award date

replace filter_ok_ted = 1 if !missing(bidder_name) | !missing(ca_date_combined)
// ca_date_combined order: tender_publications_firstdcontra tender_awarddecisiondate tender_contractsignaturedate
********************************************************************************
* Remove cancelled records

replace filter_ok_ted = 0 if !missing(tender_cancellationdate)
********************************************************************************
* Open tender [Not used for the 2024 data version]

// if ("`version'" == "case_study") replace filter_ok_ted = 0 if opentender=="f"
********************************************************************************
* Framework filter (Not availble)
// local vars_check filter_framework
// foreach var in `vars_check'{
//     capture confirm variable `var'
// 	if (_rc==0) continue
// 	else gen `var' = 1
// }
// replace filter_ok_ted = 0 if filter_framework!="TRUE" 
********************************************************************************
* Low value contracts

* Thresholds from http://europam.eu/index.php?module=country-profile&country=European%20Union#info_PP
cap drop market_id
gen market_id=substr(tender_cpvs,1,2)

cap drop low_value_filter 
gen low_value_filter = 0 
replace low_value_filter =  1 if inlist(tender_supplytype,"GOODS","SUPPLIES","SERVICES") & (tender_digiwhist_price<139000)
replace low_value_filter =  1 if (inlist(tender_supplytype,"WORKS") | market_id=="45") & (tender_digiwhist_price<5350000)

// cap drop market_id

* Thresholds from http://europam.eu/index.php?module=country-profile&country=European%20Union#info_PP
// if ("`version'" == "cross_study") replace filter_ok_ted = 0 if low_value_filter==1  
replace filter_ok_ted = 0 if low_value_filter==1  
********************************************************************************
* Year Filter [Not used for the 2024 data version]

cap drop monthly
gen monthly = ym(year, month)
format monthly %tm
replace filter_ok_ted=0 if !inrange(monthly,ym(2011, 1),ym(2022,8))
tab filter_ok_ted
********************************************************************************
tab year if filter_ok_ted
collapse (mean) cri corr_singleb if filter_ok_ted==1, by (year)
save "${data_processed}/MK_202212_ted_cri.dta", replace

use "${data_processed}/MK_202212_ted_cri.dta", clear

gen country = "MK"
frame change default
********************************************************************************
**# Load up TED data and get the year CRI 

frame create CRI_yearly
frame change CRI_yearly
// use "C:\Ourfolders\Aly\TI_Health_covid_paper\data\TED_GTI_202407.dta", clear
use "C:\Ourfolders\Aly\TI_Health_covid_paper\data\TED_GTI_20240729.dta", clear


tab year if filter_ok

cap drop monthly
gen monthly = ym(year, month)
format monthly %tm
replace filter_ok=0 if !inrange(monthly,ym(2011, 1),ym(2022,8))
tab filter_ok


do "${codes}/utility/cri.do" corr_singleb corr_proc corr_decp corr_subm corr_nocft corr_tax_haven corr_buyer_concentration corr_benfords
collapse (mean) cri corr_singleb if filter_ok==1, by (year buyer_country)
rename buyer_country country
// drop if country=="MK"
replace country = "MK_TED" if country == "MK"
frameappend default
save "${data_processed}/TED_yearly_CRI_w_MK_update.dta", replace

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

// drop if inlist(country,"Moldova","Norway","Denmark")

set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox

// graph bar cri , by(country) asyvars ytitle("CRI", size(vsmall)) ylabel(,format(%-12.0fc))  stack legend(rows(2) pos(6))

graph hbar (mean) cri,  over(country, sort((mean) cri) lab(labsize(small) angle()))  ytitle(CRI) blabel(,format(%-12.0fc)) 
// graph export "${output_figures}/MK_TED_CRI_update.png", as(png) replace	
graph export "${output_figures}/MK_TED_CRI_update_smtime.png", as(png) replace	

graph hbar (mean) corr_singleb,  over(country, sort((mean) corr_singleb) lab(labsize(small) angle()))  ytitle(Single bidding) blabel(,format(%-12.0fc)) 
graph export "${output_figures}/MK_TED_sb_update_smtime.png", as(png) replace	

drop if inlist(country,"Norway","Denmark")

graph hbar (mean) cri,  over(country, sort((mean) cri) lab(labsize(small) angle()))  ytitle(CRI) blabel(,format(%-12.0fc))
// graph export "${output_figures}/MK_TED_CRI_update2.png", as(png) replace	
graph export "${output_figures}/MK_TED_CRI_update2_smtime.png", as(png) replace	

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

// graph hbar (asis) cri , over(country, sort(1) lab(labsize(small))  ) bar(1, bfcolor(none)) scheme(s1color)

// graph hbar (asis) cri , over(country, sort(1) lab(labsize(small))  ) bar(1, bfcolor(none)) ytitle(CRI)


cap drop highlight_cri
gen highlight_cri = 0 
replace highlight_cri =  1 if country == "Republic of North Macedonia" 

// graph hbar (asis) cri , over(country, sort(1) lab(labsize(small))  ) bar(1, bfcolor(none)) over(highlight_cri) ytitle(CRI) asyvars


**# Trying to highlight the CRI
// generate highlight_cri = cri if country == "Republic of North Macedonia"
//
//
// cap drop country_enc
// gsort cri
// cap label drop lab2
// egen country_enc = group(country)
// //  CREATE A VALUE LABEL FOR VAR2 FROM THE VALUES OF VAR1
// levelsof country_enc
// forvalues i = 1/`r(r)'{
//  levelsof country if country_enc==`i', local(country)
//  label define lab2 `i' `country', add
//  }
// label list lab2
// label values country_enc lab2
//
// twoway (bar cri country_enc, barwidth(0.8) color(gs10)) ///
//        (bar highlight_cri country_enc, barwidth(0.8) color(red)), ///
//         ytitle(CRI) ///
//        xlabel(, angle(45) ) sort(1)
//	   
// sort cri
//
// twoway (bar cri country_enc, barwidth(0.8) color(gs10)) ///
//        (bar germany_cri country_enc, barwidth(0.8) color(red)), ///
//        ytitle(CRI) ///
//        xlabel(, angle(45)) legend(off)
//
