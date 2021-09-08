

// import excel "$rawdata\Countries\Belgium\Cijfers Tele-Onthaal Belgium (Flanders) 01.01.2019 - 10.06.2020.xlsx",  clear firstrow


import delimited "$rawdata\Countries\Belgium\registraties01012019-30062020.csv",  clear delim(",") encoding(utf-8)


gen ddate = date(van,"YMD")
format ddate %td

gen hour = substr(vanuur,1,2)
destring hour, replace


* drop last day, incmplete:
drop if ddate == mdy(6,29,2020)



gen female = 1 if geslachttitel == "Vrouw"
replace female = 0 if geslachttitel == "Man"
gen male = 1 if geslachttitel == "Man"
replace male = 0 if geslachttitel == "Vrouw"

replace male = . if geslachttitel == ""
replace female = . if geslachttitel == ""

// tab leeftijdtitel, m
gen agecat = leeftijdtitel
replace agecat = "" if leeftijdtitel == "Onbekend"
gen agecode = leeftijd
replace agecode = . if leeftijd == 0
replace agecode = . if leeftijd == 11


gen suicide = 0
gen addiction = 0
gen lonely = 0
gen physhealth = 0
gen sex = 0
gen relationships = 0
gen philosophy = 0
gen dailyrout = 0
gen violence = 0
gen grief = 0
gen soccult = 0
gen other = 0


foreach i in 1 2 3 {
replace suicide = 1 if gespreksthema`i'titel == "Zelfdoding" 
replace addiction = 1 if gespreksthema`i'titel == "Afhankelijkheid - Verslaving" 
replace lonely = 1 if gespreksthema`i'titel == "Eenzaamheid" 
replace physhealth = 1 if gespreksthema`i'titel == "Gezondheid" 
replace sex = 1 if gespreksthema`i'titel == "Seksualiteit" 
replace relationships = 1 if gespreksthema`i'titel == "Relaties" 
replace philosophy = 1 if gespreksthema`i'titel == "Levensbeschouwing" 	// world-view, weltanschauung...
replace dailyrout = 1 if gespreksthema`i'titel == "Dagelijkse activiteiten" 	// 
replace violence = 1 if gespreksthema`i'titel == "Slachtofferbeleving" 	// "victim experience"
replace grief = 1 if gespreksthema`i'titel == "Verliesverwerking" 	// "coping with grief"
replace soccult = 1 if gespreksthema`i'titel == "Sociaal-economische & maatschappelijke thema's" 	// 
replace other = 1 if gespreksthema`i'titel == "Varia" 	//
}

global topicsBEL "suicide addiction lonely physhealth sex relationships philosophy dailyrout violence grief soccult other"

