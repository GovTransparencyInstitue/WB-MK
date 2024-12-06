**# Figures for the paper
// grstyle init
// // grstyle set imesh, horizontal compact minor
// grstyle set color economist
// grstyle set legend 2, nobox

set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox

**# Section: Data Description

tab tender_year if filter_ok 
tab month if year ==2022 & filter_ok

**# Fig: Count of tenders + contracts - filter_ok
frame change default
cap frame drop halfyear
frame copy default halfyear
frame change halfyear

keep if filter_ok
keep tender_id year month 
egen tender_tag = tag(tender_id)
gen filter_ok =1

gen half = 1
replace half = 2 if month>=6

collapse (sum) tender_tag filter_ok , by(year half) fast

cap drop halfyearly
gen halfyearly = yh(year, half)
format halfyearly %th
tsset halfyearly

drop if year == 2022 & half == 2

tsline tender_tag filter_ok , ///
    tlabel(2011h1(1)2022h2, alternate labsize(small)) ///
    xtitle("") ///
    ytitle("Number of tenders and contracts") ///
    lpattern(solid dash) ///
    legend(label(1 "Tenders") label(2 "Contracts") rows(1) pos(6)) ///
    ylabel(, format(%9.0fc))
	
graph export "${output_figures}/MK_202211_data_monthly_tenders_contracts.png", as(png) width(3000) height(1800)  replace	


total tender_tag //174,324
total filter_ok //267,427

**# Fig: Summation of contract value
frame change default
cap frame drop total_value_halfyearly
frame copy default total_value_halfyearly
frame change total_value_halfyearly

keep if filter_ok
keep bid_price year month  filter_ok

gen half = 1
replace half = 2 if month>=6

collapse (sum) bid_price (count) count=filter_ok , by(year half) fast

cap drop halfyearly
gen halfyearly = yh(year, half)
format halfyearly %th
tsset halfyearly

cap drop bid_price_bil
gen bid_price_bil = bid_price/1000000000

drop if year == 2022 & half == 2

tsline bid_price_bil , ///
    tlabel(2011h1(1)2022h2, alternate labsize(small)) ///
    xtitle("") ///
    ytitle("Total Spending, billion MKD", size(small)) ///
    lpattern(solid) ///
	ylabel(, format(%9.0fc) ///
	)
//     legend(label(1 "Tenders") label(2 "Contracts") rows(1) pos(6)) ///
	
graph export "${output_figures}/MK_202211_data_monthly_total_value.png", as(png) width(3000) height(1800)  replace	

total bid_price_bil //511.6968 

**# Fig: Sumation of contract value by supply type

frame change default
tab tender_supplytype if filter_ok, m
replace tender_supplytype = "GOODS" if tender_supplytype == "SUPPLIES"
cap drop bid_price_bil
gen bid_price_bil = bid_price/1000000000


graph bar (sum) bid_price_bil if year >= 2011 & filter_ok == 1, ///
    over(tender_supplytype) /// Group by tender supply type
    over(year) /// Group within each year
    asyvars /// Allow variables to be treated asymmetrically
    stack /// Display bars in a stacked format
    ytitle("Total Spending, billion MKD", size(small)) /// Add y-axis title with small font
    ylabel(, format(%-12.0fc)) /// Format y-axis labels with commas
    legend(rows(1) pos(6) /// Place the legend in one row at position 6 (bottom center) ///
	) 

graph export "${output_figures}/MK_202211_supply_amt_yearly_stacked_fixed.png", as(png) width(3000) height(1800) replace		

graph bar (sum ) filter_ok if year>=2011 & filter_ok==1  , over(tender_supplytype) asyvars ytitle("Number of awarded contracts", size(small)) ylabel(,format(%-12.0fc)) over(year) stack legend(rows(1) pos(6))

