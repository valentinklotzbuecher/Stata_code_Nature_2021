
///////////////////////////////////////////////////////////////////
// obtain raw data:

* Calls:
import excel "$rawdata\Countries\Italy\Tel2019_2020.xls",  firstrow clear
save "$rawdata\Countries\Italy\Tel2019_2020.dta",  replace

* Chats:
import excel "$rawdata\Countries\Italy\Chat2019_2020.xls",  firstrow clear


save "$rawdata\Countries\Italy\Chat2019_2020.dta",  replace

use "$rawdata\Countries\Italy\Tel2019_2020.dta",  clear

gen phone = 1

append using "$rawdata\Countries\Italy\Chat2019_2020.dta"

replace phone = 0 if phone == .
gen chat = 1-phone

// gen year = substr(ID_DAY_CENTER)
gen ddate = date(DATE, "YMD")
format ddate %td

foreach V of varlist CENTER DATE ID_DAY_CENTER GENDER RELATIONALCONTEXT AGE WORKINGSITUATION LOCATION SUICIDE PROBLEM REPORTING1 REPORTING2 REPORTING3 {
replace `V' = trim(`V')
}


gen 	center = "BOLZANO" if CENTER == "AA01"
replace center = "NAPOLI" if CENTER == "CA01"
replace center = "MODENA" if CENTER == "ER91"
replace center = "PARMA" if CENTER == "ER92"
replace center = "ROMA" if CENTER == "LA01"
replace center = "BERGAMO" if CENTER == "LO01"
replace center = "BRESCIA" if CENTER == "LO02"
replace center = "MANTOVA" if CENTER == "LO03"
replace center = "BUSTOARSIZIO" if CENTER == "LO05"
replace center = "MILANO" if CENTER == "LO95"
replace center = "NAZIONALE" if CENTER == "NZ01"
replace center = "SASSARI" if CENTER == "SA02"
replace center = "PALERMO" if CENTER == "SI92"
replace center = "PRATO" if CENTER == "TO92"
replace center = "TRENTO" if CENTER == "TR01"
replace center = "PADOVA" if CENTER == "VE01"
replace center = "VENEZIA" if CENTER == "VE02"
replace center = "VICENZA" if CENTER == "VE05"
replace center = "BASSANO" if CENTER == "VE98"
replace center = "TREVISO" if CENTER == "VE99"
replace center = "UDINE" if CENTER == "VG02"

global centerlist "BOLZANO NAPOLI MODENA PARMA ROMA BERGAMO BRESCIA MANTOVA BUSTOARSIZIO MILANO NAZIONALE SASSARI PALERMO PRATO TRENTO PADOVA VENEZIA VICENZA BASSANO TREVISO UDINE"
foreach R in $centerlist {
gen `R' = (center == "`R'")
}

encode center, gen(centercode)





gen female = .
replace female = 0 if GENDER != "."
replace female = 1 if GENDER == "F"
lab var female "Female"

gen male = (GENDER == "M")
lab var male "Male"

gen duration = DURATION
lab var duration "Duration (min)"


gen age1   = (AGE == "0")
gen age2  = (AGE == "1")
gen age3  = (AGE == "2")
gen age4  = (AGE == "3")
gen age5 = (AGE == "4")
gen age6 = (AGE == "5")
gen age7 = (AGE == "6")
gen age8 = (AGE == "7")
gen age9 = (AGE == "8")  

lab var age1	"Age: 0-14"
lab var age2    "Age: 15-18"
lab var age3    "Age: 19-25"
lab var age4    "Age: 26-35"
lab var age5    "Age: 36-45"
lab var age6    "Age: 46-55"
lab var age7    "Age: 56-65"
lab var age8    "Age: 66-75"
lab var age9    "Age: 75 and older"

gen agegroup = ""
replace agegroup = "0-14" if age1 == 1
replace agegroup = "15-18" if age2 == 1
replace agegroup = "19-25" if age3 == 1
replace agegroup = "26-35" if age4 == 1
replace agegroup = "36-45" if age5 == 1
replace agegroup = "46-55" if age6 == 1
replace agegroup = "56-65" if age7 == 1
replace agegroup = "66-75" if age8 == 1
replace agegroup = "75 and older" if age9 == 1


gen retired = (WORKINGSITUATION == "2")
gen education = (WORKINGSITUATION == "0")