foreach T in $topicsBEL {
replace `T' = . if gespreksthema1 == 0
}


gen married = 0 if burgerlijkestaattitel != "" & burgerlijkestaattitel != "Onbekend"
replace married = 1 if burgerlijkestaattitel == "Gehuwd"
gen unmarried = 0 if burgerlijkestaattitel != "" & burgerlijkestaattitel != "Onbekend"
replace unmarried = 1 if burgerlijkestaattitel == "Ongehuwd"
gen widowed = 0 if burgerlijkestaattitel != "" & burgerlijkestaattitel != "Onbekend"
replace widowed = 1 if burgerlijkestaattitel == "Weduw(e)naar"
gen divorced = 0 if burgerlijkestaattitel != "" & burgerlijkestaattitel != "Onbekend"
replace divorced = 1 if burgerlijkestaattitel == "Wettelijk gescheiden"

global marstats "married unmarried widowed divorced"

gen living_alone = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_alone = 1 if woonleefsituatietitel == "Alleenwonend"
gen living_partner = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_partner = 1 if woonleefsituatietitel == "Leeft samen met partner"
gen living_psychinst = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_psychinst = 1 if woonleefsituatietitel == "Psychiatrische instelling"
gen living_prison = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_prison = 1 if woonleefsituatietitel == "Gevangenis"
gen living_care = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_care = 1 if woonleefsituatietitel == "Beschut/Begeleid wonen"
gen living_2parentfam = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_2parentfam = 1 if woonleefsituatietitel == "Leeft in tweeoudergezin"
gen living_1parentfam = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_1parentfam = 1 if woonleefsituatietitel == "Leeft in éénoudergezin"
gen living_newformfam = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_newformfam = 1 if woonleefsituatietitel == "Leeft in een nieuw-samengesteld gezin"
gen living_homeless = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_homeless = 1 if woonleefsituatietitel == "Dakloos"
gen living_shared = 0 if woonleefsituatietitel != "" & woonleefsituatietitel != "Onbekend"
replace living_shared = 1 if woonleefsituatietitel == "Leeft samen met derden"		
// Andere 

global livingsit "living_alone living_partner living_shared living_2parentfam living_1parentfam living_newformfam living_care living_psychinst living_prison living_homeless"


// tab stoornistitel
gen disorder = stoornistitel 
// gen disorder = subinstr(stoornistitel, ",", "",.) 
replace disorder = regexr(disorder, "\((.)+\)", "")
replace disorder = trim(disorder)  
split disorder, p(",")
replace disorder1 = "" if disorder1 == "Onbekend/Geen"
tab disorder1
tab disorder2
tab disorder3
tab disorder4

gen disorfear		 = 0 if disorder != ""
gen disorautism 	= 0 if disorder != "" 
gen disoreating 	= 0 if disorder != "" 
gen disorpersnlty 	= 0 if disorder != "" 
gen disorschizph 	= 0 if disorder != "" 
gen disordepress 		= 0 if disorder != "" 
gen disoraddict 	= 0 if disorder != "" 

forvalues J = 1/4 {
replace disorder`J'  = trim(disorder`J' )
replace disorfear		 = 1 if disorder`J' == "Angsten/fobieën" 
replace disorautism 	 = 1 if disorder`J' == "Autisme" 
replace disoreating 	 = 1 if disorder`J' == "Eetstoornis" 
replace disorpersnlty 	 = 1 if disorder`J' == "Persoonlijkheidsstoornis" 
replace disorschizph 	 = 1 if disorder`J' == "Schizofrenie/psychose" 
replace disordepress 		 = 1 if disorder`J' == "Stemmingsstoornis" 
replace disoraddict 	 = 1 if disorder`J' == "Verslaving"
}
// Andere

global disorders "disorfear disorautism disoreating disorpersnlt disorschizph disordepress disoraddict"

replace addiction = 1 if disoraddict == 1

gen fears = 0
replace fears = 1 if disorfear == 1

gen depressed = 0
replace depressed = 1 if disordepress == 1


tab burgerlijkestaattitel 

tab woonleefsituatietitel

tab gespreksthema1titel
tab gesprekssubthema1titel if physhealth

tab oproepertypetitel, m
gen firstcall = 0 if oproepertypetitel != ""
replace firstcall = 1 if oproepertypetitel == "Nieuwe oproeper"
gen repcall = 1- firstcall

gen habitcall = 0 if oproepertypetitel != ""
replace habitcall = 1 if oproepertypetitel == "Veelbeller" | oproepertypetitel == "Veelbeller met begrenzing"

gen repnohabitcall = 0 if repcall==1 & habitcall ==0


gen duration = duur

gen chat = 0 if subclustertitel == "Tel"
replace chat = 1 if subclustertitel == "Chat"

gen phone = 1 if subclustertitel == "Tel"
replace phone = 0 if subclustertitel == "Chat"


rename agecat agegroup


gen agemin = substr(agegroup,1,2)
replace agemin = "0" if substr(agegroup,-11,11) == " or younger"
gen agemax = subinstr(agegroup," or older","",.)
replace agemax = substr(agemax,-2,2)
replace agemax = substr(agegroup,1,2) if substr(agegroup,-11,11) == " or younger"
replace agemax = "100" if substr(agegroup,-9,9) == " or older" | agegroup == "90+"
destring agemin agemax, replace

egen age = rowmean(agemin agemax)

// addiction    relationships philosophy dailyrout grief soccult other livalone livpartner livpsychinst livprison livcare liv2parentfam liv1parentfam livnewformfam livhomeless livshared disorder disorder1 disorder2 disorder3 disorder4 disorfear disorautism disoreating disorpersnlty disorschizph disordepress disoraddict
gen country = "Belgium"
gen population = 11.46		//11.46 million (2019)



drop agecode

gen helplinename = "Tele-Onthaal"



keep ddate-disorder  disorfear-population clustertitel helplinename


gen T_mentalh =0
replace T_mentalh = 1 if depressed == 1
replace T_mentalh = 1 if fears == 1

gen T_social =0
replace T_social = 1 if relationships == 1

save `"$rawdata\Countries\Belgium\BELcontacts.dta"',  replace



