


*Hotline help-seeking Cases which related to the epidemic (Coronavirus)
import excel "$rawdata\Countries\Hong Kong\Kopie von Hotline help seeking cases till 6Oct_9am.xlsx", sheet("工作表1 (2)") firstrow clear 

renvars HotlinehelpseekingCaseswhich B E, map(word(@[2],1))
renvars  C D , map(word(@[3],1))
rename F Risklevel

drop G H I J K L M N O P

drop in 1/3
drop if _n > 636

gen stringdate = Month + "/" + Day + "/" +"2020"
gen ddate = date(stringdate, "MDY")
format ddate %td

gen female = 0 if Female == "*" | Male == "*"
gen male = 0 if Female == "*" | Male == "*"
replace female = 1 if Female == "*" 
replace male = 1 if Male == "*" 

gen country = "Hong Kong"
gen population = 7.451
gen helplinename = "Samaritan Befrienders"

save  "$rawdata\Countries\Hong Kong\HKG_contacts.dta", replace


// bysort ddate: gen helplinecontacts = _N
// bysort ddate: egen contacts_female = sum(Female == "*")
// bysort ddate: egen contacts_male = sum(Female == "*")

// bysort ddate: keep if _n == 1
// keep ddate country population helplinecontacts contacts_*

// gen helplinename = "The Samaritan Befrienders Hong Kong"

// save  "$rawdata\Countries\Hong Kong\HongKong_series.dta", replace


