// jourappel heuredébutappel heurefinappel duréeappel sexeappelant trancheage typecommunication situation01 situation1code situation02 situation2code situation03 situation3code



import delimited "$rawdata\Countries\France\RawData2021-01-03.csv",  clear delimiter(";") encoding(utf8)
rename v1 jourappel 
rename v2 heuredébutappel 
rename v3 heurefinappel 
rename v4 duréeappel 
rename v5 sexeappelant 
rename v6 trancheage 
rename v7 typecommunication 
rename v8 situation01 
rename v9 situation1code 
rename v10 situation02 
rename v11 situation2code 
rename v12 situation03 
rename v13 situation3code
save "$rawdata\Countries\France\RawData2021-01-03.dta", replace

import delimited "$rawdata\Countries\France\nov-dec2020.csv",  clear delimiter(";") encoding(utf8)
save "$rawdata\Countries\France\nov-dec2020.dta", replace

import delimited "$rawdata\Countries\France\AppelsSosa20192020.csv",  clear delimiter(";") encoding(utf8)
// import delimited ".\03_Data\Countries\France\RawData-SosAmitie-2019-2020.csv",  clear delimiter(";") encoding(utf8)

append using "$rawdata\Countries\France\nov-dec2020.dta"
append using "$rawdata\Countries\France\RawData2021-01-03.dta"
erase "$rawdata\Countries\France\nov-dec2020.dta"
erase "$rawdata\Countries\France\RawData2021-01-03.dta"

gen ddate = date(jourappel, "DMY")
format ddate %td
sort ddate

gen startdatetime = jourappel + "  " + heuredébutappel // substr(heuredébutappel,4,5)
gen enddatetime = jourappel + "  " + heurefinappel // substr(heuredébutappel,4,5)

gen double starttime = clock(startdatetime, "DMYhms")
format starttime %tC
gen double endtime = clock(enddatetime, "DMYhms")
format endtime %tc

gen hour = hh(starttime)


gen female = 0 if sexeappelant == "Homme"
replace female = 1 if sexeappelant == "Femme"
gen male = 0 if sexeappelant == "Femme"
replace male = 1 if sexeappelant == "Homme"

gen agegroup = trancheage
replace agegroup = "" if agegroup == "Non déterminé"
gen agemin =0  if agegroup == "0 à 14"
replace  agemin = 15 if agegroup == "15 à 24" 
replace  agemin = 25 if agegroup == "25 à 44"
replace  agemin = 45 if agegroup == "45 à 64"
replace  agemin = 65 if agegroup == "65 et plus"
gen agemax = 1  if agegroup == "0 à 14"
replace  agemax = 24 if agegroup == "15 à 24" 
replace  agemax = 44 if agegroup == "25 à 44"
replace  agemax = 64 if agegroup == "45 à 64"
replace  agemax = 100 if agegroup == "65 et plus"
gen age = (agemin+agemax)/2


gen phone = 0 if typecommunication != ""
replace phone = 1 if typecommunication == "téléphone"
gen chat = 0 if typecommunication != ""
replace chat = 1 if typecommunication == "chat"
replace chat = 1 if typecommunication == "messagerie"


gen suicide = 0 
gen lonely = 0 
gen addiction = 0
gen violence = 0 
gen fears = 0
gen physhealth = 0
gen sex = 0
gen unempl = 0
gen relationships = 0
gen depressed = 0
gen fininher = 0
gen livepartner = 0
gen housing = 0
gen grief = 0
gen dailyrout =0
gen separat = 0
gen worksit = 0
gen othermentalhealth = 0
gen panic = 0


forvalues J= 1/3 {
replace suicide = 1 if situation0`J' == "Suicidaire" | situation0`J' == "Suicidant" | substr(situation0`J',1,19) == "Conduite suicidaire"

replace lonely = 1 if situation0`J' == "Sentiment de solitude" | situation0`J' == "Autre (Solitude)" | situation0`J' == "Isolement social"

replace addiction = 1 if situation0`J' == "Poly addiction" | situation0`J' == "Alcool"  | situation0`J' == "Drogue" | situation0`J' == "Autre (Addiction)"| situation0`J' == "Tabac"

replace violence = 1 if situation0`J' == "Viol" | situation0`J' == "Autre (Violence)"  | situation0`J' == "Maltraitance" | situation0`J' == "Autre (Abus sexuel)" | situation0`J' == "Harcèlement sexuel" | situation0`J' == "Harcèlement, exclusion" | situation0`J' == "Harcèlement"

replace relationships = 1 if situation0`J' == "Relations parents enfants" | situation0`J' == "Conflit entre personnes" | situation0`J' == "Fratrie" | situation0`J' == "Curatelle, tutelle" | situation0`J' == "Voisinage" | situation0`J' == "Relations parents enfants" | situation0`J' == "Famille recomposée" | situation0`J' == "Familiale" | situation0`J' == "Autre (difficulté de relation)" |  situation0`J' == "Couple" | situation0`J' == "Conjugale"  | situation0`J' == "Problèmes sentimentaux" |  situation0`J' == "Divorce Séparation"

replace livepartner = 1 if situation0`J' == "Couple" | situation0`J' == "Conjugale"  | situation0`J' == "Problèmes sentimentaux" 

replace separat = 1 if situation0`J' == "Divorce Séparation"


replace depressed = 1 if situation0`J' == "Dépression, burn out"

