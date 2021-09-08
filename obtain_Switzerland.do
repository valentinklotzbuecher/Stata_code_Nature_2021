

foreach Y of numlist 2019 2020 {
foreach M of numlist 5 6 {
forvalues D=1/9 {
import delimited `".\03_Data\Countries\Switzerland\Daily raw files\0`D'.0`M'.`Y'.csv"', clear delim(";")


drop if v3 == ""
drop in 1
rename v4 share
gen contacts = subinstr(v3,"00:","",1)
destring contacts share, replace
carryforward v1, replace
gen var = v1 + ": " + v2
replace var = v1 if v2 == ""

gen ddate = mdy(`M',`D',`Y')
format ddate %td


save `".\03_Data\Countries\Switzerland\Daily raw files\0`D'.0`M'.`Y'.dta"', replace

}

foreach D of numlist  0 1 2 3 4 5 6 7 8 9 {
import delimited `".\03_Data\Countries\Switzerland\Daily raw files\1`D'.0`M'.`Y'.csv"', clear delim(";")


drop if v3 == ""
drop in 1
rename v4 share
gen contacts = subinstr(v3,"00:","",1)
destring contacts share, replace
carryforward v1, replace
gen var = v1 + ": " + v2
replace var = v1 if v2 == ""

gen ddate = mdy(`M',1`D',`Y')
format ddate %td


save `".\03_Data\Countries\Switzerland\Daily raw files\1`D'.0`M'.`Y'.dta"', replace

import delimited `".\03_Data\Countries\Switzerland\Daily raw files\2`D'.0`M'.`Y'.csv"', clear delim(";")


drop if v3 == ""
drop in 1
rename v4 share
gen contacts = subinstr(v3,"00:","",1)
destring contacts share, replace
carryforward v1, replace
gen var = v1 + ": " + v2
replace var = v1 if v2 == ""

gen ddate = mdy(`M',2`D',`Y')
format ddate %td

save `".\03_Data\Countries\Switzerland\Daily raw files\2`D'.0`M'.`Y'.dta"', replace

}


import delimited `".\03_Data\Countries\Switzerland\Daily raw files\30.0`M'.`Y'.csv"', clear delim(";")


drop if v3 == ""
drop in 1
rename v4 share
gen contacts = subinstr(v3,"00:","",1)
destring contacts share, replace
carryforward v1, replace
gen var = v1 + ": " + v2
replace var = v1 if v2 == ""

gen ddate = mdy(`M',30,`Y')
format ddate %td

save `".\03_Data\Countries\Switzerland\Daily raw files\30.0`M'.`Y'.dta"', replace


}


foreach M of numlist 5 {
import delimited `".\03_Data\Countries\Switzerland\Daily raw files\31.0`M'.`Y'.csv"', clear delim(";")

drop if v3 == ""
drop in 1
rename v4 share
gen contacts = subinstr(v3,"00:","",1)
destring contacts share, replace
carryforward v1, replace
gen var = v1 + ": " + v2
replace var = v1 if v2 == ""

gen ddate = mdy(`M',31,`Y')
format ddate %td


save `".\03_Data\Countries\Switzerland\Daily raw files\31.0`M'.`Y'.dta"', replace
}
}




use `".\03_Data\Countries\Switzerland\Daily raw files\01.05.2019.dta"', clear



foreach Y of numlist 2019 2020 {
foreach M of numlist 5 6 {
forvalues D=1/9 {
append using `".\03_Data\Countries\Switzerland\Daily raw files\0`D'.0`M'.`Y'.dta"'
append using `".\03_Data\Countries\Switzerland\Daily raw files\1`D'.0`M'.`Y'.dta"'
append using `".\03_Data\Countries\Switzerland\Daily raw files\2`D'.0`M'.`Y'.dta"'
append using `".\03_Data\Countries\Switzerland\Daily raw files\30.0`M'.`Y'.dta"'
}
}
}

