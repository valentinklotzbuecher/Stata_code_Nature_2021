






global hlinecodes "AUT  BEL BIH    CHE    CHN    CZE    FIN    FRA   GER1 GER2  GER3   GER4    HKG    HUN    ISR    ITA    LBN    LUX    NLD    PRT    SVN"

	
foreach C in $hlinecodes {

use "$rawdata\merged_series.dta",  clear

drop if HCcode == "FIN" & year == 2019
keep if HCcode == "`C'"
keep if month(ddate) < 7

drop outbreakdate dateofoutbreak
egen dateofoutbreak = min(ddate) if confirmedcasesPOP > 10 & confirmedcasesPOP != .
bysort country (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
format dateofoutbreak %td
gen outbreakdate = (ddate==dateofoutbreak)
egen dateofsignmeasures = min(ddate) if stringencyindex > 50 & stringencyindex != .
bysort country (dateofsignmeasures): replace dateofsignmeasures = dateofsignmeasures[1]
format dateofsignmeasures %td
gen signmeasuresdate = (ddate==dateofsignmeasures)

replace helplinename = "Telefonseelsorge" if helplinename == "Telefonseelsorge Deutschland"
replace helplinename = "Telefonseelsorge" if helplinename == "Telefonseelsorge Österreich"
replace helplinename = "Hope line" if HCcode == "CHN"

replace helplinename = "Nr. gegen Kummer (children)" if helplinename == "Nummer gegen Kummer (Kinder/Jugend)"
replace helplinename = "Nr. gegen Kummer (parents)" if helplinename == "Nummer gegen Kummer (Eltern)"
replace helplinename = "MIELI Mental Health" if helplinename == "MIELI Mental Health Finland"
replace helplinename = "Samaritan Befrienders" if helplinename == "The Samaritan Befrienders Hong Kong"
gen hlc =  country + ", " + helplinename
local titletext = hlc[1]
display `"`titletext'"'


replace MA7newcasesPOP = 0 if MA7newcasesPOP<0

sum dayofyear if ddate==dateofoutbreak
local eventline = r(mean)
display  "`eventline'"
sum dayofyear if ddate==dateofsignmeasures
local event2line = r(mean)
display  "`event2line'"
sum dayofyear if ddate==dateoflockdown
local event3line = r(mean)
display  "`event3line'"
sort ddate

twoway scatter helplinecontacts dayofyear if year(ddate) == 2019 , msymbol(o) mcolor(gs13)	msize(tiny) ///
	|| line MA7helplinecontacts  dayofyear if MA7helplinecontacts !=. & helplinecontacts !=. & year(ddate) == 2019, lcolor(gs13)	 ///
	|| scatter helplinecontacts dayofyear if year(ddate) == 2020 , msymbol(o) mcolor(gs0)	msize(tiny) ///
	|| line MA7helplinecontacts  dayofyear if MA7helplinecontacts !=. & helplinecontacts !=. & year(ddate) == 2020, lcolor(gs0)	 ///
		scheme(s2color) legend(off) ///
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white)  ///
		title(`"`titletext'"', margin(small) color(gs0) size(medsmall)) ///
		ytitle("", xoffset(-1) axis(1)) ///
		xline(`eventline', lcolor(cranberry))  ///
		xline(`event3line', lcolor(ebblue) lpattern(shortdash))  ///
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) ///
		xtitle("", yoffset(-2)) ///
		xlabel(15 "Jan" 45 "Feb" 75 "Mar" 106 "Apr" 137 "May" 168 "Jun", labsize(small) labcolor(gs0) notick) ///
		xtick(0 31 60 91 121 152 182) name(contacts1920`C', replace)

}

graph combine contacts1920GER1 contacts1920FRA contacts1920NLD contacts1920BEL  contacts1920CHE contacts1920GER2 contacts1920AUT  contacts1920HUN contacts1920ITA     contacts1920CHN contacts1920FIN contacts1920SVN contacts1920GER3 contacts1920CZE contacts1920ISR   contacts1920PRT contacts1920LBN contacts1920GER4 contacts1920LUX contacts1920HKG   contacts1920BIH, cols(3) xsize(18.3cm) ysize(24cm) graphregion(color(white)  margin(vsmall)) 		
	graph export ".\02_Project\Figures\contacts1920_insample.pdf", replace
	graph export ".\02_Project\Figures\contacts1920_insample.eps", replace
	
		graph export ".\Revisions_Nature\Final figures\ExtDataFig1.pdf", replace


use "$rawdata\merged_series.dta",  clear

keep if HCcode == "AUT" | HCcode == "BEL" | HCcode == "BIH" | HCcode == "CHE" | HCcode == "CHN" | HCcode == "CZE" | HCcode == "FIN" | HCcode == "FRA" | HCcode == "GER1" | HCcode == "GER2" | HCcode == "GER3" | HCcode == "GER4" | HCcode == "HKG" | HCcode == "HUN" | HCcode == "ISR" | HCcode == "ITA" | HCcode == "LBN" | HCcode == "LUX" | HCcode == "NLD" | HCcode == "PRT" | HCcode == "SVN"
keep if month(ddate) < 7

drop outbreakdate dateofoutbreak
egen dateofoutbreak = min(ddate) if confirmedcasesPOP > 10 & confirmedcasesPOP != .
bysort country (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
format dateofoutbreak %td
gen outbreakdate = (ddate==dateofoutbreak)
egen dateofsignmeasures = min(ddate) if stringencyindex > 50 & stringencyindex != .
bysort country (dateofsignmeasures): replace dateofsignmeasures = dateofsignmeasures[1]
format dateofsignmeasures %td
gen signmeasuresdate = (ddate==dateofsignmeasures)


keep ddate helplinename country MA7helplinecontacts helplinecontacts dateofoutbreak dateofsignmeasures

sort country helplinename ddate
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig1_SourceData.xlsx", firstrow(varlabels)  replace



graph close

