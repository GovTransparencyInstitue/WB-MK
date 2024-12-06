*****************************************************************
/*This script uses the tender/contract titles to find the
 relevant cpv code using token string matching*/
*****************************************************************
frames reset
frame create pp_data
frame change pp_data

use "${data}/processed/MK_202211_processed.dta", clear

keep persistent_id tender_id lot_id tender_title lot_title tender_cpvs market_id_num
replace tender_cpvs = "" if regex(tender_cpvs,"^99")
replace market_id_num = "" if regex(market_id_num,"^99")
keep if missing(tender_cpvs)
drop tender_cpvs market_id_num
gen search_text = tender_title + " " +lot_title 
do "${codes}/utility/clean_str.do" search_text
cap drop unique_id
egen unique_id=group(search_text)

save "${data}/processed/cpv_match/pp_full.dta", replace 

keep unique_id search_text
duplicates drop search_text, force
keep if !missing(search_text)
// unique  title
// unique unqiue_id

save  "${data}/processed/cpv_match/pp_nodup.dta", replace 
*****************************************************************
frame create cpv_mk
frame change cpv_mk

import delimited using "${data}/utility/cpv_2007_translated.csv", clear varnames(1)

do "${codes}/utility/clean_str.do" cpv_desc_mk
drop if missing(cpv_desc_mk)
cap drop unique_id_cpv
egen unique_id_cpv=group(cpv_desc_mk)
drop cpv_desc_en
duplicates drop cpv_desc_mk, force
save "${data}/processed/cpv_match/cpv_match_mk.dta", replace 
*****************************************************************
// Match the pp data with no duplicates with the cpv_match_mk data
frame change pp_data

cap drop unique_id_cpv cpv_desc_mk simil_token _m
use "${data}/processed/cpv_match/pp_nodup.dta", replace
matchit unique_id search_text using  "${data}/processed/cpv_match/cpv_match_mk.dta" , idusing(unique_id_cpv) txtusing(cpv_desc_mk) sim(token) w(root) score(jaccard) g(simil_token) stopw swt(0.9) time flag(10) t(0.2) over  
gsort - simil_token
format search_text cpv_desc_mk %50s
br search_text cpv_desc_mk simil_token
drop if simil_token<0.47
gsort unique_id -simil_token
duplicates drop unique_id, force

// bys unique_id: gen count=_n
// keep if count==1
// drop count
di _N

// Merge with cpv data to get the cpv code
merge m:1 unique_id_cpv using "${data}/processed/cpv_match/cpv_match_mk.dta", generate(_m) keepusing(cpv_codes)
drop if _m==2

keep unique_id cpv_codes
unique unique_id

save "${data}/processed/cpv_match/matches1.dta", replace

*Merging back with full dataset
use "${data}/processed/cpv_match/pp_full.dta", replace
merge m:1 unique_id using "${data}/processed/cpv_match/matches1.dta", generate(_m) keepusing(cpv_codes)
drop _m

ren cpv_codes cpv_codes_m1

save "${data}/processed/cpv_match/pp_full.dta", replace 

*****************************************************************
//  2nd matching 

use "${data}/processed/cpv_match/pp_full.dta", replace

keep if missing(cpv_codes_m1)
keep unique_id search_text
duplicates drop search_text, force
keep if !missing(search_text)

save  "${data}/processed/cpv_match/pp_nodup.dta", replace 

matchit unique_id search_text using  "${data}/processed/cpv_match/cpv_match_mk.dta" , idusing(unique_id_cpv) txtusing(cpv_desc_mk) sim(token) w(root) score(jaccard) g(simil_token) stopw swt(0.9) time flag(10) t(0.2) over  
gsort - simil_token
format search_text cpv_desc_mk %50s
br search_text cpv_desc_mk simil_token
drop if simil_token<0.31
gsort unique_id -simil_token
duplicates drop unique_id, force

// bys unique_id: gen count=_n
// keep if count==1
// drop count
di _N

// Merge with cpv data to get the cpv code
merge m:1 unique_id_cpv using "${data}/processed/cpv_match/cpv_match_mk.dta", generate(_m) keepusing(cpv_codes)
drop if _m==2

keep unique_id cpv_codes
unique unique_id

save "${data}/processed/cpv_match/matches2.dta", replace

*Merging back with full dataset
use "${data}/processed/cpv_match/pp_full.dta", replace
merge m:1 unique_id using "${data}/processed/cpv_match/matches2.dta", generate(_m) keepusing(cpv_codes)
drop _m

ren cpv_codes cpv_codes_m2

gen tender_cpvs_matched = cpv_codes_m1
replace tender_cpvs_matched = cpv_codes_m2 if missing(tender_cpvs_matched)

keep persistent_id tender_id lot_id tender_cpvs_matched

count if missing(tender_cpvs_matched)
di `r(N)'/_N
keep if !missing(tender_cpvs_matched)

save "${data}/processed/cpv_match/pp_full_to_match.dta", replace 

*****************************************************************
*Merging back with full dataset 
frames reset

use "${data}/processed/MK_202211_processed.dta", clear

merge 1:1  persistent_id tender_id lot_id using "${data}/processed/cpv_match/pp_full_to_match.dta", generate(_m) keepusing(tender_cpvs_matched) keep(1 3)

replace tender_cpvs_matched = tender_cpvs if missing(tender_cpvs_matched) 

drop market_id market_id_num 
cap drop market_id
gen market_id = substr(tender_cpvs_matched,1,2)
tab market_id // 36.47% missing

gen market_id_old = substr(tender_cpvs,1,2)
tab market_id_old // 53.61% missing

cap drop tender_cpvs
cap drop market_id_old
ren tender_cpvs_matched tender_cpvs
br *cpv*

save "${data}/processed/MK_202211_processed.dta", replace
*****************************************************************

br *title* *cpv*

*END
count if missing(tender_cpvs_original) // 255,362
count if missing(tender_cpvs_original) & market_id!="99" // 81,673
di 81673/255362  //32%