use `"$rawdata\Countries\Belgium\BELcontacts.dta"',  clear




# delimit ;
graph twoway histogram hour, discrete gap(0) fcolor(ebblue*0.9) lcolor(ebblue)
scheme(s2color ) legend(off) xtitle("Hour of day", yoffset(-2) size(small))
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("density", xoffset(0) axis(1) size(small)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) ) 
		yscale(titlegap(0)) 	
		xlabel(0(2)23 , labsize(small) labcolor(gs0) ) name(grc1,replace);
# delimit cr

replace duration = 90 if duration > 90 & duration != .
# delimit ;
graph twoway histogram duration, width(5) gap(0) fcolor(ebblue*0.9) lcolor(ebblue)
scheme(s2color ) legend(off) xtitle("Call duration", yoffset(-2) size(small))
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("density", xoffset(0) axis(1) size(small)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) ) 
		yscale(titlegap(0)) 	
		xlabel(0(10)90 , labsize(small) labcolor(gs0) ) name(grc2,replace);
# delimit cr

graph combine grc1 grc2 
 graph export `".\02_Project\Figures\histhour_BELGIUM.pdf"', replace




gen age1 = 0 if age != .
replace age1 = 1 if inrange(age,0,29)
gen age2 = 0 if age != .
replace age2 = 1 if inrange(age,30,60)
gen age3 = 0 if age != .
replace age3 = 1 if inrange(age,61,100)

gen age2a = 0 if age != .
replace age2a = 1 if inrange(age,30,44)
gen age2b = 0 if age != .
replace age2b = 1 if inrange(age,45,60)

estpost tabstat  female male age1 age2 age3 $marstats $livingsit $disorders,  statistics(mean  sum) columns(statistics)

