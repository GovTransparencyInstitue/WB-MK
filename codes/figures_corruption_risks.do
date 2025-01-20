***Descriptives for North Macedonia paper using Stata

keep if year>2010 

**create new variables
gen year_quarter=string(year,"%02.0f") +"_Q"+ string(quarter,"%02.0f")
egen yearquarter = group(year_quarter), label 

gen len=strlen(tender_cpvs)
gen industries=substr(tender_cpvs ,1,2)
destring industries, gen(industry)

gen  name_industry="Agricultural, fishing, forestry" if industry==3
replace name_industry="Petroleum products, fuel, electricity" if industry==9
replace name_industry="Mining" if industry==14
replace name_industry="Food, beverages, tobacco" if industry==15
replace name_industry="Agricultural machinery" if industry==16
replace name_industry="Clothing, footwear" if industry==18
replace name_industry="Leather and textile fabrics" if industry==19
replace name_industry="Printed matter" if industry==22
replace name_industry="Chemical products" if industry==24
replace name_industry="Office and computing machinery" if industry==30
replace name_industry="Electrical machinery"	if industry==31
replace name_industry="Radio, television, communication" if industry==32
replace name_industry="Medical equipments, pharmaceuticals" if industry==33
replace name_industry="Transport equipments" if industry==34
replace name_industry="Security, fire-fighting, police" if industry==35
replace name_industry="Art materials and accessories" if industry==37
replace name_industry="Laboratory, optical and precision equipment"	if industry==38
replace name_industry="Furniture, furnishings" if industry==39
replace name_industry="Collected and purified water" if industry==41
replace name_industry="Industrial machinery" if industry==42
replace name_industry="Machinery for mining, quarrying" if industry==43
replace name_industry="Construction structures and materials" if industry==44
replace name_industry="Construction work" if industry==45
replace name_industry="Software package and information systems" if industry==48
replace name_industry="Repair and maintenance services" if industry==50
replace name_industry="Installation services"	if industry==51
replace name_industry="Hotel, restaurants" if industry==55
replace name_industry="Transport services"	if industry==60
replace name_industry="Transport services"	if industry==63
replace name_industry="Postal and telecommunications services" if industry==64
replace name_industry="Public utilities" if industry==65
replace name_industry="Financial and insurance services" if industry==66
replace name_industry="Real estate services" if industry==70
replace name_industry="Architectural, construction services" if industry==71
replace name_industry="IT services"	if industry==72
replace name_industry="Research and consultancy services" if industry==73
replace name_industry="Administration, defence and social security" if industry==75
replace name_industry="Services related to the oil and gas industry" if industry==76
replace name_industry="Agricultural, forestry, horticultural" if industry==77
replace name_industry="Business services" if industry==79
replace name_industry="Education and training services" if industry==80
replace name_industry="Health and social work services" if industry==85
replace name_industry="Sewage and environmental services" if industry==90
replace name_industry="Recreational, cultural and sporting services" if industry==92
replace name_industry="Other community, social and personal service" if industry==98
replace name_industry="Other" if industry==99

***
label variable corr_singleb "Single bidder" 
label variable corr_proc "Procedure type"
label variable taxhav2  "Tax haven" 
label variable corr_subm "Length of submission" 
label variable corr_decp "Length of decision period"
label variable proa_ycsh4 "Buyer's dependence" 
label variable corr_ben "Benford's law" 

**Figures
*Figure 5: CRI distribution by contract
tabstat cri, stats(n mean median min max)
    
local mean ".426384"
local median ".421566"

hist cri, bin(30) freq color(blue) lcolor(black) lwidth(thin) ///
	ylab(, format(%8.0g)) graphregion(color(white)) ///
	xtitle("CRI") ytitle("Number of contracts") ///
	addplot( pci 0  `mean' 40000 `mean', ///
	lpattern(dash) lwidth(medium) || pci 0  `median' 40000  `median',  ///
	lpattern(dash) lwidth(medium)) bgcolor(white)  ylabel(, nogrid) ///
	legend(order(2 "Mean CRI" 3 "Median CRI") ///
	region(style(none)) pos(6) rows(1))

graph export "${output_figures}/contract_cri.jpg", as(jpg) name("Graph") quality(100) replace
		
