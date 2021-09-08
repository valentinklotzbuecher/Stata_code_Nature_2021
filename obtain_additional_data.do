


* Government response:
import delimited "$rawdata\Oxford COVID-19 Government Response Tracker\covid-policy-tracker-master\data\OxCGRT_latest.csv",  clear 

tostring date, gen(stringdate)
gen ddate = date(stringdate,"YMD")
format ddate %td

gen country = countryname

keep if jurisdiction == "NAT_TOTAL"

save "$rawdata\Oxford COVID-19 Government Response Tracker\OxCGRT_latest.dta", replace

* Mobility

import delimited "$rawdata\Google Community Mobility Reports\Global_Mobility_Report.csv",  clear 

gen ddate = date(substr(date,1,10), "YMD")
format ddate %td
gen country = country_region
keep if sub_region_1 == ""	
keep if metro_area == ""	

drop metro_area iso_3166_2_code census_fips_code country_region_code country_region sub_region_1 sub_region_2 date 

rename  retail_and_recreation_percent_ch GMretailrec 
rename  grocery_and_pharmacy_percent_cha GMgrocpharm 
rename  parks_percent_change_from_baseli GMparks
rename  transit_stations_percent_change_ GMtransit
rename  workplaces_percent_change_from_b GMworkpl
rename  residential_percent_change_from_ GMresident

global GMvars "GMretailrec  GMgrocpharm  GMparks GMtransit GMworkpl GMresident"
replace country = "Czech Republic" if country == "Czechia"

save "$rawdata\Google Community Mobility Reports\Global_Mobility_Report.dta", replace



* Merge:

use "$rawdata\Oxford COVID-19 Government Response Tracker\OxCGRT_latest.dta", clear


merge 1:1 country ddate using "$rawdata\Google Community Mobility Reports\Global_Mobility_Report.dta", gen(_mgoogle)
drop if _mgoogle == 2


replace country = "Czech Republic" if country == "Czechia"
replace country = "Bosnia" if country == "Bosnia and Herzegovina"

keep if country == "Austria" | country == "Belgium" | country == "Bosnia" | country == "Czech Republic" | country == "Denmark" | country == "Finland" | country == "France" | country == "Germany" | country == "Hungary" | country == "Italy" | country == "Latvia" | country == "Lebanon" | country == "Luxembourg" | country == "Netherlands" | country == "Portugal" | country == "Switzerland" | country == "United States" | country == "China"  | country == "Hong Kong"  | country == "Israel"  | country == "Slovenia" 


encode country, gen(countryAcode)
xtset countryAcode ddate


gen newcases = D.confirmedcases
gen newdeaths = D.confirmeddeaths

drop regionname regioncode jurisdiction m1_wildcard _mgoogle countryAcode date stringdate
order country ddate, first


rename c8_internationaltravelcontrols c8_internattravel
rename c4_restrictionsongatherings c4_restrgather
rename c7_restrictionsoninternalmovemen c7_restrinternalmov
rename h1_publicinformationcampaigns h1_publicinfocampaigns

gen ic1_schoolclosing = ((c1_schoolclosing-0.5*(1-c1_flag))/3)*100
replace ic1_schoolclosing = 0 if c1_schoolclosing == 0
gen li_c1_schoolclosing = log(ic1_schoolclosing+1)

gen ic2_workplaceclosing = ((c2_workplaceclosing-0.5*(1-c2_flag))/3)*100
replace ic2_workplaceclosing = 0 if c2_workplaceclosing == 0
gen li_c2_workplaceclosing = log(ic2_workplaceclosing+1)

gen ic6_stayathomerequirements = ((c6_stayathomerequirements-0.5*(1-c6_flag))/3)*100
replace ic6_stayathomerequirements = 0 if c6_stayathomerequirements == 0
gen li_c6_stayathomerequirements = log(ic6_stayathomerequirements+1)


gen ic4_restrgather = ((c4_restrgather-0.5*(1-c4_flag))/4)*100
replace ic4_restrgather = 0 if c4_restrgather == 0
gen li_c4_restrgather = log(ic4_restrgather+1)

gen ic8_internattravel = ((c8_internattravel)/4)*100
replace ic8_internattravel = 0 if c8_internattravel == 0
gen li_c8_internattravel = log(ic8_internattravel+1)

gen ic3_cancelpublicevents = ((c3_cancelpublicevents-0.5*(1-c3_flag))/2)*100
replace ic3_cancelpublicevents = 0 if c3_cancelpublicevents == 0
gen li_c3_cancelpublicevents = log(ic3_cancelpublicevents+1)

