


//////////////////////////////
*	The dedicated Corona line became active 16th of April 2020

import excel "$rawdata\Countries\Netherlands\De Luisterlijn (The Netherlands) - Stephanie\Phone\Dedicated Corona line\20200416-20200630 Dedicated Corona Phone Line.xlsx",  firstrow clear

gen ddate = date
format ddate %td
gen hour = hh(time)
rename age agegroup

gen agemin = substr(agegroup,1,2)
replace agemin = "0" if agegroup == "tot 25 jaar"
replace agemin = "" if agegroup == "onbekend"
gen agemax = "45" if agegroup == "25 tot 45 jaar"
replace agemax = "65" if agegroup == "45 tot 65 jaar"
replace agemax = "100" if agegroup == "65 jaar en ouder"
destring agemin agemax, replace


replace agegroup = ""
replace agegroup = "24 or younger" if agegroup == "tot 25 jaar" 
replace agegroup = "25 - 45" if agegroup == "25 tot 45 jaar" 
replace agegroup = "45 - 65" if  agegroup == "45 tot 65 jaar"
replace agegroup = "66 or older" if  agegroup == "65 jaar en ouder"
replace agegroup = ""  if agegroup == "onbekend"

egen age = rowmean(agemin agemax)

gen feellonely = 0 
gen feelafraid = 0 
gen feelworried = 0
gen feelcalm	= 0
gen feelpanic	= 0
gen feelsad		= 0
gen feelstressed	= 0

replace feeling = "" if feeling == "Overig/weet ik niet"

replace feellonely  = 1 if feeling == "Alleen voelen"
replace feelafraid  = 1 if feeling == "Bang"
replace feelworried  = 1 if feeling == "Bezorgd"
replace feelcalm	 = 1 if feeling == "Kalm"
replace feelpanic	 = 1 if feeling == "Paniek"
replace feelstressed = 1 if feeling == "Stress"
replace feelsad		 = 1 if feeling == "Verdrietig/somber"


replace levelofloneliness = "" if levelofloneliness == "Overig/weet ik niet"
encode levelofloneliness, gen(lonelineslevel)
replace reasonforcontact = "" if reasonforcontact == "Overig/weet ik niet"
encode reasonforcontact, gen(callreason)


gen fears = 0  if feeling != ""
replace fears = 1 if feelafraid == 1
// replace fears = 1 if feelworried == 1
replace fears = 1 if feelpanic == 1

gen lonely = 0 if feeling != ""
replace lonely = 1 if feellonely == 1 



rename duration excelduration
gen duration = round((excelduration - mdyhms(12,31,1899,0,0,0))/(60*1000) )


keep agegroup ddate hour duration agemin agemax age feellonely feelafraid feelworried feelcalm feelpanic feelsad feelstressed lonelineslevel callreason lonely fears

gen country = "Netherlands"
gen population = 17.28		//17.28 million (2019)

gen helplinesubname = "De Luisterlijn - dedicated Corona Helpline"

gen coronacall = 1

save `"$rawdata\Countries\Netherlands\NELCORONAcontacts.dta"',  replace




//////////////////////////////
* General helpline:

* combine chats and phone contacts:
import excel "$rawdata\Countries\Netherlands\De Luisterlijn (The Netherlands) - Stephanie\Chat\20190101-20200630 Chats.xlsx",  firstrow clear
gen chat = 1
save `"$rawdata\Countries\Netherlands\Chats.dta"', replace

import excel "$rawdata\Countries\Netherlands\De Luisterlijn (The Netherlands) - Stephanie\Phone\Regular Help line\20190101-20200630 Regular Help Line.xlsx",  firstrow clear 

gen chat = 0
append using `"$rawdata\Countries\Netherlands\Chats.dta"'
erase `"$rawdata\Countries\Netherlands\Chats.dta"'


gen phone = 1-chat

gen ddate = date
format ddate %td


