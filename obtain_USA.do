




import delimited "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddh-2019-01-01-to-2020-11-15.csv",  clear 

gen ddate = date(week_end_est ,"YMD")
format ddate %td

rename caller_state statecode
replace statecode = "XX" if statecode == ""

rename calls_routed_to_lifeline_centers ddhcalls


save "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddhraw.dta", replace

import delimited "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddh-2020-11-16-to-2021-03-31.csv",  clear 

gen ddate = date(week_end_est ,"YMD")
format ddate %td

rename caller_state statecode
replace statecode = "XX" if statecode == ""

rename calls_routed_to_lifeline_centers ddhcalls

append using "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddhraw.dta"

save "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddhraw.dta", replace



import delimited "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\lifeline-2019-01-01-to-2020-11-15.csv",  clear 

gen ddate = date(week_end_est ,"YMD")
format ddate %td

rename caller_state statecode
replace statecode = "XX" if statecode == ""

save "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\lifelineraw.dta", replace

import delimited "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\lifeline-2020-11-16-to-2021-03-31.csv",  clear 

gen ddate = date(week_end_est ,"YMD")
format ddate %td

rename caller_state statecode
replace statecode = "XX" if statecode == ""

append using "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\lifelineraw.dta"



merge 1:1 state ddate using "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddhraw.dta", nogen



erase "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\lifelineraw.dta"
erase "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\ddhraw.dta"


encode statecode, gen(statenum)

xtset statenum ddate


rename calls_routed_to_lifeline_centers lifelinecalls


gen nweek = week(ddate-2)
replace nweek = nweek+52 if year(ddate) == 2020
replace nweek = nweek+104 if year(ddate) == 2021

xtset statenum nweek 
tsfill, full

gen negdate = nweek * (-1)
bysort statenum (negdate): carryforward statecode, replace
bysort statenum (nweek): carryforward statecode, replace

replace lifelinecalls = 0 if lifelinecalls == .
replace ddhcalls = 0 if ddhcalls == .




merge 1:m statecode nweek using "$rawdata\Further Sources\NorthAmerica_otherdata.dta"


drop if _merge == 2

drop _merge _m4
drop statenum negdate
gen negdate = nweek * (-1)

drop if state == "Prince Edward Island" 

drop if nweek > 116
drop year 




replace statecode = "XX" if statecode == ""
replace state = "Puerto Rico" if statecode == "PR"
replace state = "American Samoa" if statecode == "AS"
replace state = "Northern Marianas" if statecode == "MP"
replace state = "Guam" if statecode == "GU"
replace state = "Virgin Islands" if statecode == "VI"
// drop if statecode == ""

foreach V of varlist state countryname countrycode state_pop2019 {
bysort statecode (negdate): carryforward `V', replace
  }
foreach V of varlist state countryname countrycode {
replace `V' = "XX Unknown" if statecode == "XX"
  }

replace countryname = "United States Territories" if state == "Puerto Rico" | state == "American Samoa" | state == "Northern Marianas" | state == "Guam"  | state == "Virgin Islands" 
replace countrycode = "USA Territories" if state == "Puerto Rico" | state == "American Samoa" | state == "Northern Marianas" | state == "Guam"  | state == "Virgin Islands" 


encode statecode, gen(statenum)
xtset statenum nweek


drop _m*  regioncode stateabbrev day_endofweek  week_end_est jurisdiction negdate

order statenum state nweek lifelinecalls ddhcalls state_pop2019 countryname statecode countrycode, first


gen lcalls = log(1+lifelinecalls) 
gen lddhcalls = log(1+ddhcalls) 


bysort state: egen maxstringency = max(stringency)

xtset statenum nweek


gen year = 2019 if  nweek<53
replace year = 2020 if  nweek>52 & nweek < 105
replace year = 2021 if  nweek>104

// bysort state week (month): carryforward month, replace
// replace month = 12 if nweek == 52 & year == 2019

rename month xmonth
gen month = month(ddate)
sort nweek
bysort nweek: carryforward month, replace

gen nmonth = month
replace nmonth = month+12 if year == 2020
replace nmonth = month+24 if year == 2021

