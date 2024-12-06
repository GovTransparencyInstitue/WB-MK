*******************************************************************
**# Generate Descriptive stats

*Total number of observations
quie count if filter_ok==1
local filter_nr = `r(N)'
// di `filter_nr'

*Years 
quie levelsof year if filter_ok==1
local year_first = substr(r(levels),1,4)
local year_last = substr(r(levels),-4,.)
local sep "-"
local years : list year_first | sep
local years : list years | year_last
// di "`years'"

*Unique buyers 
quie unique buyer_masterid if filter_ok==1
local unq_buyers_master `r(unique))'
quie unique buyer_id if filter_ok==1
local unq_buyers_gen `r(unique))'
// di `unq_buyers'

*Unique bidders 
quie unique bidder_masterid if filter_ok==1
local unq_bidders_master `r(unique))'
quie unique bidder_id if filter_ok==1
local unq_bidders_gen `r(unique))'
di `unq_bidders_master'
di `unq_bidders_gen'

sum cri if filter_ok
return list
local cri_mean `r(mean))'
local cri_sd `r(sd))'


*Missing rate: Locations (city/nuts), Bid price + Estimated prices
foreach var in buyer_city buyer_nuts bid_price {
di "`var'"
quie count if missing(`var') & filter_ok==1
local `var'_missrate = (`r(N)'/`filter_nr')*100
}

*******************************************************************
**# Copy results + Export to MK_202211_descriptives
cap frame drop desc
frame create desc

frame change desc
set obs 12
gen variable = ""
gen statistic = ""

replace variable = "country" in 1
replace statistic = "MK" in 1

replace variable = "years" in 2
replace statistic = "`years'" in 2

replace variable = "observations" in 3
replace statistic = "`filter_nr'" in 3

replace variable = "unq_buyers_master" in 4
replace statistic = "`unq_buyers_master'" in 4
replace variable = "unq_buyers_gen" in 5
replace statistic = "`unq_buyers_gen'" in 5

replace variable = "unq_bidders_master" in 6
replace statistic = "`unq_bidders_master'" in 6
replace variable = "unq_bidders_gen" in 7
replace statistic = "`unq_bidders_gen'" in 7

replace variable = "cri_mean" in 8
replace statistic = "`cri_mean'" in 8

replace variable = "cri_sd" in 9
replace statistic = "`cri_sd'" in 9


replace variable = "buyer_city_missrate" in 10
replace statistic = "`buyer_city_missrate'" in 10

replace variable = "buyer_nuts_missrate" in 11
replace statistic = "`buyer_nuts_missrate'" in 11

replace variable = "bid_price_missrate" in 12
replace statistic = "`bid_price_missrate'" in 12

export delimited "${data}/utility/MK_202212_descriptives.csv", replace
*******************************************************************
frame change default
