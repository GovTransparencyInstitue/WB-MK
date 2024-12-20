// Cost of corruption calculations
// WB MK - 21/11/2022
// GTI: Aly Abdou
*************************************************
**# Generate main DV: relprice
// Source only contains the tender_estimatedprice -  We can only do the calcaution accurately on the 1 lot tenders

cap drop est_price
quie gen est_price = lot_estimatedprice
quie replace est_price = tender_estimatedprice if missing(est_price)

cap drop relprice
quie gen relprice = bid_price/est_price
cap drop lrelprice
quie gen lrelprice = log(relprice)

// *************************************************
// **# 1-lot tenders filter
// cap drop count_lots
// sort tender_id
// bys tender_id: gen count_lots=_N
// tab count_lots, m
// cap drop filter_1lot
// gen filter_1lot = 0
// replace filter_1lot=1 if count_lots==1
//
// br buyer_name bidder_name tender_estimatedprice bid_price if count_lots==1
// hist relprice if filter_ok & count_lots==1 & relprice<200
//
// br buyer_name bidder_name tender_estimatedprice bid_price if filter_ok & count_lots==1 & inrange(relprice,5,200) & !missing(relprice)
//
// sort tender_id lot_id
// // Only 60 contracts as outliers within the 1 lot tenders - seems like the 1 lot estimation is good
// *************************************************
**# Generate two Analysis Sub-Samples
cap drop group_1
gen group_1 = 0
replace group_1 = 1 if (relprice < 1.3 & relprice > 0.5)

cap drop group_2
gen group_2 = 0
replace group_2 = 1 if (relprice < 1 & relprice > 0.5)

count if filter_ok 
count if filter_ok & filter_1lot
count if filter_ok & filter_1lot & group_1
count if filter_ok & filter_1lot & group_2

// hist relprice if filter_ok & group_1
// graph export "${output_figures}/MK_202211_relprice_group1.png", as(png) replace	
// hist lrelprice if filter_ok & group_1
// graph export "${output_figures}/MK_202211_lrelprice_group1.png", as(png) replace

// hist relprice if filter_ok & group_2
// graph export "${output_figures}/MK_202211_relprice_group2.png", as(png) replace	
// hist lrelprice if filter_ok & group_2
// graph export "${output_figures}/MK_202211_lrelprice_group2.png", as(png) replace	

// // 1 lot 
// hist relprice if filter_ok & filter_1lot & group_1
// graph export "${output_figures}/MK_202211_relprice_group1_1lot.png", as(png) replace	
// hist lrelprice if filter_ok & filter_1lot & group_1
// graph export "${output_figures}/MK_202211_lrelprice_group1_1lot.png", as(png) replace

// hist relprice if filter_ok & filter_1lot & group_2
// graph export "${output_figures}/MK_202211_relprice_group2_1lot.png", as(png) replace	
// hist lrelprice if filter_ok & filter_1lot & group_2
// graph export "${output_figures}/MK_202211_lrelprice_group2_1lot.png", as(png) replace			

// bcskew0 relprice_bc = relprice if filter_ok==1
// lnskew0 relprice_lc = relprice if filter_ok==1
*************************************************
**# Preparing main IV
cap drop cri2
cap drop lcri
quie gen cri2 = cri^2
quie gen lcri = log(cri)
*************************************************
**# Controls + Filters used

global controls i.cvalue10 i.anb_type i.ca_type i.anb_location i.year i.market_id
// global options vce(cluster market_id)
global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1
*************************************************
**# CRI regression

global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1

global controls_m1
global controls_m2 i.cvalue10 i.ca_type i.market_id
global controls_m3 i.cvalue10 i.ca_type i.market_id i.anb_type i.anb_location
global controls_m4 i.cvalue10 i.ca_type i.market_id i.anb_type i.anb_location i.year i.month