gen week = nweek
replace week = nweek - 52 if nweek > 52
replace week = nweek - 104 if nweek > 103

gen quarter = 1 if inrange(month,1,3) 
replace quarter = 2 if inrange(month,4,6) 
replace quarter = 3 if inrange(month,7,9) 
replace quarter = 4 if inrange(month,10,12) 

gen nquarter = quarter
replace nquarter = quarter + 4 if nweek > 52
replace nquarter = quarter + 8 if nweek > 103

bysort statenum week (year): gen clifelinecalls2019 = lifelinecalls[1]
replace clifelinecalls2019 = . if nweek < 53
bysort statenum week (year): gen cddhcalls2019 = ddhcalls[1]
replace cddhcalls2019 = . if nweek < 53

gen xlifelinecalls =  lifelinecalls - clifelinecalls2019
gen lxlifelinecalls =  (log(1+lifelinecalls) - log(1+clifelinecalls2019))*100

gen xddhcalls =  ddhcalls - cddhcalls2019
gen lxddhcalls =  (log(1+ddhcalls) - log(1+cddhcalls2019))*100

xtset statenum nweek

gen pop100k =state_pop2019/100000
gen newcasesPOP = newcases/pop100k
gen newdeathsPOP = newdeaths/pop100k

gen Dlxlifelinecalls = D.lxlifelinecalls
gen Dlxddhcalls = D.lxddhcalls

ihstrans lifelinecalls ddhcalls



foreach v of varlist GM* {
replace `v' = 0 if `v' == . & inrange(nweek,53,56)
}


order year month week ddate, after(countrycode)
order statefips, after(statecode)

rename state_pop2019 population

lab var statenum "State/province numeric"
lab var state "State/province name"
lab var nweek "Running week, starting 1/1/2019"
lab var lifelinecalls "Weekly calls to National Suicide Prevention Lifeline"
lab var ddhcalls "Weekly calls to Disaster Distress Helpline"
lab var population "State/province population in 2019"
lab var countryname "Country name"
lab var statecode "State string code"
lab var countrycode "Country string code"
lab var month "Month of year"
lab var week "Week of year"
lab var year "Year"
lab var ddate "Date, end of week"
    
lab var lcalls "log(1+Lifeline calls)"
lab var lddhcalls "log(1+Disaster Distress calls)"

lab var clifelinecalls2019 "Lifeline calls in comparison week of 2019"
lab var cddhcalls2019 "Disaster Distress calls in comparison week of 2019"

lab var lxlifelinecalls "Excess Lifeline calls"
lab var lxddhcalls "Excess Disaster Distress calls"

lab var newcasesPOP "Newly confirmed COVID-19 infections per 100.000 population"
lab var newdeathsPOP "Newly confirmed COVID-19-related deaths per 100.000 population"

drop statefips maxstringency pop100k


foreach V of varlist stringencyindex newcasesPOP newdeathsPOP economicsupportindex {
gen l`V' = log(1+`V')
}

gen lifelinecallsPOP =lifelinecalls/(population*100000)
gen llifelinecallsPOP =log(lifelinecallsPOP+1)
gen logUI=log(1+initclaims_rate_combined)




foreach V of varlist lnewcasesPOP lstringencyindex leconomicsupportindex li_c1_schoolclosing li_c2_workplaceclosing li_c3_cancelpublicevents li_c4_restrgather li_c5_closepublictransport li_c6_stayathomerequirements li_c7_restrinternalmov li_c8_internattravel li_h1_publicinfocampaigns li_e1_incomesupport li_e2_debtcontractrelief   {
replace `V' = 0 if year == 2019 & (countryname == "United States" | countryname == "Canada")
}

gen secondhalf = (nweek>87)
gen firsthalf = (nweek<88)

// keep if nweek>75
// keep if countryname == "United States"
// keep if countryname == "Canada"
xtset statenum nweek


encode countryname, gen(ccode)

foreach V of varlist lnewcasesPOP lstringencyindex leconomicsupportindex li_e1_incomesupport li_e2_debtcontractrelief {
gen US`V' = 0
replace US`V' = `V' if countryname == "United States"
gen CA`V' = 0
replace CA`V' = `V' if countryname == "Canada"
gen sh`V' = 0
replace sh`V' = `V' * secondhalf 
gen fh`V' = 0
replace fh`V' = `V' * firsthalf 
}