graph bar (sum) filter_ok if year >= 2011 & filter_ok == 1, ///
    over(tender_supplytype) /// Group by tender supply type
    over(year) /// Group within each year
    asyvars /// Allow variables to be treated asymmetrically
    stack /// Display bars in a stacked format
    ytitle("Number of awarded contracts", size(small)) /// Add y-axis title with small font
    ylabel(, format(%-12.0fc)) /// Format y-axis labels with commas
    legend(rows(1) pos(6) /// Place the legend in one row at position 6 (bottom center) ///
	) 

graph export "${output_figures}/MK_202211_supply_freq_yearly_stacked_fixed.png", as(png) width(3000) height(1800) replace	

**# Fig Geographical distribution and counts of number of organizations 
cap drop buyer_loc
gen buyer_loc="Vardarski" if buyer_nuts=="MK001"
replace buyer_loc="Istočen" if buyer_nuts=="MK002"
replace buyer_loc="Jugozapaden" if buyer_nuts=="MK003"
replace buyer_loc="Jugoistočen" if buyer_nuts=="MK004"
replace buyer_loc="Pelagoniski" if buyer_nuts=="MK005"
replace buyer_loc="Pološki" if buyer_nuts=="MK006"
replace buyer_loc="Severoistočen" if buyer_nuts=="MK007"
replace buyer_loc="Skopski" if buyer_nuts=="MK008" 

tab buyer_loc if filter_ok, m

encode buyer_loc, gen(buyer_loc_end)

graph bar (sum) filter_ok if year >= 2011 & filter_ok == 1, ///
    over(buyer_loc_end) /// Group by buyer location
    over(year) /// Group within each year
    asyvars /// Allow variables to be treated asymmetrically
    stack /// Display bars in a stacked format
    ytitle("Number of awarded contracts", size(small)) /// Add y-axis title with small font
    ylabel(0(5000)30000, format(%-12.0fc)) /// Format y-axis labels with commas
    legend(rows(2) pos(6) /// Place the legend in two rows at position 6 (bottom center) ///
	) 
graph export "${output_figures}/MK_202211_loc_freq_yearly_stacked.png", as(png) width(3000) height(1800) replace	

graph bar (sum) bid_price_bil if year >= 2011 & filter_ok == 1, ///
    over(buyer_loc_end) /// Group by buyer location
    over(year) /// Group within each year
    asyvars /// Allow variables to be treated asymmetrically
    stack /// Display bars in a stacked format
    ytitle("Total Spending, billion MKD", size(small)) /// Add y-axis title with small font
    ylabel(0(5)65, format(%-12.0fc)) /// Format y-axis labels with commas
    legend(rows(2) pos(6) /// Place the legend in two rows at position 6 (bottom center) ///
	) 
graph export "${output_figures}/MK_202211_loc_amt_yearly_stacked.png", as(png) width(3000) height(1800) replace	

**# Fig: Organization counts
// Unique suppliers and buyers - based on generate buyer/bidder_ ids
cap frame drop counts
frame put buyer_id bidder_id filter_ok year , into(counts)
frame change counts
drop if filter_ok==0

bys year: egen count_buyer=nvals(buyer_id)
bys year: egen count_bidder=nvals(bidder_id)
collapse (firstnm) count_buyer count_bidder, by(year)

graph bar (sum) count_buyer count_bidder if year >= 2011 & !missing(year), ///
    over(year) /// Group by year
    asyvars /// Allow variables to be treated asymmetrically
    stack /// Display bars in a stacked format
    ytitle("Number of organizations", size(small)) /// Add y-axis title
    ylabel(0(1000)6000, format(%-12.0fc)) /// Format y-axis labels with commas
    legend( /// Customize legend
        label(1 "Buyers") /// Label for count_buyer
        label(2 "Suppliers") /// Label for count_bidder
        rows(2) /// Arrange legend in two rows
        pos(6) /// Place legend at position 6 (bottom center)
    )
graph export "${output_figures}/org_count_yearly_MK_202211.png", as(png) width(3000) height(1800) replace

frame change default
cap frame drop counts