forval x=1/4{
quie reg lrelprice cri ${controls_m`x'} if $sub_sample, $options
est store m
estout m, keep(cri) cells(b(star fmt(3)) se) stats(N r2)
}

// quie reg lrelprice c.cri##c.cri $controls if $sub_sample, $options
// est store m
// estout m, keep(*cri) cells(b(star fmt(3)) se) stats(N r2)

// quie reg lrelprice lcri $controls if $sub_sample, $options
// est store m
// estout m, keep(lcri) cells(b(star fmt(3)) se) stats(N r2)

**# CRI regression figures
graph twoway (scatter lrelprice cri) (qfitci lrelprice cri, ciplot(rline)) if filter_ok==1 & filter_1lot==1 & group_1==1, title(OLS ) subtitle(`subtitle') xtitle(CRI, size(small)) ytitle(`ytitle', size(small)) legend(off)
// graph export "${output_figures}/MK_202211_lrelprice_cri_group1.png", as(png) replace	

// graph twoway (scatter lrelprice cri) (qfitci lrelprice cri, ciplot(rline)) if filter_ok==1 & filter_1lot==1 & group_2==1, title(OLS ) subtitle(`subtitle') xtitle(CRI, size(small)) ytitle(`ytitle', size(small)) legend(off)
// graph export "${output_figures}/MK_202211_lrelprice_cri_group2.png", as(png) replace			
*************************************************
**# Robustness regression - individual components
di "Start here"
local components corr_singleb corr_proc corr_subm corr_decp corr_ben taxhav3
local groups group_1 
// group_2
foreach comp in `components'{
	cap drop `comp'_x
	gen `comp'_x=`comp'*2
	replace `comp'_x = 9 if missing(`comp'_x)
	
	foreach group in `groups'{
		di "Result for `comp' & `group' "
		global sub_sample filter_ok==1 & filter_1lot==1 & `group'==1
		quie reg lrelprice i.`comp'_x $controls if $sub_sample, $options
		est store m
estout m, keep(*.`comp'_x) cells(b(star fmt(3)) se) stats(N r2)
		
	}
	cap drop `comp'_x
}

// Changed corr_proc  -- only one case of corrproc==1
global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1
tab corr_proc if filter_ok & filter_1lot, m
tab corr_proc if $sub_sample, m
gen xcorr_proc = corr_proc
replace xcorr_proc =1 if xcorr_proc==0.5 & $sub_sample
tab xcorr_proc if $sub_sample, m

quie reg lrelprice i.xcorr_proc $controls if $sub_sample, $options
est store m
estout m, keep(*.xcorr_proc) cells(b(star fmt(3)) se) stats(N r2)
// cap drop xcorr_proc


// Buyer concentration

global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1
quie reg lrelprice c.w_ycsh4 $controls if $sub_sample, $options
est store m
estout m, keep(w_ycsh4) cells(b(star fmt(3)) se) stats(N r2)
*************************************************
**# CRI + Individual indicators COC Estimations
frame change default

// cap frame drop coc
// frame copy default coc

global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1 & inrange(year,2011,2022)

global options vce(cluster market_id)

// local components cri corr_singleb corr_subm corr_proc corr_decp corr_ben taxhav2 w_ycsh4

local components cri corr_singleb corr_subm corr_proc 

// replace taxhav2= 0 if taxhav2==9
tab taxhav2 if $sub_sample
tab corr_singleb if $sub_sample

foreach ind in `components'{

		switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
		local ind_shrt $switch_return
	
		foreach var in x`ind' lrelprice_p lrelprice_se_p lrelprice_lb_p lrelprice_ub_p lrelprice_p_zero`ind_shrt' lrelprice_se_p_zero`ind_shrt' lrelprice_lb_p_zero`ind_shrt' lrelprice_ub_p_zero`ind_shrt' contract_value_pred`ind_shrt' contract_value_pred`ind_shrt'_lb contract_value_pred`ind_shrt'_ub contract_value_zero`ind_shrt' contract_value_zero`ind_shrt'_lb contract_value_zero`ind_shrt'_ub {
	cap drop `var'
}
	
	clonevar x`ind' = `ind' 
	if inlist("`ind'","taxhav2") replace x`ind'=0 if x`ind'==9 
	if inlist("`ind'","corr_proc") replace x`ind'=1 if x`ind'==0.5 & $sub_sample
	if inlist("`ind'","corr_decp") replace x`ind'=x`ind'*2
	
	local iv i.x`ind'
	if inlist("`ind'","w_ycsh4","cri") local iv c.x`ind'
	
	quie reg lrelprice `iv' $controls if $sub_sample, $options
	predict lrelprice_p , xb
	predict lrelprice_se_p , stdp
	gen lrelprice_lb_p = lrelprice_p-(invnormal(.975)*lrelprice_se_p)
	gen lrelprice_ub_p = lrelprice_p+(invnormal(.975)*lrelprice_se_p)
	replace lrelprice_p = exp(lrelprice_p) 
	replace lrelprice_lb_p = exp(lrelprice_lb_p) 
	replace lrelprice_ub_p = exp(lrelprice_ub_p) 
	
	replace x`ind' = 0 if !missing(`ind')
	
	predict lrelprice_p_zero`ind_shrt', xb
	predict lrelprice_se_p_zero`ind_shrt' , stdp
	gen lrelprice_lb_p_zero`ind_shrt' = lrelprice_p_zero`ind_shrt'-(invnormal(.975)*lrelprice_se_p_zero`ind_shrt')
	gen lrelprice_ub_p_zero`ind_shrt' = lrelprice_p_zero`ind_shrt'+(invnormal(.975)*lrelprice_se_p_zero`ind_shrt')

	replace lrelprice_p_zero`ind_shrt' = exp(lrelprice_p_zero`ind_shrt') 	
	replace lrelprice_lb_p_zero`ind_shrt' = exp(lrelprice_lb_p_zero`ind_shrt') 	
	replace lrelprice_ub_p_zero`ind_shrt' = exp(lrelprice_ub_p_zero`ind_shrt')
	
	// Estimated contract values
	gen contract_value_pred`ind_shrt' = est_price * lrelprice_p 
	gen contract_value_pred`ind_shrt'_lb = est_price * lrelprice_lb_p 
	gen contract_value_pred`ind_shrt'_ub = est_price * lrelprice_ub_p 

	gen contract_value_zero`ind_shrt' = est_price * lrelprice_p_zero`ind_shrt' 
	gen contract_value_zero`ind_shrt'_lb = est_price * lrelprice_lb_p_zero`ind_shrt' 
	gen contract_value_zero`ind_shrt'_ub = est_price * lrelprice_ub_p_zero`ind_shrt' 
	
