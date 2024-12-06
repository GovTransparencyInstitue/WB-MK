* Generate CRI
********************************************************************************
local country `1'

local country MK

********************************************************************************
frame create ind
frame change ind

	import excel "${data}\utility\CRI_components.xlsx", sheet("in_cri") firstrow clear
	keep if country == "`country'"
	levelsof indicators, local(indicators)
//	Re-ordering the indicators list if corr_nocft is included as it should be run after corr_subm
	local nocft_macro "corr_nocft"
	local result : list corr_nocft in indicators
	di "`result'"
	if (`result' ==  1) {
	local indicators : list indicators - nocft_macro
	local indicators : list indicators | nocft_macro 
	}

frame change default
frame drop ind

********************************************************************************
foreach var in corr_singleb corr_proc corr_nocft corr_decp corr_subm taxhav2 taxhav3 proa_ycsh4 corr_ben {
	cap drop `var'
	
}

foreach indicator in `indicators'{
if inlist("`indicator'","corr_singleb") do "${codes}/utility/indicators/gen_corr_singleb.do" `country'

if inlist("`indicator'","corr_proc") do "${codes}/utility/indicators/gen_corr_proc.do" `country'

if inlist("`indicator'","corr_subm") do "${codes}/utility/indicators/gen_corr_subm.do" `country'

if inlist("`indicator'","corr_decp") do "${codes}/utility/indicators/gen_corr_decp.do" `country'

if inlist("`indicator'","corr_nocft") do "${codes}/utility/indicators/gen_corr_nocft.do" `country'

if inlist("`indicator'","taxhav2") do "${codes}/utility/indicators/gen_corr_taxhav.do" `country'

if inlist("`indicator'","proa_ycsh4") do "${codes}/utility/indicators/gen_proa_ycsh.do" `country'

if inlist("`indicator'","corr_ben") do "${codes}/utility/indicators/gen_corr_ben.do" `country'
}
********************************************************************************
//Generate missing indicators as missing

local miss_vars corr_singleb corr_proc corr_decp corr_subm taxhav2 taxhav3 w_ycsh4 corr_ben corr_nocft
foreach var in `miss_vars'{
    tab `var'
//     capture confirm variable `var'
// 	if (_rc==0) continue
// 	else gen `var' = ""
}
// replace corr_nocft = .

// Generate cri

foreach var in corr_singleb corr_proc corr_decp corr_subm taxhav2 taxhav3 w_ycsh4 corr_ben{
destring `var', replace
}

do "${codes}/utility/cri.do" corr_singleb corr_proc corr_decp corr_subm taxhav2 w_ycsh4 corr_ben

// local vars  corr_singleb corr_proc corr_nocft corr_decp corr_subm taxhav2  corr_ben
// foreach var in `vars'{
// tab `var'
// }

*******************************************************************
*END