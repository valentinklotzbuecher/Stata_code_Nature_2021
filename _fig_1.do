frame reset

use "$rawdata\merged_series.dta",  clear


drop if HCcode == "FIN" & year == 2019

bysort HCcode: egen mindate = min(ddate)     if helplinecontacts !=0 & helplinecontacts !=.
bysort HCcode: egen maxdate = max(ddate)     if helplinecontacts !=0 & helplinecontacts !=.
format mindate maxdate %td
replace helplinename = "Nr. gegen Kummer (children)" if helplinename == "Nummer gegen Kummer (Kinder/Jugend)"
replace helplinename = "Nr. gegen Kummer (parents)" if helplinename == "Nummer gegen Kummer (Eltern)"
replace helplinename = "MIELI Mental Health" if helplinename == "MIELI Mental Health Finland"
replace helplinename = "Samaritan Befrienders" if helplinename == "The Samaritan Befrienders Hong Kong"


collapse (firstnm) country helplinename dateofoutbreak dateoflockdown mindate maxdate (sum) helplinecontacts , by(HCcode)

gen datastart = string(day(mindate)) + "." + string(month(mindate)) + "." + string(year(mindate)) 
gen dataend = string(day(maxdate)) + "." + string(month(maxdate)) + "." + string(year(maxdate)) 
format helplinecontacts %9.0fc
tostring helplinecontacts , gen(callsumstring) format(%12.0fc) force

gsort -helplinecontacts
keep  country helplinename helplinecontacts datastart dataend



use "$rawdata\merged_series.dta",  clear

drop if ddate > mdy(6,30,2020)
drop if HCcode == "LVA"
drop if HCcode == "DNK"
drop if HCcode == "FIN" & year == 2019

egen dateofsignmeasures = min(ddate) if stringencyindex > 50 & stringencyindex != .
bysort country (dateofsignmeasures): replace dateofsignmeasures = dateofsignmeasures[1]
format dateofsignmeasures %td
gen signmeasuresdate = (ddate==dateofsignmeasures)