// 	replace contract_value_zero`ind_shrt' = .if missing(`ind')
// 	replace contract_value_zero`ind_shrt'_lb = . if missing(`ind')
// 	replace contract_value_zero`ind_shrt'_ub = . if missing(`ind')

}

*************************************************
* Aggregation Figures (over time + over locations + Over organizations + over sectors)
frame change default

global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1 & inrange(year,2011,2022)

**# Fig: Savings as a % of total spending by cri + indicators over quarters
cap frame drop quarter
frame copy default quarter
frame change quarter

keep if $sub_sample


local components cri corr_singleb corr_subm corr_proc 
// corr_decp corr_ben taxhav2 w_ycsh4

foreach ind in `components'{
		switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
		local ind_shrt $switch_return
		
local collapse_cmd `collapse_cmd' total_spending_model`ind_shrt'=contract_value_pred`ind_shrt' total_spending_model`ind_shrt'_lb=contract_value_pred`ind_shrt'_lb total_spending_model`ind_shrt'_ub=contract_value_pred`ind_shrt'_ub total_spending_zero`ind_shrt'=contract_value_zero`ind_shrt' total_spending_zero`ind_shrt'_lb=contract_value_zero`ind_shrt'_lb total_spending_zero`ind_shrt'_ub=contract_value_zero`ind_shrt'_ub 
}


cap drop half
gen half = 1
replace half = 2 if month>=6


