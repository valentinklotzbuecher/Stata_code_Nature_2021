
import excel  "$rawdata\Countries\Israel\Kopie von Hebräisch Übersetzung.xlsx",  clear firstrow 

drop if Datum == ""

replace Datum = trim(Datum)
replace Datum = "12/3/2020" if Datum == "1010-12-03"
replace Datum = "12/8/2020" if Datum == "12/8/3030"

gen ddate = date(Datum, "MDY")
format ddate %td
sort ddate

gen female = (Geschlecht == "weiblich")
lab var female "Female"

gen male = (Geschlecht == "männlich")
lab var male "Male"


tab Alter, m

gen agegroup = "0-13" if Alter == "Oct-13"
replace agegroup = "14-17" if Alter == "14-17"
replace agegroup = "18-20" if Alter == "18-20"
replace agegroup = "21-30" if Alter == "21-30"
replace agegroup = "31-40" if Alter == "31-40"
replace agegroup = "41-50" if Alter == "41-50"
replace agegroup = "51-65" if Alter == "51-65"
replace agegroup = ">65" if Alter == "65+"
replace agegroup = "" if Alter == "" | Alter == "Nein bekannt"

 
gen age_min = 0 if agegroup == "0-13"
replace age_min = 14 if agegroup == "14-17"
replace age_min = 18 if agegroup == "18-20"
replace age_min = 21 if agegroup == "21-30"
replace age_min = 31 if agegroup == "31-40"
replace age_min = 41 if agegroup == "41-50"
replace age_min = 51 if agegroup == "51-65"
replace age_min = 65 if agegroup == ">65"

gen age_max = 13 if agegroup == "0-13"
replace age_max = 17 if agegroup == "14-17"
replace age_max = 20 if agegroup == "18-20"
replace age_max = 30 if agegroup == "21-30"
replace age_max = 40 if agegroup == "31-40"
replace age_max = 50 if agegroup == "41-50"
replace age_max = 65 if agegroup == "51-65"
replace age_max = 100 if agegroup == ">65"

 gen age = round((age_min + age_max)/2)

 gen suicide = 0 if SelbstmordgehaltGefahrerhöh == "Nein"
 replace suicide = 1 if SelbstmordgehaltGefahrerhöh == "Ja"
 
 gen coronacall = 0 if GabesaucheinenHinweisaufCo == "Nein"
 replace coronacall = 1 if GabesaucheinenHinweisaufCo == "Ja"
 
 
gen firstcall = (Kommstduzurück == "Nein") 
gen repcall = (Kommstduzurück == "Ja") 
 foreach V of varlist firstcall repcall {
replace `V' = . if Kommstduzurück == "" | Kommstduzurück == "Nein bekannt"
}


 
forvalues j = 1/3 {
 replace Gesprächsthema`j' = trim(Gesprächsthema`j')
 }
tab Gesprächsthema1, m
tab Gesprächsthema2, m
tab Gesprächsthema3, m
 
gen lonely = 0 if Gesprächsthema1 != ""
gen fears = 0 if Gesprächsthema1 != ""
gen depressed = 0 if Gesprächsthema1 != ""
gen violence = 0 if Gesprächsthema1 != ""
gen addiction = 0 if Gesprächsthema1 != ""
gen T_econ = 0 if Gesprächsthema1 != ""
gen T_social = 0 if Gesprächsthema1 != ""
gen othermental = 0 if Gesprächsthema1 != ""

forvalues j = 1/3 {
replace lonely = 1 if Gesprächsthema`j' == "Einsamkeit"
replace fears = 1 if Gesprächsthema`j' == "Ängste"
replace depressed = 1 if Gesprächsthema`j' == "Depression und schwere Traurigkeit"
replace violence = 1 if Gesprächsthema`j' == "Häusliche Gewalt"
replace addiction = 1 if Gesprächsthema`j' == "Sucht"
replace othermental = 1 if Gesprächsthema`j' == "Abbruch der psychologischen Behandlung" | Gesprächsthema`j' == "Verschiedene psychische Störungen"
replace T_econ = 1 if Gesprächsthema`j' == "Wirtschaftliche Schwierigkeiten" | Gesprächsthema`j' == "Aktien und Konsultationen"
replace T_social = 1 if Gesprächsthema`j' == "Soziale Schwierigkeiten" | Gesprächsthema`j' == "Familienschwierigkeiten" | Gesprächsthema`j' == "Romantische Angelegenheiten"| Gesprächsthema`j' == "Beziehung ist wichtig"
}
 

keep ddate-othermental

gen chat = 1
gen phone = 0

// gen helplinename = "ERAN Emotional First Aid"
gen helplinename = "SAHAR Emotional support chat"
gen country = "Israel"
gen population = 9.053

drop if year(ddate) == 2019 & month(ddate)>5


save `"$rawdata\Countries\Israel\ISRcontacts.dta"',  replace


use `"$rawdata\Countries\Israel\ISRcontacts.dta"',  clear
 
 
   