lab var retired "Retired"
lab var education "In education"



gen agemin = "0" if age1 == 1
replace agemin = "15" if age2 == 1
replace agemin = "19" if age3 == 1
replace agemin = "26" if age4 == 1
replace agemin = "36" if age5 == 1
replace agemin = "46" if age6 == 1
replace agemin = "56" if age7 == 1
replace agemin = "66" if age8 == 1
replace agemin = "75" if age9 == 1
gen agemax = "14" if age1 == 1
replace agemax = "18" if age2 == 1
replace agemax = "25" if age3 == 1
replace agemax = "35" if age4 == 1
replace agemax = "45" if age5 == 1
replace agemax = "55" if age6 == 1
replace agemax = "65" if age7 == 1
replace agemax = "75" if age8 == 1
replace agemax = "100" if age9 == 1
destring agemax agemin, replace
egen age = rowmean(agemin agemax)




gen living_alone = (RELATIONALCONTEXT == "0")
gen living_partner = (RELATIONALCONTEXT == "1")
gen living_family = (RELATIONALCONTEXT == "2")
gen living_other = (RELATIONALCONTEXT == "3")
foreach V of varlist living_* {
replace `V' = . if RELATIONALCONTEXT == "4"
}

lab var living_alone 	"Living alone"
lab var living_partner	"Living with partner"
lab var living_family	"Living with family"
lab var living_other 	"Living other"

gen region =	 "North east" 			if LOCATION == "0"
replace region = "North west" 			if LOCATION == "1"
replace region = "Center" 				if LOCATION == "2"
replace region = "South and Islands" if LOCATION == "3"
replace region = "Not detected" 					if LOCATION == "4"
replace region = "Foreign" 				if LOCATION == "5"

destring LOCATION, gen(regioncode)
gen region0 = "Nord est"		 if regioncode == 0	
gen region1 = "Nord ovest"    if regioncode == 1	
gen region2 = "Centro"        if regioncode == 2	
gen region3 = "Sud e isole"   if regioncode == 3	
gen region4 = "Non rilevato"  if regioncode == 4	
gen region5 = "Estero"        if regioncode == 5	

gen problem = ""                                       
	replace problem = "abitative"						if PROBLEM == "A"	
	replace problem = "lav.-econom."					if PROBLEM == "B"		
	replace problem = "giuridiche"						if PROBLEM == "C"	
	replace problem = "sanitarie"						if PROBLEM == "D"	
	replace problem = "varie (prob. serv.)"				if PROBLEM == "E"			
	replace problem = "parafilie"						if PROBLEM == "F"	
	replace problem = "id. di genere e orient. sex."	if PROBLEM == "G"						
	replace problem = "masturbazione"					if PROBLEM == "H"		
	replace problem = "prob. attività  sex"				if PROBLEM == "I"			
	replace problem = "intos."							if PROBLEM == "J"
	replace problem = "diff. rapporti e relazioni"		if PROBLEM == "K"					
	replace problem = "ins. sociale"					if PROBLEM == "L"		
	replace problem = "ins. lavorativo"					if PROBLEM == "M"		
	replace problem = "prob. sentimentali"				if PROBLEM == "N"			
	replace problem = "familiari"						if PROBLEM == "O"	
	replace problem = "coppia"							if PROBLEM == "P"
	replace problem = "amicali/altre relazioni"			if PROBLEM == "Q"				
	replace problem = "lavorativi"						if PROBLEM == "R"	
	replace problem = "esistenziali"					if PROBLEM == "S"		
	replace problem = "bisogno di comp."				if PROBLEM == "T"			
	replace problem = "prosp. e cambiamento"			if PROBLEM == "U"				
	replace problem = "solitudine"						if PROBLEM == "V"	
	replace problem = "depressione"						if PROBLEM == "W"	
	replace problem = "malattia fisica"					if PROBLEM == "X"		
	replace problem = "malattia psichica"				if PROBLEM == "Y"			
	replace problem = "suicidio"						if PROBLEM == "Z"	
	replace problem = "problema non emerso"				if PROBLEM == "&"			
	replace problem = "info sul servizio"				if PROBLEM == "1"			
	replace problem = "prop. di collab."				if PROBLEM == "2"			
	replace problem = "scherzo"							if PROBLEM == "3"

drop if problem == "scherzo"		

gen physhealth = 0 if problem != ""
replace physhealth = 1 if problem == "malattia fisica"

gen mentalhealth = 0 if problem != ""
replace mentalhealth = 1 if problem == "malattia psichica"

gen healthcare = 0 if problem != ""
replace healthcare = 1 if problem == "sanitarie"

gen lonely = 0 if problem != ""
replace lonely = 1 if problem == "solitudine"

gen depressed = 0 if problem != ""
replace depressed = 1 if problem == "depressione"



gen T_econ =  0 if problem != ""
replace T_econ = 1 if problem == "abitative"
replace T_econ = 1 if problem == "lav.-econom."
replace T_econ = 1 if problem == "lavorativi"
replace T_econ = 1 if problem == "ins. sociale"
replace T_econ = 1 if problem == "ins. lavorativo"

gen sex = 0 if problem != ""
replace sex = 1 if problem == "parafilie" ///
						| problem == "prob. attività  sex"	///
						| problem == "masturbazione"	///
						| problem == "prob. sentimentali" ///
						| problem == "id. di genere e orient. sex."

gen T_social = 0 if problem != ""
replace T_social = 1 if problem == "amicali/altre relazioni" ///
					   | problem == "familiari"	/// ///
					   | problem == "diff. rapporti e relazioni"	/// 
					   | problem == "bisogno di comp."	/// 
					   | problem == "coppia"



gen suicide = 0 if SUICIDE == "0"
replace suicide = 1 if SUICIDE == "1"
replace suicide = 1 if problem == "suicidio"


forvalues J=1/3 {

gen reporting`J' = ""
replace reporting`J' = "aborto" if REPORTING`J' == "A"
replace reporting`J' = "aids" if REPORTING`J' == "B"
replace reporting`J' = "dipendenza sostanze" if REPORTING`J' == "C"
replace reporting`J' = "anzianità" if REPORTING`J' == "D"
replace reporting`J' = "disturbi alimentari" if REPORTING`J' == "E"
replace reporting`J' = "malattia invalidante" if REPORTING`J' == "F"
replace reporting`J' = "ludopatia" if REPORTING`J' == "G"
replace reporting`J' = "handicap" if REPORTING`J' == "H"
replace reporting`J' = "immigrazione" if REPORTING`J' == "I"
replace reporting`J' = "lutto" if REPORTING`J' == "J"
replace reporting`J' = "malattia psichica" if REPORTING`J' == "K"
replace reporting`J' = "malattia terminale" if REPORTING`J' == "L"
replace reporting`J' = "omosessualità" if REPORTING`J' == "M"
replace reporting`J' = "pedofilia" if REPORTING`J' == "N"
replace reporting`J' = "problemi economici e lavorativi" if REPORTING`J' == "O"
replace reporting`J' = "telefonata incompiuta per caduta linea" if REPORTING`J' == "P"
replace reporting`J' = "prostituzione" if REPORTING`J' == "Q"
replace reporting`J' = "separazione/divorzio" if REPORTING`J' == "R"
replace reporting`J' = "suicidio" if REPORTING`J' == "S"
replace reporting`J' = "usura/estorsione" if REPORTING`J' == "T"
replace reporting`J' = "immagine del T.A." if REPORTING`J' == "V"
replace reporting`J' = "violenza, fisica/psicologica, stalking, mobbing" if REPORTING`J' == "U"
replace reporting`J' = "incesto" if REPORTING`J' == "W"
replace reporting`J' = "transessualità" if REPORTING`J' == "Z"
replace reporting`J' = "Internet e social network" if REPORTING`J' == "X"
replace reporting`J' = "parafilie" if REPORTING`J' == "Y"
}

	
	