// collapse (sum) `collapse_cmd' if $sub_sample, by(year quarter)
collapse (sum) `collapse_cmd' if $sub_sample, by(year half)

// collapse (firstnm ) total_spending_modelcri total_spending_modelcri_lb total_spending_modelcri_ub total_spending_zerocri total_spending_zerocri_lb total_spending_zerocri_ub total_spending_modelsb total_spending_modelsb_lb total_spending_modelsb_ub total_spending_zerosb total_spending_zerosb_lb total_spending_zerosb_ub total_spending_modelsub total_spending_modelsub_lb total_spending_modelsub_ub total_spending_zerosub total_spending_zerosub_lb total_spending_zerosub_ub total_spending_modelproc total_spending_modelproc_lb total_spending_modelproc_ub total_spending_zeroproc total_spending_zeroproc_lb total_spending_zeroproc_ub, by(year quarter)

// gen qdate = yq(year, quarter)
// format qdate %tq
// tsset qdate

cap drop qdate
gen qdate = yh(year, half)
format qdate %th
tsset qdate


local components cri corr_singleb corr_subm corr_proc 
// corr_decp corr_ben taxhav2 w_ycsh4

foreach ind in `components'{
switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
local ind_shrt $switch_return
gen loss_percent`ind_shrt' = ((total_spending_model`ind_shrt'-total_spending_zero`ind_shrt')/(total_spending_model`ind_shrt'))*100
gen loss_percent`ind_shrt'_ub = ((total_spending_model`ind_shrt'_lb-total_spending_zero`ind_shrt'_lb)/(total_spending_model`ind_shrt'_lb))*100
gen loss_percent`ind_shrt'_lb = ((total_spending_model`ind_shrt'_ub-total_spending_zero`ind_shrt'_ub)/(total_spending_model`ind_shrt'_ub))*100
}

// grstyle set color economist   
set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox

// br loss_percentsb total_spending_modelsb total_spending_zerosb
* Figure 17 Potential savings after eliminating procurement corruption risks (CRI), North Macedonia, 20122-2022
* Panel A: Half Yearly potential savings rate by eliminating CRI and other selected corruption risk indicators
twoway (rarea loss_percentcri_lb loss_percentcri_ub qdate, fi(inten75)) (rarea loss_percentsb_lb loss_percentsb_ub qdate, fi(inten50) ) (rarea loss_percentproc_lb loss_percentproc_ub qdate, fi(inten50)) (rarea loss_percentsub_lb loss_percentsub_ub qdate, fi(inten50)) (line loss_percentcri qdate, lcolor(grey%10)) ///
(line loss_percentsb qdate, lcolor(grey%10)) ///
(line loss_percentproc qdate, lcolor(grey%10)) ///
(line loss_percentsub qdate, lcolor(grey%10)) , ///
legend(order(1 "CRI" 2 "Single bidding" 3 "Procedure type" 4 "Submission period" )) legend(rows(1) pos(6))  tlab(2011h1(1)2022h2, angle(45)  labsize(small)) ylab(0(1)8, labsize(medium)) xtitle("")  ytitle("Potential savings, %", size(medium))
graph export "${output_figures}/Loss_quarters_1lottenders.png", as(png) width(5000) height(2500)   replace

**# Fig: Loss (MKD) by cri + indicators over quarters
local components cri corr_singleb corr_subm corr_proc
//  corr_decp corr_ben taxhav2 w_ycsh4

foreach ind in `components'{
switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
local ind_shrt $switch_return
cap drop loss_`ind_shrt' loss_`ind_shrt'_ub loss_`ind_shrt'_lb
gen loss_`ind_shrt' = (total_spending_model`ind_shrt'-total_spending_zero`ind_shrt')
replace loss_`ind_shrt' = loss_`ind_shrt'/1000000
gen loss_`ind_shrt'_ub = (total_spending_model`ind_shrt'_lb-total_spending_zero`ind_shrt'_lb)
replace loss_`ind_shrt'_ub = loss_`ind_shrt'_ub/1000000
gen loss_`ind_shrt'_lb = (total_spending_model`ind_shrt'_ub-total_spending_zero`ind_shrt'_ub)
replace loss_`ind_shrt'_lb = loss_`ind_shrt'_lb/1000000

}
* Panel B: Half Yearly potential savings in million MDK by eliminating CRI and other selected corruption risk indicators 
twoway (rarea loss_cri_lb loss_cri_ub qdate, fi(inten75)) (rarea loss_sb_lb loss_sb_ub qdate, fi(inten50) ) (rarea loss_proc_lb loss_proc_ub qdate, fi(inten50)) (rarea loss_sub_lb loss_sub_ub qdate, fi(inten50)) (line loss_cri qdate, lcolor(grey%10)) ///
(line loss_sb qdate, lcolor(grey%10)) ///
(line loss_proc qdate, lcolor(grey%10)) ///
(line loss_sub qdate, lcolor(grey%10)) , ///
legend(order(1 "CRI" 2 "Single bidding" 3 "Procedure type" 4 "Submission period" )) legend(rows(1) pos(6))  tlab(2011h1(1)2022h2, angle(45) labsize(small)) ylab(0(100)1000, labsize(medium) format(%9.0fc)) xtitle("")  ytitle("Potential savings, million MKD", size(medium))
graph export "${output_figures}/Loss_quarters_1lottenders_coc_abs.png", as(png)  width(5000) height(2500)   replace


**#Fig Aggregation of losses over locations
* Figure 18: Distribution of potential savings (million MKD) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia 2011-2022
frame change default
global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1 & inrange(year,2011,2022)

