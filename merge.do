


use `"$rawdata\Countries\Austria\AUTcontacts.dta"',  clear

append using `"$rawdata\Countries\Germany\GERcontacts.dta"'
append using "$rawdata\Countries\Germany\Nummer gegen Kummer\GER2contacts.dta"
append using "$rawdata\Countries\Germany\Muslimische TS\GERmuslcontacts.dta"
append using `"$rawdata\Countries\France\FRAcontacts.dta"'
append using "$rawdata\Countries\Netherlands\NELcontacts.dta"
append using "$rawdata\Countries\Belgium\BELcontacts.dta"
append using "$rawdata\Countries\Italy\ITAcontacts.dta"
append using `"$rawdata\Countries\Lebanon\LBNcontacts.dta"'
append using `"$rawdata\Countries\Portugal\PRTcontacts.dta"'
append using `"$rawdata\Countries\China\CHNcontacts.dta"'
append using `"$rawdata\Countries\Hong Kong\HKG_contacts.dta"'
append using `"$rawdata\Countries\Luxembourg\LUXcontacts.dta"'
append using `"$rawdata\Countries\Bosnia Herz\Bosnia_contacts.dta"'
append using `"$rawdata\Countries\Czech Republic\Modralinka.dta"'
append using `"$rawdata\Countries\Israel\ISRcontacts.dta"'
append using `"$rawdata\Countries\Slovenia\SLVcontacts.dta"'

drop if year(ddate) == 2019 & country == "Israel"		// too many weird movements also before June 19...


replace chat = 1 if mail == 1

merge m:1 country ddate using "$rawdata\otherdata.dta", nogen keep(master match)


foreach C of varlist stringencyindex governmentresponseindex containmenthealthindex economicsupportindex c1_schoolclosing c1_flag c2_workplaceclosing c2_flag c3_cancelpublicevents c3_flag c4_restrgather c4_flag c5_closepublictransport c5_flag c6_stayathomerequirements c6_flag c7_restrinternalmov c7_flag c8_internattravel e1_incomesupport e1_flag e2_debtcontractrelief e3_fiscalmeasures e4_internationalsupport h1_publicinfocampaigns h1_flag h2_testingpolicy h3_contacttracing h4_emergencyinvestmentinhealthca h5_investmentinvaccines h6_facialcoverings h6_flag h7_vaccinationpolicy h7_flag h8_protectionofelderlypeople h8_flag  confirmedcases confirmeddeaths newcases newdeaths {
replace `C' = 0 if `C' == . & year(ddate) == 2019
}



tab country
foreach C in Austria Belgium  China Denmark France Germany Italy Israel Latvia Lebanon Luxembourg Netherlands Portugal Slovenia {
gen `C' = (country=="`C'")
}
gen Bosnia = (country=="Bosnia")
gen CzechRepublic = (country=="Czech Republic")
gen HongKong = (country=="Hong Kong")

gen negdate = ddate*(-1)
bysort country (negdate): carryforward countrycode, replace
bysort country (population): carryforward population, replace

gen HCcode = countrycode
replace HCcode = "GER1" if helplinename == "Telefonseelsorge Deutschland"
replace HCcode = "GER2" if helplinename == "Nummer gegen Kummer (Kinder/Jugend)"
replace HCcode = "GER3" if helplinename == "Nummer gegen Kummer (Eltern)"
replace HCcode = "GER4" if helplinename == "Muslimisches Seelsorgetelefon"





// sort country ddate
replace agemin = age_min if agemin == .
replace agemax = age_max if agemax == .
drop age_min age_max 


gen age1 = 0 if age != .
// replace age1 = 1 if inrange(age,0,29)
replace age1 = 1 if inrange(agemax,0,29)
gen age3 = 0 if age != .
replace age3 = 1 if inrange(agemin,60,100)
gen age2 = 0 if age != .
replace age2 = 1 if  age1 == 0 & age3 == 0 & age != .



order country ddate duration chat female age* suicide mentalhealth violence addiction living_alone, first

