/*
Description: City Standardization for the MK dataset
*/
frames reset
**# Get all cities from buyers and bidders 
use "${data_processed}/MK_buyer_raw.dta", clear
drop buyer_country
gen buyer_country = "MK"
cap drop *api*
frame put buyer_city buyer_country, into(buyer_city)

use "${data_processed}/MK_bidder_raw.dta", clear
cap drop *api*

// Fix bidder country 
tab bidder_country, m  //106,790 missing the bidder_country
replace bidder_country = "MK" if missing(bidder_country) & ustrregexm(bidder_city,"с[\. ]",1) 
replace bidder_country = "MK"  if missing(bidder_country) & ustrregexm(bidder_city,"Скопје",1) 
replace bidder_country = "MK"  if missing(bidder_country) & ustrregexm(bidder_city,"Strelci",1) 

frame put bidder_city bidder_country, into(bidder_city)
clear 

//Append into one dataframe
foreach frame in buyer bidder{
frame `frame'_city{
	ren `frame'_city city
	ren `frame'_country country
	gen type = "`frame'"
	drop if missing(city)
}
frameappend `frame'_city, drop
}

**# Send cities to API
duplicates drop 
drop if city=="null"
gen city_clean = city + " " +country
// sample 5, count

export delimited using "${data_processed}/stata_city.csv", replace

! ${R_path} "${codes_utility}/locate_region.R" "${data}/processed" en 
// & pause
local dir `c(pwd)'
cd "${data_processed}"
! rename "MK_cities_api_en.csv" "MK_cities_api_en_1.csv" 
cd `dir'


**# Structure resulting dataframe
import delimited using "${data_processed}/MK_cities_api_en_1.csv", encoding(UTF-8) varnames(1) clear 
foreach var in country_api state_api county_api city_api district_api street_api{
	replace `var'="" if `var'=="NULL"
}

**# Send the missing results to API a second time using city only as the search term
keep if missing(country_api) & missing(state_api) & missing(county_api) & missing(city_api) & missing(district_api) & missing(street_api)
drop city_clean country_api state_api county_api city_api district_api street_api
gen city_clean = city 

export delimited using "${data_processed}/stata_city.csv", replace

! ${R_path} "${codes_utility}/locate_region.R" "${data}/processed" en 
// & pause
local dir `c(pwd)'
cd "${data_processed}"
! rename "MK_cities_api_en.csv" "MK_cities_api_en_2.csv" 
cd `dir'


**# append the city dataframes
import delimited using "${data_processed}/MK_cities_api_en_1.csv", encoding(UTF-8) varnames(1) clear 
foreach var in country_api state_api county_api city_api district_api street_api{
	replace `var'="" if `var'=="NULL"
}
drop if missing(country_api) & missing(state_api) & missing(county_api) & missing(city_api) &  missing(district_api) &  missing(street_api)

frame create frame_2
frame change frame_2
import delimited using "${data_processed}/MK_cities_api_en_2.csv", encoding(UTF-8) varnames(1) clear 
foreach var in country_api state_api county_api city_api country district_api street_api{
	tostring `var', replace
	replace `var'="" if `var'=="NULL"
	replace `var'="" if missing(`var')
}
frame change default 
frameappend frame_2, drop

**# Manually Fixing cities that were not found
tab city if missing(state_api) & missing(county_api) & missing(city_api) &  missing(district_api)
br if missing(state_api) & missing(county_api) & missing(city_api) &  missing(district_api)
do "${codes_utility}/manual_fix_locations.do" 

save "${data_processed}/MK_cities_api_en.dta", replace
export delimited using "${data_processed}/MK_cities_api_en.csv", replace

erase "${data_processed}/MK_cities_api_en_1.csv"
erase "${data_processed}/MK_cities_api_en_2.csv"
erase "${data_processed}/stata_city.csv"


**# Merge to dataset 
// Bidders
use "${data_processed}/MK_bidder_raw.dta", clear
gen city = bidder_city
cap drop *api*
// Fix bidder country 
gen country = bidder_country
replace country = "MK" if missing(bidder_country) & ustrregexm(bidder_city,"с[\. ]",1) 
replace country = "MK"  if missing(bidder_country) & ustrregexm(bidder_city,"Скопје",1) 
replace country = "MK"  if missing(bidder_country) & ustrregexm(bidder_city,"Strelci",1) 
gen type = "bidder"
merge m:1 city country type using "${data_processed}/MK_cities_api_en.dta", nogen keep(1 3)  keepusing(country_api state_api county_api city_api  district_api street_api)
drop city country type
ren *api bidder_*api
save "${data_processed}/MK_bidder_raw.dta", replace

// Buyers
use "${data_processed}/MK_buyer_raw.dta", clear
cap drop *api*
gen city = buyer_city
gen country = "MK"
gen type = "buyer"
merge m:1 city country type using "${data_processed}/MK_cities_api_en.dta", nogen keep(1 3)  keepusing(country_api state_api county_api city_api  district_api street_api)
drop city country type
ren *api buyer_*api

save "${data_processed}/MK_buyer_raw.dta", replace

*END

//City Standardization Stats
use "${data_processed}/MK_cities_api_en.dta", clear
unique city if !missing(city) //1306
unique city if !missing(city) & type=="buyer" //173
unique city if !missing(city) & type=="bidder" //1212

unique city country if !missing(city) //1429
unique city country if !missing(city) & type=="buyer" //173
unique city country if !missing(city) & type=="bidder" //1331

unique city_api if !missing(city_api) //291
unique city_api if !missing(city_api) & type=="buyer" //70
unique city_api if !missing(city_api) & type=="bidder" //289

unique country_api state_api county_api city_api district_api street_api if !missing(city_api) //764
unique country_api state_api county_api city_api district_api street_api if !missing(city_api) & type=="buyer" //132
unique country_api state_api county_api city_api district_api street_api if !missing(city_api) & type=="bidder" //738