gen grief = 0 if reporting1 != ""
gen violence = 0 if reporting1 != ""
gen addiction = 0 if reporting1 != ""


forvalues J=1/3 {
replace grief = 1 if reporting`J' == "lutto"
replace violence = 1 if substr(reporting`J',1,8) == "violenza"
replace addiction = 1 if reporting`J'  == "dipendenza sostanze"
replace suicide = 1 if reporting`J'  == "suicidio"
	
}	

// latabstat centercode, statistics(count) by(center)

gen country = "Italy"
		
gen population = 60.36



keep ddate center region phone chat duration female male agegroup agemin agemax age suicide retired education living_* physhealth-population 
drop reporting1 reporting2 reporting3

gen helplinename = "Telefono Amico"


save `"$rawdata\Countries\Italy\ITAcontacts.dta"',  replace








use `"$rawdata\Countries\Italy\ITAcontacts.dta"',  clear





bysort ddate: gen helplinecontactsITA = _N
foreach V in  male female suicide retired educ age1 age2 age3 age4 age5 age6 age7 age8 age9  living_alone living_partner living_family living_other $topicsITA {
bysort ddate: egen contacts_`V'ITA = sum(`V' == 1)
}
foreach V in $centerlist {
bysort ddate: egen contacts_`V' = sum(`V' == 1)
}
foreach V of numlist 1 2 3 4 5 {
bysort ddate: egen contacts_`V' = sum(regioncode == `V')
}

