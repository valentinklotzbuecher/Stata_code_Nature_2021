

import excel ".\03_Data\Countries\Finland\suicidality_1.19-6.20.xlsx",  clear 

gen suicidality = "acute" if A == "acute suicidality"
replace suicidality = "behavior" if A == "suicidal behavior"
replace suicidality = "thoughts" if A == "suicidal thoughts"
replace suicidality = "plan" if A == "suicide plan (method, time, place)"
replace suicidality = "others" if A == "suicidality of a loved one"
replace suicidality = "alltogether" if A == "altogether"
replace suicidality = "allcalls" if A == "all calls"

drop A B
renvars C-UC, map("contacts" + subinstr(word(@[1],1),".","_",.))

drop in 1
encode suicidality, gen(suiccode)

reshape long contacts, i(suiccode) j(stringdate) string


gen ddate = date(stringdate, "DMY")
format ddate %td

sort ddate

drop suiccode

rename contacts contacts_suicidal_

reshape wide contacts_suicidal_, i(ddate) j(suicidality) string

destring contacts_*, replace

drop stringdate

rename contacts_suicidal_alltogether contacts_suicide
drop contacts_suicidal_allcalls

save  ".\03_Data\Countries\Finland\Finland_suicide.dta", replace


import excel ".\03_Data\Countries\Finland\Gender_1_19_6_20.xlsx", sheet("Sheet1") firstrow clear 




gen helplinecontacts = Allcalls

gen contacts_female =  Female 
gen contacts_male = Male
gen contacts_othergender  = Other

gen ddate = date(date, "DMY")
format ddate %td



bysort ddate: keep if _n == 1
keep helplinecontacts contacts_* ddate

gen helplinename = "MIELI Mental Health Finland"

gen country = "Finland"
		
gen population = 5.518 	// million (2019)


merge 1:1 ddate using ".\03_Data\Countries\Finland\Finland_suicide.dta", nogen


save  ".\03_Data\Countries\Finland\Finland_series.dta", replace