# delimit ;
esttab using ".\02_Project\Tables\descriptives_BELGIUM.tex", replace style(tex) type noabbrev label nomtitle nonumber noisily
	cells("mean(fmt(%9.3f) label(\multicolumn{1}{c}{Share}))  sum(fmt(%12.0fc) label(\multicolumn{1}{c}{Sum}))" )  
	substitute("\_" "\"
				"\hline" "\midrule")
				stats(N , fmt(%9.0fc) labels("Total calls"))  
				varlabels(living_alone "\textit{Living alone}"
						  female "\textit{Female}"
						  male "\textit{Male}"
						  age "\textit{Age}"
						  age1 "\textit{Age < 30}"
						  age2 "\textit{Age 30-60}"
						  age3 "\textit{Age > 60}"
						  phones "\textit{Phone contacts}"
						  firstcall "\textit{First-time caller}"
						  repcall "\textit{Repeat caller}"
						  hour "\textit{Hour of day}"
						  chat "\textit{Chat contact}"
						  duration "\textit{Duration}"
						  suicide "\textit{Suicide}"
						  lonely "\textit{Loneliness}"
						  violence "\textit{Violence}"
						  addiction "\textit{Addiction}"
						  depressed  "\textit{Depression}"
						  worksit  "\textit{Work situation}"
						  unempl   "\textit{Unemplyment}"
						  grief  "\textit{Grief}"
						  belief   "\textit{Religion}"						  
						   fears "\textit{Fear}"
						   pregnancy  "\textit{Pregnancy}"
						   sex "\textit{Sexuality}"
						   T_econ  "\textit{Livelihood (broad)}"
						    T_social "\textit{Relationships (broad)}"
						   T_mentalh "\textit{Mental health (broad)}"
						  physhealth "\textit{Physical health}"
						  living_alone "\textit{Living alone}" 
						  living_partner  "\textit{Living with partner}" 
						  living_shared  "\textit{Shared accomodation}" 
						  living_2parentfam  "\textit{Two-parent family}" 
						  living_1parentfam  "\textit{One-parent family}" 
						  living_newformfam  "\textit{Newly formed family}" 
						  living_care  "\textit{Living in care}" 
						  living_psychinst  "\textit{Living in istitution}" 
						  living_prison  "\textit{Living in prison}" 
						  living_homeless "\textit{Homeless}" 
						  livepartner "\textit{Life with partner}"
						  married  "\textit{Married}" 
						  unmarried   "\textit{Unmarried}" 
						 widowed   "\textit{Widowed}" 
						 divorced  "\textit{Divorced}" 
						 disorfear   "\textit{Disorder: Fear}" 
						 disorautism   "\textit{Disorder: Autism}" 
						 disoreating   "\textit{Disorder: Eating}" 
						 disorpersnlty   "\textit{Disorder: Personality}" 
						 disorschizph   "\textit{Disorder: Schizophrenia}" 
						 disordepress   "\textit{Disorder: Depression}" 
						 disoraddict  "\textit{Disorder: Addiction}" 
						 parenting "\textit{Parenting}")
				prehead("{\small"
							"\renewcommand{\arraystretch}{0.9}"
							"\begin{longtable}{p{5cm} D{.}{.}{2.5}@{}  D{.}{.}{8.0}@{}}"
							"\caption{\normalsize{Tele-Onthaal, caller characteristics \label{descriptives_BELGIUM}}}\\\toprule"
							"\endfirsthead"
							"\midrule"
							"& \multicolumn{1}{c}{Mean} & \multicolumn{1}{c}{N}\\"
							"\endhead")	
				postfoot("\bottomrule\\[-0.2cm]
							\parbox{7cm}{\footnotesize \textit{Note:} All calls from 1 January 2019 to 30 June 2020.}\\
							\end{longtable}}");
# delimit cr

estpost tabstat  lonely depressed fears suicide  violence addiction physhealth  grief  sex T_social,  statistics(mean  sum) columns(statistics) 