bysort ddate: keep if _n == 1
keep helplinecontactsITA contacts_* ddate

gen country = "Italy"
		
gen population = 60.36




gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020
gen daily19 = ddate - mdy(1,1,2019) + 1 if year(ddate) == 2019



gen zero = 0
gen c2 = contacts_age1ITA + contacts_age2ITA
gen c3 = c2 + contacts_age3ITA
gen c4 = c3 + contacts_age4ITA
gen c5 = c4 + contacts_age5ITA
gen c6 = c5  + contacts_age6ITA
gen c7 = c6  + contacts_age7ITA
gen c8 = c7  + contacts_age8ITA
gen c9 = c8  + contacts_age9ITA



tsset ddate
foreach V of varlist helplinecontactsITA c2 c3 c4 c5 c6 c7 c8 c9 contacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}

 // mentalhealth physhealth lonely depressed sentimental relations sex family partner
# delimit ;
twoway scatter contacts_familyITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_familyITA  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| scatter contacts_mentalhealthITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_mentalhealthITA  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| scatter contacts_lonelyITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_lonelyITA  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| scatter contacts_physhealthITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_physhealthITA  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	|| scatter contacts_partnerITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb2)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_partnerITA  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
		scheme(s2color) legend( label(1 "")  label(2 "Family") label(4 "Mental health") label(6 "Loneliness") label(8 "Physical health") label(10 "Partner")  
			order(2 4 6 8 10 )  cols(1) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" , labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 );
# delimit cr
graph export ".\02_Project\Figures\contacts_topics_ITA.pdf", replace



 // mentalhealth physhealth lonely depressed sentimental relations sex family partner health
# delimit ;
twoway scatter contacts_healthITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_healthITA  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| scatter contacts_econfinITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_econfinITA  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| scatter contacts_relationsITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_relationsITA  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| scatter contacts_sexITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_sexITA  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
		scheme(s2color) legend( label(1 "")  label(2 "Health") label(4 "Work and financials") label(6 "Relationhships") label(8 "Sex") 
			order(2 4 6 8)  cols(1) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" , labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152);
# delimit cr
graph export ".\02_Project\Figures\contacts_topics2_ITA.pdf", replace











# delimit ;
twoway rbar zero contacts_age1ITA daily20  if year(ddate) == 2020 , bcolor(ebblue*0.1)  yaxis(1)  
	|| rbar contacts_age1ITA c2 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.4)  yaxis(1)  
	|| rbar c2 c3 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.6)  yaxis(1)  
	|| rbar c3 c4  daily20  if year(ddate) == 2020 , bcolor(ebblue*0.8)  yaxis(1)  
	|| rbar c4 c5  daily20  if year(ddate) == 2020 , bcolor(ebblue*1)  yaxis(1)  
	|| rbar c5 c6  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.2)  yaxis(1)  
	|| rbar c6 c7  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.4)  yaxis(1)  
	|| rbar c7 c8  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.6)  yaxis(1)  
	|| rbar c8 c9  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.8)  yaxis(1)  
		scheme(s2color)  legend(label(1 "-14") label(2 "15-18") label(3 "19-25") label(4 "26-35") 
			label(5 "36-45") label(6 "46-55") label(7 "56-65") label(8 "66-75") label(9 "75+")
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121)
		name(age1, replace);
		