gen ic5_closepublictransport = ((c5_closepublictransport-0.5*(1-c3_flag))/2)*100
replace ic5_closepublictransport = 0 if c5_closepublictransport == 0
gen li_c5_closepublictransport = log(ic5_closepublictransport+1)

gen ic7_restrinternalmov = ((c7_restrinternalmov-0.5*(1-c3_flag))/2)*100
replace ic7_restrinternalmov = 0 if c7_restrinternalmov == 0
gen li_c7_restrinternalmov = log(ic7_restrinternalmov+1)

gen ie1_incomesupport = ((e1_incomesupport-0.5*(1-e1_flag))/2)*100
replace ie1_incomesupport = 0 if e1_incomesupport == 0
gen li_e1_incomesupport = log(ie1_incomesupport+1)

gen ie2_debtcontractrelief = ((e2_debtcontractrelief)/2)*100
replace ie2_debtcontractrelief = 0 if e2_debtcontractrelief == 0
gen li_e2_debtcontractrelief = log(ie2_debtcontractrelief+1)


gen ih1_publicinfocampaigns = ((h1_publicinfocampaigns-0.5*(1-h1_flag))/2)*100
replace ih1_publicinfocampaigns = 0 if h1_publicinfocampaigns == 0
gen li_h1_publicinfocampaigns = log(ih1_publicinfocampaigns+1)

save "$rawdata\otherdata.dta", replace



keep if country == "Finland" | country == "Hungary" | country == "Switzerland" 

save "$rawdata\otherTSdata.dta", replace


erase "$rawdata\Google Community Mobility Reports\Global_Mobility_Report.dta"
erase  "$rawdata\Oxford COVID-19 Government Response Tracker\OxCGRT_latest.dta"








///////////////////////////////////////////////////////////
* US States (and Canadian provinces):



* US and CA subnational:





* Mobility:
import delimited "$rawdata\Google Community Mobility Reports\Global_Mobility_Report.csv",  clear 

keep if country_region == "United States" |  country_region == "Canada"

keep if sub_region_2 == "" & sub_region_1 != ""	//  dicard national and county
gen ddate = date(substr(date,1,10), "YMD")
format ddate %td
gen country = country_region
drop metro_area iso_3166_2_code sub_region_2 date country_region_code country_region

rename  retail_and_recreation_percent_ch GMretailrec 
rename  grocery_and_pharmacy_percent_cha GMgrocpharm 
rename  parks_percent_change_from_baseli GMparks
rename  transit_stations_percent_change_ GMtransit
rename  workplaces_percent_change_from_b GMworkpl
rename  residential_percent_change_from_ GMresident

rename sub_region_1 state 

save "$rawdata\Google Community Mobility Reports\NAmerica_Mobility_daily.dta", replace

gen nweek = week(ddate-5)+51
replace nweek = nweek +52 if nweek <100 & year(ddate) == 2021
collapse (mean) GM* , by(state nweek)

sort state nweek


save "$rawdata\Google Community Mobility Reports\USA_Mobility_Report.dta", replace


* Canadian provinces population
import delimited "$rawdata\Oxford COVID-19 Government Response Tracker\canada_population.csv",  clear 
keep v1 v5
drop in 1/7
drop in 14/23
rename v1 state
rename v5 popul
replace state = "Northwest Territories" if state == "Northwest Territories 5 (map)"
replace state = "Nunavut" if state == "Nunavut 5 (map)"
destring popul, replace ignore(",")
save "$rawdata\Oxford COVID-19 Government Response Tracker\canada_population.dta", replace








* OI tracker
import delimited "$rawdata\Opportunity Insights Economic Tracker\GeoIDs - State.csv",  clear 

rename statename state
save "$rawdata\Opportunity Insights Economic Tracker\states.dta", replace



import delimited "$rawdata\Opportunity Insights Economic Tracker\UI Claims - State - Weekly.csv",  clear 
bysort statefips ( year month day_endofweek): gen nweek = _n + 51

save "$rawdata\Opportunity Insights Economic Tracker\UIclaims.dta", replace



import delimited "$rawdata\Opportunity Insights Economic Tracker\COVID - State - Daily.csv",  clear 

gen ddatestring = string(day) + "/" + string(month) + "/" + string(year)
gen ddate = date(ddatestring, "DMY")
format ddate %td
gen nweek = week(ddate-5)+51
sort ddate

collapse (sum) case_count death_count test_count new_case_count new_death_count new_test_count (lastnm) case_rate death_rate test_rate new_case_rate new_death_rate new_test_rate , by(statefips nweek)


save "$rawdata\Opportunity Insights Economic Tracker\COVID.dta", replace