/*
(NOT USED in PAPER)
**# Fig: CRI Distribution (averged by buyers) + contract level
frame change default

cap drop buyer_tag mean_cri_buyer
bys buyer_id: egen mean_cri_buyer = mean(cri) if filter_ok==1
egen buyer_tag = tag(buyer_id) if filter_ok

sum cri  if filter_ok==1 & buyer_tag==1, det
di `r(mean)'
di `r(p50)'
local x=`r(p50)'+0.01
graph twoway (hist mean_cri_buyer if filter_ok==1 & buyer_tag==1, freq xtitle(CRI) lcolor(grey%10) bcolor(grey%20)) (scatteri 0 `r(mean)' 0.15 `r(mean)', c(l) m(i) lcolor(red) lpattern(dash)) (scatteri 0 `r(p50)' 0.15 `r(p50)', c(l) m(i) lcolor(blue) lpattern(dash)) , legend( rows(1) pos(6)) ttext(0.152 `r(mean)' "0.48" 0.152 `x' "0.50", size(tiny)) legend(order(2 "Mean" 3 "Median"))
// hist mean_cri_buyer if filter_ok==1 & buyer_tag==1, frac xtitle(CRI) lcolor(grey%10)  xline(0.29, lcolor(red))
// xline(`r(p50)', lcolor(blue%40))
graph export "${output_figures}/cri_buyers_avg_MK_202211.png", as(png) replace

// hist mean_cri_buyer if filter_ok==1 & buyer_tag==1, frac xtitle(CRI) by(year)
// graph export "${output_figures}/cri_buyers_avg_yearly_MK_202211.png", as(png) replace

sum cri  if filter_ok==1 , det
di `r(mean)'
di `r(p50)'
local x=`r(p50)'-0.015
local y=`r(mean)'+0.005
graph twoway (hist cri if filter_ok==1 , freq xtitle(CRI) lcolor(grey%10) bcolor(grey%20)) (scatteri 0 `r(mean)' 0.2 `r(mean)', c(l) m(i) lcolor(red) lpattern(dash)) (scatteri 0 `r(p50)' 0.2 `r(p50)', c(l) m(i) lcolor(blue) lpattern(dash)) , legend( rows(1) pos(6)) ttext(0.202 `y' "0.43" 0.202 `x' "0.42", size(tiny)) legend(order(2 "Mean" 3 "Median"))
// hist cri if filter_ok==1, frac xtitle(CRI)
graph export "${output_figures}/cri_contracts_avg_MK_202211.png", as(png) replace

**# Fig CRI (+ indicators) over time
frame change default
cap frame drop quarter_cri
frame copy default quarter_cri
frame change quarter_cri

replace taxhav2 = . if taxhav2==9

keep if filter_ok
// keep if inrange(year,2011,2022)
collapse (mean) cri corr_singleb corr_nocft corr_proc corr_subm corr_decp corr_ben proa_ycsh4 taxhav2 , by(year quarter) fast

gen qdate = yq(year, quarter)
format qdate %tq
tsset qdate
di yq(2011, 1)

**# Figures for the paper

tsline cri corr_singleb corr_proc corr_subm corr_decp corr_ben proa_ycsh4 taxhav2, tlab(2011q1(2)2022q4, angle(45) labsize(vsmall)) lpattern(solid dash "--.." dash_dot shortdash shortdash_dot longdash longdash_dot "--..")  legend( rows(3) pos(6)) legend(order(1 "Composite risk score (CRI)" 2 "Single bidding" 3 "Procedure type" 4 "Submission period" 5 "Decision period" 6 "Benford's law'" 7 "Buyer concentration" 8 "Tax haven" )) xtitle("")

// lcolor(black black black black black black black black black)
//  ttext(0.19 204 "CRI" 0.32 204 "Procedure Type" 0.25 204 "Single bidding" 0.1 204 "No CFT" 0.06 204 "Buyer_concentration" 0.04 204 "Submission period" 0.02 204 "Decision period" 0.005 204 "Tax haven" 0.48 204 "Benford's law'" ,size(tiny))

graph export "${output_figures}/MK_202211_CRI_quarterly_contracts.png", as(png)  replace

**# Fig CRI over markets - Box plot

frame change default
label variable market_id_num "CPV divisions"
graph box cri if !inlist(market_id_num,"99") & filter_ok==1, over(market_id_num, label(alternate labs(vsmall)) sort(1)) ytitle(CRI, size(small)) marker(2)
graph export "${output_figures}/MK_202211_CRI_markets.png", as(png)  replace
*/