bysort country: egen dateoflockdown = min(ddate) if c6_stayathomerequirements > 0 & c6_stayathomerequirements != .
bysort country (dateoflockdown): replace dateoflockdown = dateoflockdown[1]
format dateoflockdown %td
gen lockdowndate = (ddate==dateoflockdown)



drop if ddate == .

gen weekday = dow(ddate)

gen year = year(ddate)
gen weekofyear = week(ddate)
gen monthofyear = month(ddate)

gen nmonth = monthofyear
replace nmonth = monthofyear+12 if year == 2020
replace nmonth = monthofyear+24 if year == 2021

gen nweek = weekofyear
replace nweek = nweek+ 52 if ddate>mdy(1,5,2020)
replace nweek = nweek+ 52 if ddate>mdy(1,3,2021)



gen quarter = 1 if inrange(monthofyear,1,3) 
replace quarter = 2 if inrange(monthofyear,4,6) 
replace quarter = 3 if inrange(monthofyear,7,9) 
replace quarter = 4 if inrange(monthofyear,10,12) 

gen nquarter = quarter
replace nquarter = nquarter+ 4 if year == 2020
replace nquarter = nquarter+ 4 if year == 2021

replace state = clustertitel if state == ""
replace state = region if state == ""

drop disorder-call_reason
drop relation2child-topisknown
drop startdatetime-other
drop othergender-soccult
drop statecode-TH
drop othermental grief belief livepartner parenting pregnancy sex worksit unempl

order  HCcode helplinename population country countrycode  state  , first

gen vlongduration = (duration > 180)
replace duration = . if vlongduration == 1

replace duration = . if phone == 0


gen newcasesPOP = newcases/population
gen newdeathsPOP = newdeaths/population




foreach V of varlist stringencyindex newcasesPOP newdeathsPOP economicsupportindex {
gen l`V' = log(1+`V')
}

gen stringencyXage3 = lstringencyindex * age3
gen stringencyXage2 = lstringencyindex * age2
gen stringencyXage1 = lstringencyindex * age1




cap drop tknown0sum tknown1sum othertopic
gen tknown0sum = (fears == 0 & lonely == 0 & suicide == 0 & violence == 0 & addiction == 0 & physhealth == 0 &  T_econ == 0 &  T_social == 0 )
gen tknown1sum = (fears == 1 | lonely == 1 | suicide == 1 | violence == 1 | addiction == 1 | physhealth == 1 |  T_econ == 1 |  T_social == 1 )
egen tsum = rowtotal(fears lonely suicide violence addiction physhealth  T_econ  T_social)

gen othertopic = 0 if  tknown1sum == 1
replace othertopic = 1 if  tknown0sum == 1

lab var othertopic "Other topics"

encode HCcode, gen(helplinecode)


lab var fears "Fear and anxiety"
lab var violence "Physical and sexual violence"
lab var lonely "Loneliness and isolation"
lab var suicide "Suicidal ideation and behaviour"
lab var addiction "Addiction"
lab var depressed "Depression and burn out"
lab var physhealth "Physical health and disease"
lab var T_econ "Livelihood"
lab var T_social "Relationships"


drop if ddate<mdy(1,1,2019)

save "$rawdata\merged_contacts.dta",  replace
////////////////////////////////////////////////////////////////////////////////////////////////////////////

use "$rawdata\merged_contacts.dta",  clear


keep  if ddate < mdy(7,1,2020)

gen postlockdown = (ddate>=dateoflockdown)
gen compdate = dateoflockdown-366
format compdate %td
gen post1920 = (ddate>=compdate & year ==2019)
replace post1920 = 1 if postlockdown

gen lockdownweek = nweek if lockdowndate == 1
bysort country (lockdownweek): replace lockdownweek = lockdownweek[1]

gen ldweek = nweek - lockdownweek


forvalues J = 0/12 {
gen week`J'post20 = 0
replace week`J'post20 = 1  if ldweek == `J' & year == 2020
}

forvalues J = 1/12 {
gen week`J'pre20 = 0
replace week`J'pre20 = 1 if  ldweek == -`J' & year == 2020
}