replace physhealth = 1 if situation0`J' == "Physique" | situation0`J' == "Handicap physique" | situation0`J' == "Autre (Physique)" | situation0`J' == "Longue maladie" | situation0`J' == "Maladie"


replace panic = 1 if situation0`J' == "Crise Angoisse" 

replace fears = 1 if situation0`J' == "Peur Anxiété" | situation0`J' == "Peur de la mort" | panic == 1 

replace unempl = 1 if situation0`J' == "Chômage"

replace worksit = 1 if situation0`J' == "Autre (travail)" | situation0`J' == "Emploi protégé" | situation0`J' == "Emploi précaire"

replace housing = 1 if situation0`J' == "Sans logement" | situation0`J' == "Mal logé" | situation0`J' == "Autre (logement)"

replace fininher = 1 if situation0`J' == "Autres (finances)" | situation0`J' == "Surendettement"

replace grief = 1 if situation0`J' == "Deuil" | situation0`J' == "Autre deuil"

replace dailyrout = 1 if situation0`J' == "Vie courante"


replace othermentalhealth = 1 if  situation0`J' == "Autre (santé psychique)" | situation0`J' == "Suivi Psy" | situation0`J' == "Pathologie psy annoncée" | situation0`J' == "Traumatisme accidentel" | situation0`J' == "Trouble du sommeil"  | situation0`J' == "Trouble de la sexualité"  | situation0`J' == "Stress" 

}

// tab situation01, m
// tab situation02, m
// tab situation03, m



gen country = "France"
gen population = 66.99		

gen helplinename = "S.O.S. Amitié"

keep ddate - helplinename

gen T_mentalh =0
replace T_mentalh = 1 if depressed == 1
replace T_mentalh = 1 if lonely == 1
replace T_mentalh = 1 if suicide == 1
replace T_mentalh = 1 if addiction == 1
replace T_mentalh = 1 if fears == 1
replace T_mentalh = 1 if othermentalhealth == 1
replace T_mentalh = 1 if grief == 1


gen T_social =0
replace T_social = 1 if relationships == 1


gen T_econ = 0
replace T_econ = 1 if unempl == 1
replace T_econ = 1 if worksit == 1
replace T_econ = 1 if fininher == 1
replace T_econ = 1 if housing == 1


save `"$rawdata\Countries\France\FRAcontacts.dta"',  replace


use `"$rawdata\Countries\France\FRAcontacts.dta"',  clear




// tab agegroup, gen(agec)


// foreach V in agec1 agec2 agec3 agec4 agec5 {
// bysort ddate: egen contacts_`V' = sum(`V' == 1)
// }
// bysort ddate: gen helplinecontacts = _N

// bysort ddate: keep if _n == 1
// keep ddate helplinecontacts contacts_age*


// tsset ddate
// tsfill

    


// gen zero = 0
// gen c2 = contacts_agec1
// gen c3 = c2  + contacts_agec2
// gen c4 = c3  + contacts_agec3
// gen c5 = c4  + contacts_agec4 
// gen c6 = c5  + contacts_agec5 



// gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020
// gen daily19 = ddate - mdy(1,1,2019) + 1 if year(ddate) == 2019

// foreach V of varlist helplinecontacts contacts_* {
// mvsumm `V', gen(MA7`V') stat(mean) window(7) force
// }

// keep if month(ddate)<7

// # delimit ;
// twoway rbar zero c2 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.4)  yaxis(1)  
	// || rbar c2 c3 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.6)  yaxis(1)  
	// || rbar c3 c4  daily20  if year(ddate) == 2020 , bcolor(ebblue*0.8)  yaxis(1)  
	// || rbar c4 c5  daily20  if year(ddate) == 2020 , bcolor(ebblue*1)  yaxis(1)  
	// || rbar c5 c6  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.2)  yaxis(1)
		// scheme(s2color) legend(label(1 "-14") label(2 "15-24") label(3 "25-44") label(4 "45-64") 
			// label(5 "65+") 
			// pos(2) ring(1)  cols(1) order(5 4 3 2 1) region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		// ytitle("", xoffset(-1) axis(1)) 
		// xtitle("", yoffset(-2)) 
		// xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		// xtick(0 31 60 91 121 152)
		// name(age1, replace);
// # delimit cr

// # delimit ;
// twoway line contacts_agec1 daily20  if year(ddate) == 2020 ,  lcolor(plb1)  yaxis(1)  
	// || line contacts_agec2 daily20  if year(ddate) == 2020 ,  lcolor(plg1)  yaxis(1)  
	// || line contacts_agec3  daily20  if year(ddate) == 2020 ,  lcolor(ply1)  yaxis(1)  
	// || line contacts_agec4  daily20  if year(ddate) == 2020 , lcolor(pll1)  yaxis(1)  
	// || line contacts_agec5  daily20  if year(ddate) == 2020 , lcolor(plb2) yaxis(1)  
		// scheme(s2color) legend(label(1 "-14") label(2 "15-24") label(3 "25-44") label(4 "45-64") 
			// label(5 "65+") 
			// pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		// ytitle("", xoffset(-1) axis(1)) 
		// xtitle("", yoffset(-2)) 
		// xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		// xtick(0 31 60 91 121 152)
		// name(age2, replace);
// # delimit cr

// graph combine age1 age2, cols(1)

// graph export ".\02_Project\Figures\ageofcontacts_FRA.pdf", replace