*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*	Contact characteristics:
gen female = 1 if sex == "Vrouw"
replace female = 0 if sex == "Man"
gen male = 1 if sex == "Man"
replace male = 0 if sex == "Vrouw"

*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*	situation, feeling, subjects discussed:
gen situation = situation_of_the_caller
replace situation = subinstr(situation,"Geen van de onderstaande situaties / weet ik niet","",.)
replace situation = subinstr(situation,"Cliënt van GGZ","",.)
replace situation = subinstr(situation,"Ex-cliënt van GGZ","",.)
replace situation = substr(situation,3,.) if substr(situation,1,2) == ", " 
tab situation
// split situation, p(",")
// tab situation1 
// tab situation2 
// tab situation6 

replace situation = "" if situation == "-"
replace situation = "" if situation == ", "


gen living_alone = 0 if situation != "" 
replace living_alone = 1 if regexm(situation,"Alleenwonend") == 1 

gen education = 0 if situation != "" 
replace education = 1 if regexm(situation,"Student") == 1 


// tab feeling
replace feeling = subinstr(feeling," /","/",.)
replace feeling = subinstr(feeling,"/ ","/",.)
replace feeling = subinstr(feeling,", ",",",.)
replace feeling = subinstr(feeling,"Geïrriteerd","Geirriteerd",.)
replace feeling = subinstr(feeling,"GeÃ¯rriteerd","Geirriteerd",.)
split feeling, p(",")
tab feeling1
tab feeling2

gen feellonely = 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelafraid = 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelworried = 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelangry	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelfrust	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelcalm	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelpanic	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelshame	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelguilt	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelsad		= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelstressed	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"
gen feelhappy	= 0 if feeling1 != "" & feeling1 != "Overig/weet ik niet"

forvalues J = 1/14  {
tostring feeling`J', replace
replace feellonely  = 1 if feeling`J' == "Alleen voelen"
replace feelafraid  = 1 if feeling`J' == "Bang"
replace feelworried  = 1 if feeling`J' == "Bezorgd"
replace feelangry	 = 1 if feeling`J' == "Boos"
replace feelfrust	 = 1 if feeling`J' == "Geirriteerd/gefrustreerd"
replace feelcalm	 = 1 if feeling`J' == "Kalm"
replace feelpanic	 = 1 if feeling`J' == "Paniek"
replace feelshame	 = 1 if feeling`J' == "Schaamte"
replace feelguilt	 = 1 if feeling`J' == "Schuldgevoel"
replace feelstressed = 1 if feeling`J' == "Stress"
replace feelsad		 = 1 if feeling`J' == "Verdrietig/somber"
replace feelhappy		 = 1 if feeling`J' == "Blij/gelukkig"
}                                        
//  Verveeld

gen fears = 0 if (feeling1 != "" & feeling1 != "Overig/weet ik niet")
replace fears = 1 if feelafraid == 1
replace fears = 1 if feelworried == 1
replace fears = 1 if feelpanic == 1



gen lonely = 0 if situation != "" 
replace lonely = 1 if regexm(situation,"Eenzaam") == 1 
// gen lonely = 0 if (feeling1 != "" & feeling1 != "Overig/weet ik niet")
// replace lonely = 1 if feellonely == 1 


// tab subjects_discussed 
replace subjects_discussed = "" if subjects_discussed == "-"
replace subjects_discussed = "" if subjects_discussed == "Overig / weet ik niet"
replace subjects_discussed = "" if subjects_discussed == "Overig/ weet ik niet"
gen topics = regexr(subjects_discussed, "\((.)+\)", "") 
replace topics = trim(topics)
split topics , p(",")
// forvalues J = 1/14  {
forvalues J = 1/2 {
replace topics`J' = trim(topics`J')
}
// tab topics1
tab topics2
// tab topics5

gen suicide = 0 if subjects_discussed != ""
replace suicide = 1 if regexm(subjects_discussed,"Zelfmoord") == 1

