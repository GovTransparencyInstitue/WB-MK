/*
Description: Bidder Entity Cleaning and matching 
*/

**# Bidders
frames reset
 
use "${data_processed}/MK_bidder_raw.dta", clear

**# Clean bidder name

cap drop bidder_name_clean
gen bidder_name_clean = bidder_name
replace bidder_name_clean = "" if bidder_name_clean =="null"

// Remove City name from the company name variable
local city_names ""на град Скопје" "Скопје" "Тетово" "и други" "NOVI SAD" "Zagreb" "Струмица" "Битола" "Skopje" "
foreach city_name in `city_names'{
    replace bidder_name_clean = ustrregexra(bidder_name_clean,"`city_name'"," ",1) 
}

// Remove .com
local websites ""\.com" "\.mk" "\.co\.uk""
foreach site in `websites'{
    replace bidder_name_clean = ustrregexra(bidder_name_clean,"`site'"," ",1) 
}

// Generate legal form
replace bidder_name_clean = " " + bidder_name_clean + " " 
cap drop legal_form
gen legal_form=""

local legal_forms Limited d\.?o\.?o\.?e\.?l \.?О\.?О\.?О\.?Е\.?Л Д\.?О\.?О\.?Е\.?Л\.? G\.?m\.?b\.?H Е\.?О\.?О\.?Д Ј\.?Т\.?Д Д\.?О\.?О О\.?О\.?Д O\.?O\.?D D\.?O\.?O d\.?o\.?o А\.?Д К\.?Д A\.?D

foreach legal_form in `legal_forms'{
replace legal_form = ustrregexs(1) if ustrregexm(bidder_name_clean, "([ .,-]?`legal_form'[ .,-]?)",1) & missing(legal_form)
replace bidder_name_clean = ustrregexra(bidder_name_clean,"[ .,-]?`legal_form'[ .,-]?"," ",1) 
}

// Remove all Symbols from cleaned name and legal form
local drop_list 33 34 35 36 37 38 39 40 41 42 43 44 45 6 7 58 59 60 61 62 63 64 91 92 93 94 95 96 123 124 125 126
foreach char in `drop_list'{
di "`char'"
di char(`char') 
replace bidder_name_clean = subinstr(bidder_name_clean,char(`char')," ",.)
replace legal_form = subinstr(legal_form,char(`char')," ",.)

}

local drop_list % ' , - \. ` ~ „
foreach char in `drop_list'{
di "`char'"
replace bidder_name_clean = ustrregexra(bidder_name_clean,"`char'"," ",1)
replace legal_form = ustrregexra(legal_form,"`char'"," ",1)

}
forval val=1/4{
replace bidder_name_clean = ustrregexra(bidder_name_clean,"  ","",1)
replace legal_form = ustrregexra(legal_form,"  ","",1)
}
replace bidder_name_clean = ustrlower(bidder_name_clean)
replace legal_form = ustrlower(legal_form)

replace bidder_name_clean = ustrregexra(bidder_name_clean," ","",1)
replace legal_form = ustrregexra(legal_form," ","",1)

replace legal_form = stritrim(legal_form)
replace legal_form = strtrim(legal_form)

replace legal_form = ustrtrim(legal_form)
replace legal_form = ustrregexra(legal_form," ","",1)


**# Standardize legalforms and cities

// Standarize legal forms
tab legal_form
replace legal_form="ад" if legal_form == "ad"
replace legal_form="доо" if legal_form == "doo"
replace legal_form="оод" if legal_form == "ood"

// Copy legal forms to empty entity names with missing legal form
// Most common
cap drop x
cap drop y

replace legal_form="," if missing(legal_form)
bys bidder_name_clean: egen x = nvals(legal_form)
gsort bidder_name_clean  -x
bys bidder_name_clean: replace  x = x[1] if missing(x)
bys bidder_name_clean legal_form: gen y = _N if legal_form!=","
gsort bidder_name_clean  -x -y
bys bidder_name_clean: replace  legal_form = legal_form[1] if legal_form==","
replace legal_form="" if legal_form==","

// Copy bidder_city_api to entity with missing city
// Most common
cap drop x
cap drop y

count if missing(bidder_state_api) 
count if missing(bidder_county_api) 
count if missing(bidder_city_api) 
count if missing(bidder_district_api) 
count if missing(bidder_street_api) 

cap drop bidder_location
egen bidder_location =  concat(bidder_state_api bidder_county_api bidder_city_api bidder_district_api bidder_street_api), punct(,)
replace bidder_location="" if bidder_location==",,,,"
replace bidder_location=subinstr(bidder_location,",,",",",.)
unique bidder_location

sort bidder_city
br bidder_city bidder_location
cap drop bidder_location


replace bidder_city_api="," if missing(bidder_city_api)

bys bidder_name_clean: egen x = nvals(bidder_city_api)
gsort bidder_name_clean  -x
bys bidder_name_clean: replace  x = x[1] if missing(x)
bys bidder_name_clean bidder_city_api: gen y = _N if bidder_city_api!=","
gsort bidder_name_clean  -x -y
bys bidder_name_clean: replace  bidder_city_api = bidder_city_api[1] if bidder_city_api==","
replace bidder_city_api="" if bidder_city_api==","
cap drop x
cap drop y

**# Generate ID
cap drop bidder_id
// tabstat bidder_id, stat(max)
egen bidder_id = group(bidder_name_clean legal_form bidder_city_api) //10292
sum bidder_id
local max `r(max)'

// For missing legal form 
cap drop buyer_id_ex
egen buyer_id_ex = group(bidder_name_clean bidder_city_api) if missing(bidder_id)
replace buyer_id_ex = `max' + buyer_id_ex if !missing(buyer_id_ex)
replace bidder_id = buyer_id_ex if missing(bidder_id)
sum bidder_id
local max `r(max)'

// For missing bidder city
cap drop buyer_id_ex
egen buyer_id_ex = group(bidder_name_clean legal_form) if missing(bidder_id)
replace buyer_id_ex = `max' + buyer_id_ex if !missing(buyer_id_ex)
replace bidder_id = buyer_id_ex if missing(bidder_id)
sum bidder_id
local max `r(max)'

// For missing bidder city + legal form
cap drop buyer_id_ex
egen buyer_id_ex = group(bidder_name_clean) if missing(bidder_id)
replace buyer_id_ex = `max' + buyer_id_ex if !missing(buyer_id_ex)
replace bidder_id = buyer_id_ex if missing(bidder_id)
*************************************
// ID Comparison
sort bidder_id
br bidder_id bidder_name_clean legal_form bidder_city_api
unique bidder_id 

unique bidder_id //16,742 Entity
unique bidder_masterid //129,014 Entity

cap drop x y
cap drop  buyer_id_ex

save "${data_processed}/MK_bidder_raw.dta", replace

cap frame drop bidders_export 
frame put bidder_masterid bidder_id bidder_name bidder_name_clean legal_form bidder_city bidder_country bidder_country_api bidder_state_api bidder_county_api bidder_city_api bidder_district_api bidder_street_api, into(bidders_export)

frame change bidders_export
sort bidder_masterid bidder_id
bys bidder_id: gen contract_count = _N
duplicates drop bidder_masterid, force

ren bidder_id bidder_id_assigned

export delimited "${data_processed}/MK_WB_bidders_202211.csv", replace

save "${data_processed}/MK_bidder_id_match.dta", replace
*************************************
*END