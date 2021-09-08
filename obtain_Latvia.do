









import excel ".\03_Data\Countries\Latvia\Crisisline_DATASET_KT_2019_2020.xlsx", firstrow  clear



gen ddate = date(Date, "MDY")
format ddate %td

gen duration = minutes(Endofcall - Startofcall) if Endofcall>Startofcall
gen daybreakstring = "31dec1899 00:00:00"
destring daybreakstring, gen(daybreak)

// gen daybreak = clock(daybreakstring, "DMYhms" )
// format daybreak %tcHH:MM:SS


gen female = 0 if Sexagegroup != ""
replace female = 1 if Sexagegroup == "Women (adult)"
replace female = 1 if Sexagegroup == "Girl (child)"
gen male = 0 if Sexagegroup != ""
replace male = 1 if Sexagegroup == "Men (adult)"
replace male = 1 if Sexagegroup == "Boy (child)"
gen child = 0 if Sexagegroup != ""
replace child = 1 if Sexagegroup == "Boy (child)"
replace child = 1 if Sexagegroup == "Girl (child)"
gen adult = 0 if Sexagegroup != ""
replace adult = 1 if Sexagegroup == "Women (adult)"
replace adult = 1 if Sexagegroup == "Men (adult)"

gen repcall = 0 if Regularcaller != ""
replace repcall = 1 if Regularcaller == "Yes"
gen first = 0 if Regularcaller != ""
replace first = 1 if Regularcaller == "No"

tab Addiction
gen addiction = 1 if Addiction != "no"
replace addiction = 0 if Addiction == "no"
replace addiction = . if Addiction == "no informācijas"

tab Victimofviolence
gen violence = 1 if Victimofviolence != "no"
replace violence = 0 if Victimofviolence == "no"

gen suicide = 1 if Suiciderisk != "no"
replace suicide = 0  if Suiciderisk == "no"

gen suicide_thoughts = 0
replace suicide_thoughts = 1  if regexm(Suiciderisk,"suicide thoughts") == 1
gen suicide_plan = 0
replace suicide_plan = 1  if regexm(Suiciderisk,"has a realistic plan of suicide") == 1
gen suicide_pastat = 0
replace suicide_pastat = 1  if regexm(Suiciderisk,"suicide attempt in past") == 1



//   Sexagegroup Language Regularcaller Socialproblems Relationshipproblems Addiction Victimofviolence Clientisperpetrator Violencefrom Emotionsofclient Suiciderisk Stageofcrisis Typeofconsultation Providedinformationdeleted Calldescriptiondeleted Disasterorcatastropheexperien Callisrelatedwithfearaffect














import excel ".\03_Data\Countries\Latvia\DATASET_116006_2019_withoutSensitiveData_VicitimLine.xls",   clear

renvars A-J, map(word(@[2],1))

gen ddate = date(Date, "DMY")
format ddate %td


gen starttimestring = substr(Time,1,5)
gen dtime = Date + " " + starttimestring
 gen double starttime = clock(dtime, "DMYhm")
 format starttime  %tc
 
gen endtimestring = substr(Time,9,13)
replace dtime = Date + " " + endtimestring
 gen double endtime = clock(dtime, "DMYhm")
 format endtime  %tc
drop Date Time dtime
gen duration = minutes(endtime - starttime)
order ddate duration starttime endtime, first


rename Predictive Age
rename Language main_language
renvars K-W, map("Crime_" + subinstr(word(@[2],1)," ","_",.))
renvars X-Z, map("Violence_" + subinstr(word(@[2],1)," ","_",.))
rename AA Violence_Internet
rename AB Violence_Other
renvars AC AE, map("Victim_" + subinstr(word(@[2],4)," ","_",.))
renvars AD, map("Victim_" + subinstr(word(@[2],3)," ","_",.))
renvars AF-AI, map("Violence_type_" + subinstr(word(@[2],1)," ","_",.))
renvars AJ-AL, map("Crisis_stage" + subinstr(word(@[2],1)," ","_",.))
rename Crisis_stageHronical Crisis_stage_Chronic
rename AM Crisis_stage_Intervention
rename AN Suicidal_Thoughts
rename AP Suicidal_Attempt
rename AO Suicidal_Plan
rename AS  Consult_type_Witness
rename AR  Consult_type_Crimprocess
renvars AT-BB, map("Crime19_" + subinstr(word(@[2],1)," ","_",1))
drop AQ BC-BF


