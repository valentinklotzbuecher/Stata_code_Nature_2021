



import excel ".\03_Data\Countries\Denmark\dataset 2019.xlsx",  firstrow clear 

save `".\03_Data\Countries\Denmark\2019data.dta"',  replace

import excel ".\03_Data\Countries\Denmark\2020-06-11 dataset 2020.xlsx",  firstrow clear 

append using  `".\03_Data\Countries\Denmark\2019data.dta"'

replace Opkalderskøn = Opkaldersalder if  Opkaldersalder == "Kvinde" | Opkaldersalder == "Mand" 
replace Opkaldersalder = Bopælsregion if  Bopælsregion == "30-44 år (yngre voksne)" | Opkaldersalder == "45-64 år (midaldrende voksne)"  | Opkaldersalder == "65-79 år (yngre ældre)" 
replace Bopælsregion = Bopælsregion if  Bopælsregion == "30-44 år (yngre voksne)" | Opkaldersalder == "45-64 år (midaldrende voksne)"  | Opkaldersalder == "65-79 år (yngre ældre)" 

replace Boform = Socialstatus if Socialstatus == "Bor alene"

gen ddate = date(substr(Tidsstempel,1,10), "DMY")
format ddate %td
sort ddate




replace Opkalderskøn = "" if Opkalderskøn == "det ved jeg ikke"
replace Opkalderskøn = "" if Opkalderskøn == "Ikke oplyst"
gen female = 0 if Opkalderskøn != ""
replace female = 1 if Opkalderskøn == "Kvinde"

gen male = 0 if Opkalderskøn != ""
replace male = 1 if Opkalderskøn == "Mand"



replace Opkaldersalder = "" if Opkaldersalder == "Ikke oplyst" | Opkaldersalder == "Kvinde" | Opkaldersalder == "Mand"
gen agemin = 80 if Opkaldersalder == "+80 år (ældste ældre)"
replace agemin = 0 if Opkaldersalder == "Under 18 år"
replace agemin = 18 if Opkaldersalder == "18-29 år (unge)"
replace agemin = 30 if Opkaldersalder == "30-44 år (yngre voksne)"
replace agemin = 45 if Opkaldersalder == "145-64 år (midaldrende voksne) "
replace agemin = 56 if Opkaldersalder == "165-79 år (yngre ældre)"
gen agemax = 100 if Opkaldersalder == "+80 år (ældste ældre)"
replace agemax = 17 if Opkaldersalder == "Under 18 år"
replace agemax = 29 if Opkaldersalder == "18-29 år (unge)"
replace agemax = 44 if Opkaldersalder == "30-44 år (yngre voksne)"
replace agemax = 64 if Opkaldersalder == "145-64 år (midaldrende voksne) "
replace agemax = 79 if Opkaldersalder == "165-79 år (yngre ældre)"

gen  age = (agemax + agemin)/2

replace Socialstatus = "" if Socialstatus == "Ikke oplyst" 
gen retired = 0 if Socialstatus != ""
replace retired = 1 if Socialstatus == "Pensioneret"

replace Boform = "" if Boform == "Ikke oplyst"
gen living_alone = 0 if Boform != ""
replace living_alone = 1 if Boform == "Bor alene"

replace Bopælsregion = "" if Bopælsregion == "Ikke oplyst"
gen region = Bopælsregion
gen city = HvilkenkommuneiNordjylland 
replace city = HvilkenkommuneiMidtjylland  if city == ""
replace city = HvilkenkommuneiSyddanmark   if city == ""
replace city = HvilkenkommunepåSjælland    if city == ""
replace city = HvilkenkommuneiHovedstaden  if city == ""

replace Opkaldersopkaldsmønster = "" if Opkaldersopkaldsmønster == "Ikke oplyst" 
gen firstcall = 0 if Opkaldersopkaldsmønster != ""
replace firstcall = 1 if Opkaldersopkaldsmønster == "Første opkald"
gen repcall = 0 if Opkaldersopkaldsmønster != ""
replace repcall = 1 if Opkaldersopkaldsmønster == "Har ringet før"


gen suicide = 0 if Hvadvardenprimæreproblematik != ""
replace suicide = 1 if Hvadvardenprimæreproblematik == "selvmords tanker"
replace suicide = 1 if Hvadvardenprimæreproblematik == "selvmordstanker"

gen coronacall = 0 if Hvadvardenprimæreproblematik != ""
replace coronacall = 1 if substr(Hvadvardenprimæreproblematik,1,6) == "corona"


gen country = "Denmark"
gen population = 5.806


drop Tidsstempel Brugtedusamtalemodellen Hvilkeafdefiredomænerisamt Varderfokuspåopkaldersresso Vardetenpårørendesamtale Hvadvardenprimæreproblematik Hvilkenrelationvardertaleom Vardetogsåentaleomensomhed Hvilkenmentaltrivselvardert Hvordantabuogmindreværd Hvadhandledesamtalenomarbejd Hvaderopkaldersprimæregrund Handledesamtalenogsåomkonkre Hvilkenslagsmisbrugellerselv Hvilkenslagssamtalevarderi Hvilkenslagsfysisksygdom Hvilkenformforovergreb Hvadtogopkaldermedsigfrasa S T U V W X Harduinformeretopkalderoman Z Ringededuop Hvornårstartedesamtalen Hvormangeminuttervaredesamta Opkaldersopkaldsmønster Opkalderskøn Opkaldersalder Bopælsregion HvilkenkommuneiNordjylland HvilkenkommuneiMidtjylland HvilkenkommuneiSyddanmark HvilkenkommunepåSjælland HvilkenkommuneiHovedstaden Boform Socialstatus AO AP AQ AR Varopkalderenpårørende Vardetogsåensamtaleomensom Hvadtogopkalderenmedsigfra R Opkalderensopkaldsmønster Hvorhavdeopkalderfundetos AD Hvilketsøgeord HvilkenkommuneiRegionHovedst

gen helplinename = "Startlinjen"

save `".\03_Data\Countries\Denmark\DNKcontacts.dta"',  replace





