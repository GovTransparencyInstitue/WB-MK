* Generate indicators taxhav
********************************************************************************
local country `1'

foreach drop_var in iso sec_score fsuppl taxhav taxhav2 taxhav3{
cap drop `drop_var'
}

gen iso = bidder_country

cap drop sec_score*
merge m:1 iso using "${data}/utility/FSI_wide_200812_fin.dta", keep(1 3)
lab var iso "Supplier country ISO"
drop _merge

gen sec_score = sec_score2009 if tender_year<=2009
replace sec_score = sec_score2011 if (tender_year==2010 | tender_year==2011) & sec_score==.
replace sec_score = sec_score2013 if (tender_year==2012 | tender_year==2013) & sec_score==.
replace sec_score = sec_score2015 if (tender_year==2014 | tender_year==2015) & sec_score==.
replace sec_score = sec_score2017 if (tender_year==2016 | tender_year==2017) & sec_score==.
replace sec_score = sec_score2019 if (tender_year==2018 | tender_year==2019 | tender_year==2020 | tender_year==2021 |tender_year==2022) & sec_score==.

lab var sec_score "supplier country Secrecy Score (time varying)"
drop sec_score1998-sec_score2019

gen fsuppl=1 
replace fsuppl=0 if bidder_country=="`country'" | bidder_country==""
// tab fsuppl, missing

gen taxhav =.
replace taxhav = 0 if sec_score<=59.5 & sec_score !=.
replace taxhav = 1 if sec_score>59.5 & sec_score!=.
replace taxhav = 9 if fsuppl==0
lab var taxhav "Supplier is from tax haven (time varying)"
replace taxhav = 0 if bidder_country=="US" //removing the US

gen taxhav2 = taxhav
replace taxhav2 = 0 if taxhav==. 
lab var taxhav2 "Tax haven supplier, missing = 0 (time varying)"
// tab taxhav2, missing

gen taxhav3= fsuppl
replace taxhav3 = 2 if fsuppl==1 & taxhav==1
lab var taxhav3 "Tax haven supplier, 3 categories  (time varying)"
// tab taxhav3 if filter_ok, m

********************************************************************************
*END