# delimit ;
esttab using ".\02_Project\Tables\descriptives_BELGIUM2.tex", replace style(tex) type noabbrev label nomtitle nonumber noisily
	cells("mean(fmt(%9.3f) label(\multicolumn{1}{c}{Share}))  sum(fmt(%12.0fc) label(\multicolumn{1}{c}{Sum}))" )  
	substitute("\_" "\"
				"\hline" "\midrule")
				stats(N , fmt(%9.0fc) labels("Total calls"))  
				varlabels(living_alone "\textit{Living alone}"
						  female "\textit{Female}"
						  male "\textit{Male}"
						  age "\textit{Age}"
						  age1 "\textit{Age < 30}"
						  age2 "\textit{Age 30-60}"
						  age3 "\textit{Age > 60}"
						  phones "\textit{Phone contacts}"
						  firstcall "\textit{First-time caller}"
						  repcall "\textit{Repeat caller}"
						  hour "\textit{Hour of day}"
						  chat "\textit{Chat contact}"
						  duration "\textit{Duration}"
						  suicide "\textit{Suicide}"
						  lonely "\textit{Loneliness}"
						  violence "\textit{Violence}"
						  addiction "\textit{Addiction}"
						  depressed  "\textit{Depression}"
						  worksit  "\textit{Work situation}"
						  unempl   "\textit{Unemplyment}"
						  grief  "\textit{Grief}"
						  belief   "\textit{Religion}"						  
						   fears "\textit{Fear}"
						   pregnancy  "\textit{Pregnancy}"
						   sex "\textit{Sexuality}"
						   T_econ  "\textit{Livelihood (broad)}"
						    T_social "\textit{Relationships (broad)}"
						   T_mentalh "\textit{Mental health (broad)}"
						  physhealth "\textit{Physical health}"
						  living_alone "\textit{Living alone}" 
						  living_partner  "\textit{Living with partner}" 
						  living_shared  "\textit{Shared accomodation}" 
						  living_2parentfam  "\textit{Two-parent family}" 
						  living_1parentfam  "\textit{One-parent family}" 
						  living_newformfam  "\textit{Newly formed family}" 
						  living_care  "\textit{Living in care}" 
						  living_psychinst  "\textit{Living in istitution}" 
						  living_prison  "\textit{Living in prison}" 
						  living_homeless "\textit{Homeless}" 
						  livepartner "\textit{Life with partner}"
						  married  "\textit{Married}" 
						  unmarried   "\textit{Unmarried}" 
						 widowed   "\textit{Widowed}" 
						 divorced  "\textit{Divorced}" 
						 disorfear   "\textit{Disorder: Fear}" 
						 disorautism   "\textit{Disorder: Autism}" 
						 disoreating   "\textit{Disorder: Eating}" 
						 disorpersnlty   "\textit{Disorder: Personality}" 
						 disorschizph   "\textit{Disorder: Schizophrenia}" 
						 disordepress   "\textit{Disorder: Depression}" 
						 disoraddict  "\textit{Disorder: Addiction}" 
						 parenting "\textit{Parenting}")
				prehead("{\small"
							"\renewcommand{\arraystretch}{0.9}"
							"\begin{longtable}{p{5cm} D{.}{.}{2.5}@{}  D{.}{.}{8.0}@{}}"
							"\caption{\normalsize{Tele-Onthaal, Topics \label{descriptives_BELGIUM2}}}\\\toprule"
							"\endfirsthead"
							"\midrule"
							"& \multicolumn{1}{c}{Mean} & \multicolumn{1}{c}{N}\\"
							"\endhead")	
				postfoot("\bottomrule\\[-0.2cm]
							\parbox{7cm}{\footnotesize \textit{Note:} All calls from 1 January 2019 to 30 June 2020.}\\
							\end{longtable}}");
# delimit cr





encode agegroup, gen(agecode)
foreach V in  female male  duration   $marstats $livingsit $disorders $topicsBEL {
bysort ddate: egen contacts_`V'BEL = sum(`V' == 1)
}

forvalues J= 1/10 {
bysort ddate: egen contacts_age`J'BEL = sum(agecode == `J')
}



bysort ddate: gen helplinecontacts = _N
bysort ddate: keep if _n == 1
keep helplinecontacts  ddate contacts*


gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020
gen daily19 = ddate - mdy(1,1,2019) + 1 if year(ddate) == 2019





gen zero = 0
gen c2 = contacts_age1BEL + contacts_age2BEL
gen c3 = c2 + contacts_age3BEL
gen c4 = c3 + contacts_age4BEL
gen c5 = c4 + contacts_age5BEL
gen c6 = c5  + contacts_age6BEL
gen c7 = c6  + contacts_age7BEL
gen c8 = c7  + contacts_age8BEL
gen c9 = c8  + contacts_age9BEL
gen c10 = c9 + contacts_age10BEL

tsset daily20
foreach V of varlist helplinecontacts c2 c3 c4 c5 c6 c7 c8 c9 c10 contacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}