drop outbreakdate dateofoutbreak
bysort country: egen dateofoutbreak = min(ddate) if confirmedcasesPOP > 10 & confirmedcases != .
bysort country (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
format dateofoutbreak %td
gen outbreakdate = (ddate==dateofoutbreak)

gen outbreakweek = nweek if outbreakdate == 1
bysort country (outbreakweek): replace outbreakweek = outbreakweek[1]
gen signmeasuresweek = nweek if signmeasuresdate == 1
bysort country (signmeasuresweek): replace signmeasuresweek = signmeasuresweek[1]

gen obweek = nweek - outbreakweek
replace obweek = obweek+52 if year == 2019

gen smweek = nweek - signmeasuresweek
replace smweek = smweek+52 if year == 2019

replace ldweek = ldweek+52 if year == 2019


gen lcalls = log(helplinecontacts)
ihstrans helplinecontacts

bysort HCcode: egen tot_calls = sum(helplinecontacts) 
bysort HCcode: egen m_calls = mean(helplinecontacts)  
bysort HCcode: egen sd_calls = sd(helplinecontacts)   
gen stdzd_calls = (helplinecontacts-m_calls)/sd_calls

global eventtime "smweek"
global eventtime "ldweek"
global eventtime "obweek"



preserve
forvalues J = 0/12 {
gen week`J'post = 0
replace week`J'post = 1  if $eventtime == `J'
gen week`J'post20 = 0
replace week`J'post20 = 1  if $eventtime == `J' & year == 2020
}
forvalues J = 1/12 {
gen week`J'pre = 0
replace week`J'pre = 1 if  $eventtime == -`J' 
gen week`J'pre20 = 0
replace week`J'pre20 = 1 if  $eventtime == -`J' & year == 2020
}


global ld0wdums "week4pre20 week3pre20 week2pre20 week1pre20  week1post20 week2post20 week3post20 week4post20 week5post20 week6post20 week7post20 week8post20 week9post20 week10post20 week11post20 week12post20"


xtset helplinecode ddate


keep if inrange($eventtime,-4,12)


reghdfe lcalls  $ld0wdums , absorb(helplinecode#year helplinecode#weekofyear helplinecode#weekday) nocons vce(cluster helplinecode#nmonth)
egen totcallsinsamp= sum(helplinecontacts) if e(sample)
local N_C = totcallsinsamp[1]
tab helplinename if e(sample)
local N_HL = r(r)
estadd scalar N_g = r(r), replace
estadd local wtd "\textsc{No}"
est store vols1
regsave using "$rawdata\cplotVOL.dta", ci level(95) addlabel(nhelplines, `N_HL', ncalls, `N_C', weighted, "No") detail(all) replace
tab HCcode if e(sample)

reghdfe lcalls  $ld0wdums [aweight=tot_calls], absorb(helplinecode#year helplinecode#weekofyear helplinecode#weekday) nocons vce(cluster helplinecode#nmonth)
drop totcallsinsamp
egen totcallsinsamp= sum(helplinecontacts) if e(sample)
local N_C = totcallsinsamp[1]
tab helplinename if e(sample)
local N_HL = r(r)
estadd scalar N_g = r(r), replace
estadd local wtd "\textsc{Yes}"
est store vols2
regsave using "$rawdata\cplotVOL.dta", ci level(95) addlabel(nhelplines, `N_HL', ncalls, `N_C', weighted, "Yes") detail(all) append
tab HCcode if e(sample)
tab helplinename if e(sample)


keep if e(sample) == 1
bysort HCcode: egen mindate = min(ddate)     if helplinecontacts !=0
bysort HCcode: egen maxdate = max(ddate)     if helplinecontacts !=0
format mindate maxdate %td

replace helplinename = "Nr. gegen Kummer (children)" if helplinename == "Nummer gegen Kummer (Kinder/Jugend)"
replace helplinename = "Nr. gegen Kummer (parents)" if helplinename == "Nummer gegen Kummer (Eltern)"
replace helplinename = "MIELI Mental Health" if helplinename == "MIELI Mental Health Finland"
replace helplinename = "Samaritan Befrienders" if helplinename == "The Samaritan Befrienders Hong Kong"


collapse (firstnm) country helplinename dateofoutbreak dateoflockdown mindate maxdate (sum) helplinecontacts , by(HCcode)

gsort -helplinecontacts



restore
global eventtime "ldweek"
forvalues J = 0/12 {
gen week`J'post = 0
replace week`J'post = 1  if $eventtime == `J'
gen week`J'post20 = 0
replace week`J'post20 = 1  if $eventtime == `J' & year == 2020
}
forvalues J = 1/12 {
gen week`J'pre = 0
replace week`J'pre = 1 if  $eventtime == -`J' 
gen week`J'pre20 = 0
replace week`J'pre20 = 1 if  $eventtime == -`J' & year == 2020
}


global ld0wdums "week4pre20 week3pre20 week2pre20 week1pre20  week1post20 week2post20 week3post20 week4post20 week5post20 week6post20 week7post20 week8post20 week9post20 week10post20 week11post20 week12post20"

xtset helplinecode ddate


keep if inrange($eventtime,-4,12)

reghdfe lcalls  $ld0wdums , absorb(helplinecode#year helplinecode#weekofyear helplinecode#weekday) nocons vce(cluster helplinecode#nmonth)
egen totcallsinsamp= sum(helplinecontacts) if e(sample)
local N_C = totcallsinsamp[1]
tab helplinename if e(sample)
local N_HL = r(r)
estadd scalar N_g = r(r), replace
estadd local wtd "\textsc{No}"
est store vols3
frame create eresults
regsave using "$rawdata\cplotVOLsm.dta", ci level(95) addlabel(nhelplines, `N_HL', ncalls, `N_C', weighted, "No") detail(all) replace
frame change default
tab HCcode if e(sample)

reghdfe lcalls  $ld0wdums [aweight=tot_calls], absorb(helplinecode#year helplinecode#weekofyear helplinecode#weekday) nocons vce(cluster helplinecode#nmonth)
drop totcallsinsamp
egen totcallsinsamp= sum(helplinecontacts) if e(sample)
local N_C = totcallsinsamp[1]
tab helplinename if e(sample)
local N_HL = r(r)
estadd scalar N_g = r(r), replace
estadd local wtd "\textsc{Yes}"
est store vols4
frame eresults: regsave using "$rawdata\cplotVOLsm.dta", ci level(95) addlabel(nhelplines, `N_HL', ncalls, `N_C', weighted, "Yes") detail(all) append
tab HCcode if e(sample)
tab helplinename if e(sample)



# delimit ;
estout vols1 vols2 vols3 vols4
 using ".\02_Project\tables\RESULTS_vols.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(wtd N_g N, fmt( %9.0fc %9.0fc %9.0fc) 
  labels("\midrule  Weighted" "\# Helplines" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
  ")          &                      &                      \\" ")          &                      &                      \\[0.17cm]"
   ")          \\" ")          \\[0.17cm]"
      "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(week1post20 "\textit{Week 1}"  
				 week1pre20 "\textit{Week -1}"  
				 week2pre20 "\textit{Week -2}"  
				 week3pre20 "\textit{Week -3}"  
				 week4pre20 "\textit{Week -4}"  
				 week5pre20 "\textit{Week -5}"  
				 week6pre20 "\textit{Week -6}"  
				 week7pre20 "\textit{}"  
				 week8pre20 "\textit{}"  
				 week9pre20 "\textit{}"  
				 week2post20 "\textit{Week 2}"  
				 week3post20 "\textit{Week 3}"  
				 week4post20 "\textit{Week 4}"  
				 week5post20 "\textit{Week 5}"  
				 week6post20 "\textit{Week 6}"  
				 week7post20 "\textit{Week 7}"  
				 week8post20 "\textit{Week 8}"  
				 week9post20 "\textit{Week 9}"  
				 week10post20 "\textit{Week 10}"  
				 week11post20 "\textit{Week 11}"  
				 week12post20 "\textit{Week 12}")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8} \setlength{\tabcolsep}{0.5cm}"
	"\begin{table}[ht!]"
		"\caption{Call volumes during the first wave - event study results \label{RESULTS_vols}}\footnotesize"
		"\begin{tabular}{p{4cm} cccc}\toprule"
		 "Event week 0:& \multicolumn{2}{c}{Local outbreak}& \multicolumn{2}{c}{Shelter-in-place introduction} \\\cmidrule(lr){2-3}\cmidrule(lr){4-5}"
		 "& \multicolumn{1}{c}{(1)}& \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\\midrule")
		 postfoot("\bottomrule\\
		\end{tabular}"			
			"\\\footnotesize \textbf{Note:} Estimation results shown in Figure \ref{cplotVOL}. Dependent variable is log(Lifeline calls+1), standard errors in parentheses are clustered at the state/province-month level.\\
			\end{table}");
# delimit cr



use  "$rawdata\cplotVOL.dta", clear

drop if var == "_cons"

tostring N, gen(N_string) format(%12.0fc) force
local obs= N_string[1]
display "`obs'"

tostring nhelplines, gen(nh_string) format(%12.0fc) force
local hlines= nh_string[1]
display "`hlines'"

tostring ncalls, gen(nc_string) format(%12.0fc) force
local callsum= nc_string[1]
display "`callsum'"


gen lockdownweek0 = .
forvalues J = 0/12 {
replace lockdownweek0 = `J' if var == "week`J'post20"
}
forvalues J = 1/10 {
replace lockdownweek0 = -`J' if var == "week`J'pre20"
}
encode weighted, gen(ecode)
xtset ecode lockdownweek0
tsfill
gen base = 0 if lockdownweek0 == 0
gen ci90_lower = coef-1.645*(stderr)
gen ci95_lower = coef-1.96*(stderr)
gen ci99_lower = coef-2.54*(stderr)

gen ci90_upper = coef+1.645*(stderr)
gen ci95_upper = coef+1.96*(stderr)
gen ci99_upper = coef+2.54*(stderr) 


replace lockdownweek0 = lockdownweek0-0.1 if weighted == "No"
replace lockdownweek0 = lockdownweek0+0.1 if weighted == "Yes"

foreach V of varlist coef ci_upper ci_lower  {
replace `V' = `V' * 100
}

rename lockdownweek0 eventweek
# delimit ;
graph twoway rcap ci_lower ci_upper eventweek if weighted == "No",  color(edkbg) 
		 || scatter coef eventweek if weighted == "No", mc(edkbg)  m(d) msize(large)
		 ||	rcap ci_lower ci_upper eventweek if weighted == "Yes",  color(gs0) 
		 || scatter coef eventweek if weighted == "Yes", mc(gs0)  m(d) msize(large)
		 || scatter base eventweek  , mc(cranberry)  m(s) msize(vlarge)
				scheme(s2color ) legend(label(1 "unweighted") label(3 "weighted") pos(1) ring(0) cols(1) size(medsmall) order(3 1) region(lcolor(white)))  text(52 1.5 "Outbreak", color(cranberry))
			title("{bf:a} ", size(large) color(gs0) pos(11)  span justification(left) margin(small) ) 
		ytitle("Change in daily calls (%)", size(medlarge)) xtitle("Weeks from outbreak", size(medlarge)) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ylabel(-20(10)50, labcolor(gs0) angle(horizontal) labsize(medlarge) axis(1) format(%9.0f)  nogrid ) 
		yscale(range(-25 55)  ) xline(0, lcolor(cranberry) lpattern(shortdash))	
		yline(0, lcolor(edkbg) lwidth(medthin) lpattern(solid))
		xlabel(-4(2)12 , labsize(medlarge) labcolor(gs0) ) 
		name(cplotVOLob, replace) xsize(9) ysize(5) 
		note("N = `obs' daily call volumes" "(`hlines' helplines, `callsum' calls)" , pos(5) ring(0) size(medsmall) color(gs0));
# delimit cr


keep var coef ci_lower ci_upper weighted N N_g ncalls
gen event = "Pandemic outbreak"
*gen panel = "a"
replace var = subinstr(var,"20","",.)
drop if var == ""
format coef ci_lower ci_upper %9.3f
export excel using ".\Revisions_Nature\Final figures\SourceData_Fig1.xlsx", firstrow(varlabels) sheet("Panel a") replace




///////////////////////
use  "$rawdata\cplotVOLsm.dta", clear

drop if var == "_cons"

tostring N, gen(N_string) format(%12.0fc) force
local obs= N_string[1]
display "`obs'"

tostring nhelplines, gen(nh_string) format(%12.0fc) force
local hlines= nh_string[1]
display "`hlines'"

tostring ncalls, gen(nc_string) format(%12.0fc) force
local callsum= nc_string[1]
display "`callsum'"


gen lockdownweek0 = .
forvalues J = 0/12 {
replace lockdownweek0 = `J' if var == "week`J'post20"
}
forvalues J = 1/10 {
replace lockdownweek0 = -`J' if var == "week`J'pre20"
}
encode weighted, gen(ecode)
xtset ecode lockdownweek0
tsfill
gen base = 0 if lockdownweek0 == 0
gen ci90_lower = coef-1.645*(stderr)
gen ci95_lower = coef-1.96*(stderr)
gen ci99_lower = coef-2.54*(stderr)

gen ci90_upper = coef+1.645*(stderr)
gen ci95_upper = coef+1.96*(stderr)
gen ci99_upper = coef+2.54*(stderr) 

replace lockdownweek0 = lockdownweek0-0.1 if weighted == "No"
replace lockdownweek0 = lockdownweek0+0.1 if weighted == "Yes"

foreach V of varlist coef ci_upper ci_lower {
replace `V' = `V' * 100
}

rename lockdownweek0 eventweek

# delimit ;
graph twoway rcap ci_lower ci_upper eventweek if weighted == "No",  color(edkbg) 
		 || scatter coef eventweek if weighted == "No", mc(edkbg)  m(d) msize(large)
		 ||	rcap ci_lower ci_upper eventweek if weighted == "Yes",  color(gs0) 
		 || scatter coef eventweek if weighted == "Yes", mc(gs0)  m(d) msize(large)
		 || scatter base eventweek  , mc(ebblue)  m(s) msize(vlarge)
			scheme(s2color ) legend(label(1 "unweighted") label(3 "weighted") pos(1) ring(0) cols(1) size(medsmall) order(3 1) region(lcolor(white)))
			title("{bf:b} ", size(large) color(gs0) pos(11)  span justification(left) margin(small) ) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Change in daily calls (%)", size(medlarge)) xtitle("Weeks from SIP introduction", size(medlarge)) xline(0, lcolor(ebblue) lpattern(shortdash)) text(52 0.8 "SIP", color(ebblue))
		ylabel(-20(10)50, labcolor(gs0) angle(horizontal) labsize(medlarge) axis(1) format(%9.0f) nogrid ) 
		yscale(range(-25 55)  ) 	
		yline(0, lcolor(edkbg) lwidth(medthin) lpattern(solid))
		xlabel(-4(2)12 , labsize(medlarge) labcolor(gs0) ) 
		name(cplotVOLXsm, replace) xsize(9) ysize(5) 
		note("N = `obs' daily call volumes" "(`hlines' helplines, `callsum' calls)" , pos(5) ring(0) size(medsmall) color(gs0))
		saving(".\02_Project\Figures\cplotVOLXsm.gph", replace);
# delimit cr

graph combine cplotVOLob cplotVOLXsm , cols(2) 	xsize(18.3cm) ysize(6cm) graphregion(color(white)  margin(vsmall)) iscale(1.1) 
		

graph combine cplotVOLob cplotVOLXsm , cols(1) 	xsize(8.9cm) ysize(12.5cm) graphregion(color(white)  margin(small)) altshrink imargin(vsmall)

		graph export ".\02_Project\Figures\cplotVOLXsm.pdf", replace
		graph export ".\02_Project\Figures\cplotVOLXsm.eps", replace
		graph export ".\02_Project\Figures\cplotVOLXsm.png", replace
		
		graph export ".\Revisions_Nature\Final figures\Fig1.pdf", replace
	iscale(1.1) 
keep var coef ci_lower ci_upper weighted N N_g ncalls
gen event = " SIP Introduction"
*gen panel = "b"
replace var = subinstr(var,"20","",.)
drop if var == ""
format coef ci_lower ci_upper %9.3f
export excel using ".\Revisions_Nature\Final figures\Fig1_SourceData.xlsx", firstrow(varlabels) sheet("Panel b") sheetreplace