**# total loss % and in MKD calculation
// total spending 
frame change quarter
total total_spending_modelcri 
local totalmodel= r(table)[1,1]
total total_spending_zerocri 
local totalzero= r(table)[1,1]
local loss_percent= (`totalmodel'-`totalzero')/`totalmodel'
local loss_mill= (`totalmodel'-`totalzero')/1000000000
di `loss_percent'
di `loss_mill'

**# Fig: Savings as a % of total spending by cri + indicators over locations
* Figure 18: Distribution of potential savings (million MKD) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia 2011-2022
frame change default
cap frame drop quarter
frame copy default quarter
frame change quarter

keep if $sub_sample

local components cri corr_singleb corr_subm corr_proc 
// corr_decp corr_ben taxhav2 w_ycsh4

foreach ind in `components'{
		switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
		local ind_shrt $switch_return
		
local collapse_cmd `collapse_cmd' total_spending_model`ind_shrt'=contract_value_pred`ind_shrt' total_spending_model`ind_shrt'_lb=contract_value_pred`ind_shrt'_lb total_spending_model`ind_shrt'_ub=contract_value_pred`ind_shrt'_ub total_spending_zero`ind_shrt'=contract_value_zero`ind_shrt' total_spending_zero`ind_shrt'_lb=contract_value_zero`ind_shrt'_lb total_spending_zero`ind_shrt'_ub=contract_value_zero`ind_shrt'_ub 
}

cap drop half
gen half = 1
replace half = 2 if month>=6

// collapse (sum) `collapse_cmd', by(buyer_nuts year quarter) fast
collapse (sum) `collapse_cmd', by(buyer_nuts year half) fast
drop if missing(buyer_nuts)

cap drop buyer_loc
gen buyer_loc="Vardarski" if buyer_nuts=="MK001"
replace buyer_loc="Istočen" if buyer_nuts=="MK002"
replace buyer_loc="Jugozapaden" if buyer_nuts=="MK003"
replace buyer_loc="Jugoistočen" if buyer_nuts=="MK004"
replace buyer_loc="Pelagoniski" if buyer_nuts=="MK005"
replace buyer_loc="Pološki" if buyer_nuts=="MK006"
replace buyer_loc="Severoistočen" if buyer_nuts=="MK007"
replace buyer_loc="Skopski" if buyer_nuts=="MK008"


// gen qdate = yq(year, quarter)
// format qdate %tq
// tsset qdate


cap drop qdate
gen qdate = yh(year, half)
format qdate %th
// tsset qdate

local components cri corr_singleb corr_subm corr_proc 
// corr_decp corr_ben taxhav2 w_ycsh4

foreach ind in `components'{
switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
local ind_shrt $switch_return
gen loss_percent`ind_shrt' = ((total_spending_model`ind_shrt'-total_spending_zero`ind_shrt')/(total_spending_model`ind_shrt'))*100
gen loss_percent`ind_shrt'_ub = ((total_spending_model`ind_shrt'_lb-total_spending_zero`ind_shrt'_lb)/(total_spending_model`ind_shrt'_lb))*100
gen loss_percent`ind_shrt'_lb = ((total_spending_model`ind_shrt'_ub-total_spending_zero`ind_shrt'_ub)/(total_spending_model`ind_shrt'_ub))*100
}

// grstyle set color economist   
set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox

levelsof buyer_loc, local(locs)
foreach loc in `locs'{
    di "`loc'"
// 	local rarea_cmd `rarea_cmd' (rarea loss_percentcri_lb loss_percentcri_ub qdate if buyer_loc=="`loc'", fi(inten75)) 
// 	local line_cmd `line_cmd' (line loss_percentcri qdate if buyer_loc=="`loc'", lcolor(grey%10))
twoway (rarea loss_percentcri_lb loss_percentcri_ub qdate if buyer_loc=="`loc'", fi(inten50)) (line loss_percentcri qdate if buyer_loc=="`loc'", lcolor(grey%10)) , tlab(2011h1(2)2022h2, angle(45) labsize(vsmall))  xtitle("")  ytitle("")  legend(off) title(`loc', size(medium)) saving("${output_figures}/Stata_format/loss_percent_`loc'", replace)
// graph export "${output_figures}/Stata_format/loss_percent_`loc'.png", as(png) replace
}

levelsof buyer_loc, local(locs)
foreach loc in `locs'{
    di "`loc'"
	local combine_cmd `combine_cmd' "${output_figures}/Stata_format/loss_percent_`loc'.gph"
}

graph combine `combine_cmd', row(3) col(3)  colfirst title("") xcommon l1title("Potential savings, % of total spending", size(small))
graph export "${output_figures}/Loss_quarters_1lottenders_locs.png", as(png)  replace

**# FIG : Loss % from singlebidding over regions
* Figure 20: Distribution of potential savings (percentage points) by eliminating single bidding corruption risk across regions in North Macedonia 2011-2022
// grstyle set color economist   
set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox

levelsof buyer_loc, local(locs)
foreach loc in `locs'{
    di "`loc'"