# delimit ;
twoway rbar zero contacts_age1BEL daily20  if year(ddate) == 2020 , bcolor(ebblue*0.1)  yaxis(1)  
	|| rbar contacts_age1BEL c2 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.4)  yaxis(1)  
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
graph export ".\02_Project\Figures\ageofcontacts_BEL.pdf", replace

// graph export ".\02_Project\Figures\ageofcontacts_BEL.pdf", replace

// plb1 plg1 ply1 pll1 plb2 plg2
# delimit ;
twoway line MA7contacts_age1BEL daily20  if year(ddate) == 2020 ,  lcolor(plb1)  yaxis(1)  
	|| line MA7contacts_age2BEL daily20  if year(ddate) == 2020 ,  lcolor(plg1)  yaxis(1)  
	|| line MA7contacts_age3BEL daily20  if year(ddate) == 2020 ,  lcolor(ply1)  yaxis(1)  
	|| line MA7contacts_age4BEL  daily20  if year(ddate) == 2020 , lcolor(pll1)  yaxis(1)  
	|| line MA7contacts_age5BEL  daily20  if year(ddate) == 2020 , lcolor(plb2) yaxis(1)  
	|| line MA7contacts_age6BEL  daily20  if year(ddate) == 2020 , lcolor(plg2)  yaxis(1)  
	|| line MA7contacts_age7BEL  daily20  if year(ddate) == 2020 , lcolor(ply2)  yaxis(1)  
	|| line MA7contacts_age8BEL  daily20  if year(ddate) == 2020 , lcolor(pll2)  yaxis(1)  
	|| line MA7contacts_age9BEL  daily20  if year(ddate) == 2020 , lcolor(plb3)  yaxis(1)  
	|| line MA7contacts_age10BEL daily20  if year(ddate) == 2020 , lcolor(plg3)  yaxis(1)  
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

// graph export ".\02_Project\Figures\ageofcontacts_BEL.pdf", replace




