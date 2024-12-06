* Generate indicators taxhav
********************************************************************************
local country `1'
********************************************************************************
*Winning Supplier's contract share (by PE, by year)

********************************************************************************
foreach drop_var in w_yam proa_w_yam w_ycsh w_mycsh w_ynrc proa_ynrc filter_wy filter_w filter_wproa filter_wproay w_ycsh4 proa_yam proa_ycsh proa_mycsh filter_proay filter_proa proa_nrc proa_ycsh4{
cap drop `drop_var'
}
********************************************************************************
sort buyer_id
// format buyer_masterid buyer_id buyer_name %20s

*Use bidder_id and buyer_id
egen w_yam=sum(bid_price) if filter_ok==1 & !missing(bidder_id) & !missing(year), by (bidder_id year) 
lab var w_yam "By Winner-year: Spending amount"

egen proa_w_yam=sum(bid_price) if filter_ok==1 & !missing(buyer_id) & !missing(bidder_id) & !missing(year), by(buyer_id bidder_id year)
lab var proa_w_yam "By PA-year-supplier: Amount"

gen w_ycsh=proa_w_yam/w_yam 
lab var w_ycsh "By Winner-year-buyer: share of buyer in total annual winner contract value"

egen w_mycsh=max(w_ycsh), by(bidder_id year)
lab var w_mycsh "By Win-year: Max share received from one buyer"

cap drop x
gen x=1
egen w_ynrc=total(x) if filter_ok==1 & !missing(bidder_id) & !missing(year), by(bidder_id year)
drop x
lab var w_ynrc "#Contracts by Win-year"

gen x=1
egen proa_ynrc=total(x) if filter_ok==1 & !missing(buyer_id) & !missing(year), by(buyer_id year)
drop x
lab var proa_ynrc "#Contracts by PA-year"

sort bidder_id year aw_date
egen filter_wy = tag(bidder_id year) if filter_ok==1 & !missing(bidder_id) & !missing(year)
lab var filter_wy "Marking Winner years"
// tab filter_wy

sort bidder_id
egen filter_w = tag(bidder_id) if filter_ok==1 & !missing(bidder_id)
lab var filter_w "Marking Winners"
// tab filter_w

sort bidder_id buyer_id
egen filter_wproa = tag(bidder_id buyer_id) if filter_ok==1 & !missing(bidder_id) & !missing(buyer_id)
lab var filter_wproa "Marking Winner-buyer pairs"
// tab filter_wproa

sort year bidder_id buyer_id
egen filter_wproay = tag(year bidder_id buyer_id) if filter_ok==1 & !missing(buyer_id) & !missing(bidder_id) & !missing(year)
lab var filter_wproay "Marking Winner-buyer pairs"
// tab filter_wproay

gen w_ycsh4=w_ycsh if filter_ok==1 & w_ynrc>4 & w_ycsh!=.
*******************************************************************
*Buyer dependence on supplier

egen proa_yam=sum(bid_price) if filter_ok==1 & !missing(buyer_id) & !missing(year), by(buyer_id year) 
lab var proa_yam "By PA-year: Spending amount"
*proa_w_yam already generated
*proa_ynrc already generated

gen proa_ycsh=proa_w_yam/proa_yam 
lab var proa_ycsh "By PA-year-supplier: share of supplier in total annual PA spend"
egen proa_mycsh=max(proa_ycsh), by(buyer_id year)
lab var proa_mycsh "By PA-year: Max share spent on one supplier"

gsort buyer_id +year +aw_date
egen filter_proay = tag(buyer_id year) if filter_ok==1 & !missing(buyer_id) & !missing(year)
lab var filter_proay "Marking PA years"
// tab filter_proay

sort buyer_id
egen filter_proa = tag(buyer_id) if filter_ok==1 & !missing(buyer_id)
lab var filter_proa "Marking PAs"
// tab filter_proa

gen x=1
egen proa_nrc=total(x) if filter_ok==1 & !missing(buyer_id), by(buyer_id)
cap drop x
lab var proa_nrc "#Contracts by PAs"
// sum proa_nrc
// hist proa_nrc

gen proa_ycsh4=proa_ycsh if filter_ok==1 & proa_ynrc>4 & proa_ycsh!=.
********************************************************************************
*END