import delimited "$rawdata\Opportunity Insights Economic Tracker\Employment Combined - State - Daily.csv",  clear 


gen ddatestring = string(day) + "/" + string(month) + "/" + string(year)
gen ddate = date(ddatestring, "DMY")
format ddate %td
gen nweek = week(ddate-5) + 51
sort ddate

collapse (mean) emp_* , by(statefips nweek)

save "$rawdata\Opportunity Insights Economic Tracker\Employment.dta", replace



import delimited "$rawdata\Oxford COVID-19 Government Response Tracker\covid-policy-tracker-master\data\OxCGRT_latest.csv",  clear 

keep if countryname == "Canada" | countryname == "United States"
keep if jurisdiction == "STATE_TOTAL"

gen state = regionname


merge m:1 state using "$rawdata\Oxford COVID-19 Government Response Tracker\canada_population.dta"


tostring date, gen(stringdate)
gen ddate = date(stringdate,"YMD")
format ddate %td

gen nweek = week(ddate-5) 
replace nweek = nweek+ 52 if ddate>mdy(1,5,2020)
replace nweek = nweek+ 52 if ddate>mdy(1,5,2021)


gen statecode = substr(regioncode, -2,2)
encode statecode, gen(statenumG)

xtset statenumG ddate

gen newcases = D.confirmedcases
replace newcases = 0 if newcases == .
gen newdeaths = D.confirmeddeaths
replace newdeaths = 0 if newdeaths == .

gen month = month(ddate)



rename c8_internationaltravelcontrols c8_internattravel
rename c4_restrictionsongatherings c4_restrgather
rename c7_restrictionsoninternalmovemen c7_restrinternalmov
rename h1_publicinformationcampaigns h1_publicinfocampaigns

gen ic1_schoolclosing = ((c1_schoolclosing-0.5*(1-c1_flag))/3)*100
replace ic1_schoolclosing = 0 if c1_schoolclosing == 0
gen li_c1_schoolclosing = log(ic1_schoolclosing+1)

gen ic2_workplaceclosing = ((c2_workplaceclosing-0.5*(1-c2_flag))/3)*100
replace ic2_workplaceclosing = 0 if c2_workplaceclosing == 0
gen li_c2_workplaceclosing = log(ic2_workplaceclosing+1)

gen ic6_stayathomerequirements = ((c6_stayathomerequirements-0.5*(1-c6_flag))/3)*100
replace ic6_stayathomerequirements = 0 if c6_stayathomerequirements == 0
gen li_c6_stayathomerequirements = log(ic6_stayathomerequirements+1)


gen ic4_restrgather = ((c4_restrgather-0.5*(1-c4_flag))/4)*100
replace ic4_restrgather = 0 if c4_restrgather == 0
gen li_c4_restrgather = log(ic4_restrgather+1)

gen ic8_internattravel = ((c8_internattravel)/4)*100
replace ic8_internattravel = 0 if c8_internattravel == 0
gen li_c8_internattravel = log(ic8_internattravel+1)

gen ic3_cancelpublicevents = ((c3_cancelpublicevents-0.5*(1-c3_flag))/2)*100
replace ic3_cancelpublicevents = 0 if c3_cancelpublicevents == 0
gen li_c3_cancelpublicevents = log(ic3_cancelpublicevents+1)

gen ic5_closepublictransport = ((c5_closepublictransport-0.5*(1-c3_flag))/2)*100
replace ic5_closepublictransport = 0 if c5_closepublictransport == 0
gen li_c5_closepublictransport = log(ic5_closepublictransport+1)

gen ic7_restrinternalmov = ((c7_restrinternalmov-0.5*(1-c3_flag))/2)*100
replace ic7_restrinternalmov = 0 if c7_restrinternalmov == 0
gen li_c7_restrinternalmov = log(ic7_restrinternalmov+1)

gen ie1_incomesupport = ((e1_incomesupport-0.5*(1-e1_flag))/2)*100
replace ie1_incomesupport = 0 if e1_incomesupport == 0
gen li_e1_incomesupport = log(ie1_incomesupport+1)

gen ie2_debtcontractrelief = ((e2_debtcontractrelief)/2)*100
replace ie2_debtcontractrelief = 0 if e2_debtcontractrelief == 0
gen li_e2_debtcontractrelief = log(ie2_debtcontractrelief+1)


gen ih1_publicinfocampaigns = ((h1_publicinfocampaigns-0.5*(1-h1_flag))/2)*100
replace ih1_publicinfocampaigns = 0 if h1_publicinfocampaigns == 0
gen li_h1_publicinfocampaigns = log(ih1_publicinfocampaigns+1)