// 	local rarea_cmd `rarea_cmd' (rarea loss_percentcri_lb loss_percentcri_ub qdate if buyer_loc=="`loc'", fi(inten75)) 
// 	local line_cmd `line_cmd' (line loss_percentcri qdate if buyer_loc=="`loc'", lcolor(grey%10))
twoway (rarea loss_percentsb_lb loss_percentsb_ub qdate if buyer_loc=="`loc'", fi(inten50)) (line loss_percentsb qdate if buyer_loc=="`loc'", lcolor(grey%10)) , tlab(2011h1(2)2022h2, angle(45) labsize(vsmall))  xtitle("")  ytitle("")  legend(off) title(`loc', size(medium)) saving("${output_figures}/Stata_format/loss_percent_`loc'", replace)
// graph export "${output_figures}/Stata_format/loss_percent_`loc'.png", as(png) replace
}

levelsof buyer_loc, local(locs)
foreach loc in `locs'{
    di "`loc'"
	local combine_cmd `combine_cmd' "${output_figures}/Stata_format/loss_percent_`loc'.gph"
}

graph combine `combine_cmd', row(3) col(3)  colfirst title("") xcommon l1title("Potential savings, % of total spending", size(small))
graph export "${output_figures}/Loss_quarters_1lottenders_locs_sb.png", as(png)  replace

**# Fig: Loss (MKD) by cri  over quarters by locations
local components cri corr_singleb corr_subm corr_proc 
// corr_decp corr_ben taxhav2 w_ycsh4

foreach ind in `components'{
switch `ind', cases(cri corr_singleb corr_subm corr_proc corr_decp corr_ben corr_nocft taxhav2 w_ycsh4) values(cri sb sub proc dec ben nocft tx ycsh)
local ind_shrt $switch_return
cap drop loss_`ind_shrt' loss_`ind_shrt'_ub loss_`ind_shrt'_lb
gen loss_`ind_shrt' = (total_spending_model`ind_shrt'-total_spending_zero`ind_shrt')
replace loss_`ind_shrt' = loss_`ind_shrt'/1000000
gen loss_`ind_shrt'_ub = (total_spending_model`ind_shrt'_lb-total_spending_zero`ind_shrt'_lb)
replace loss_`ind_shrt'_ub = loss_`ind_shrt'_ub/1000000
gen loss_`ind_shrt'_lb = (total_spending_model`ind_shrt'_ub-total_spending_zero`ind_shrt'_ub)
replace loss_`ind_shrt'_lb = loss_`ind_shrt'_lb/1000000

}

levelsof buyer_loc, local(locs)
foreach loc in `locs'{
    di "`loc'"
// 	local rarea_cmd `rarea_cmd' (rarea loss_percentcri_lb loss_percentcri_ub qdate if buyer_loc=="`loc'", fi(inten75)) 
// 	local line_cmd `line_cmd' (line loss_percentcri qdate if buyer_loc=="`loc'", lcolor(grey%10))
twoway (rarea loss_cri_lb loss_cri_ub qdate if buyer_loc=="`loc'", fi(inten50)) (line loss_cri qdate if buyer_loc=="`loc'", lcolor(grey%10)) , tlab(2011h1(2)2022h2, angle(45) labsize(vsmall) ) xtitle("")  ytitle("")  legend(off) title(`loc', size(medium)) saving("${output_figures}/Stata_format/loss_percent_`loc'", replace)
// graph export "${output_figures}/Stata_format/loss_percent_`loc'.png", as(png) replace
}

levelsof buyer_loc, local(locs)
foreach loc in `locs'{
    di "`loc'"
	local combine_cmd `combine_cmd' "${output_figures}/Stata_format/loss_percent_`loc'.gph"
}