gen lemp_combined = log(emp_combined)

gen lcalls100 = lcalls*100
gen l19calls100 = log(1+clifelinecalls2019)*100

gen ihs_lifelinecalls100 = ihs_lifelinecalls*100
ihstrans clifelinecalls2019
gen ihs_clifelinecalls2019100 =  ihs_clifelinecalls2019*100

lab var c1_schoolclosing "School closing"
lab var c2_workplaceclosing "Workplace closing" 
lab var c3_cancelpublicevents "Public events cancellation"
lab var c4_restrgather "Gatherings restricted"
lab var c5_closepublictransport "Public transport closing"
lab var c6_stayathomerequirements "Stay-at-home requirements"
lab var c7_restrinternalmov "Internal movement restricted"
lab var c8_internattravel "International movement restricted"
lab var e1_incomesupport "Income support" 
lab var e2_debtcontractrelief "Debt relief"

order countryname countrycode statecode statenum state population year quarter month week nweek lifelinecalls ddhcalls lxlifelinecalls lxddhcalls newcasesPOP newdeathsPOP, first 




bysort statenum: egen dateofoutbreak = min(nweek) if newcasesPOP > 10 & newcases != .
bysort statenum (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
gen outbreakdate = (nweek==dateofoutbreak)
gen postoutbreak = (nweek>=dateofoutbreak)



bysort statenum: egen weekofSAH =  min(nweek) if c6_stayathomerequirements > 0 & c6_stayathomerequirements != .
bysort statenum (weekofSAH): replace weekofSAH = weekofSAH[1]
gen SAHweek = (nweek==weekofSAH)
gen postSAH = (nweek>=weekofSAH)

gen SAHnweek = nweek - weekofSAH
replace SAHnweek = SAHnweek+52 if year == 2019


gen postmarch9 = (nweek>60 & nweek<weekofSAH)



xtset statenum nweek


drop if nweek > 117
drop if state == "XX Unknown" 
drop if countryname == "United States Territories" 

save "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\USstatepanel.dta", replace







use "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\USstatepanel.dta", clear


// keep if countryname == "United States"

reghdfe lcalls lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nweek)  vce(cluster statenum#nmonth) nocons

keep if e(sample) // keep if !mi(lcalls,lnewcasesPOP , lstringencyindex ,leconomicsupportindex)

egen mobility = rowmean(GMretailrec GMgrocpharm GMtransit GMworkpl)

reghdfe lcalls, absorb( statenum)  vce($SE) nocons resid
// reghdfe lcalls, absorb( statenum )  vce($SE) nocons resid

gen resid = _reghdfe_resid
bysort nweek : egen meanres = mean(resid)


gen ddhcallsPOP = ddhcalls/population*100000

bysort nweek : egen meanmobility = mean(mobility)
bysort nweek : egen meanstringeny = mean(stringencyindex)
bysort nweek : egen meancovid = mean(newcasesPOP)
bysort nweek : egen totalcovid = sum(newcases)
bysort nweek : egen meansupport = mean(ie1_incomesupport)
bysort nweek : egen meanllcalls = mean(lcalls)
bysort nweek : egen meancalls = mean(lifelinecalls)
bysort nweek : egen totalcalls = sum(lifelinecalls)
bysort nweek : egen meanddhcalls = mean(ddhcallsPOP)
bysort nweek : egen p25llcalls = pctile(lifelinecallsPOP), p(25)
bysort nweek : egen p50llcalls = pctile(lifelinecallsPOP), p(50)
bysort nweek : egen p75llcalls = pctile(lifelinecallsPOP), p(75) 

xtset statenum nweek
tsfill

gen nationalcovidPOP = totalcovid/32820
mvsumm totalcalls, gen(MA7totalcalls) stat(mean) window(3) force
mvsumm nationalcovidPOP, gen(MA7covid) stat(mean) window(3) force



replace nweek = nweek-52 if nweek>52
replace nweek = nweek-52 if nweek>52
replace totalcalls = totalcalls/1000
replace MA7totalcalls = MA7totalcalls/1000
gen wdate = yw(year(ddate),week(ddate))



replace nweek = nweek+52 if year == 2021 
# delimit ;
twoway  line lifelinecalls wdate if year !=2018 , lcolor(edkbg) lpattern(solid) yaxis(1) connect(ascending) lwidth(thin)
	||  line lifelinecalls wdate if year !=2018 & statecode == "CA", lcolor(ply1) lpattern(solid) yaxis(1) connect(ascending) lwidth(medthick)
	|| line lifelinecalls wdate   if year !=2018 & statecode == "TX" , lcolor(plb1) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthick)  
	|| line lifelinecalls wdate   if year !=2018 & statecode == "NY" , lcolor(pll1) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthick)  
	|| line lifelinecalls wdate   if year !=2018 & statecode == "FL" , lcolor(plg1) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthick)  
	  scheme(s2color) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1) size(small)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale( axis(1) titlegap(0)) 	
		title("(A) Lifeline",  size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		xtitle("", yoffset(-2)) 
 		xlabel(3068(26)3183 , labsize(medsmall) labcolor(gs0) format(%twMon_CCYY)) 
		name(llcallsoverview, replace);
# delimit cr
# delimit ;
twoway  line ddhcalls wdate if year !=2018 , lcolor(edkbg) lpattern(solid) yaxis(1) connect(ascending) lwidth(thin)
	||  line ddhcalls wdate if year !=2018 & statecode == "CA", lcolor(ply1) lpattern(solid) yaxis(1) connect(ascending) lwidth(medthick)
	|| line ddhcalls wdate   if year !=2018 & statecode == "TX" , lcolor(plb1) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthick)  
	|| line ddhcalls wdate   if year !=2018 & statecode == "NY" , lcolor(pll1) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthick)  
	|| line ddhcalls wdate   if year !=2018 & statecode == "FL" , lcolor(plg1) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthick)  
	  scheme(s2color) legend(label(2 "California") label(3 "Texas") label(4 "New York") label(5 "Florida") label(1 "Other") order(2 3 4 5 1) pos(2) ring(0) region(lcolor(white)) cols(1)) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1) size(small)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale( axis(1) titlegap(0)) 	
		title("(B) Disaster Distress Helpline",  size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		xtitle("", yoffset(-2)) 
 		xlabel(3068(26)3183 , labsize(medsmall) labcolor(gs0) format(%twMon_CCYY)) 
		name(ddhoverview, replace);
# delimit cr





graph combine llcallsoverview ddhoverview, cols(2) xsize(6) ysize(3) title("",  size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 	 	

graph export ".\02_Project\Figures\vibrant_supp.pdf", replace
graph export ".\02_Project\Figures\vibrant_supp.png", replace



// # delimit ;
// twoway scatter totalcalls nweek if year == 2019 , msymbol(d) mcolor(edkbg)	msize(vsmall) yaxis(1)
 	// || line MA7totalcalls  nweek if year == 2019 & statecode == "TX", lcolor(edkbg) lpattern(solid)  yaxis(1) connect(ascending)
	// || scatter totalcalls nweek if year == 2020, msymbol(d) mcolor(gs0)	msize(vsmall) yaxis(1)
 	// || line MA7totalcalls  nweek if year == 2020& statecode == "TX", lcolor(gs0) lpattern(solid) yaxis(1)  connect(ascending)
	// || scatter totalcalls nweek if year == 2021, msymbol(d) mcolor(eltblue)	msize(vsmall) yaxis(1)
 	// || line MA7totalcalls  nweek if year == 2021& statecode == "TX" & nweek <12, lcolor(eltblue) lpattern(solid) yaxis(1)  connect(ascending)
	  // scheme(s2color) legend(label(2 "2019") label(4 "2020") label(6 "2021") order(6 4 2)  cols(1) rowgap(zero) region(lcolor(white)) pos(2) ring(0) size(medsmall)) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("", xoffset(-1) axis(1) size(medsmall)) 
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		// title("Weekly calls to the Disaster Disaster Helpline ('000)",  size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		// xtitle("", yoffset(-2)) 
// xlabel(2.5 "J" 7 "F" 11.5 "M" 16 "A" 20 "M" 24.5 "J" 29 "J" 33 "A" 37.5 "S" 42 "O" 46 "N" 50 "D", labsize(medsmall) labcolor(gs0) notick)
		// xtick(1 5 9 14 18 22 27 31 35 40 44 48 52) 
		// xsize(6) ysize(3.5)
		// name(ddh_supp, replace);
// # delimit cr


// keep if year > 2019
// keep if statecode == "TX"

// # delimit ;
// twoway  line MA7covid ddate , lcolor(cranberry) lpattern(solid) yaxis(2) lwidth(medthick) connect(ascending)
 // || line meanstringeny ddate , lcolor(ebblue) lpattern(solid) lwidth(medthick)  yaxis(2) connect(ascending)
	// || scatter totalcalls ddate , msymbol(o) mcolor(gs0)	msize(medsmall) yaxis(1)
 	// || line MA7totalcalls  ddate, lcolor(gs0) lpattern(solid) yaxis(1) lwidth(medthick) connect(ascending)
		// scheme(s2color) 
		// legend(label(4 "Daily helpline calls (7-day moving average)") label(1  "Newly confirmed Covid-19 infections/million population")  label(2 "Government response stringency index")  order(4 2 1) cols(1)  pos(7) ring(1) colfirst size(medsmall)  colgap(30) region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("Index score/cases rate", xoffset(0) axis(2) size(medsmall)) 
		// ytitle("Daily calls", xoffset(0) axis(1) size(medsmall) color(gs0) )	
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(2) nogrid) 
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		// yscale( axis(2) titlegap(0)) 	
		// yscale(axis(1) titlegap(0))
		// xtitle("", yoffset(-2)) 
 		// xlabel( , labsize(medsmall) labcolor(gs0) format(%tdMon_YY)) 
		// xsize(6) ysize(3);
// # delimit cr
// graph export ".\02_Project\Figures\OverviewUSA.pdf", replace



// # delimit ;
// twoway scatter totalcalls nweek if year == 2019 , msymbol(d) mcolor(edkbg)	msize(vsmall) yaxis(1)
 	// || line MA7totalcalls  nweek if year == 2019 & statecode == "TX", lcolor(edkbg) lpattern(solid)  yaxis(1) connect(ascending)
	// || scatter totalcalls nweek if year == 2020, msymbol(d) mcolor(gs0)	msize(vsmall) yaxis(1)
 	// || line MA7totalcalls  nweek if year == 2020& statecode == "TX", lcolor(gs0) lpattern(solid) yaxis(1)  connect(ascending)
	// || scatter totalcalls nweek if year == 2021, msymbol(d) mcolor(eltblue)	msize(vsmall) yaxis(1)
 	// || line MA7totalcalls  nweek if year == 2021& statecode == "TX" & nweek <12, lcolor(eltblue) lpattern(solid) yaxis(1)  connect(ascending)
	  // scheme(s2color) legend(label(2 "2019") label(4 "2020") label(6 "2021") order(6 4 2)  cols(1) rowgap(zero) region(lcolor(white)) pos(5) ring(0) size(medsmall)) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("", xoffset(-1) axis(1) size(medsmall)) 
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		// yscale(range(22 40) axis(1) titlegap(0)) 	
		// title("Weekly calls to the Lifeline ('000)",  size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		// xtitle("", yoffset(-2)) 
// xlabel(2.5 "J" 7 "F" 11.5 "M" 16 "A" 20 "M" 24.5 "J" 29 "J" 33 "A" 37.5 "S" 42 "O" 46 "N" 50 "D", labsize(medsmall) labcolor(gs0) notick)
		// xtick(1 5 9 14 18 22 27 31 35 40 44 48 52) 
		// xsize(6) ysize(3.5)
		// name(lifeline_supp, replace);
// # delimit cr