*Figure 6: CRI distribution per buyers
egen count=count(cri),by(cri)
egen tag=tag(cri)
tab count if tag==1 
bysort buyer_id: gen no_tenders_buyers=_N
tabstat no_tenders_buyers, stats(n mean median min max)

preserve
	collapse (mean) cri no_tenders_buyers, by(buyer_id)

	tabstat cri, stats(n mean median min max) save
	local mean ".4894625"
	local median "0.5"

	hist cri, freq color(blue) lcolor(black) lwidth(thin) ///
		ylab(, format(%8.0g)) graphregion(color(white)) ///
		xtitle("Average CRI per buyer") ytitle("Number of buyers") ///
		addplot( pci 0 `mean' 200 `mean', ///
		lpattern(dash) lwidth(medium) || pci 0  `median' 200  `median',  ///
		lpattern(dash) lwidth(medium)) bgcolor(white)  ylabel(, nogrid) ///
		legend(order(2 "Mean CRI" 3 "Median CRI") ///
		region(style(none)) pos(6) rows(1))
		
	graph export "${output_figures}/buyers_cri.png", as(png) replace
restore

**Figure 7: CRI distribution per supplier
preserve
	keep if filter_ok==1
	bysort bidder_id: gen no_tenders_bidder=_N
	tabstat no_tenders_bidder, stats(n mean median min max)
	collapse (mean) cri no_tenders_bidder, by(bidder_id)

	tabstat cri, stats(n mean median min max)

	local mean ".5012833" 
	local median ".5"

	hist cri, bin(25) freq color(blue) lcolor(black) lwidth(thin) ///
		ylab(, format(%8.0g)) graphregion(color(white)) ///
		xtitle("Average CRI per supplier") ytitle("Number of suppliers") ///
		addplot( pci 0 `mean' 2000 `mean', ///
		lpattern(dash) lwidth(medium) || pci 0 `median' 2000 `median',  ///
		lpattern(dash) lwidth(medium)) bgcolor(white)  ylabel(, nogrid) ///
		legend(order(2 "Mean CRI" 3 "Median CRI") ///
		region(style(none)) pos(6) rows(1))

	graph export "${output_figures}/supplier_cri.png", as(png) replace

restore

*Figure 8: Cri by year
preserve
	collapse (mean) cri, by(year)
	twoway (connected cri year, ///
		sort xlabel(2011(1)2022, angle(0) valuelabel) graphregion(color(white)) ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1) xtitle("Year") ytitle("CRI") ), ///
		aspectratio(0.5)
		
	graph export "${output_figures}/quarter_cri.png", as(png) replace

restore

****Figure 9: cri by regions
preserve
	keep if filter_ok==1
	collapse (mean) cri corr_singleb corr_nocft corr_proc corr_subm ///
		corr_decp proa_ycsh4 corr_ben taxhav , by(buyer_nuts year)
		
	twoway (connected cri year if buyer_nuts=="MK001", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022)) ///
		(connected cri year if buyer_nuts=="MK002", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022)) ///	
		(connected cri year if buyer_nuts=="MK003", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022)) ///
		(connected cri year if buyer_nuts=="MK004", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022))  ///
		(connected cri year if buyer_nuts=="MK005", ysc(r(0 1))  ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022))  ///
		(connected cri year if buyer_nuts=="MK006", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022)) ///	
		(connected cri year if buyer_nuts=="MK007", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(3)2022)) 	///
		(connected cri year if buyer_nuts=="MK008", ysc(r(0 1)) ///
		ylabel(0 0.25 0.5 0.75 1) xlabel(2011(1)2022) graphregion(color(white)) ///
		,legend(order(1 "Vardarski" 2 "Istočen" 3 "Jugozapaden"  4 "Jugoistočen" ///
		5 "Pelagoniski" 6 "Pološki" 7 "Severoistočen" 8 "Skopski")))
	graph export "${output_figures}/regions_cri.png", as(png) replace
restore

**Figure 10: graph box cri mean
bysort industry: gen cont_ind=_N
graph box cri if cont_ind>1000 ,  over(name_industry, sort(1)) horizontal 

