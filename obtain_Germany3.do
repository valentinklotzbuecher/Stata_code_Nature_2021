

import excel "$rawdata\Countries\Germany\Muslimische TS\Kopie von tsvictor_stelle_26.xlsx",  firstrow clear

gen ddate = dofC(datum_formatted)

format ddate %td

rename chats 	chat
rename mails    mail
rename phones   phone
rename firsts   firstcall
rename recurs   repcall

replace firstcall = . if firstcall + repcall ==0
replace repcall = . if repcall ==0 & firstcall ==. 

replace male = . if male == 0 & female == 0 & othergender == 0
replace female = . if male == . 
replace othergender = . if male == . 


gen agegroup = "age_0_9"  if age_0_9 == 1
replace agegroup = "age_10_14" if age_10_14 == 1
replace agegroup = "age_15_19" if age_15_19 == 1
replace agegroup = "age_20_29" if age_20_29 == 1
replace agegroup = "age_30_39" if age_30_39 == 1
replace agegroup = "age_40_49" if age_40_49 == 1
replace agegroup = "age_50_59" if age_50_59 == 1
replace agegroup = "age_60_69" if age_60_69 == 1
replace agegroup = "age_70_79" if age_70_79 == 1
replace agegroup = "age_80plus" if age_80plus == 1

gen agemin = 10 if agegroup == "age_10_14" 
replace agemin =15 if agegroup == "age_15_19" 
replace agemin =20 if agegroup == "age_20_29" 
replace agemin =30 if agegroup == "age_30_39" 
replace agemin =40 if agegroup == "age_40_49" 
replace agemin =50 if agegroup == "age_50_59" 
replace agemin =60 if agegroup == "age_60_69" 
replace agemin =70 if agegroup == "age_70_79" 
replace agemin =80 if agegroup == "age_80plus"

gen agemax = 14 if agegroup == "age_10_14" 
replace agemax =19 if agegroup == "age_15_19" 
replace agemax =29 if agegroup == "age_20_29" 
replace agemax =39 if agegroup == "age_30_39" 
replace agemax =49 if agegroup == "age_40_49" 
replace agemax =59 if agegroup == "age_50_59" 
replace agemax =69 if agegroup == "age_60_69" 
replace agemax =79 if agegroup == "age_70_79" 
replace agemax =80 if agegroup == "age_80plus"

egen age = rowmean(agemin agemax)

gen  duration = mins + 60*hrs

gen suicide = (suicself == 1 | suicother == 1)


rename addict addiction
gen violence =  0 if physviol !=. | sexviol !=.
replace violence =  1 if physviol ==1 | sexviol ==1
renvars alone inst family partner, prefix("living_")
gen unemployed = 0 if jobsearch  != .
replace unemployed = 1 if jobsearch  == 1 | nojobsearch == 1
 
rename physicalprobs physhealth
rename disab disability   
replace physhealth = 1 if disability

gen T_econ = (unemployed == 1 | worksit == 1 |poverty == 1 |fininher == 1 |housing == 1)
gen T_social = (partnersearch == 1 | livepartner == 1 | parenting == 1 | pregnancy == 1 | famrel == 1 | everydayrel == 1 | virtualrel == 1)

rename educ education


drop TSfeedback_pos TSfeedback_neg TSfeedback_agr topic_current ID datum_formatted centercode region hrs mins living_inst suicide0 suicide1 suicide2 suicide3 drtn volunt confshame pubinstcont caretherap
* all zero:
drop age_0_9  age_10_14 age_15_19 age_20_29 age_30_39 age_40_49 age_50_59 age_60_69 age_70_79 age_80plus othergender psydiknowns grief 
drop dailyrout belief church soccult

gen country = "Germany"
gen population = 83.02 	// million (2019)



gen helplinename = "Muslimisches Seelsorgetelefon"



save `"$rawdata\Countries\Germany\Muslimische TS\GERmuslcontacts.dta"',  replace


/*
use `"$rawdata\Countries\Germany\Muslimische TS\GERmuslcontacts.dta"',  clear





bysort ddate: gen helplinecontactsGER = _N


// gen age_0_9 = 	 (agegroup == "0_to_9")
// gen age_10_14  = (agegroup == "10_14" )
// gen age_15_19  = (agegroup == "15_19" )
// gen age_20_29  = (agegroup == "20_29" )
// gen age_30_39  = (agegroup == "30_39" )
// gen age_40_49  = (agegroup == "40_49" )
// gen age_50_59  = (agegroup == "50_59" )
// gen age_60_69  = (agegroup == "60_69" )
// gen age_70_79  = (agegroup == "70_79" )
// gen age_80plus = (agegroup == "80_or_above")  
// foreach V of varlist age_* {
// replace `V' = . if agegroup == ""
// }