collapse (firstnm) countryname countrycode state popul statecode regioncode jurisdiction /// 
		 (lastnm) ddate month  ///
		 (mean) stringencyindex governmentresponseindex containmenthealthindex economicsupportindex ///
		 (mean) c1_schoolclosing c2_workplaceclosing c3_cancelpublicevents c4_restrgather c5_closepublictransport c6_stayathomerequirements  c7_restrinternalmov c8_internattravel e1_incomesupport e2_debtcontractrelief e3_fiscalmeasures e4_internationalsupport h1_publicinfocampaigns h2_testingpolicy h3_contacttracing h4_emergencyinvestmentinhealthca h5_investmentinvaccines h6_facialcoverings ie1_incomesupport ie2_debtcontractrelief  li_* ///
		 (sum) newcases newdeaths confirmedcases confirmeddeaths, by(statenumG nweek)
		 
xtset statenumG nweek



replace state = "District Of Columbia" if state == "Washington DC"
merge m:1 state using "$rawdata\Opportunity Insights Economic Tracker\states.dta"

replace state_pop2019 = popul if state_pop2019 == .
drop popul

merge m:1 statefips nweek using "$rawdata\Opportunity Insights Economic Tracker\UIclaims.dta", gen(_m2)

merge m:1 statefips nweek using "$rawdata\Opportunity Insights Economic Tracker\Employment.dta", gen(_mE)

merge m:1 statefips nweek using "$rawdata\Opportunity Insights Economic Tracker\COVID.dta", gen(_m3)

replace state = "District of Columbia" if state == "District Of Columbia"

lab var emp_combined "Employment level for all workers"
lab var emp_combined_inclow "Employment level for workers in the bottom quartile of the income distribution (incomes approximately under $27,000)"
lab var emp_combined_incmiddle "Employment level for workers in the middle two quartiles of the income distribution (incomes approximately $27,000 to $60,000)"
lab var emp_combined_inchigh "Employment level for workers in the top quartile of the income distribution (incomes approximately over $60,000)"
lab var emp_combined_ss40 "Employment level for workers in trade, transportation and utilities (NAICS supersector 40)"
lab var emp_combined_ss60 "Employment level for workers in professional and business services (NAICS supersector 60)"
lab var emp_combined_ss65 "Employment level for workers in education and health services (NAICS supersector 65)"
lab var emp_combined_ss70 "Employment level for workers in leisure and hospitality (NAICS supersector 70)"

lab var initclaims_rate_regular "Number of initial claims per 100 people in the 2019 labor force, Regular UI only"
lab var initclaims_count_regular "Count of initial claims, Regular UI only"
lab var initclaims_rate_pua "Number of initial claims per 100 people in the 2019 labor force, PUA (Pandemic Unemployment Assistance) only"
lab var initclaims_count_pua "Count of initial claims, PUA (Pandemic Unemployment Assistance) only"
lab var initclaims_rate_combined "Number of initial claims per 100 people in the 2019 labor force, combining Regular and PUA claims"
lab var initclaims_count_combined "Count of initial claims, combining Regular and PUA claims"
lab var contclaims_rate_regular "Number of continued claims per 100 people in the 2019 labor force, Regular UI only"
lab var contclaims_count_regular "Count of continued claims, Regular UI only"
lab var contclaims_rate_pua "Number of continued claims per 100 people in the 2019 labor force, PUA (Pandemic Unemployment Assistance) only"
lab var contclaims_count_pua "Count of continued claims, PUA (Pandemic Unemployment Assistance) only"
lab var contclaims_rate_peuc "Number of continued claims per 100 people in the 2019 labor force, PEUC (Pandemic Emergency Unemployment Compensation) only"
lab var contclaims_count_peuc "Count of continued claims, PEUC (Pandemic Emergency Unemployment Compensation) only"
lab var contclaims_rate_combined "Number of continued claims per 100 people in the 2019 labor force, combining Regular, PUA and PEUC claims"
lab var contclaims_count_combined "Count of continued claims, combining Regular, PUA and PEUC claims"


merge 1:1 state nweek using  "$rawdata\Google Community Mobility Reports\USA_Mobility_Report.dta", gen(_m4)



drop _merge statenumG



save "$rawdata\NorthAmerica_otherdata.dta", replace

erase "$rawdata\Oxford COVID-19 Government Response Tracker\canada_population.dta"
erase "$rawdata\Opportunity Insights Economic Tracker\Employment.dta"
erase "$rawdata\Opportunity Insights Economic Tracker\states.dta"
erase  "$rawdata\Opportunity Insights Economic Tracker\COVID.dta"
erase "$rawdata\Opportunity Insights Economic Tracker\UIclaims.dta"
















