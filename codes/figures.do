**# Figures 
set scheme plotplain

// Tender year 
// ssc install tabplot 

label define filter_ok_lbl 0 "Excluded" 1 "Included"
label values filter_ok filter_ok_lbl 
tab filter_ok
tostring filter_ok, replace
destring filter_ok ,replace 

lab var year "Tender Year"

//Tab tenders - Yearly distribution of tenders

egen tender_tag = tag(tender_id)
tabplot year if tender_tag==1 & year>=2011 , title(MK_202211) subtitle(Tenders) showval(offset(0.09) format(%12.0fc)) horizontal 
graph export "${output_figures}/MK_202211_tenders_full_sample.png", as(png) replace	

tabplot year if tender_tag==1 & year>=2011 & filter_ok==1, title(MK_202211) subtitle(Tenders) showval(offset(0.09) format(%12.0fc)) horizontal 
graph export "${output_figures}/MK_202211_tenders_filter_ok.png", as(png) replace	

// tabplot year , title(MK_202211) subtitle(Full sample) showval(offset(0.09) format(%12.0fc)) horizontal 
// graph export "${output_figures}/Year_freq_full_sample_MK_202211.png", as(png) replace	

//Tab Contracts - Yearly distribution of contracts
tabplot year if year>=2011 & filter_ok==1 , title(MK_202211) subtitle(Contracts) showval(offset(0.09) format(%12.0fc)) horizontal 
graph export "${output_figures}/MK_202211_contracts_filter_ok.png", as(png) replace		

tabplot year if year>=2011 , title(MK_202211) subtitle(Contracts) showval(offset(0.09) format(%12.0fc)) horizontal by(filter_ok)
graph export "${output_figures}/MK_202211_contracts_by_filter_ok.png", as(png) replace	

tabplot year if year>=2011 , title(MK_202211) subtitle(Contracts) showval(offset(0.09) format(%12.0fc)) horizontal
graph export "${output_figures}/MK_202211_contracts_no_filter_ok.png", as(png) replace	


// Procedure types (national)
grstyle init
grstyle set imesh, horizontal compact minor
grstyle set color economist
grstyle set legend 2, nobox

graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_nationalproceduretype) asyvars ytitle(Number of Awarded contracts) 
graph export "${output_figures}/MK_202211_proc_filter_ok.png", as(png) replace	

graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_nationalproceduretype) asyvars ytitle(Number of Awarded contracts) by(year)
graph export "${output_figures}/MK_202211_proc_yearly.png", as(png) replace	


graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_natproctype) asyvars ytitle(Number of Awarded contracts) 
graph export "${output_figures}/MK_202211_proc_mod_filter_ok.png", as(png) replace	

graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_natproctype) asyvars ytitle(Number of Awarded contracts) by(year)
graph export "${output_figures}/MK_202211_proc_mod_yearly.png", as(png) replace	

// Summation by contract value
cap drop bid_price_adg
gen bid_price_adg = bid_price/1000000000

graph bar (sum ) bid_price_adg if year>=2011 & filter_ok==1  , over(tender_natproctype) asyvars ytitle("Total awarded Amount, billion MKD") ylabel(,format(%-12.0fc)) 
graph export "${output_figures}/MK_202211_proc_mod_contract_value.png", as(png) replace	

// Procedure types (DW)

graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_proceduretype) asyvars ytitle(Number of Awarded contracts) 
graph export "${output_figures}/MK_202211_proc_dw_filter_ok.png", as(png) replace	

graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_proceduretype) asyvars ytitle(Number of Awarded contracts) by(year)
graph export "${output_figures}/MK_202211_proc_dw_yearly.png", as(png) replace	

// tabplot tender_nationalproceduretype if filter_ok==1 , showval(offset(0.09) format(%12.0fc)) horizontal  by(year)
// graph export "${output_figures}/proc_year_freq_MK_202211.png", as(png) replace

// Supply types
// Total awarded value
/*
graph bar (sum ) bid_price_adg if year>=2011 & filter_ok==1  , over(tender_supplytype) asyvars ytitle("Total awarded Amount, billion MKD") ylabel(,format(%-12.0fc)) over(year) 
graph export "${output_figures}/MK_202211_supply_amt_yearly.png", as(png) replace	

graph bar (sum ) bid_price_adg if year>=2011 & filter_ok==1  , over(tender_supplytype) asyvars ytitle("Total awarded Amount, billion MKD") ylabel(,format(%-12.0fc)) over(year) stack
graph export "${output_figures}/MK_202211_supply_amt_yearly_stacked.png", as(png) replace	

tabplot tender_supplytype if filter_ok==1 , title(MK_202211) subtitle(filter_ok) showval(offset(0.09) format(%12.0fc)) horizontal 
graph export "${output_figures}/supply_freq_MK_202211.png", as(png) replace		

tabplot tender_supplytype if filter_ok==1 , showval(offset(0.09) format(%12.0fc)) horizontal  by(year)
graph export "${output_figures}/supply_year_freq_MK_202211.png", as(png) replace

*/

/*
// Unique suppliers and buyers - based on generate buyer/bidder_ ids
cap frame drop counts
frame put buyer_id bidder_id filter_ok year , into(counts)
frame change counts
drop if filter_ok==0

bys year: egen count_buyer=nvals(buyer_id)
bys year: egen count_bidder=nvals(bidder_id)
collapse (firstnm) count_buyer count_bidder, by(year)
graph bar (sum ) count_buyer count_bidder if year>=2011 & !missing(year)  ,  asyvars  legend(label(1 "Procurment Authorties") label(2 "Suppliers")) ytitle(Number of organizatons) 
graph export "${output_figures}/org_count_total_MK_202211.png", as(png) replace

graph bar (sum ) count_buyer count_bidder if year>=2011 & !missing(year)  , over(year) asyvars stack legend(label(1 "Procurment Authorties") label(2 "Suppliers")) ytitle(Number of organizatons) 
graph export "${output_figures}/org_count_yearly_MK_202211.png", as(png) replace

frame change default
cap frame drop counts
*/