twoway line MA7contacts_age1ITA daily20  if year(ddate) == 2020 ,  lcolor(plb1)  yaxis(1)  
	|| line MA7contacts_age2ITA daily20  if year(ddate) == 2020 ,  lcolor(plg1)  yaxis(1)  
	|| line MA7contacts_age3ITA daily20  if year(ddate) == 2020 ,  lcolor(ply1)  yaxis(1)  
	|| line MA7contacts_age4ITA  daily20  if year(ddate) == 2020 , lcolor(pll1)  yaxis(1)  
	|| line MA7contacts_age5ITA  daily20  if year(ddate) == 2020 , lcolor(plb2) yaxis(1)  
	|| line MA7contacts_age6ITA  daily20  if year(ddate) == 2020 , lcolor(plg2)  yaxis(1)  
	|| line MA7contacts_age7ITA  daily20  if year(ddate) == 2020 , lcolor(ply2)  yaxis(1)  
	|| line MA7contacts_age8ITA  daily20  if year(ddate) == 2020 , lcolor(pll2)  yaxis(1)  
	|| line MA7contacts_age9ITA  daily20  if year(ddate) == 2020 , lcolor(plb3)  yaxis(1)  
		scheme(s2color) legend(label(1 "-14") label(2 "15-18") label(3 "19-25") label(4 "26-35") 
			label(5 "36-45") label(6 "46-55") label(7 "56-65") label(8 "66-75") label(9 "75+")
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121)
		name(age2, replace);
# delimit cr

// graph combine age1 age2, cols(1)

graph export ".\02_Project\Figures\ageofcontacts_ITA.pdf", replace







# delimit ;   
twoway scatter contacts_living_aloneITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_living_aloneITA  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| scatter contacts_living_partnerITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_living_partnerITA  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| scatter contacts_living_familyITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_living_familyITA  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| scatter contacts_living_otherITA daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_living_otherITA  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	legend( label(1 "")  label(2 "Alone") label(4 "With partner")  label(6 "With family")  label(8 "Other")  
			order(2 4 6 8)  cols(2) pos(6) ring(1) colfirst colgap(0) size(small)  region(lcolor(white))) 
		scheme(s2color) graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152);
# delimit cr
graph export ".\02_Project\Figures\contacts_livingsit_ITA.pdf", replace






use `"$rawdata\Countries\Italy\ITAcontactsFULL.dta"',  clear




bysort region ddate: gen ccontacts = _N
foreach V in  male female suicide retired educ age1 age2 age3 age4 age5 age6 age7 age8 age9  living_alone living_partner living_family living_other {
bysort region ddate: egen ccontacts_`V' = sum(`V' == 1)
}
foreach V of numlist 1 2 3 4 5 {
bysort ddate: egen contacts_reg`V' = sum(regioncode == `V')
}


collapse (firstnm) ccontacts ccontacts_* region, by(regioncode ddate)

xtset regioncode ddate

tsfill
foreach V of varlist ccontacts ccontacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}
gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020


sum ccontacts_*

# delimit ;
twoway line MA7ccontacts daily20  if year(ddate) == 2020 & region ==   "North west" ,		   lcolor(plb1)  yaxis(1)  
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & region ==   "North east" ,		   lcolor(plg1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & region ==   "Center" 	,		   lcolor(ply1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & region ==   "South and Islands" ,  lcolor(pll1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & region ==   "Foreign" 	,		   lcolor(gs10)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & region ==   "Not detected" 	,		lpattern(dash)   lcolor(gs10)  yaxis(2) 
	legend(label(1 "North West"	)
		   label(2 "North East" ) 
		   label(3 "Center"     ) 
		   label(4 "South and Islands" )
		   label(5  "Foreign"      )
		   label(6  "Not detected (right axis)"      )
		   pos(11) ring(0) cols(1) region(lcolor(white)) size(small)) 
	scheme(s2color) graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
	ytitle("", xoffset(-1) axis(1)) 
	ytitle("", xoffset(-1) axis(2)) 
	xtitle("", yoffset(-2)) 
	xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May", labsize(small) labcolor(gs0) notick) 
	xtick(0 31 60 91 121);
# delimit cr
graph export ".\02_Project\Figures\Regional_contacts_ITA.pdf", replace














use `"$rawdata\Countries\Italy\ITAcontactsFULL.dta"',  clear





bysort region: tab center 





// CEnter level:

bysort center ddate: gen ccontacts = _N
foreach V in  male female suicide retired educ age1 age2 age3 age4 age5 age6 age7 age8 age9  living_alone living_partner living_family living_other {
bysort center ddate: egen ccontacts_`V' = sum(`V' == 1)
}

foreach V in $centerlist {
bysort center ddate: egen ccontacts_`V' = sum(`V' == 1)
}

collapse (firstnm) ccontacts ccontacts_* center region regioncode, by(centercode ddate)




xtset centercode ddate


tsfill
foreach V of varlist ccontacts ccontacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}
gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020