graph combine `combine_cmd', row(3) col(3) colfirst title("") xcommon l1title("Potential savings, million MKD", size(small))
//  iscale(0.4)
graph export "${output_figures}/Loss_quarters_1lottenders_amt_locs.png", as(png)  replace

**# total loss % and in MKD calculation over locations
* Figure 19: Distribution of potential savings (percentage points) by eliminating all procurement corruption risks (CRI) across regions in North Macedonia 2011-2022
// total spending 
encode buyer_loc,gen(buyer_loc_num)
levelsof buyer_loc_num,local(locs)
foreach loc in `locs'{
    tab buyer_loc if buyer_loc_num==`loc'
}


total total_spending_modelcri , over(buyer_loc_num)
matrix x=r(table)
levelsof buyer_loc_num,local(locs)
foreach loc in `locs'{
    di `loc'
	local totalmodel`loc' `=x[1,`loc']'
	di `totalmodel`loc''
	
}
total total_spending_zerocri , over(buyer_loc_num)
matrix x=r(table)
levelsof buyer_loc_num,local(locs)
foreach loc in `locs'{
    di `loc'
	local totalzero`loc' `=x[1,`loc']'
	di `totalzero`loc''
}
// levelsof buyer_loc_num,local(locs)
forval loc=1/8{
local loss_percent (`totalmodel`loc''-`totalzero`loc'')/`totalmodel`loc''
local loss_mill (`totalmodel`loc''-`totalzero`loc'')/1000000
// di "`loc'"
quietly levelsof buyer_loc if buyer_loc_num==`loc', local(location)
di "Loss percent in `loc' "`location'" is: " 
di `loss_percent'
di "Loss Amount in `loc' is million MKD: " 
di `loss_mill'
di "***********"
}


**#Fig Aggregation of losses over sectors

frame change default
global sub_sample filter_ok==1 & filter_1lot==1 & group_1==1 & inrange(year,2011,2022)


**# Fig: Total spending and cost of corruption risk by cri + indicators over sectors

cap frame drop sectors
frame copy default sectors
frame change sectors

keep if $sub_sample
gen x = 1
local components cri corr_singleb corr_submp corr_proc
foreach ind in `components'{
			switch `ind', cases(cri corr_singleb corr_submp corr_proc) values(cri sb sub proc)
		local ind_shrt $switch_return
local collapse_cmd `collapse_cmd' total_spending_model`ind_shrt'=contract_value_pred`ind_shrt' total_spending_model`ind_shrt'_lb=contract_value_pred`ind_shrt'_lb total_spending_model`ind_shrt'_ub=contract_value_pred`ind_shrt'_ub total_spending_zero`ind_shrt'=contract_value_zero`ind_shrt' total_spending_zero`ind_shrt'_lb=contract_value_zero`ind_shrt'_lb total_spending_zero`ind_shrt'_ub=contract_value_zero`ind_shrt'_ub 
}

collapse (sum) `collapse_cmd' (count) count = x, by(market_id ) fast


local components cri corr_singleb corr_submp corr_proc

foreach ind in `components'{
switch `ind', cases(cri corr_singleb corr_submp corr_proc) values(cri sb sub proc)
local ind_shrt $switch_return
gen loss_percent`ind_shrt' = ((total_spending_model`ind_shrt'-total_spending_zero`ind_shrt')/(total_spending_model`ind_shrt'))*100
gen loss_percent`ind_shrt'_ub = ((total_spending_model`ind_shrt'_lb-total_spending_zero`ind_shrt'_lb)/(total_spending_model`ind_shrt'_lb))*100
gen loss_percent`ind_shrt'_lb = ((total_spending_model`ind_shrt'_ub-total_spending_zero`ind_shrt'_ub)/(total_spending_model`ind_shrt'_ub))*100


cap drop loss_`ind_shrt' loss_`ind_shrt'_ub loss_`ind_shrt'_lb
gen loss_`ind_shrt' = (total_spending_model`ind_shrt'-total_spending_zero`ind_shrt')
replace loss_`ind_shrt' = loss_`ind_shrt'/1000000000
gen loss_`ind_shrt'_ub = (total_spending_model`ind_shrt'_lb-total_spending_zero`ind_shrt'_lb)
replace loss_`ind_shrt'_ub = loss_`ind_shrt'_ub/1000000000
gen loss_`ind_shrt'_lb = (total_spending_model`ind_shrt'_ub-total_spending_zero`ind_shrt'_ub)
replace loss_`ind_shrt'_lb = loss_`ind_shrt'_lb/1000000000
}

local components cri corr_singleb corr_submp corr_proc
foreach ind in `components'{
switch `ind', cases(cri corr_singleb corr_submp corr_proc) values(cri sb sub proc)
local ind_shrt $switch_return
replace total_spending_zero`ind_shrt' = total_spending_zero`ind_shrt'/1000000000
}

//Removing the missing category as it inflates the figures
// grstyle set color economist
set scheme plotplain
grstyle init
grstyle set color economist
grstyle set legend 2, nobox