******
**Figure 11: Construction and the rest
preserve 
	gen construction=0
	replace construction=1 if industry==43 | industry==44 | industry==45 | industry==71

	collapse (mean) cri, by(construction year)

	twoway (connected cri year if construction==1, sort) ///
			(connected cri year if construction==0, sort ///
			xlabel(2011(1)2022, angle(0) valuelabel) ///
			graphregion(color(white)) ///
			xtitle("Year") ytitle("CRI")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1) ///
			legend(order( 1 "Construction sector"  2 "Other sectors") ///
				  rows(1) ring(1) position(6)))
		
restore

**Figure 12: Covid-health by quarter

preserve

	gen health=0
	replace health=1 if industry==85
	replace health=2 if industry==33

	collapse (mean) cri, by(health year)

	twoway (connected cri year if health==1, sort) ///
			(connected cri year if health==2, sort) ///
			(connected cri year if health==0, sort ///
			xline(38) xlabel(2011(1)2022, angle(0) valuelabel) ///
			graphregion(color(white)) ytitle("CRI") ///
			xtitle("Year")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1) ///
			legend(order(1 "Health and social work services"  3 "Other" ///
			2 "Medical equipments, pharmaceuticals products") ///
				  rows(2) ring(1) position(6)))
		
restore


**Figure 13: cri variables
preserve
	keep if filter_ok==1
	collapse (mean) cri corr_singleb corr_nocft corr_proc corr_subm ///
		corr_decp proa_ycsh4 corr_ben taxhav2 , by(year)

	twoway (connected corr_singleb year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Single bidding")  ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
	graph save g11, replace	
	twoway (connected corr_proc year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Procedure type")  ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1) )
	graph save g13, replace	
	twoway (connected taxhav2 year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Tax haven")  ///
		ysc(r(0 9)) ylabel(0 3 6 9) )
	graph save g14, replace	
	twoway (connected corr_subm  year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Length of submission")  ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
	graph save g15, replace	
	twoway (connected  corr_decp year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Length of decision period")  ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
	graph save g16, replace	
	twoway (connected proa_ycsh4 year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Buyer's dependence")  ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
	graph save g17, replace	
	twoway (connected corr_ben  year, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		xtitle("Year") ytitle("Benford's law")  ///
		ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
	graph save g18, replace		

	graph combine "g11" "g13" "g14" "g15" "g16" "g17" "g18", rows(4) graphregion(color(white)) iscale(.5) 
	graph export "${output_figures}/individual_flags.png", as(png) replace
	
restore


******Appendix figures

preserve
	keep if filter_ok==1

	gen skopje=0
	replace skopje=1 if buyer_nuts=="MK008"
	collapse (sum) bid_price, by(skopje year)
	replace bid_price=bid_price/1000000000
	egen total_tender = total(bid_price), by(year)
	gen percent= bid_price*100/total_tender

	*Figure A1.b: Total awarded contract value as a percentage for Skopje and other regions
	twoway (connected percent year if skopje==1) ///
		   (connected percent year if skopje==0), ///
			xlabel(2011(1)2022) graphregion(color(white)) ///
		   legend(order(1 "Skopje" 2 "Other regions") pos(6) rows(1) region(style(none))) ///
		   ylabel(, nogrid) xtitle("Year") ytitle("Percentage of awarded contract values") 

	graph export "${output_figures}/awarded_skopje_perc.png", as(png) replace

	*Figure A1.c: Total awarded contract value for Skopje and other regions, 2011-2022, North Macedonia.
	twoway (connected bid_price year if skopje==1) ///
		(connected bid_price year if skopje==0, ///
		sort xlabel(2011(1)2022) graphregion(color(white)) ///
		legend(order(1 "Skopje" 2 "Other regions") pos(6) rows(1) ///
		region(style(none))) ylabel(, nogrid) ///
		xtitle("Year") ytitle("Sum of awarded contract in billion MKD"))
		
		
	graph export "${output_figures}/regions_total.png", as(png) replace

restore

*Figure A1.d: Average CRI across regions in North Macedonia for 2011-2022.
encode buyer_nuts, gen(buyer_nuts_num)
 
label define buyer_nuts_lbl 1 "Vardarski" 2 "Istočen" 3 "Jugozapaden" 4 "Jugoistočen" ///
                            5 "Pelagoniski" 6 "Pološki" 7 "Severoistočen" 8 "Skopski"
label values buyer_nuts_num buyer_nuts_lbl

graph box cri, over(buyer_nuts_num, label(labsize(small))) ///
    ytitle("CRI") graphregion(color(white))

graph export "${output_figures}/regions_graphbox.png", as(png) replace


**Figure A1.e: Annual trends for individual red flags by each region, 2011-2022.
preserve
	destring(buyer_nuts), gen (nuts) ignore("MK")

	collapse (mean) cri corr_singleb corr_nocft corr_proc corr_subm ///
		corr_decp proa_ycsh4 corr_ben taxhav2 , by(year nuts)

	local titles "Vardarski Istočen Jugozapaden Jugoistočen Pelagoniski Pološki Severoistočen Skopski"

	forvalues i = 1/8 {
		local text : word `i' of `titles'

		twoway (connected corr_singleb year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Single bidding")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
		graph save g`i'1, replace
		
		twoway (connected corr_proc year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Procedure type")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
		graph save g`i'3, replace

		twoway (connected taxhav2 year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Tax haven")  ///
			ysc(r(0 9)) ylabel(0 3 6 9))
		graph save g`i'4, replace
		
		twoway (connected corr_subm year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Length of submission")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
		graph save g`i'5, replace

		twoway (connected corr_decp year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Length of decision period")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
		graph save g`i'6, replace
		
		twoway (connected proa_ycsh4 year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Buyer's dependence")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
		graph save g`i'7, replace
		
		twoway (connected corr_ben year if nuts == `i', ///
			sort xlabel(2011(1)2022) graphregion(color(white)) ///
			xtitle("Year") ytitle("Benford's law")  ///
			ysc(r(0 1)) ylabel(0 0.25 0.5 0.75 1))
		graph save g`i'8, replace
		
		graph combine "g`i'1" "g`i'3" "g`i'4" "g`i'5" "g`i'6" "g`i'7" "g`i'8", ///
			rows(4) graphregion(color(white)) iscale(.5) title("`text'", size(small))
		
		graph export "${output_figures}/annex_reg_`i'.png", as(jpg) name("Graph") quality(100) replace
	}

restore

*Figure A1.f: Annual trends for cri by industry, 2011-2022. (red line shows the start of Covid-19 pandemic)

preserve

	collapse (mean) cri, by(name_industry year)

	levelsof name_industry, local(industry_list)

	local counter = 1 

	foreach industry in `industry_list' {
		twoway (connected cri year if name_industry == "`industry'"), ///
			xline(2020) xlabel(2012(2)2022, angle(0) valuelabel) ///
			graphregion(color(white)) ///
			xtitle("Year") ytitle("CRI") ///
			yscale(r(0 1)) ylabel(0 0.25 0.5 0.75 1) ///
			title("`industry'")
			
		graph save "g`counter'", replace
		
		local counter = `counter' + 1
	}


	graph combine "g1" "g2" "g3" "g4" "g5" "g6" "g7" "g8" "g9", ///
			rows(3) graphregion(color(white)) iscale(.5) title("`text'", size(small))
	graph export "${output_figures}/annex_ind_1.png", as(jpg) name("Graph") quality(100) replace

	graph combine "g10" "g11" "g12" "g13" "g14" "g15" "g16" "g17" "g18", ///
			rows(3) graphregion(color(white)) iscale(.5) title("`text'", size(small))
	graph export "${output_figures}/annex_ind_2.png", as(jpg) name("Graph") quality(100) replace


	graph combine "g19" "g20" "g21" "g22" "g23" "g24" "g25" "g26" "g27", ///
			rows(3) graphregion(color(white)) iscale(.5) title("`text'", size(small))
	graph export "${output_figures}/annex_ind_3.png", as(jpg) name("Graph") quality(100) replace


	graph combine "g28" "g29"  "g30" "g31" "g32" "g33" "g34" "g35" "g36", ///
			rows(3) graphregion(color(white)) iscale(.5) title("`text'", size(small))
	graph export "${output_figures}/annex_ind_4.png", as(jpg) name("Graph") quality(100) replace

	graph combine "g38" "g38" "g39"  "g40" "g41" "g42" "g43" "g44" "g45", ///
			rows(3) graphregion(color(white)) iscale(.5) title("`text'", size(small))
	graph export "${output_figures}/annex_ind_5.png", as(jpg) name("Graph") quality(100) replace

restore
