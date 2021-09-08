


import excel ".\03_Data\Countries\Luxembourg\Statistik für Uni Freiburg.xlsx",  firstrow clear 



gen ddate = date(Datum, "DMY") 
// if substr(Datum,3,1)=="."
// replace ddate = date(Datum, "DMY") if ddate == .
format ddate %td
sort ddate

drop K L M
 
replace mw = "" if mw == "N/A"
replace mw = "" if mw == "?  "
replace mw = "" if mw == "  "
gen female = 0 if mw != ""
replace female = 1 if mw == "Frau  "
replace female = 1 if mw == "w"
gen male = 0 if mw != ""
replace male = 1 if mw == "Mann  "
replace male = 1 if mw == "m"

gen durationm = substr(Dauer,3,2)
gen durationh = substr(Dauer,1,1)
destring duration*, replace
gen duration = 60*durationh + durationm
drop durationh durationm


replace Alter = subinstr(Alter,"  ","",.)
replace Alter = "" if Alter == "N/A"
gen age = Alter if length(Alter) == 2
gen agemin = substr(Alter,1,2)
replace agemin = "0" if Alter == "unter 15"
replace agemin = "70" if Alter == "über 70"
gen agemax = substr(Alter,-2,2)
replace agemax = "15" if Alter == "unter 15"
replace agemax = "100" if Alter == "über 70"
destring age agemin agemax, replace
replace age = (agemax + agemin)/2 if age == .

gen suicide = 0
replace suicide = 1 if regexm(Problemnennungen,"Suizid") == 1 
gen violence = 0
replace violence = 1 if regexm(Problemnennungen,"Gewalt") == 1 
gen worksit = 0
replace worksit = 1 if regexm(Problemnennungen,"Beruf") == 1 

gen addiction = 0
replace addiction = 1 if regexm(Problemnennungen,"Abhängigkeit") == 1 
replace addiction = 1 if regexm(Problemnennungen,"Sucht") == 1 

gen education = 0 if Problemnennungen != "" 
replace education = 1 if regexm(Problemnennungen,"Student") == 1 


gen mentalhealth = 0 if Problemnennungen != "" 
replace mentalhealth = 1 if regexm(Problemnennungen,"psych") == 1 & regexm(Problemnennungen,"ische Erkrankungen") == 1 

gen relationships = 0 if Problemnennungen != "" 
replace relationships = 1 if regexm(Problemnennungen,"Zwischenmenschliche Beziehungen") == 1 
replace relationships = 1 if regexm(Problemnennungen,"soziale Kontakte") == 1 

split Problemnennungen, gen(problem) p("/" "-")
tab problem2

// forvalues i = 1/12 {
// replace problem`i' = subinstr(problem`i',"  ","",.)
// replace problem`i' = subinstr(problem`i'," ","",.)
// replace suicide = 1 if problem`i' == "Suizid"
// replace addiction = 1 if problem`i' == "Suizid"
// }

gen migrant = 1 if MigrationHintergrund == "mit"

drop problem*



gen country = "Luxembourg"
gen population = 0.613

gen agegroup = Alter

gen hour = substr(Zeit,1,2)
destring hour, replace

gen helplinename = "SOS Détresse"

drop Nr Datum Zeit Dauer mw Alter Sprache MigrationHintergrund Problemnennungen Weiterverwiesen
save  ".\03_Data\Countries\Luxembourg\LUXcontacts.dta", replace