**# Fig: Loss as a % of total spending by cri + indicators over sectors
* Figure 21: Distribution of potential savings (% of total spending by eliminating all procurement corruption risks (CRI) across regions in North Macedonia 2011-2022 – Top 10 CPV divisions by highest saving potential
cap drop market_id_str
decode market_id, gen(market_id_str)
cap drop market_id
ren market_id_str market_id

* replace market_id_str codes with the corresponding text labels
cap drop market_id_str
gen market_id_str = ""
replace market_id_str = "Agricultural and related products" if market_id == "03"
replace market_id_str = "Petroleum products and other sources of energy" if market_id == "09"
replace market_id_str = "Mining related products" if market_id == "14"
replace market_id_str = "Food, beverages and related products" if market_id == "15"
replace market_id_str = "Agricultural machinery" if market_id == "16"
replace market_id_str = "Clothing and accessories" if market_id == "18"
replace market_id_str = "Leather and textile fabrics" if market_id == "19"
replace market_id_str = "Printed matter and related products" if market_id == "22"
replace market_id_str = "Chemical products" if market_id == "24"
replace market_id_str = "Office and computing machinery" if market_id == "30"
replace market_id_str = "Electrical machinery" if market_id == "31"
replace market_id_str = "Telecommunication and related equipment" if market_id == "32"
replace market_id_str = "Medical equipments and pharmaceuticals" if market_id == "33"
replace market_id_str = "Transport equipment " if market_id == "34"
replace market_id_str = "Security and defence equipment" if market_id == "35"
replace market_id_str = "Musical instruments, sport goods, games, toys, handicraft, art materials and accessories" if market_id == "37"
replace market_id_str = "Laboratory, optical and precision equipments (excl. glasses)" if market_id == "38"
replace market_id_str = "Furniture (incl. office furniture), furnishings, domestic appliances (excl. lighting) and cleaning products" if market_id == "39"
replace market_id_str = "Collected and purified water" if market_id == "41"
replace market_id_str = "Industrial machinery" if market_id == "42"
replace market_id_str = "Machinery for mining, quarrying, construction equipment" if market_id == "43"
replace market_id_str = "Construction structures and materials; auxiliary products to construction (except electric apparatus)" if market_id == "44"
replace market_id_str = "Construction work" if market_id == "45"
replace market_id_str = "Software package and information systems" if market_id == "48"
replace market_id_str = "Repair and maintenance services" if market_id == "50"
replace market_id_str = "Installation services (except software)" if market_id == "51"
replace market_id_str = "Hotel, restaurant and retail trade services" if market_id == "55"
replace market_id_str = "Transport services" if market_id == "60"
replace market_id_str = "Supporting and auxiliary transport services; travel agencies services" if market_id == "63"
replace market_id_str = "Postal and telecommunications services" if market_id == "64"
replace market_id_str = "Public utilities" if market_id == "65"
replace market_id_str = "Financial and insurance services" if market_id == "66"
replace market_id_str = "Real estate services" if market_id == "70"
replace market_id_str = "Architectural, construction, engineering and inspection services" if market_id == "71"
replace market_id_str = "IT services: consulting, software development, Internet and support" if market_id == "72"
replace market_id_str = "Research and development services" if market_id == "73"
replace market_id_str = "Administration, defence and social security services" if market_id == "75"
replace market_id_str = "Services related to the oil and gas industry" if market_id == "76"
replace market_id_str = "Agricultural services" if market_id == "77"
replace market_id_str = "Business services: law, marketing, consulting, recruitment, printing and security" if market_id == "79"
replace market_id_str = "Education and training services" if market_id == "80"
replace market_id_str = "Health services" if market_id == "85"
replace market_id_str = "Sewage, refuse, cleaning and environmental services" if market_id == "90"
replace market_id_str = "Recreational services" if market_id == "92"
replace market_id_str = "Other community, social and personal services" if market_id == "98"


keep market_id market_id_str loss_percentcri_lb loss_percentcri_ub loss_percentcri
gsort -loss_percentcri
drop if _n>10

cap drop market_enc
gsort loss_percentcri
cap label drop lab2
gen market_enc = _n
//  CREATE A VALUE LABEL FOR VAR2 FROM THE VALUES OF VAR1
forvalues i = 1/`=_N' {
 label define lab2   `=market_enc[`i']'    "`=market_id_str[`i']'", add
}
label values market_enc lab2

levelsof market_enc, local(var2values)
twoway (rbar loss_percentcri_lb loss_percentcri_ub market_enc if !inlist(market_enc,28), barwidth(0.7)) ///
    (scatter loss_percentcri market_enc if !inlist(market_enc,28), mstyle(p7) mcolor(black%30) msize(*0.7)), ///
    legend(label(1 "Loss upper/lower limits") label(2 "Average value") rows(1) pos(6)) ///
    ytitle("Estimated potential savings\n from total spending lost (%)", size(small)) ///
    xtitle("") ///
    xlabel(`var2values', valuelabels labs(small) angle(40) alternate)
graph export "${output_figures}/Loss_sectors_1lottenders_percent_Actualcri.png", as(png) width(3000) height(1800)  replace


