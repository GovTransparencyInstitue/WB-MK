**# CRI validation
// North Macedonia 
// Data version: MK_data_202211

// Load data
// import delimited using "${data}/processed/MK_202211_processed.dta", encoding(UTF-8) clear 
// *****************************************************************
// *Preparing Controls 
// *****************************************************************
// *Contract Value
// cap drop lca_contract_value 
// cap drop cvalue10
// gen lca_contract_value = log(bid_price)
//
// xtile cvalue10=bid_price if filter_ok==1, nquantiles(10)
// replace cvalue10=99 if bid_price==.
// tab cvalue10
// ************************************
// *Buyer type
//
// tab buyer_buyertype, m
// cap drop anb_type
// gen buyer_type = buyer_buyertype
// replace buyer_type="NA" if missing(buyer_type)
// encode buyer_type, gen(anb_type)
// drop buyer_type
// ************************************
// *Buyer Location
// tab buyer_nuts, m
//
// cap drop anb_location1
// cap drop anb_location
//
// gen anb_location1=buyer_nuts if regex(buyer_nuts,"^MK") 
// replace anb_location1 = substr(buyer_nuts,1,5)
// replace anb_location1="EXT" if regex(buyer_nuts,"^MK")==0 & !missing(buyer_nuts)
// replace anb_location1="NA" if missing(anb_location1)
//
// encode anb_location1, gen(anb_location)
// drop anb_location1
// tab anb_location, m
// ************************************
// // Supply type
//
// tab tender_supplytype, m
// cap drop supply_type
// cap drop ca_type
// gen supply_type = tender_supplytype
// replace supply_type="NA" if missing(tender_supplytype)
// encode supply_type, gen(ca_type)
// drop supply_type
// tab ca_type, m
// ************************************
// *Market ids [+ the missing cpv fix]
//
// cap drop market_id
// gen market_id=substr(tender_cpvs,1,2)
// tab market_id, m
// *Only these market divisions belong to the CPV2008
// gen market_id2 = market_id if inlist(market_id,"03","09","14","15","16","18","19") | inlist(market_id,"22","24","30","31","32","33","34","35","37") | inlist(market_id,"38","39","41","42","43","44","45","48","50") | inlist(market_id,"51","55","60","63","64","65","66","70") | inlist(market_id,"71","72","73","75","76","77","79","80") | inlist(market_id,"85","90","92","98","99") 
// tab market_id2, m
//
// *replace bad codes as missing  - dropping bad codes //937 observations
// gen tender_cpvs_original = tender_cpvs
// gen tender_cpvs2= tender_cpvs
// replace tender_cpvs2 = "99100000" if missing(market_id2) & tender_supplytype=="SUPPLIES"
// replace tender_cpvs2 = "99200000" if missing(market_id2) & tender_supplytype=="SERVICES"
// replace tender_cpvs2 = "99300000" if missing(market_id2) & tender_supplytype=="WORKS"
// replace tender_cpvs2 = "99000000" if missing(market_id2) & missing(tender_supplytype)
// drop market_id market_id2
// drop tender_cpvs
// rename tender_cpvs2 tender_cpvs
//
// gen market_id=substr(tender_cpvs,1,2)
// *Clean Market id
// tab market_id, m
// replace market_id="NA" if missing(market_id)
// cap drop market_id_num
// gen market_id_num = market_id
// encode market_id,gen(market_id2)
// drop market_id
// rename market_id2 market_id
// tab market_id, m
// *****************************************************************
// * Indicator Validation 
// *****************************************************************
//
// // Replace missing indicators with 9 to not drop observations during validation
// // We also multiply by 2 as binary indicators do not accept a 0.5 encoding
// foreach var in  corr_singleb corr_ben corr_decp corr_subm corr_proc taxhav3{
// gen y`var' = `var'
// replace y`var' = y`var'*2
// replace y`var' = 9 if missing(`var')
// tab y`var' 
// }
//
// // replacing the missing buyer concentration with the mean 
// sum w_ycsh4 if filter_ok
// di `r(mean)'
// gen yw_ycsh4= w_ycsh4
// replace  yw_ycsh4 = `r(mean)' if missing(w_ycsh4)

**# Open log file
local today : display %tdCYND date(c(current_date), "DMY")
log using "${output_log}/MK_validation_log_`today'" , replace

// Set global controls, options and sample 
global controls i.cvalue10 i.anb_type i.ca_type i.anb_location i.year i.market_id
global options vce(robust)
global sub_sample filter_ok 

// Individual indicator validation
foreach var in corr_ben corr_decp corr_subm corr_proc taxhav3 w_ycsh4{

global dep_vars i.y`var'
if inlist("`var'","w_ycsh4") global dep_vars c.y`var'

logit corr_singleb $dep_vars $controls if $sub_sample, $options
}

// Combined indicator validation
global dep_vars yw_ycsh4 i.ycorr_ben i.ytaxhav3 i.ycorr_decp  i.ycorr_subm i.ycorr_proc
logit corr_singleb $dep_vars $controls if $sub_sample, $options

**# Close log file
log close 
local today : display %tdCYND date(c(current_date), "DMY")
translate "${output_log}/MK_validation_log_`today'.smcl" "${output_log}/MK_validation_log_`today'.pdf", replace
erase "${output_log}/MK_validation_log_`today'.smcl"