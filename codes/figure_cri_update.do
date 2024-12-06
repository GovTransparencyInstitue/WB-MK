
// CRI by quarters
// 25/5/2024 the requested an update for the CRI figure

import delimited using "C:/Ourfolders/Aly/MK_WB/data/processed/MK_202212_processed.csv", encoding(UTF-8) clear 

frame change default
cap frame drop quarter_cri
frame copy default quarter_cri
frame change quarter_cri



keep if filter_ok
// keep if inrange(year,2011,2022)
collapse (mean) cri , by(year quarter) fast

gen qdate = yq(year, quarter)
format qdate %tq
tsset qdate
di yq(2011, 1)

**# Figures for the paper

tsline cri , tlab(2011q1(2)2022q4, angle(45) labsize(vsmall)) lpattern(solid )  legend( rows(3) pos(6))  xtitle("") ytitle("CRI") msymbol(o)
graph export "C:/Ourfolders/Aly/MK_WB/output/figures/MK_202212_CRI_quarters.png", as(png) replace
export delimited "C:/Ourfolders/Aly/MK_WB/data/processed/MK_202212_CRI_quarters.csv", replace
