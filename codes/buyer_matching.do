/*
Description: Buyers Entity Cleaning and matching 
*/

**# Buyers
frames reset 

use "${data_processed}/MK_buyer_raw.dta", clear

**# Clean Buyer name
br buyer_name
sort buyer_name

cap drop buyer_name_clean
gen buyer_name_clean = buyer_name 

local drop_list 33 34 35 36 37 38 39 40 41 42 43 44 45 6 7 58 59 60 61 62 63 64 91 92 93 94 95 96 123 124 125 126
foreach char in `drop_list'{
di "`char'"
di char(`char') 
replace buyer_name_clean = subinstr(buyer_name_clean,char(`char')," ",.)
}

local drop_list % ' , - \. ` ~ „
foreach char in `drop_list'{
di "`char'"
replace buyer_name_clean = ustrregexra(buyer_name_clean,"`char'"," ",1)
}
// forval val=1/4{
// replace buyer_name_clean = ustrregexra(buyer_name_clean,"  "," ",1)
// }
replace buyer_name_clean = ustrlower(buyer_name_clean)
replace buyer_name_clean = ustrregexra(buyer_name_clean," ","",1)
*************************************
**# The grouping location variable

sort buyer_city buyer_country
br buyer_city *api*

tab buyer_state_api, m // only 1 state - not using  
tab buyer_county_api, m 
tab buyer_city_api, m 
tab buyer_district_api, m 
tab buyer_street_api, m 

cap drop buyer_location
egen buyer_location =  concat(buyer_county_api buyer_city_api buyer_district_api buyer_street_api), punct(,)
replace buyer_location="" if buyer_location==",,,"
replace buyer_location=subinstr(buyer_location,",,",",",.)
unique buyer_location

tab buyer_city_api if !missing(buyer_district_api)
tab buyer_city if missing(buyer_location)
tab buyer_location
************************************* 
**# Generate Buyer id based on uncleaned variables
egen buyer_id_1 = group(buyer_name buyer_city) 
sum buyer_id_1
local max `r(max)'
cap drop buyer_id_ex
egen buyer_id_ex = group(buyer_name) if missing(buyer_id_1)
replace buyer_id_ex = `max' + buyer_id_ex if !missing(buyer_id_ex)
replace buyer_id_1 = buyer_id_ex if missing(buyer_id_1)

// Generate Buyer id based on cleaned variables
egen buyer_id_2 = group(buyer_name_clean buyer_location) 
sum buyer_id_2
local max `r(max)'
cap drop buyer_id_ex
egen buyer_id_ex = group(buyer_name_clean) if missing(buyer_id_2)
replace buyer_id_ex = `max' + buyer_id_ex if !missing(buyer_id_ex)
replace buyer_id_2 = buyer_id_ex if missing(buyer_id_2)

cap drop buyer_id_ex
*************************************
// ID comparison

unique buyer_id_1 //1544
unique buyer_id_2 //1539

drop buyer_id_1
ren buyer_id_2 buyer_id

sort buyer_id
br buyer_id buyer_name_clean buyer_city_api

unique buyer_id //1,542 Entity
unique buyer_masterid //2,505 Entity

// drop buyer_name_clean

save "${data_processed}/MK_buyer_raw.dta", replace

cap frame drop buyers_export
frame put buyer_masterid buyer_id buyer_name buyer_name_clean buyer_city buyer_country  buyer_country_api buyer_state_api buyer_county_api buyer_city_api buyer_district_api buyer_street_api, into(buyers_export)

frame change buyers_export
order buyer_masterid buyer_id buyer_name buyer_name_clean buyer_city buyer_country  buyer_country_api buyer_state_api buyer_county_api buyer_city_api buyer_district_api buyer_street_api
sort buyer_masterid buyer_id
bys buyer_id: gen contract_count = _N
duplicates drop buyer_masterid, force

ren buyer_id buyer_id_assigned

export delimited "${data_processed}/MK_WB_buyers_202211.csv", replace

duplicates drop buyer_masterid, force
save "${data_processed}/MK_buyer_id_match.dta", replace
*************************************