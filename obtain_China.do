

import excel "$rawdata\Countries\China\2019.xls",  firstrow clear 

save "$rawdata\Countries\China\2019.dta", replace


import excel "$rawdata\Countries\China\2020.xls",  firstrow clear 


append using "$rawdata\Countries\China\2019.dta"
erase "$rawdata\Countries\China\2019.dta"




gen ddate = date(substr(Dateandtime,1,10), "YMD")
format ddate %td

gen hour = substr(Dateandtime,12,2)
destring hour, replace

gen phone = 1 	// Mode distinguishes different phone types

gen female = 0 if Gender == "Male"
replace female  = 1 if Gender == "Female"
gen male = 0 if Gender  == "Female"
replace male  = 1 if Gender == "Male"

destring Age, gen(age) 
replace age = . if age >100

gen married = 0 if Marriage != ""
replace married = 1 if Marriage == "Remarried" | Marriage  == "Married"


gen firstcall = 0 if Classificationofcase != ""
replace firstcall = 1 if Classificationofcase == "New case"
gen repcall = 0 if Classificationofcase != ""
replace repcall = 1 if Classificationofcase == "Old case"

					
replace Occupation = "" if Occupation == "Don't know"
replace Occupation = "Soldier" if Occupation == "Solider"

gen retired = 0 if Occupation != ""
replace retired = 1 if Occupation == "Retirement"

gen employed = 0 if Occupation != ""
replace employed = 1 if Occupation == "White collar worker"
replace employed = 1 if Occupation == "Blue collar worker"
replace employed = 1 if Occupation == "Civil servant"
replace employed = 1 if Occupation == "Teacher"
replace employed = 1 if Occupation == "Peasant worker"
replace employed = 1 if Occupation == "Soldier"

gen unemployed = 0 if Occupation != ""
replace unemployed = 1 if Occupation == "Unemployed"


gen education = 0 if Occupation != ""
replace education = 1 if Occupation == "Junior school student"
replace education = 1 if Occupation == "Elementary school student"
replace education = 1 if Occupation == "Student in college"
replace education = 1 if Occupation == "Kindergarten pupil"
replace education = 1 if Occupation == "Senior high school student"
replace education = 1 if Occupation == "Elementary school students "



gen physhealth = 0 if Reasonsforconsultation != ""
replace physhealth = 1 if Reasonsforconsultation == "Disabled or disease" | Reasonsforconsultation == "Disabled or diease"

gen T_econ = 0 if Reasonsforconsultation != ""
replace T_econ = 1 if Reasonsforconsultation == "Job-related" | Reasonsforconsultation == "Financial issues"

gen T_social = 0 if Reasonsforconsultation != ""
replace T_social = 1 if Reasonsforconsultation == "Relationship" | Reasonsforconsultation == "Friendship" | Reasonsforconsultation == "Marriage" | Reasonsforconsultation == "Issues with children" | Reasonsforconsultation == "Issues with parents"

gen suicide = 0 if Pychologicaltraumalevel != ""
replace suicide = 1 if Pychologicaltraumalevel == "Suicide"

gen selfharm = 0 if Pychologicaltraumalevel != ""
replace selfharm = 1 if Pychologicaltraumalevel == "Self-abuse" | Pychologicaltraumalevel == "Self-injury"






gen country = "China"
gen population = 1393

keep  ddate-population age

gen age_min = age
gen age_max = age

gen helplinename = "Hope 24 Line" 



save `"$rawdata\Countries\China\CHNcontacts.dta"',  replace