drop in 1/2
replace Consult_type_Witness = "1" if Consult_type_Witness == "jā"
replace Consult_type_Witness = "1" if Consult_type_Witness == "Jā"
replace Consult_type_Witness = "0" if Consult_type_Witness == "nē"
replace Consult_type_Witness = "0" if Consult_type_Witness == "Nē"
replace Consult_type_Witness = "" if Consult_type_Witness == "emocionālai vardarbībai pret vecmammu"
destring Female-Crime19_Other, replace ignore(".")

replace Age = subinstr(Age,".","",.)
replace Age = subinstr(Age,"`","",.)
replace Age = subinstr(Age,"Ap","",.)
replace Age = subinstr(Age,"lv","",.)
replace Age = "" if Age == "<40"
replace Age = "" if Age == "70 vai vairāk"
replace Age = "" if Age == "?"
replace Age = "75" if Age == "70-80"
replace Age = "65" if Age == "60-70"
replace Age = "27" if Age == " 25-30"
replace Age = trim(Age)
destring Age, replace 

renvars _all, lower
save `".\03_Data\Countries\Latvia\Latvia2019x.dta"', replace


import excel ".\03_Data\Countries\Latvia\Book2.xlsx",   clear

renvars A-J, map(word(@[2],1))
rename Predictive Age
rename Sarunu main_language
renvars K-V, map("Crime_" + subinstr(word(@[2],1)," ","_",.))
renvars W-Y, map("Violence_" + subinstr(word(@[2],1)," ","_",.))
rename Z Violence_Internet
rename AA Violence_Other
renvars AB-AD, map("Victim_" + subinstr(word(@[2],1)," ","_",.))
renvars AE-AH, map("Violence_type_" + subinstr(word(@[2],1)," ","_",.))
renvars AJ-AL, map("Crisis_stage" + subinstr(word(@[2],1)," ","_",.))
rename AI Crisis_stage_Chronic
renvars AN-AO, map("Suicidal_" + subinstr(word(@[2],3),"#","_",.))
rename AM Suicidal_Thoughts
renvars AP-AT, map("Consult_type_" + subinstr(word(@[2],1)," ","_",.))
renvars AU-BC, map("Crime20_" + subinstr(word(@[2],1)," ","_",.))

drop in 1/2
replace Consult_type_Witness = "1" if Consult_type_Witness == "jā"
destring Age-Crime20_Other, replace ignore(".")

gen ddate = date(DATE, "DMY")
format ddate %td


gen starttimestring = substr(TIME,1,5)
gen dtime = DATE + " " + starttimestring
 gen double starttime = clock(dtime, "DMYhm")
 format starttime  %tc
 
gen endtimestring = substr(TIME,9,13)
replace dtime = DATE + " " + endtimestring
 gen double endtime = clock(dtime, "DMYhm")
 format endtime  %tc
drop DATE TIME dtime
gen duration = minutes(endtime - starttime)
order ddate duration starttime endtime, first

renvars _all, lower
save `".\03_Data\Countries\Latvia\Latvia2020.dta"', replace

import excel ".\03_Data\Countries\Latvia\Book1.xlsx",   clear

renvars A-E, map(word(@[2],1))
rename F Other_Gender
rename Predictive Age
renvars G-H, map(word(@[2],1))
rename I Other_Status
renvars J-K, map(word(@[2],1))
rename L Other_Language
renvars N-P, map("Consult_title_" + subinstr(word(@[2],1)," ","_",.))
renvars Q-R, map("Special_event" + subinstr(word(@[2],1)," ","_",.))
renvars S-U, map("Violence_" + subinstr(word(@[2],1)," ","_",.))
rename V Violence_Internet
rename W Violence_Other
renvars X-Z, map("Victim_" + subinstr(word(@[2],1)," ","_",.))
renvars AA-AD AF, map("Violence_type_" + subinstr(word(@[2],1)," ","_",.))
rename AE Violence_type_Violcontrol