gen mentalhealth = 0
replace mentalhealth = 1 if regexm(subjects_discussed,"Geestelijke gezondheid") == 1
replace mentalhealth = 1 if regexm(subjects_discussed,"Omgaan met psychiatrisch ziektebeeld") == 1

gen physhealth = 0
replace physhealth = 1 if regexm(subjects_discussed,"Lichamelijke gezondheid") == 1

gen coronacall = 0
replace coronacall = 1  if regexm(subjects_discussed,"Corona") == 1

gen addiction = 0
replace addiction = 1 if regexm(subjects_discussed,"Verslaving") == 1

gen violence = 0
replace violence = 1 if regexm(subjects_discussed,"Huiselijk geweld") == 1
replace violence = 1 if regexm(subjects_discussed,"Geweld & veiligheid") == 1
replace violence = 1 if regexm(subjects_discussed,"Seksueel misbruik") == 1
replace violence = 1 if regexm(subjects_discussed,"Ouderenmishandeling") == 1		// elder abuse
replace violence = 1 if regexm(subjects_discussed,"Pesten") == 1			// bullying
replace violence = 1 if regexm(subjects_discussed,"Verwaarlozing") == 1			// neglect

gen parenting = 0
replace parenting = 1 if regexm(subjects_discussed,"Opvoeding van kind") == 1

gen grief = 0
replace grief = 1 if regexm(subjects_discussed,"Rouw of verlies") == 1

gen belief = 0
replace belief = 1 if regexm(subjects_discussed,"Geloof") == 1

gen worksit = 0 
replace worksit = 1 if regexm(subjects_discussed,"Werk") == 1 & regexm(subjects_discussed,"Werkloosheid") != 1

gen unempl = 0 
replace unempl = 1 if regexm(subjects_discussed,"Werkloosheid") ==1

gen dailyrout = 0 
replace dailyrout = 1 if regexm(subjects_discussed,"Invulling van de dag") == 1 

gen fininher 	= 0 
replace fininher = 1 if regexm(subjects_discussed,"Financ") == 1 

gen housing		= 0
replace housing = 1 if regexm(subjects_discussed,"Huisvesting") == 1 

gen relationships	= 0
replace relationships = 1 if regexm(subjects_discussed,"Relaties") == 1 
replace relationships = 1 if regexm(subjects_discussed,"Burenoverlast/-ruzie") == 1 

gen selfharm	= 0
replace selfharm = 1 if regexm(subjects_discussed,"Zelfbeschadiging") == 1 

gen soccult	= 0
replace soccult = 1 if regexm(subjects_discussed,"Maatschappij & politiek") == 1 
replace soccult = 1 if regexm(subjects_discussed,"Actualiteit") == 1 
replace soccult = 1 if regexm(subjects_discussed,"Extremisme & radicalisering") == 1 
replace soccult = 1 if regexm(subjects_discussed,"Toekomst") == 1 
replace soccult = 1 if regexm(subjects_discussed,"nieuws & media") == 1 
replace soccult = 1 if regexm(subjects_discussed,"spiritualiteit en levensvragen") == 1 


tab results


gen agegroup = ""
replace agegroup = "24 or younger" if age == "Tot 25 jaar" 
replace agegroup = "25 - 45" if age == "25-45" 
replace agegroup = "45 - 65" if age == "45-65" 
replace agegroup = "66 or older" if age == "65+" 
// encode agegroup, gen(agecode)

global topicsNEL "suicide mentalhealth physhealth"
global feelingsNEL "feellonely feelafraid feelworried feelangry feelfrust feelcalm feelpanic feelshame feelguilt feelsad feelstressed feelhappy"



gen country = "Netherlands"
gen population = 17.28		//17.28 million (2019)




replace duration = duration/60