foreach C of varlist   addiction violence  physviol sexviol  fears suicide lonely firstcall repcall female male age_0_9 age_10_14 age_15_19 age_20_29 age_30_39 age_40_49 age_50_59 age_60_69 age_70_79 age_80plus  {
bysort ddate: egen contacts_`C'GER = sum(`C')
}

bysort ddate: keep if _n == 1
keep ddate helplinecontactsGER helplinecontactsGER-contacts_age_80plusGER

// keep if ddate < mdy(5,18,2020)

tsset ddate
tsfill

// gen country = "Germany"
// gen population = 83.02 	// million (2019)



gen zero = 0
gen c2 = contacts_age_0_9GER + contacts_age_10_14GER
gen c3 = c2  + contacts_age_15_19GER
gen c4 = c3  + contacts_age_20_29GER
gen c5 = c4  + contacts_age_30_39GER 
gen c6 = c5  + contacts_age_40_49GER 
gen c7 = c6  + contacts_age_50_59GER 
gen c8 = c7  + contacts_age_60_69GER 
gen c9 = c8  + contacts_age_70_79GER 
gen c10 = c9 + contacts_age_80plusGER






gen daily20 = ddate - mdy(1,1,2020) if year(ddate) == 2020
gen daily19 = ddate - mdy(1,1,2019) + 1 if year(ddate) == 2019

foreach V of varlist helplinecontactsGER c2 c3 c4 c5 c6 c7 c8 c9 c10 contacts_* {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}



# delimit ;
twoway rbar zero contacts_age_0_9GER daily20  if year(ddate) == 2020 , bcolor(ebblue*0.1)  yaxis(1)  
	|| rbar contacts_age_0_9GER c2 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.4)  yaxis(1)  
	|| rbar c2 c3 daily20  if year(ddate) == 2020 , bcolor(ebblue*0.6)  yaxis(1)  
	|| rbar c3 c4  daily20  if year(ddate) == 2020 , bcolor(ebblue*0.8)  yaxis(1)  
	|| rbar c4 c5  daily20  if year(ddate) == 2020 , bcolor(ebblue*1)  yaxis(1)  
	|| rbar c5 c6  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.2)  yaxis(1)  
	|| rbar c6 c7  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.4)  yaxis(1)  
	|| rbar c7 c8  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.6)  yaxis(1)  
	|| rbar c8 c9  daily20  if year(ddate) == 2020 , bcolor(ebblue*1.8)  yaxis(1)  
	|| rbar c9 c10 daily20  if year(ddate) == 2020 , bcolor(ebblue*2)  yaxis(1)  
		scheme(s2color) legend(label(1 "-9") label(2 "10-14") label(3 "15-19") label(4 "20-29") 
			label(5 "30-39") label(6 "40-49") label(7 "50-59") label(8 "60-69") label(9 "70-79") label(10 "80+") 
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152)
		name(age1, replace);
# delimit cr

# delimit ;
twoway line MA7contacts_age_0_9GER   daily20  if year(ddate) == 2020 ,  lcolor(plb1)  yaxis(1)  
	|| line MA7contacts_age_10_14GER daily20  if year(ddate) == 2020 ,  lcolor(plg1)  yaxis(1)  
	|| line MA7contacts_age_15_19GER  daily20  if year(ddate) == 2020 ,  lcolor(ply1)  yaxis(1)  
	|| line MA7contacts_age_20_29GER  daily20  if year(ddate) == 2020 , lcolor(pll1)  yaxis(1)  
	|| line MA7contacts_age_30_39GER  daily20  if year(ddate) == 2020 , lcolor(plb2) yaxis(1)  
	|| line MA7contacts_age_40_49GER  daily20  if year(ddate) == 2020 , lcolor(plg2)  yaxis(1)  
	|| line MA7contacts_age_50_59GER  daily20  if year(ddate) == 2020 , lcolor(ply2)  yaxis(1)  
	|| line MA7contacts_age_60_69GER  daily20  if year(ddate) == 2020 , lcolor(pll2)  yaxis(1)  
	|| line MA7contacts_age_70_79GER  daily20  if year(ddate) == 2020 , lcolor(plb3)  yaxis(1)  
	|| line MA7contacts_age_80plusGER daily20  if year(ddate) == 2020 , lcolor(plg3)  yaxis(1)  
		scheme(s2color) legend(label(1 "-9") label(2 "10-14") label(3 "15-19") label(4 "20-29") 
			label(5 "30-39") label(6 "40-49") label(7 "50-59") label(8 "60-69") label(9 "70-79") label(10 "80+") 
			pos(2) ring(1)  cols(1) order(10 9 8 7 6 5 4 3 2 1) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(zero)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1)) 
		xtitle("", yoffset(-2)) 
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) 
		xtick(0 31 60 91 121 152)
		name(age2, replace);
# delimit cr

graph combine age1 age2, cols(1)

graph export ".\02_Project\Figures\ageofcontacts_GER3.pdf", replace