renvars AG-AI, map("Crisis_stage" + subinstr(word(@[2],1)," ","_",.))
rename AJ Crisis_stage_Chronic
rename AK Crisis_intervention
renvars AN-AO, map("Suicidal_" + subinstr(word(@[2],3),"#","_",.))
rename AM Suicidal_Thoughts
renvars AP-AX, map("Crime19_" + subinstr(word(@[2],1)," ","_",.))
renvars BC-BD, map("Consult_type_" + subinstr(word(@[2],1)," ","_",.))
rename BE  Consult_type_Both
rename BF  Consult_type_Other
rename AY  Consult_type_Witness
rename BA  Consult_type_Initiated
drop AL AZ BG BH BB Special_eventNo M

drop in 1/2
destring Age-Consult_type_Other, replace ignore(".")

gen ddate = date(DATE, "DMY")
format ddate %td

gen starttimestring = substr(TIME,1,5)
gen dtime = DATE + " " + starttimestring
 gen double starttime = clock(dtime, "DMYhm")
 format starttime  %tc
 
gen endtimestring = substr(TIME,9,13)
replace dtime = DATE + " " + endtimestring
 gen double endtime = clock(dtime, "DMYhm")
 format endtime  %tc
drop DATE TIME dtime
gen duration = minutes(endtime - starttime)
order ddate duration starttime endtime, first

renvars _all, lower

append using `".\03_Data\Countries\Latvia\Latvia2020.dta"'
append using `".\03_Data\Countries\Latvia\Latvia2019x.dta"'

sort ddate starttime



replace female = 0 if male ==1 | other_gender == 1
replace male = 0 if female ==1 | other_gender == 1
replace other_gender = 0 if female ==1 | male == 1


replace child = 0 if adult ==1 
replace adult  = 0 if child ==1 

gen violence = 0 
replace violence = 1 if violence_family == 1 ///
					| violence_workplace  == 1 ///
					| violence_street  == 1 ///
					| violence_internet  == 1 ///
					| violence_other == 1

gen physviol = (violence_type_physical==1) 
gen sexviol = (violence_type_sexual==1)

gen suicide = 0
replace suicide = 1 if suicidal_thoughts == 1 |  suicidal_plan == 1 | suicidal_attempt ==1


// crisis_stageacute crisis_stagenot crisis_stagehronical crisis_stage_chronic crisis_intervention 


gen country = "Latvia"
gen population = 1.92

gen helplinename = "Skalbes (Victims and Crisis helpline)"

gen hour = hh(starttime)

keep ddate duration hour age female male other_gender child adult other_status suicidal_thoughts suicidal_plan suicidal_attempt violence physviol sexviol suicide country population helplinename

save `".\03_Data\Countries\Latvia\LATcontacts.dta"',  replace





use `".\03_Data\Countries\Latvia\LATcontacts.dta"',  clear


bysort ddate: gen helplinecontactsLAT = _N

foreach V in male female child adult violence physviol sexviol suicide {
bysort ddate: egen contacts_`V' = sum(`V' == 1)
}

gen agecode = .
replace agecode = 1 if inrange(age,0,11)
replace agecode = 2 if inrange(age,12,17)
replace agecode = 3 if inrange(age,18,24)
replace agecode = 4 if inrange(age,25,39)
replace agecode = 5 if inrange(age,40,49)
replace agecode = 6 if inrange(age,50,59)
replace agecode = 7 if inrange(age,60,69)
replace agecode = 8 if inrange(age,70,79)
replace agecode = 9 if inrange(age,80,89)
replace agecode = 10 if inrange(age,90,100)
forvalues J= 1/10 {
bysort ddate: egen contacts_age`J' = sum(agecode == `J')
}

bysort ddate: keep if _n == 1
keep ddate country population helplinecontactsLAT contacts_*

// save `".\03_Data\Countries\Latvia\Latvia_series.dta"',  replace



gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020
gen daily19 = ddate - mdy(1,1,2019) + 1 if year(ddate) == 2019



