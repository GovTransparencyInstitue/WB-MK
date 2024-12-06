// Import Manual location fixes from Manua_location_fixes.csv

// Store indicator levels in local indicators_var
frame create test
frame change test

import delimited using "${data}/utility/Manua_location_fixes.csv", encoding(UTF-8) varnames(1) clear 

quie count
local rows `r(N)'

forval x=1/`rows'{
    levelsof city in `x', local(city_raw_`x')
	local city_raw_`x' "`: word 1 of `city_raw_`x'''"
    
	levelsof country_api in `x', local(country_api_`x')
	local country_api_`x' "`: word 1 of `country_api_`x'''"
    
	levelsof state_api in `x', local(state_api_`x')
	local state_api_`x' "`: word 1 of `state_api_`x'''"

    levelsof county_api in `x', local(county_api_`x')
	local county_api_`x' "`: word 1 of `county_api_`x'''"

    levelsof district_api in `x', local(district_api_`x') 
	local district_api_`x' "`: word 1 of `district_api_`x'''"

	levelsof street_api in `x', local(street_api_`x') 
	local street_api_`x' "`: word 1 of `street_api_`x'''"

}

forval x=1/`rows' {
di "`city_raw_`x''"
di "`country_api_`x''"
di "`county_api_`x''"
di "`city_api_`x''"
di "`state_api_`x''"
di "`street_api_`x''"
di "`district_api_`x''"

}

// di "`city_raw_5'"
// di "`country_api_5'"

frame change default

forval x=1/`rows' {
replace country_api = "`country_api_`x''" if city=="`city_raw_`x''" & missing(country_api)
replace state_api  = "`state_api_`x''" if city=="`city_raw_`x''" & missing(state_api)
replace county_api  = "`county_api_`x''" if city=="`city_raw_`x''" & missing(county_api)
replace city_api  = "`city_api_`x''" if city=="`city_raw_`x''" & missing(city_api)
replace district_api  = "`district_api_`x''" if city=="`city_raw_`x''" & missing(district_api)
replace street_api  = "`street_api_`x''" if city=="`city_raw_`x''" & missing(street_api)
}


replace country_api = "MKD" if city=="Р'ЖАНИЧИНО" & missing(country_api)
replace state_api  = "" if city=="Р'ЖАНИЧИНО" & missing(state_api)
replace county_api  = "Skopski" if city=="Р'ЖАНИЧИНО" & missing(county_api)
replace city_api  = "Petrovec" if city=="Р'ЖАНИЧИНО" & missing(city_api)
replace district_api  = "" if city=="Р'ЖАНИЧИНО" & missing(district_api)
replace street_api  = "Ulica Rzanicino" if city=="Р'ЖАНИЧИНО" & missing(street_api)


// di `city_raw_5'
// di `country_api_5'
// di `state_api_5'
// di `county_api_5'
// di `district_api_5'
// di `street_api_5'

frame drop test