**# Fig: Single lot tenders

frame change default
cap drop bid_price_bil
gen bid_price_bil = bid_price/1000000000

cap drop tender_tag
egen tender_tag = tag(tender_id)

tab filter_ok filter_1lot, m 
tab filter_1lot if filter_ok & tender_tag==1, m //1lots are 78.3% 

cap drop monthly
gen monthly = ym(year, month)
format monthly %tm

// drop if !inrange(monthly,ym(2011, 1),ym(2022,8))

total bid_price_bil if filter_ok & inrange(monthly,ym(2011, 1),ym(2022,8)) , over(filter_1lot)
total bid_price_bil if filter_ok & inrange(monthly,ym(2011, 1),ym(2022,8))

//1lots 65.6% of contract values - 78.3% of all tenders


graph bar (sum) filter_ok if year >= 2011 & filter_ok == 1 & tender_tag == 1, ///
    over(filter_1lot) /// Group by filter_1lot (multi-lot vs single-lot)
    asyvars /// Allow variables to be treated asymmetrically
    ytitle("Number of tenders", size(small)) /// Add y-axis title with small font
    ylabel(, format(%-12.0fc)) /// Format y-axis labels with commas
    over(year) /// Group within each year
    stack /// Display bars in a stacked format
    legend( /// Customize the legend
        rows(1) /// Place the legend in one row
        pos(6) /// Position the legend at the bottom center
        order(1 "Multi-lot tenders" 2 "Single-lot tenders") /// Label order and descriptions
    )
graph export "${output_figures}/MK_202211_lotcount_freq_yearly_stacked.png", as(png)  width(3000) height(1800) replace	


graph bar (sum) bid_price_bil if year >= 2011 & filter_ok == 1, ///
    over(filter_1lot) /// Group by filter_1lot (multi-lot vs single-lot)
    asyvars /// Allow variables to be treated asymmetrically
    ytitle("Total Spending, billion MKD", size(small)) /// Add y-axis title with small font
    ylabel(, format(%-12.0fc)) /// Format y-axis labels with commas
    over(year) /// Group within each year
    stack /// Display bars in a stacked format
    legend( /// Customize the legend
        rows(1) /// Place the legend in one row
        pos(6) /// Position the legend at the bottom center
        order(1 "Multi-lot tenders" 2 "Single-lot tenders") /// Label order and descriptions
    )
graph export "${output_figures}/MK_202211_lotcount_amt_yearly_stacked.png", as(png)  width(3000) height(1800) replace	


**# Histogram of Relative price

sum lrelprice  if filter_ok==1 & filter_1lot==1 , det
di `r(mean)'
di `r(p50)'
local y=`r(mean)'-0.2
local x=`r(p50)'+0.7
graph twoway (hist lrelprice if filter_ok==1 & filter_1lot==1, frac xtitle(Log(Relative Price)) lcolor(grey%10) bcolor(grey%20)) (scatteri 0 `r(mean)' 0.8 `r(mean)', c(l) m(i) lcolor(red) lpattern(dash)) (scatteri 0 `r(p50)' 0.8 `r(p50)', c(l) m(i) lcolor(blue) lpattern(dash)) , legend( rows(1) pos(6)) ttext(0.81 `y' "-0.26" 0.81 `x' "-0.03", size(small)) legend(order(2 "Mean" 3 "Median"))
graph export "${output_figures}/MK_202211_lrelprice_1lottenders.png", as(png)  width(3000) height(1800) replace