foreach Y of numlist 2019 2020 {
foreach M of numlist 5 6 {
forvalues D=1/9 {
erase `".\03_Data\Countries\Switzerland\Daily raw files\0`D'.0`M'.`Y'.dta"'
erase `".\03_Data\Countries\Switzerland\Daily raw files\1`D'.0`M'.`Y'.dta"'
erase `".\03_Data\Countries\Switzerland\Daily raw files\2`D'.0`M'.`Y'.dta"'
}

forvalues D=0/1 {
capture append using `".\03_Data\Countries\Switzerland\Daily raw files\3`D'.0`M'.`Y'.dta"'
}
forvalues D=0/1 {
capture erase `".\03_Data\Countries\Switzerland\Daily raw files\3`D'.0`M'.`Y'.dta"'
}
}
}

drop in 1/54

encode var, gen(varcode)



gen helplinecontacts = contacts if var == "Total aller Anrufe"
gen contacts_male = contacts if var == "Geschlecht: Männlich"
gen contacts_female = contacts if var == "Geschlecht: Weiblich"
gen contacts_age_18  = contacts if var == "Alter: bis 18 J."
gen contacts_age_40  = contacts if var == "Alter: 19 - 40 J."
gen contacts_age_65  = contacts if var == "Alter: 41 - 65 J."
gen contacts_age_100 = contacts if var == "Alter: über 65 J."

gen contacts_suicide = contacts if var == "Beratungsinhalt: Suizidalität"
gen contacts_lonely = contacts if var == "Beratungsinhalt: Einsamkeit"
gen contacts_violence = contacts if var == "Beratungsinhalt: Gewalt"
gen contacts_physhealth = contacts if var == "Beratungsinhalt: Körperliches Leiden"
gen contacts_mentalhealth = contacts if var == "Beratungsinhalt: Psychisches Leiden"
gen contacts_sex = contacts if var == "Beratungsinhalt: Sexualität"
gen contacts_coronacall = contacts if var == "Beratungsinhalt: Sorge wegen Infektion"
gen contacts_addiction = contacts if var == "Beratungsinhalt: Suchtverhalten"
gen contacts_grief = contacts if var == "Beratungsinhalt: Verlust / Trauer / Tod"
gen contacts_worksit = contacts if var == "Beratungsinhalt: Arbeit / Ausbildung"

collapse (firstnm) helplinecontacts contacts_* , by(ddate)

save `".\03_Data\Countries\Switzerland\Daily raw files\newcombined.dta"', replace



use ".\03_Data\Countries\Switzerland\Dargebotene_Hand.dta", clear


rename tot_calls helplinecontacts
rename sex_m contacts_male
rename sex_f contacts_female

rename age_18  contacts_age_18 
rename age_40  contacts_age_40 
rename age_65  contacts_age_65 
rename age_100 contacts_age_100

rename problem_suicide contacts_suicide 
rename problem_loneliness contacts_lonely 
rename problem_violence contacts_violence 
rename problem_physical_health contacts_physhealth 
rename problem_psych_suffering contacts_mentalhealth 
rename problem_sexuality contacts_sex 
rename problem_fear_infection contacts_coronacall 
rename problem_addiction contacts_addiction 
rename problem_loss_grief contacts_grief 
rename problem_work_studies contacts_worksit
rename problem_livelihood contacts_livelihood


gen ddate = date(date_orig,"DMY")
format ddate %td




// keep helplinecontacts contacts_* ddate


append using `".\03_Data\Countries\Switzerland\Daily raw files\newcombined.dta"'


gen country = "Switzerland"
gen population = 8.57 	// million (2019)

collapse (firstnm) country population helplinecontacts contacts_* , by(ddate)
tsset ddate

gen helplinename = "Die Dargebotene Hand"

save `".\03_Data\Countries\Switzerland\Switzerland_series.dta"',  replace
use `".\03_Data\Countries\Switzerland\Switzerland_series.dta"',  clear