tsset ddate

   
# delimit ;    
twoway line MA7contacts_unmarriedBEL  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_marriedBEL  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
		|| line MA7contacts_divorcedBEL  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_widowedBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
		scheme(s2color) legend( label(1  "Unmarried") label(2 "Married") label(3 "Divorced") label(4 "Widowed")
			order(1 2 3 4)  cols(1) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr
graph export ".\02_Project\Figures\contacts_marstat_BEL.pdf", replace

	// || scatter contacts_livnewformfamBEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_livnewformfamBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	// || scatter contacts_livsharedBEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_livsharedBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	// || scatter contacts_livcareBEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb2)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_livcareBEL  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
	// || scatter contacts_livpsychinstBEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(ply1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_livpsychinstBEL  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	// || scatter contacts_livprisonBEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(pll1)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_livprisonBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	// || scatter contacts_livhomelessBEL daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb2)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_livhomelessBEL  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
		// scheme(s2color) legend( label(1 "")  label(2 "Alone") label(4 "With partner")  label(6 "Two-parent family")  label(8 "Single parent family") label(10 "Newly formed family") label(12 "Shared with third party") label(14 "Assisted living/care")  label(16 "Psychiatric Institution") label(18 "Prison") label(20 "Homeless")   
egen recliving = rowtotal(contacts_living_homelessBEL contacts_living_prisonBEL contacts_living_psychinstBEL contacts_living_careBEL contacts_living_sharedBEL contacts_living_newformfamBEL)
gen otherliving = helplinecontacts - recliving
egen MA7recliving = rowtotal(MA7contacts_living_homelessBEL MA7contacts_living_prisonBEL MA7contacts_living_psychinstBEL MA7contacts_living_careBEL MA7contacts_living_sharedBEL MA7contacts_living_newformfamBEL) if MA7contacts_living_aloneBEL !=.
gen MA7otherliving = MA7helplinecontacts - MA7recliving


# delimit ;   
twoway line MA7contacts_living_aloneBEL  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_living_partnerBEL  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_living_2parentfamBEL  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_living_1parentfamBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	|| line MA7otherliving  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
	legend(label(1 "Alone") label(2 "With partner")  label(3 "Two-parent family")  label(4 "Single parent family") label(5 "Other")  
			order(1 2 3 4 5)  cols(2) pos(6) ring(1) colfirst colgap(0) size(small)  region(lcolor(white))) 
		scheme(s2color) graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr
graph export ".\02_Project\Figures\contacts_livingsit_BEL.pdf", replace



# delimit ;
twoway line MA7contacts_relationshipsBEL  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_physhealthBEL  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_lonelyBEL  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_dailyroutBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_violenceBEL  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
	|| line MA7contacts_addictionBEL  daily20 if year(ddate) == 2020, lcolor(plg2) msize(medsmall) yaxis(1) 
		scheme(s2color) legend( label(1 "Relationships") label(2 "Health") label(3 "Loneliness") label(4 "Everyday activities") label(5 "Violence")  label(6 "Addiction")  
			order(1 2 3 4 5 6)  cols(2) pos(6) ring(1) colfirst colgap(0) size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr
graph export ".\02_Project\Figures\contacts_topics_BEL.pdf", replace

# delimit ;      
twoway  line MA7contacts_disorfearBEL  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_disorautismBEL  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_disoreatingBEL  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_disorpersnltBEL  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	|| line MA7contacts_disorschizphBEL  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
	|| line MA7contacts_disordepressBEL  daily20 if year(ddate) == 2020, lcolor(plg2) msize(medsmall) yaxis(1) 
	|| line MA7contacts_disoraddictBEL  daily20 if year(ddate) == 2020, lcolor(ply2) msize(medsmall) yaxis(1) 
		scheme(s2color) legend( label(1 "Fear") label(2 "Autism") label(3 "Eating") label(4 "Personality") label(5 "Schizophrenia")  label(6 "Depression")    label(7 "Addiction")  
			order(6 1 7 4 5 2 3)  cols(2) pos(6) ring(1) colfirst colgap(0) size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		title("",  size(medsmall) color(gs0)) 		
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale(titlegap(0)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152 182);
# delimit cr
graph export ".\02_Project\Figures\contacts_disorders_BEL.pdf", replace



// tsset ddate
// foreach T in $topicsBEL {
// gen share_`T' = MA7contacts_`T'BEL/helplinecontacts


// # delimit ;
// twoway scatter contacts_`T' daily19 if year(ddate) == 2019  & daily19<182, msymbol(O) mcolor(plb1*0.7)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_`T'  daily19 if year(ddate) == 2019 & daily19<182, lcolor(plb1*0.7) msize(medsmall) yaxis(1) 
	// || scatter contacts_`T' daily20 if year(ddate) == 2020 , msymbol(O) mcolor(plb1*1.2)	msize(vsmall) yaxis(1) 
	// || line MA7contacts_`T'  daily20 if year(ddate) == 2020, lcolor(plb1*1.2) msize(medsmall) yaxis(1) 
		// scheme(s2color) legend( label(1 "")  label(2 "2019") label(4 "2020")  
			// order(4 2)  cols(1) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		// title("",  size(medsmall) color(gs0)) 		
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		// yscale(titlegap(0)) 
		// xtitle("", yoffset(-2)) 
		// xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		// xtick(0 31 60 91 121 152 182) 
		// name(combi1, replace);
// # delimit cr
// # delimit ;
// twoway line share_`T'  daily19 if year(ddate) == 2019 & month(ddate) < 7, lcolor(plg1*0.7) msize(medsmall) yaxis(1) 
	// || line share_`T'  daily20 if year(ddate) == 2020, lcolor(plg1*1.2) msize(medsmall) yaxis(1) 
		// scheme(s2color) legend( label(1 "2019") label(2 "2020") order(2 1)  
			 // cols(1) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("share of all contacts", xoffset(-1) axis(1) size(small)) 
		// title("",  size(medsmall) color(gs0)) 		
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		// yscale(titlegap(0)) 
		// xtitle("", yoffset(-2)) 
		// xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		// xtick(0 31 60 91 121 152 182) 
		// name(combi2, replace);
// # delimit cr

// graph combine combi1 combi2, cols(1)

// graph export ".\02_Project\Figures\contacts_`T'_BEL.pdf", replace
// }

// # delimit ;
// twoway line share_relationships  daily20 if year(ddate) == 2020, lcolor(plb1) msize(medsmall) yaxis(1) 
	// || line share_physhealth  daily20 if year(ddate) == 2020, lcolor(plg1) msize(medsmall) yaxis(1) 
	// || line share_lonely  daily20 if year(ddate) == 2020, lcolor(ply1) msize(medsmall) yaxis(1) 
	// || line share_dailyrout  daily20 if year(ddate) == 2020, lcolor(pll1) msize(medsmall) yaxis(1) 
	// || line share_violence  daily20 if year(ddate) == 2020, lcolor(plb2) msize(medsmall) yaxis(1) 
	// || line share_addiction  daily20 if year(ddate) == 2020, lcolor(plg2) msize(medsmall) yaxis(1) 
		// scheme(s2color) legend( label(1 "Relationships")  label(2 "Health") label(3 "Loneliness") label(4 "Everyday activities") label(5 "Violence") label(6 "Addiction") 
			// order(1 2 3 4 5 6)  cols(2) pos(11) ring(0) colfirst colgap(0) size(small)  region(lcolor(white))) 
		// graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		// ytitle("daily contacts", xoffset(-1) axis(1) size(small)) 
		// title("",  size(medsmall) color(gs0)) 		
		// ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		// yscale(titlegap(0)) 
		// xtitle("", yoffset(-2)) 
		// xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		// xtick(0 31 60 91 121 152 182);
// # delimit cr
// graph export ".\02_Project\Figures\contacts_topicshares_BEL.pdf", replace











 
// Regional Panel:

use `"$rawdata\Countries\Belgium\BELcontacts.dta"',  clear

tab clustertitel
encode clustertitel, gen(cluster)

bysort cluster ddate: gen clcontacts = _N
 
bysort cluster ddate: egen clcont_female = sum(female== 1)
bysort cluster ddate: egen clcont_male = sum(male== 1)
bysort cluster ddate: egen clcont_suicide = sum(suicide==1)


collapse (firstnm) clcontacts clcont_* clustertitel, by(cluster ddate)
 
   


gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020

xtset cluster ddate
tsfill

foreach V of varlist clcontacts clcont_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}



# delimit ;
twoway line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "ANTW",  lcolor(plb1)  yaxis(1)  
	|| line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "BRUGGE",  lcolor(plg1)  yaxis(1) 
	|| line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "BRUSSEL",  lcolor(ply1)  yaxis(1) 
	|| line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "KORTRIJK",  lcolor(pll1)  yaxis(1) 
	|| line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "LEUVEN",  lcolor(plb2)  yaxis(1) 
	|| line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "LIMB",  lcolor(plg2)  yaxis(1) 
	|| line MA7clcontacts daily20  if year(ddate) == 2020 & clustertitel == "OVL",  lcolor(ply2)  yaxis(1) 
	legend(label(1 "Antwerp") 
		   label(2 "Brugge") 
		   label(3 "Brussels") 
		   label(4 "Kortriyk") 
		   label(5 "Leuven") 
		   label(6 "Limurg") 
		   label(7 "East Flanders") pos(6) ring(1) cols(3) colfirst region(lcolor(white))) 
	scheme(s2color) graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
	ytitle("", xoffset(-1) axis(1)) 
	xtitle("", yoffset(-2)) 
	xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
	xtick(0 31 60 91 121 152);
# delimit cr
graph export ".\02_Project\Figures\Regional_contacts_BEL.pdf", replace







 graph close









