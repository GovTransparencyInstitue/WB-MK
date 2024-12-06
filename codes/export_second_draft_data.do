// THe tender_cpv variable was updated using the matchit code in the MK_202211_processed.dta and a re-export was created MK_202303_processed.csv

frame copy default export

frame change export


tab corr_singleb, m
tab corr_proc
tab corr_nocft
tab corr_subm
tab corr_decp
tab corr_ben
tab taxhav2
replace taxhav2 =. if taxhav2==9


// corr_singleb corr_proc corr_nocft corr_subm corr_decp corr_ben taxhav2 proa_ycsh4

keep  persistent_id tender_id tender_title tender_proceduretype tender_nationalproceduretype tender_isawarded tender_supplytype tender_biddeadline tender_iscentralprocurement tender_isjointprocurement tender_onbehalfof_count tender_isonbehalfof tender_lotscount tender_recordedbidscount tender_documents_count tender_npwp_reasons tender_isframeworkagreement tender_isdps tender_estimateddurationindays tender_contractsignaturedate tender_maincpv tender_cpvs tender_cpvs_original tender_iseufunded tender_selectionmethod tender_awardcriteria_count tender_iselectronicauction tender_cancellationdate cancellation_reason tender_awarddecisiondate tender_iscoveredbygpa tender_eligiblebidlanguages tender_estimatedprice tender_finalprice lot_estimatedprice bid_price tender_corrections_count lot_row_nr lot_title lot_status lot_bidscount lot_validbidscount lot_electronicbidscount lot_smebidscount lot_othereumemberstatescompanies lot_noneumemberstatescompaniesbi lot_foreigncompaniesbidscount lot_amendmentscount lot_updatedprice lot_updatedcompletiondate lot_updateddurationdays buyer_masterid buyer_name buyer_nuts buyer_email buyer_contactname buyer_contactpoint buyer_city buyer_country buyer_mainactivities buyer_buyertype buyer_postcode bidder_masterid bidder_name bidder_nuts bidder_city bidder_country bid_iswinning bid_issubcontracted bid_subcontractedproportion bid_isconsortium award_count notice_count source tender_publications_lastcontract tender_publications_firstcontrac notice_url tender_publications_lastcallfort tender_publications_firstcallfor tender_year savings award_period_length tender_addressofimplementation_n opentender currency tender_digiwhist_price bid_digiwhist_price payments_sum last_payment_year lot_id bid_id buyer_id buyer_country_api buyer_state_api buyer_county_api buyer_city_api buyer_district_api buyer_street_api bidder_id legal_form bidder_country_api bidder_state_api bidder_county_api bidder_city_api bidder_district_api bidder_street_api  year quarter month cft_date_combined ca_date_combined filter_ok filter_1lot corr_singleb corr_proc submp corr_subm corr_nocft decp corr_decp iso sec_score fsuppl taxhav taxhav2 taxhav3 MAD_conformitiy MAD  corr_ben w_yam proa_w_yam w_ycsh w_mycsh w_ynrc proa_ynrc filter_wy filter_w filter_wproa filter_wproay w_ycsh4 proa_yam proa_ycsh proa_mycsh filter_proay filter_proa proa_nrc proa_ycsh4 cri

rename legal_form bidder_legal_form

// submp decp sec_score fsuppl taxhav taxhav3 MAD_conformitiy MAD proa_ycsh w_ycsh

export delimited "${data}/processed/MK_202303_processed.csv", replace
! ${R_path} ${codes_utility}/data_rename.R ${data_processed}


frame change default
cap frame drop export

local filename "MK_202303_processed"
//Zip files
//csv
!"C:/Program Files/7-Zip/7z.exe" a -tgzip "${data}/processed/`filename'.csv.gz" "${data}/processed/`filename'.csv"