gen agemin = substr(agegroup,1,2)
replace agemin = "0" if substr(agegroup,-11,11) == " or younger"
gen agemax = subinstr(agegroup," or older","",.)
replace agemax = substr(agemax,-2,2)
replace agemax = substr(agegroup,1,2) if substr(agegroup,-11,11) == " or younger"
replace agemax = "100" if substr(agegroup,-9,9) == " or older" | agegroup == "90+"
destring agemin agemax, replace

rename age agestring

egen age = rowmean(agemin agemax)

gen helplinesubname = "De Luisterlijn"

append using `"$rawdata\Countries\Netherlands\NELCORONAcontacts.dta"'




keep ddate duration hour chat phone female male lonely fears living_alone feellonely-feelhappy suicide-agegroup country-helplinesubname
cap drop lonelineslevel callreason

gen T_econ = 0
replace T_econ = 1 if unempl == 1
replace T_econ = 1 if worksit == 1
replace T_econ = 1 if fininher == 1
replace T_econ = 1 if housing == 1

gen T_mentalh =0
replace T_mentalh = 1 if mentalhealth == 1
replace T_mentalh = 1 if fears == 1
replace T_mentalh = 1 if selfharm == 1


gen T_social =0
replace T_social = 1 if relationships == 1


gen helplinename = "De Luisterlijn"


save `"$rawdata\Countries\Netherlands\NELcontacts.dta"',  replace
/*







use `"$rawdata\Countries\Netherlands\NELcontacts.dta"',  clear









gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020
gen daily19 = ddate - mdy(1,1,2019) + 1 if year(ddate) == 2019


foreach V in male female  $feelingsNEL $topicsNEL {
bysort ddate: egen contacts_`V'NEL = sum(`V' == 1)
}

encode agegroup, gen(agecode)
forvalues J= 1/4 {
bysort ddate: egen contacts_age`J'NEL = sum(agecode == `J')
}


bysort ddate: gen helplinecontactsNEL = _N


bysort ddate: keep if _n == 1
keep helplinecontacts   ddate country population daily20 daily19 contacts_*




gen zero = 0
gen c2 = contacts_age1NEL + contacts_age2NEL
gen c3 = c2 + contacts_age3NEL
gen c4 = c3 + contacts_age4NEL

tsset daily20
foreach V of varlist c2 c3 c4 contacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}


# delimit ;
twoway rbar zero contacts_age1NEL daily20  if year(ddate) == 2020 , bcolor(ebblue*0.1)  yaxis(1)  
	|| rbar contacts_age1NEL c2 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.4)  yaxis(1)  
	|| rbar c2 c3 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.6)  yaxis(1)  
	|| rbar c3 c4  daily20  if year(ddate) == 2020 , bcolor(ebblue*0.8)  yaxis(1)  
		scheme(s2color) legend(label(1 "-25") label(2 "26-45") label(3 "46-65") label(4 "66+") 
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152)
		name(age1, replace);
# delimit cr

# delimit ;
twoway line MA7contacts_age1NEL daily20  if year(ddate) == 2020 ,  lcolor(plb1)  yaxis(1)  
	|| line MA7contacts_age2NEL daily20  if year(ddate) == 2020 ,  lcolor(plg1)  yaxis(1)  
	|| line MA7contacts_age3NEL daily20  if year(ddate) == 2020 ,  lcolor(ply1)  yaxis(1)  
	|| line MA7contacts_age4NEL  daily20  if year(ddate) == 2020 , lcolor(pll1)  yaxis(1)  
		scheme(s2color) legend(label(1 "-25") label(2 "26-45") label(3 "46-65") label(4 "66+") 
			pos(2) ring(1)  cols(1) order(4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152)
		name(age2, replace);
# delimit cr
graph export ".\02_Project\Figures\ageofcontacts_NEL.pdf", replace



graph combine age1 age2, cols(1)



   
   
# delimit ;
twoway scatter contacts_feellonelyNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feellonelyNEL  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelfrustNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelfrustNEL  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelsadNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelsadNEL  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
		scheme(s2color) legend(label(2 "Lonely") label(4 "Frustrated") label(6 "Sad")  cols(3) pos(6) ring(1) colfirst size(small) 
		order(2 4 6) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily calls", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) name(comb1, replace)
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr

# delimit ;
twoway scatter contacts_feelafraidNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelafraidNEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelworriedNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb2)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelworriedNEL  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelpanicNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg2)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelpanicNEL  daily20 if year(ddate) == 2020, lcolor(plg2) msize(medsmall) yaxis(1) 
		scheme(s2color) legend(label(2 "Afraid") label(4 "Worried") label(6 "Panic")  cols(3) pos(6) ring(1) colfirst size(small) 
		order(2 4 6 ) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily calls", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) name(comb2, replace)
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr


# delimit ;
twoway  scatter contacts_feelhappyNEL  daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply2)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelhappyNEL  daily20 if year(ddate) == 2020, lcolor(ply2) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelguiltNEL  daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll2)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelguiltNEL  daily20 if year(ddate) == 2020, lcolor(pll2) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelshameNEL  daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb3)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelshameNEL  daily20 if year(ddate) == 2020, lcolor(plb3) msize(medsmall) yaxis(1) 
		scheme(s2color) legend(label(2 "Happy") label(4 "Guilty") label(6 "Ashamed")  cols(3) pos(6) ring(1) colfirst size(small) 
		order(2 4 6) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily calls", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) name(comb3, replace)
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr

# delimit ;
twoway scatter contacts_feelangryNEL     daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll3)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelangryNEL     daily20 if year(ddate) == 2020, lcolor(pll3) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelstressedNEL  daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply3)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelstressedNEL  daily20 if year(ddate) == 2020, lcolor(ply3) msize(medsmall) yaxis(1) 
	|| scatter contacts_feelcalmNEL      daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plg3)	msize(vsmall) yaxis(1) 
	|| line MA7contacts_feelcalmNEL      daily20 if year(ddate) == 2020, lcolor(plg3) msize(medsmall) yaxis(1) 
		scheme(s2color) legend(label(2 "Angry") label(4 "Stressed") label(6 "Calm")  cols(3) pos(6) ring(1) colfirst size(small) 
		order(2 4 6) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily calls", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) name(comb4, replace)
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr


graph combine comb1 comb2 comb4 comb3 ///
	,  cols(2)  iscale(*0.8)  xcommon 

graph export ".\02_Project\Figures\contacts_feelings_NEL.pdf", replace


graph combine comb1 comb2  ///
	,  cols(2)  iscale(*0.8)  xcommon 

graph export ".\02_Project\Figures\contacts_feelings_NEL1.pdf", replace


graph combine comb4 comb3 ///
	,  cols(2)  iscale(*0.8)  xcommon 

graph export ".\02_Project\Figures\contacts_feelings_NEL2.pdf", replace




// # delimit ;
// ||     scatter contacts_feelangryNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_feelangryNEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1)
	// || scatter contacts_feelhappyNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll2)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_feelhappyNEL  daily20 if year(ddate) == 2020, lcolor(plg3) msize(medsmall) yaxis(1) 
	// || scatter contacts_feelguiltNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply3)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_feelguiltNEL  daily20 if year(ddate) == 2020, lcolor(ply3) msize(medsmall) yaxis(1) 
	// || scatter contacts_feelshameNEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll3)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_feelshameNEL  daily20 if year(ddate) == 2020, lcolor(pll3) msize(medsmall) yaxis(1) 
		// scheme(s2color) legend(  cols(3) pos(6) ring(1) colfirst colgap(0) size(small) 
		// order(2 4 6 8 10 12 14 16 18 20 22 24) region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("daily calls", xoffset(-1) axis(1) size(small)) 
		// title("",  size(medsmall) color(gs0)) 		
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		// yscale(titlegap(0)) 
		// xtitle("", yoffset(-2)) name(comb1, replace)
		// xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		// xtick(0 31 60 91 121 152 182);
// # delimit cr




