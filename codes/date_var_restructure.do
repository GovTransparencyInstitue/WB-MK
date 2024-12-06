*Restructure date variables 

*Generate empty date var if variable is missing from dataset

local dt_vars tender_publications_firstcallfor tender_biddeadline tender_publications_firstcontrac tender_awarddecisiondate tender_contractsignaturedate 
foreach dt in `dt_vars'{
count if missing(`dt')
if (r(N)/_N==1){
	cap drop `dt'
	gen `dt' = "1800/12/12"
} 
else continue
}


* Generate vars in correct date format
foreach dt in first_cft_pub bid_deadline ca_date aw_date sign_date first_cft_pub{
cap drop `dt'
}
gen first_cft_pub = date(tender_publications_firstcallfor,"YMD")
gen bid_deadline = date(tender_biddeadline,"YMD")
gen ca_date = date(tender_publications_firstcontrac,"YMD")
gen aw_date = date(tender_awarddecisiondate ,"YMD")
gen sign_date = date(tender_contractsignaturedate ,"YMD")
format first_cft_pub bid_deadline ca_date aw_date sign_date  %d

foreach var in  first_cft_pub bid_deadline ca_date aw_date sign_date {
replace `var' = . if `var'==date("1800/12/12","YMD")
}

*Generate new year variable
cap drop year month quarter
cap gen year = .
foreach var in  first_cft_pub bid_deadline ca_date aw_date sign_date{
replace year = year(`var') if missing(year)
}

*Generate new quarter variable
cap gen quarter = .
foreach var in  first_cft_pub bid_deadline ca_date aw_date sign_date{
replace quarter = quarter(`var') if missing(quarter)
}

*Generate new month variable
cap gen month = .
foreach var in  first_cft_pub bid_deadline ca_date aw_date sign_date{
replace month = month(`var')  if missing(month)
}

*Generate combined cft and ca date variables
cap drop cft_date_combined
gen cft_date_combined = .
foreach var in  first_cft_pub bid_deadline{
replace cft_date_combined = `var' if missing(cft_date_combined)
}

cap drop ca_date_combined
gen ca_date_combined = .
foreach var in ca_date aw_date sign_date{
replace ca_date_combined = `var' if missing(ca_date_combined)
}
