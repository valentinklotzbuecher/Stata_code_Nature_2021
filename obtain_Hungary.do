




import excel ".\03_Data\Countries\Hungary\Statistical Data.xlsx",  firstrow clear sheet("Total")

gen ddate = DATE
format ddate %td

egen helplinecontacts = rowtotal(Male-MaleFemalenotknown)


renvars _all, lower
rename malefemalenotknown contacts_othergender

rename suicidecrisiscryforhelp suicide  
rename loneliness lonely 
rename drogalcoholother addiction




// save `".\03_Data\Countries\Hungary\HGRcontacts.dta"',  replace



renvars male female suicide lonely  addiction mentalhealth, prefix(contacts_)


// Physicalproblems Suicidecrisiscryforhelp Loneliness Drogalcoholother Mentalhealth Familyproblems Generationproblems ProblemswithChildren Financial Lossandmourning FearsanxietyOtheremotions


keep ddate helplinecontacts contacts_*

gen obsday = 1

// tsset ddate
// tsfill

replace obsday = 0 if obsday == .
drop obsday

gen country = "Hungary"
gen population = 9.773 

gen helplinename = "LESZ"

save `".\03_Data\Countries\Hungary\Hungary_series.dta"',  replace


