// Clean MK text for general purpose

// Remove stopwords
preserve 

	import delimited using "${data}/utility/MK_stopwords.csv", clear varnames(1)
	replace words =ustrlower(words)
	replace words = subinstr(words, ".", " ",.)
	replace words = subinstr(words, ",", " ",.)
	replace words = subinstr(words, "(", " ",.)
	levelsof words, local(mk_stopwords)
restore

replace `1' = " " +  `1' + " "

// Lower case 
replace `1' =ustrlower(`1')

// Remove stop words
foreach word in `mk_stopwords'{
    di "`word'"
	replace `1' = subinstr(`1'," `word' "," ",.)
}

// Remove unwanted characters
local temp "« » ‹ › Þ þ ð º ° ª ¡ ¿ ¢ £ € ¥ ƒ ¤ © ® ™ • § † ‡ ¶ & " " ¦ ¨ ¬ ¯ ± ² ³ ´ µ · ¸ ¹ º ¼ ½ ¾"
local n_temp : word count `temp'
forval s =1/`n_temp'{
 replace `1' = subinstr(`1', "`: word `s' of `temp''", " ",.)
	}
	
// Replace other special character
local stop " "+" "'" "~" "!" "*" "<" ">" "[" "]" "=" "&" "(" ")" "?" "#" "^" "%"  "," "-" ":" ";" "@" "_" "„" "´" "ʼ" "|" "'""
foreach v of local stop {
 replace `1' = subinstr(`1', "`v'", " ",.)
}

replace `1' = subinstr(`1', "–", " ",.)
replace `1' = subinstr(`1', ".", " ",.)
replace `1' = subinstr(`1', "—", " ",.)
replace `1' = subinstr(`1', "'", " ",.)
replace `1' = subinstr(`1', "ʼ", " ",.)
replace `1' = subinstr(`1', `"$"', " ",.) 
replace `1' = subinstr(`1', "`", " ",.) 
replace `1' = subinstr(`1', `"""', " ",.)
replace `1' = subinstr(`1', `"/"', " ",.)
replace `1' = subinstr(`1', `"\"', " ",.)
replace `1' = subinstr(`1', "  ", " ",.)

// Remove numbers
// ereplace `1' = sieve(`1'), omit(0123456789)
local stop "0 1 2 3 4 5 6 7 8 9"
foreach v of local stop {
 replace `1' = subinstr(`1', "`v'", " ",.)
}


// Strip unwanted whitespace
forval var=1/10{
replace `1' = subinstr(`1', "  ", "",.)
}

replace `1' = stritrim(`1')
replace `1' = strtrim(`1')