* Adding supplmentary variables 

*****************************************************************
*Preparing Filters 
*****************************************************************
cap drop filter_ok
gen filter_ok=1
replace filter_ok=0  if missing(bidder_name)  |  lot_status=="CANCELLED" 
//| !missing(tender_cancellationdate)

replace filter_ok=0 if missing(bidder_name) 
// replace filter_ok=0 if !missing(tender_cancellationdate) 
replace filter_ok=0 if lot_status=="CANCELLED" 

cap drop monthly
gen monthly = ym(year, month)
format monthly %tm

replace filter_ok=0 if !inrange(monthly,ym(2011, 1),ym(2022,8))


tab filter_ok
count if missing(bidder_name) & filter_ok==1
count if !missing(tender_cancellationdate) & filter_ok==1
tab lot_status if filter_ok
*************************************************
**# 1-lot tenders filter
frame change default 

cap drop count_lots
sort notice_url
bys notice_url: gen count_lots=_N
tab count_lots, m
cap drop filter_1lot
gen filter_1lot = 0
replace filter_1lot=1 if count_lots==1
tab filter_1lot  

tab  filter_ok, m
tab filter_1lot filter_ok, m
// Ask gergo about rows missing both urls and have a bidder_name
// bys notice_url: gen xcount_lots_url=_N
// bys tender_id: gen xcount_lots_id=_N
// br notice_url  tender_id if xcount_lots_url!=xcount_lots_id
// count if missing(tender_publications_lastcontract) & missing(notice_url)
// br buyer_name bidder_name if missing(bidder_name) & missing(tender_publications_lastcontract) & missing(notice_url)
// tab filter_ok filter_1lot if missing(tender_publications_lastcontract) & missing(notice_url)
*****************************************************************
*Preparing Controls 
*****************************************************************
*Contract Value
cap drop lca_contract_value 
cap drop cvalue10
gen lca_contract_value = log(bid_price)

xtile cvalue10=bid_price if filter_ok==1, nquantiles(10)
replace cvalue10=99 if bid_price==.
tab cvalue10
************************************
*Buyer type

tab buyer_buyertype, m
cap drop anb_type
gen buyer_type = buyer_buyertype
replace buyer_type="NA" if missing(buyer_type)
encode buyer_type, gen(anb_type)
drop buyer_type
************************************
*Buyer Location
tab buyer_nuts, m

cap drop anb_location1
cap drop anb_location

gen anb_location1=buyer_nuts if regex(buyer_nuts,"^MK") 
replace anb_location1 = substr(buyer_nuts,1,5)
replace anb_location1="EXT" if regex(buyer_nuts,"^MK")==0 & !missing(buyer_nuts)
replace anb_location1="NA" if missing(anb_location1)

encode anb_location1, gen(anb_location)
drop anb_location1
tab anb_location, m
************************************
// Supply type

tab tender_supplytype, m
cap drop supply_type
cap drop ca_type
gen supply_type = tender_supplytype
replace supply_type="NA" if missing(tender_supplytype)
encode supply_type, gen(ca_type)
drop supply_type
tab ca_type, m
************************************
*Market ids [+ the missing cpv fix]

cap drop market_id
gen market_id=substr(tender_cpvs,1,2)
tab market_id, m
*Only these market divisions belong to the CPV2008
gen market_id2 = market_id if inlist(market_id,"03","09","14","15","16","18","19") | inlist(market_id,"22","24","30","31","32","33","34","35","37") | inlist(market_id,"38","39","41","42","43","44","45","48","50") | inlist(market_id,"51","55","60","63","64","65","66","70") | inlist(market_id,"71","72","73","75","76","77","79","80") | inlist(market_id,"85","90","92","98","99") 
tab market_id2, m

*replace bad codes as missing  - dropping bad codes //937 observations
gen tender_cpvs_original = tender_cpvs
gen tender_cpvs2= tender_cpvs
replace tender_cpvs2 = "99100000" if missing(market_id2) & tender_supplytype=="SUPPLIES"
replace tender_cpvs2 = "99200000" if missing(market_id2) & tender_supplytype=="SERVICES"
replace tender_cpvs2 = "99300000" if missing(market_id2) & tender_supplytype=="WORKS"
replace tender_cpvs2 = "99000000" if missing(market_id2) & missing(tender_supplytype)
drop market_id market_id2
drop tender_cpvs
rename tender_cpvs2 tender_cpvs

gen market_id=substr(tender_cpvs,1,2)
*Clean Market id
tab market_id, m
replace market_id="NA" if missing(market_id)
cap drop market_id_num
gen market_id_num = market_id
encode market_id,gen(market_id2)
drop market_id
rename market_id2 market_id
tab market_id, m
************************************

// Fix the tender_nationalproceduretype
tab tender_nationalproceduretype
levelsof tender_nationalproceduretype
cap drop tender_natproctype
gen tender_natproctype = ""
replace tender_natproctype = "Low estimated value procedure" if ustrregexm(tender_nationalproceduretype,"LOW",1)
replace tender_natproctype = "QualificationSystem" if ustrregexm(tender_nationalproceduretype,"QualificationSystem",1)
replace tender_natproctype = "RequestForProposal" if ustrregexm(tender_nationalproceduretype,"RequestForProposal",1)
replace tender_natproctype = "SimplifiedOpenProcedure" if ustrregexm(tender_nationalproceduretype,"SIMPLIFIED",1)
replace tender_natproctype = "Negotiatedwithoutpublication" if ustrregexm(tender_nationalproceduretype,"Negotiated procedure without prior publication of a contract notice",1) | ustrregexm(tender_nationalproceduretype,"PROCEDUREFORTALKINGWITHOUTPREVIOUSANNOUNCEMENT",1)
replace tender_natproctype = "Negotiatedwithpublication" if ustrregexm(tender_nationalproceduretype,"PROCEDUREFORTALKINGWITHPREVIOUSANNOUNCEMENT",1)
replace tender_natproctype = "Open" if ustrregexm(tender_nationalproceduretype,"Open",1) &  ustrregexm(tender_nationalproceduretype,"Simplified",1)==0
replace tender_natproctype = "Other" if missing(tender_natproctype)

tab tender_natproctype, m
tab tender_nationalproceduretype if missing(tender_natproctype)
tab tender_nationalproceduretype if tender_natproctype=="Open"

levelsof tender_natproctype, local(procs)
foreach proc in `procs'{
    di "`proc'"
    tab tender_proceduretype if tender_natproctype=="`proc'"
}


************************************
*END