drop if HCcode == "LUX"
drop if HCcode == "HKG"
drop if HCcode == "BIH"
drop if HCcode == "DNK"
drop if HCcode == "LVA"
drop if HCcode == "GER4"
drop if HCcode == "PRT"

gen mainsample1 = 0
replace mainsample1 = 1 if HCcode == "GER1"
replace mainsample1 = 1 if HCcode == "GER2"
replace mainsample1 = 1 if HCcode == "GER3"
replace mainsample1 = 1 if HCcode == "FRA"
replace mainsample1 = 1 if HCcode == "NLD"
replace mainsample1 = 1 if HCcode == "BEL"
replace mainsample1 = 1 if HCcode == "PRT"
replace mainsample1 = 1 if HCcode == "AUT"
replace mainsample1 = 1 if HCcode == "ITA"
replace mainsample1 = 1 if HCcode == "SVN"


save "$rawdata\merged_contacts_estimation.dta",  replace
// use "$rawdata\merged_contacts_estimation.dta",  clear
////////////////////////////////////////////////////////////////////////////////




use "$rawdata\merged_contacts.dta", clear
gen helplinecontacts = 1

gen obssuicide = (suicide != .)
global IVARS "female male age1 age2 age3 suicide violence addiction living_alone  lonely coronacall obssuicide  depressed fears  physhealth T_econ T_mentalh T_social repcall firstcall habitcall"

gen female_age1 = age1*female
gen female_age2 = age2*female
gen female_age3 = age3*female
gen male_age1 = age1*male
gen male_age2 = age2*male
gen male_age3 = age3*male

fcollapse (sum) helplinecontacts (firstnm) HCcode helplinename country population (sum) female_age* male_age*  $IVARS, by(helplinecode ddate)

renvars $IVARS female_age* male_age*, prefix("contacts_")

xtset helplinecode ddate
xtdes

tsfill