sum ccontacts_BOLZANO ccontacts_NAPOLI ccontacts_MODENA ccontacts_PARMA ccontacts_ROMA ccontacts_BERGAMO ccontacts_BRESCIA ccontacts_MANTOVA ccontacts_BUSTOARSIZIO ccontacts_MILANO ccontacts_NAZIONALE ccontacts_SASSARI ccontacts_PALERMO ccontacts_PRATO ccontacts_TRENTO ccontacts_PADOVA ccontacts_VENEZIA ccontacts_VICENZA ccontacts_BASSANO ccontacts_TREVISO ccontacts_UDINE
// BOLZANO NAPOLI MODENA PARMA ROMA BERGAMO BRESCIA MANTOVA BUSTOARSIZIO MILANO NAZIONALE SASSARI PALERMO PRATO TRENTO PADOVA VENEZIA VICENZA BASSANO TREVISO UDINE

# delimit ;
twoway line MA7ccontacts daily20  if year(ddate) == 2020 & center == "BOLZANO" , 		lcolor(plb1)  yaxis(1)  
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "NAPOLI"  , 		lcolor(plg1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "MODENA"	,		lcolor(ply1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "PARMA"	,		lcolor(pll1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "ROMA"		,		lcolor(plb2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "BERGAMO"	,		lcolor(plg2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "BRESCIA"	    ,   lcolor(ply2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "MANTOVA"	    ,   lcolor(pll2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "BUSTOARSIZIO"	,   lcolor(plb3)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "MILANO"	    ,   lcolor(plg3)  yaxis(1) 
	legend(label(1 "BOLZANO")
		   label(2 "NAPOLI" )
		   label(3 "MODENA")
		   label(4 "PARMA"	 )
		   label(5 "ROMA"	)	
		   label(6 "BERGAMO")
		   label(7 "BRESCIA") 
		   label(8 "MANTOVA"	   ) 
		   label(9 "BUSTOARSIZIO") 
		   label(10 "MILANO"	   ) 
		   pos(6) ring(1) cols(4) colfirst region(lcolor(white))) 
	scheme(s2color) graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
	ytitle("", xoffset(-1) axis(1)) 
	xtitle("", yoffset(-2)) 
	xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May", labsize(small) labcolor(gs0) notick) 
	xtick(0 31 60 91 121) name(gr1, replace);
# delimit cr
# delimit ;
twoway line MA7ccontacts daily20  if year(ddate) == 2020 & center == "SASSARI"     ,  lcolor(plb1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "PALERMO"     ,  lcolor(plg1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "PRATO"	     ,lcolor(ply1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "TRENTO"	     ,lcolor(pll1)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "PADOVA"	     ,lcolor(plb2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "VENEZIA"	     ,lcolor(plg2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "VICENZA"     ,  lcolor(ply2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "BASSANO"     ,  lcolor(pll2)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "TREVISO"     ,  lcolor(plb3)  yaxis(1) 
	|| line MA7ccontacts daily20  if year(ddate) == 2020 & center == "UDINE"	     ,lcolor(plg3)  yaxis(1) 
	legend(label( 1  "SASSARI"    ) 
		   label(2  "PALERMO"    ) 
		   label(3  "PRATO"	   ) 
		   label(4  "TRENTO"	   ) 
		   label(5  "PADOVA"	   ) 
		   label(6  "VENEZIA"	   ) 
		   label(7  "VICENZA"    ) 
		   label(8  "BASSANO"    ) 
		   label(9  "TREVISO"    ) 
		   label(10 "UDINE"	   ) 
		   pos(6) ring(1) cols(4) colfirst region(lcolor(white))) 
	scheme(s2color) graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
	ytitle("", xoffset(-1) axis(1)) 
	xtitle("", yoffset(-2)) 
	xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May", labsize(small) labcolor(gs0) notick) 
	xtick(0 31 60 91 121) name(gr2, replace);
# delimit cr
		
graph combine gr1 gr2, cols(1) ycommon 


graph export ".\02_Project\Figures\Regional_ccontacts_ITA.pdf", replace




 


















