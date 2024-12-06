/*
Project Title: MK - Entity IDs
Author: Aly Abdou 
Date: 7th October 2022

Description: This project generates entity ids for the MK data
*/
clear all
cap program drop _all

**# Initialize Project folder
init_project "C:/Ourfolders/Aly" "MK_WB"

**# Load Global Macros
// cd "C:/Ourfolders/Aly/MK_WB"
do "./codes/utility/config_macros.do"
macro list

**# Prep starting data

//Data used 7th of October 2022: 0:/08akkiGH/1_DATA/MK_North_Macedonia/MK_data_raw20220201.zip - in which you find a digiwhist-mk-2022_01_31.csv
//10th November 2022 - A new data update /08akkiGH/1_DATA/MK_North_Macedonia/MK_202211.zip

// import delimited using "${data_raw}/MK_202211_1stpresentation_data/MK_202211.csv", encoding(UTF-8) clear 

//18th November 2022 - Newer data update 
// Notes from Gergo
// i found a few hundred records that could not be inserted into the database because they contained some special characters in the description or title fields. i added proper escaping to the scraping code and this is now ok
// scraping is finished
// i added a new parsing class to process those assigned contracts that do not have a related contract notice or award decision. these include the 2 types that Bence highlighted from an earlier export but i also found a few other types

// /08akkiGH/1_DATA/MK_North_Macedonia/MK_202211.zip

// import delimited using "${data_raw}/MK_202211_20221118/MK_data_202211.csv", encoding(UTF-8) clear 

//25th November 2022 - Newer data update 
// fixed the missing bidder names issue 

import delimited using "${data_raw}/MK_202211_20221125/MK_data_202211.csv", encoding(UTF-8) clear 

frame put buyer_masterid buyer_name buyer_city buyer_country buyer_postcode, into(buyer)

frame put bidder_masterid bidder_name bidder_city bidder_country , into(bidder)

foreach frame in buyer bidder{
frame `frame'{
drop if missing(`frame'_masterid)
save "${data_processed}/MK_`frame'_raw.dta", replace
}
}

frames reset 
**# Standardizing Cities
do "${codes}/city_standardization.do"
clear

**# Matching Buyers
do "${codes}/buyer_matching.do" 
//From 2,505 Entity to 1,542 Entity

**# Matching Bidders
do "${codes}/bidder_matching.do" 
//From 129,014 Entity to 16,742 Entity

**# Merge to main
frames reset
// import delimited using "${data_raw}/MK_202211/MK_202211.csv", encoding(UTF-8) clear 
// import delimited using "${data_raw}/MK_202211_20221118/MK_data_202211.csv", encoding(UTF-8) clear 

import delimited using "${data_raw}/MK_202211_20221125/MK_data_202211.csv", encoding(UTF-8) clear 

cap drop buyer_id bidder_id

// Match generated buyer id
merge m:1 buyer_masterid using "${data_processed}/MK_buyer_id_match.dta", nogen keep(1 3)  keepusing(buyer_id_assigned buyer_country_api buyer_state_api buyer_county_api buyer_city_api buyer_district_api buyer_street_api)

// Match generated bidder id
merge m:1 bidder_masterid using "${data_processed}/MK_bidder_id_match.dta", nogen keep(1 3) keepusing(bidder_id_assigned legal_form bidder_country_api bidder_state_api bidder_county_api bidder_city_api bidder_district_api bidder_street_api)  

ren *_id_assigned *_id

sort bidder_id
// br bidder_masterid bidder_id bidder_name
// br buyer_masterid buyer_id buyer_name 


**# Add a random bidder name + id for missing bidder names 
replace bidder_name="" if bidder_name=="null"
/* skipped for now (29/11/22) because we basically have a contract level data, so those extra records missing a bidder name are not contract awards inspite the lot_status_being awarded
gsort bidder_id 
sum bidder_id
local max `r(max)'
cap drop x
cap drop y
gen y = missing(bidder_id)
replace y  = 2 if y==1 & (!inlist(lot_status,"CANCELLED") & missing(tender_cancellationdate) & !missing(tender_publications_lastcontract))
bys y: gen x = _n if missing(bidder_id) & !inlist(lot_status,"CANCELLED") & missing(tender_cancellationdate) & !missing(tender_publications_lastcontract)
replace x = `max' + x if !missing(x)

replace bidder_name = "bidder_"+string(x) if y==2
replace bidder_id = x if y==2
cap drop x y
*/

**# Calculate CRI
do "${codes}/date_var_restructure.do"
do "${codes}/gen_controls.do"

set seed 35847352
do "${codes}/gen_cri.do" "MK"  

save "${data}/processed/MK_202211_processed.dta", replace
use "${data}/processed/MK_202211_processed.dta", clear

do "${codes}/export_first_draft_data.do"

**# Improve CPV codes
// On 12 Feb 2023 added a second export to supplement the tender_cpvs
// done using the matchit code on 5th of March 2023
do "${codes}/cpv_matchit_mk.do"

// use "${data}/processed/MK_202211_processed.dta", clear
// keep persistent_id tender_id lot_id tender_title lot_title tender_cpvs market_id_num
// replace tender_cpvs = "" if regex(tender_cpvs,"^99")
// replace market_id_num = "" if regex(market_id_num,"^99")
// keep if missing(tender_cpvs)
// export delimited "${data}/processed/MK_cpvs_to_fix.csv", replace
// do "${codes}/cpv_fix_mk.do"   // not used using python instead - also the python code wasn't used

do "${codes}/export_second_draft_data.do"


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
// do "${codes}/figures.do" 

**# Cost of corruption risks calculation
do "${codes}/coc_calculations.do" 

**# Filter the data in the same way as TED to create a comparable CRI
do "${codes}/ted_cri_export.do" 

**# Update the figures 
do "${codes}/figures_paper_v2.do" 

save "${data}/processed/MK_202212_processed.dta", replace

**# Save data to FTP server
local ftp_save_folder "/08akkiGH/1_DATA/MK_North_Macedonia"
local filename "MK_202211_processed"
//Save dta
save "${data}/processed/`filename'.dta", replace
//Save csv
export delimited "${data}/processed/`filename'.csv", replace
//Zip files
//csv
!"C:/Program Files/7-Zip/7z.exe" a -tgzip "${data}/processed/`filename'.csv.gz" "${data}/processed/`filename'.csv"