gen negdate = -1*ddate
foreach V of varlist HCcode helplinename country population {
bysort helplinecode (negdate): carryforward `V', replace
}

gen dshare_suicide = contacts_suicide/contacts_obssuicide

xtset helplinecode ddate
save "$rawdata\calls_dseries.dta",  replace
////////////////////////////////////////////////////////////////////////////////////////////////////////////


use "$rawdata\calls_dseries.dta", clear

append using `"$rawdata\Countries\Switzerland\Switzerland_series.dta"'
append using `"$rawdata\Countries\Hungary\Hungary_series.dta"'
append using `"$rawdata\Countries\Finland\Finland_series.dta"'

merge m:1 country ddate using "$rawdata\otherdata.dta"

drop if country == "United States"
replace HCcode = "CHE" if country == "Switzerland"
replace HCcode = "HUN" if country == "Hungary"
replace HCcode = "FIN" if country == "Finland"

drop helplinecode negdate
gen negdate = -1*ddate
foreach V of varlist HCcode helplinename population {
bysort country (ddate): carryforward `V' if country != "Germany", replace
bysort country (negdate): carryforward `V' if country != "Germany", replace
}


drop if HCcode == ""
encode HCcode, gen(helplinecode)
xtset helplinecode ddate
tsfill, full


drop negdate
gen negdate = -1*ddate
foreach V of varlist HCcode helplinename country population {
bysort helplinecode (negdate): carryforward `V', replace
bysort helplinecode (ddate): carryforward `V', replace
}


foreach V of varlist  c1_schoolclosing-economicsupportindexfordisplay {
replace `V' = 0 if  year(ddate) == 2019
}


gen confirmedcasesPOP = confirmedcases/population


bysort country: egen dateofoutbreak = min(ddate) if confirmedcasesPOP > 10 & confirmedcases != .
bysort country (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
format dateofoutbreak %td
gen outbreakdate = (ddate==dateofoutbreak)

bysort country: egen dateoflockdown = min(ddate) if c6_stayathomerequirements > 0 & c6_stayathomerequirements != .
bysort country (dateoflockdown): replace dateoflockdown = dateoflockdown[1]
format dateoflockdown %td
gen lockdowndate = (ddate==dateoflockdown)

foreach V of varlist  newcases newdeaths confirmeddeaths {
replace `V' = 0 if `V' == . & ddate < dateofoutbreak
gen `V'POP = `V'/population
}

gen weekday = dow(ddate)
gen year = year(ddate)
gen weekofyear = week(ddate)
gen monthofyear = month(ddate)
gen nmonth = monthofyear
replace nmonth = monthofyear+12 if year == 2020
replace nmonth = monthofyear+24 if year == 2021

gen nweek = weekofyear
replace nweek = nweek+ 52 if year == 2020
replace nweek = nweek+ 52 if year == 2021



gen quarter = 1 if inrange(monthofyear,1,3) 
replace quarter = 2 if inrange(monthofyear,4,6) 
replace quarter = 3 if inrange(monthofyear,7,9) 
replace quarter = 4 if inrange(monthofyear,10,12) 

gen nquarter = quarter
replace nquarter = nquarter+ 4 if year == 2020
replace nquarter = nquarter+ 4 if year == 2021


gen lockdownweek = nweek if lockdowndate == 1
bysort country (lockdownweek): replace lockdownweek = lockdownweek[1]

gen ldweek = nweek - lockdownweek

xtset helplinecode ddate

foreach V of varlist contacts_suicide contacts_violence contacts_addiction  contacts_lonely  contacts_fears contacts_physhealth  contacts_T_econ contacts_T_social {
bysort HCcode: egen max`V' = max(`V') if `V' != .
replace `V' = . if max`V' == 0
}

foreach V of varlist newcasesPOP newcases helplinecontacts contacts_male contacts_female contacts_age1 contacts_age2 contacts_age3 contacts_suicide contacts_violence contacts_addiction  contacts_lonely  contacts_fears contacts_physhealth  contacts_T_econ contacts_T_social {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}

foreach V of varlist helplinecontacts contacts_male contacts_female contacts_age1 contacts_age2 contacts_age3 contacts_suicide contacts_violence contacts_addiction  contacts_lonely  contacts_fears  contacts_physhealth  contacts_T_econ contacts_T_social {
replace `V' = . if country == "Denmark" & year == 2020 & monthofyear < 2
}


foreach V of varlist MA7helplinecontacts MA7contacts_male MA7contacts_female MA7contacts_age1 MA7contacts_age2 MA7contacts_age3 MA7contacts_suicide MA7contacts_violence MA7contacts_addiction MA7contacts_lonely  MA7contacts_fears   MA7contacts_physhealth MA7contacts_T_econ  MA7contacts_T_social {
replace `V' = . if ddate > mdy(6,15,2020) & HCcode == "PRT"
replace `V' = . if ddate > mdy(6,28,2020) & HCcode == "AUT"
}
drop if ddate > mdy(6,30,2020) & HCcode == "AUT"


gen dayofyear = ddate - mdy(1,1,2019) if year(ddate) == 2019
replace dayofyear = ddate - mdy(1,1,2020) if year(ddate) == 2020
replace dayofyear = ddate - mdy(1,1,2021) if year(ddate) == 2021


bysort country dayofyear (ddate): gen ldiffincontacts = log(helplinecontacts[2]) - log(helplinecontacts[1]) 
replace ldiffincontacts = . if year(ddate) == 2019


xtset  helplinecode ddate


lab var contacts_fears "Fear and anxiety"
lab var contacts_violence "Physical and sexual violence"
lab var contacts_lonely "Loneliness and isolation"
lab var contacts_suicide "Suicidal ideation and behaviour"
lab var contacts_addiction "Addiction"
lab var contacts_depressed "Depression and burn out"
lab var contacts_physhealth "Physical health and disease"
lab var contacts_T_econ "Livelihood (broad)"
lab var contacts_T_social "Relationships (broad)"
lab var contacts_T_mentalh "Mental health (broad)"

foreach V of varlist stringencyindex newcasesPOP newdeathsPOP economicsupportindex {
gen l`V' = log(1+`V')
}


save "$rawdata\merged_series.dta",  replace

// use "$rawdata\merged_series.dta", clear











