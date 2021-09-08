





import excel "$rawdata\Countries\Austria\2019_01_Jan.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\jan2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_02_Feb.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\feb2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_03_Maerz.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\mar2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_04_April2019.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\apr2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_05_Mai.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\may2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_06_Jun.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\jun2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_07_Jul.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\jul2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_08_August.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\aug2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_09_September2019.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\sep2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_10_Okt.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\oct2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_11_Nov.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\nov2019.dta", replace

import excel "$rawdata\Countries\Austria\2019_12_Dez.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\dec2019.dta", replace



import excel "$rawdata\Countries\Austria\2020_01_Jan.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\jan2020.dta", replace

import excel "$rawdata\Countries\Austria\2020_02_Feb.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\feb2020.dta", replace

import excel "$rawdata\Countries\Austria\2020_03_Mrz.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\mar2020.dta", replace


import excel "$rawdata\Countries\Austria\April2020.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\apr2020.dta", replace

import excel "$rawdata\Countries\Austria\Mai2020.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\may2020.dta", replace

import excel "$rawdata\Countries\Austria\Juni2020.xls",  firstrow clear 
save  "$rawdata\Countries\Austria\jun2020.dta", replace






use "$rawdata\Countries\Austria\jan2019.dta" , clear 


append using  "$rawdata\Countries\Austria\feb2019.dta"
append using  "$rawdata\Countries\Austria\mar2019.dta"
append using  "$rawdata\Countries\Austria\apr2019.dta"
append using  "$rawdata\Countries\Austria\may2019.dta"
append using  "$rawdata\Countries\Austria\jun2019.dta"
append using  "$rawdata\Countries\Austria\jul2019.dta"
append using  "$rawdata\Countries\Austria\aug2019.dta"
append using  "$rawdata\Countries\Austria\sep2019.dta"
append using  "$rawdata\Countries\Austria\oct2019.dta"
append using  "$rawdata\Countries\Austria\nov2019.dta"
append using  "$rawdata\Countries\Austria\dec2019.dta"
append using  "$rawdata\Countries\Austria\jan2020.dta"
append using  "$rawdata\Countries\Austria\feb2020.dta"
append using  "$rawdata\Countries\Austria\mar2020.dta"
append using  "$rawdata\Countries\Austria\apr2020.dta"
append using  "$rawdata\Countries\Austria\may2020.dta"
append using  "$rawdata\Countries\Austria\jun2020.dta"


 

erase  "$rawdata\Countries\Austria\feb2019.dta"
erase  "$rawdata\Countries\Austria\mar2019.dta"
erase  "$rawdata\Countries\Austria\apr2019.dta"
erase  "$rawdata\Countries\Austria\may2019.dta"
erase  "$rawdata\Countries\Austria\jun2019.dta"
erase  "$rawdata\Countries\Austria\jul2019.dta"
erase  "$rawdata\Countries\Austria\aug2019.dta"
erase  "$rawdata\Countries\Austria\sep2019.dta"
erase  "$rawdata\Countries\Austria\oct2019.dta"
erase  "$rawdata\Countries\Austria\nov2019.dta"
erase  "$rawdata\Countries\Austria\dec2019.dta"
erase  "$rawdata\Countries\Austria\jan2020.dta"
erase  "$rawdata\Countries\Austria\feb2020.dta"
erase  "$rawdata\Countries\Austria\mar2020.dta"
erase  "$rawdata\Countries\Austria\apr2020.dta"
erase  "$rawdata\Countries\Austria\may2020.dta"
erase  "$rawdata\Countries\Austria\jun2020.dta"







drop if Datum == ""
gen ddate = date(Datum, "DMY")
format ddate %td


gen female = 0 if G == "M"
replace female = 1 if G == "W"
gen male = 0 if G == "W"
replace male = 1 if G == "M"

tab Thema, m


gen suicide = 0 if Thema != ""
replace suicide = 1 if Thema == "5. Suizid" 
replace suicide = 1 if Thema == "5a Suizidgefährdete" 
replace suicide = 1 if Thema == "5b Sorge um Suizidgefährde" 
     
gen lonely = 0 if Thema != ""
replace lonely = 1 if Thema == "1. Einsamkeit/Isolation/Allta"

gen violence = 0 if Thema != ""
replace violence = 1 if Thema == "10. Gewalt/Missbrauch"
replace violence = 1 if Thema == "10a Gewalt geg. Erwachsene"
replace violence = 1 if Thema == "10b Gewalt/Missbr. Kinder"


