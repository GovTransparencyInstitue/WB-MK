frame change default 

cap drop tender_cpvs_gen
gen tender_cpvs_gen = ""

cap frame drop CPV
frame create CPV
frame change CPV


// import delimited "${data_utility}/cpv_2007.csv", varnames(1) encoding("UTF-8") stringc(_all) clear 
// rename description2007 cpv_desc_en
// ren cpvcode2007 cpv_codes
// drop if cpv_desc_en=="#N/A"
// drop if missing(cpv_desc_en)
// drop if missing(cpv_codes)
//
// local temp ". ,"
// local n_temp : word count `temp'
// forval s =1/`n_temp'{
//  replace cpv_desc_en = subinstr(cpv_desc_en, "`: word `s' of `temp''", "",.)
// 	}
//
// export delimited "${data_utility}/cpv_2007.csv",  replace 

// After using google translate
import delimited "${data_utility}/cpv_2007.csv", varnames(1) encoding("UTF-8") stringc(_all) clear 

replace cpv_codes=substr(cpv_codes,1,8)

// Clean cpv_desc_mk from stop words

replace cpv_desc_mk =  " " +  cpv_desc_mk + " "
local mk_stopwords ""и" "ако" "беше" "би" "биде" "бил" "бува" "веќе" "во" "врз" "ги" "го" "им" "исто така" "како" "кога" "ме" "многу" "над" "наместо" "нас" "неговиот" "нејзиниот" "нив" "но" "освен" "откако" "пред" "со" "само" "сите" "со цел" "тоа" "тој" "таа" "тие" "токму" "треба" "ќе" "договорот" "јавен" "јавна" "јавно" "квалитет" "компанија" "корисникот" "набавката" "објавена" "објавен" "објавување" "објектот" "овластување" "понудите" "понудата" "понудувачот" "постапката" "постапките" "преглед" "примената" "протоколот" "рокот" "согласно" "спецификациите" "трошоците" "увид" "условите" "учесниците" "фазата" "цената" "членот""
foreach word in `mk_stopwords'{
    di "`word'"
    replace cpv_desc_mk = subinstr(cpv_desc_mk, " `word' ", "",.) 
}
replace cpv_desc_mk = trim(cpv_desc_mk)
sort cpv_codes

local rows = _N
forval i=1/`rows'{
    local code = cpv_codes[`i']
	local cpv_desc_mk = cpv_desc_mk[`i']
	di "`code'"
	di "`cpv_desc_mk'"
	
//	 replace spaces with .* and add front and back

	local n : word count `cpv_desc_mk' 
	di `n'
	local i = 0
	foreach x in `cpv_desc_mk'{
	local i = `i' + 1
// 	di "Word `i' is `x'"
	local word`i' "`x'"
	}

	frames default {
	    di "Looking for `word1' `word2' `word4' `word5' `word6' `word7'"
		replace tender_cpvs_gen = "`code'" if ustrregexm(tender_title_lot_title,".*`word1'.*.*`word2'.*", 1)
		
		forval h = 1/7{
		    local word`h' ""
			} 
		
	}

}

frame change default
count if missing(tender_cpvs) & filter_ok==1
count if missing(tender_cpvs_gen) & filter_ok==1