gen zero = 0
gen c2 = contacts_age1 + contacts_age2
gen c3 = c2 + contacts_age3
gen c4 = c3 + contacts_age4
gen c5 = c4 + contacts_age5
gen c6 = c5  + contacts_age6
gen c7 = c6  + contacts_age7
gen c8 = c7  + contacts_age8
gen c9 = c8  + contacts_age9
gen c10 = c9 + contacts_age10

tsset daily20
tsfill
foreach V of varlist helplinecontacts c2 c3 c4 c5 c6 c7 c8 c9 c10 contacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}

# delimit ;
twoway rbar zero contacts_age1 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.1)  yaxis(1)  
	|| rbar contacts_age1 c2 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.4)  yaxis(1)  
	|| rbar c2 c3 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.6)  yaxis(1)  
	|| rbar c3 c4  daily20  if year(ddate) == 2020 , bcolor(ebblue*0.8)  yaxis(1)  
	|| rbar c4 c5  daily20  if year(ddate) == 2020 , bcolor(ebblue*1)  yaxis(1)  
	|| rbar c5 c6  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.2)  yaxis(1)  
	|| rbar c6 c7  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.4)  yaxis(1)  
	|| rbar c7 c8  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.6)  yaxis(1)  
	|| rbar c8 c9  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.8)  yaxis(1)  
	|| rbar c9 c10 daily20  if year(ddate) == 2020 , bcolor(ebblue*2)  yaxis(1)  
		scheme(s2color) legend(label(1 "-12") label(2 "12-17") label(3 "18-24") label(4 "25-39") 
			label(5 "40-49") label(6 "50-59") label(7 "60-69") label(8 "70-79") label(9 "80-89") label(10 "90+") 
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152)
		name(age1, replace);
# delimit cr

// plb1 plg1 ply1 pll1 plb2 plg2
# delimit ;
twoway line MA7contacts_age1 daily20  if year(ddate) == 2020 ,  lcolor(plb1)  yaxis(1)  
	|| line MA7contacts_age2 daily20  if year(ddate) == 2020 ,  lcolor(plg1)  yaxis(1)  
	|| line MA7contacts_age3 daily20  if year(ddate) == 2020 ,  lcolor(ply1)  yaxis(1)  
	|| line MA7contacts_age4  daily20  if year(ddate) == 2020 , lcolor(pll1)  yaxis(1)  
	|| line MA7contacts_age5  daily20  if year(ddate) == 2020 , lcolor(plb2) yaxis(1)  
	|| line MA7contacts_age6  daily20  if year(ddate) == 2020 , lcolor(plg2)  yaxis(1)  
	|| line MA7contacts_age7  daily20  if year(ddate) == 2020 , lcolor(ply2)  yaxis(1)  
	|| line MA7contacts_age8  daily20  if year(ddate) == 2020 , lcolor(pll2)  yaxis(1)  
	|| line MA7contacts_age9  daily20  if year(ddate) == 2020 , lcolor(plb3)  yaxis(1)  
	|| line MA7contacts_age10 daily20  if year(ddate) == 2020 , lcolor(plg3)  yaxis(1)  
		scheme(s2color) legend(label(1 "-12") label(2 "12-17") label(3 "18-24") label(4 "25-39") 
			label(5 "40-49") label(6 "50-59") label(7 "60-69") label(8 "70-79") label(9 "80-89") label(10 "90+") 
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152)
		name(age2, replace);
# delimit cr

graph combine age1 age2, cols(1)

graph export ".\02_Project\Figures\ageofcontacts_LAT.pdf", replace



tsset ddate

      
# delimit ;    
twoway|| scatter contacts_physviol daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_physviol  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| scatter contacts_sexviol daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_sexviol  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
			scheme(s2color) legend( label(1 "")  label(2 "Physical violence") label(4 "Sexual violence") 
			order(2 4 )  cols(2) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr
graph export ".\02_Project\Figures\contacts_violenceLAT.pdf", replace

 // scatter contacts_violence daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_violence  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
// || scatter contacts_suicide daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_suicide  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	