gen depressed = 0  if Thema != ""
replace depressed = 1 if Thema == "3a Depression"
gen addiction = 0  if Thema != ""
replace addiction = 1 if substr(Thema,1,1) == "4"
gen fears = 0  if Thema != ""
replace fears = 1 if Thema == "3b Ängste, Zwänge"
gen othermental = 0  if Thema != ""
replace othermental = 1 if Thema == "3c andere psyc. Erkrankung" |Thema == "3d Sorge um psych. Kranke"

gen grief = 0  if Thema != ""
replace grief = 1 if substr(Thema,1,1) == "6"
gen belief = 0  if Thema != ""
replace belief = 1 if Thema == "7. Sinn- und Glaubensfragen"
gen livepartner = 0  if Thema != ""
replace livepartner = 1 if Thema == "8a Partnerschaft"
gen parenting = 0  if Thema != ""
replace parenting = 1 if Thema == "8b Erziehung"
gen pregnancy = 0  if Thema != ""
replace pregnancy = 1 if Thema == "8g Schwangerschaft/Abtreibung" | Thema == "9b Schwangerschaft"
gen sex = 0  if Thema != ""
replace sex = 1 if substr(Thema,1,1) == "9" & Thema != "9b Schwangerschaft"

 
gen worksit = 0  if Thema != ""
replace worksit = 1 if Thema == "11. Arbeitswelt" | Thema == "11b Probl. Ausbild.+Beruf"
gen unempl = 0  if Thema != ""
replace unempl = 1 if Thema == "11a Arbeitslos, Arb.Suche"

 
gen mentalhealth = 0 if Thema != ""
replace mentalhealth = 1 if substr(Thema,1,1) == "3"

 
gen physhealth = 0 if Thema != ""
replace physhealth = 1 if substr(Thema,1,1) == "2"


gen agegroup = ""
replace agegroup = "19 or younger" if Alter == "1" | Alter == "bis 19 Jahre"
replace agegroup = "20 - 29" if Alter == "2" | Alter == "20 - 29 Jahre"
replace agegroup = "30 - 39" if Alter == "3" | Alter == "30 - 39 Jahre"
replace agegroup = "40 - 49" if Alter == "4" | Alter == "40 - 49 Jahre"
replace agegroup = "50 - 59" if Alter == "5" | Alter == "50 - 59 Jahre"
replace agegroup = "60 - 69" if Alter == "6" | Alter == "60 - 69 Jahre"
replace agegroup = "70 - 79" if Alter == "7" | Alter == "70 - 79 Jahre"
replace agegroup = "80 or older" if Alter == "8" | Alter == "80 und darüber"

gen durationh = substr(Dauer,1,2)
gen durationm = substr(Dauer,4,2)
gen durations = substr(Dauer,7,2)
replace durationm = "" if substr(durationm,1,1) == ":"
replace durations = "" if substr(durations,1,1) == ":"
destring duration*, replace
gen duration = durationm +  60*durationh
replace duration = duration+1 if durations>29
gen hour = substr(Beginn,1,2)
destring hour, replace


// br if month(ddate) > 6 & year(ddate) == 2020
// drop if month(ddate) > 6 & year(ddate) == 2020

gen agemin = substr(agegroup,1,2)
replace agemin = "0" if substr(agegroup,-11,11) == " or younger"
gen agemax = subinstr(agegroup," or older","",.)
replace agemax = substr(agemax,-2,2)
replace agemax = substr(agegroup,1,2) if substr(agegroup,-11,11) == " or younger"
replace agemax = "100" if substr(agegroup,-9,9) == " or older" | agegroup == "90+"
destring agemin agemax, replace

egen age = rowmean(agemin agemax)

gen country = "Austria"
gen population = 8.859		// 8.859 million (2019)

gen helplinename = "Telefonseelsorge Österreich"

keep ddate-agegroup duration-helplinename

order helplinename country population ddate hour duration female male age agemin agemax agegroup , first

gen T_econ = 0
replace T_econ = 1 if unempl == 1
replace T_econ = 1 if worksit == 1

gen T_mentalh =0
replace T_mentalh = 1 if mentalhealth == 1

gen T_social =0
replace T_social = 1 if livepartner == 1
replace T_social = 1 if parenting == 1

gen phone = 1
gen chat = 0

save `"$rawdata\Countries\Austria\AUTcontacts.dta"',  replace

use `"$rawdata\Countries\Austria\AUTcontacts.dta"', clear






