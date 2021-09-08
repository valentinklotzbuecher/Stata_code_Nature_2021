
foreach C in GER1 FRA  {

use "$rawdata\merged_series.dta",  clear


keep if HCcode == "`C'"

replace helplinename = "Telefonseelsorge" if helplinename == "Telefonseelsorge Deutschland"
replace helplinename = "Telefonseelsorge" if helplinename == "Telefonseelsorge Österreich"

/*gen xcountry = "{bf:a } Germany" if HCcode == "GER1"
replace xcountry = "{bf:b } France" if HCcode == "FRA"
gen hlc = xcountry + ", " + helplinename
*/
gen xcountry = "{bf:a }" if HCcode == "GER1"
replace xcountry = "{bf:c }" if HCcode == "FRA"
local titletext = xcountry[1]
display `"`titletext'"'

gen wave1 = 0
replace wave1 = 1 if ddate > mdy(3,11,2020) & ddate < mdy(7,1,2020)
egen w1date1 = min(ddate) if wave1 == 1
egen w1date2 = max(ddate) if wave1 == 1

gen wave2 = 0
replace wave2 = 1 if ddate > mdy(9,30,2020)
egen w2date1 = min(ddate) if wave2 == 1
egen w2date2 = max(ddate) if wave2 == 1

format w1date1 w1date2 w2date1 w2date2  %td
foreach V of varlist w1date1 w1date2 w2date1 w2date2 {
sort `V'
replace `V' = `V'[1]
}

sort ddate

replace MA7newcasesPOP = MA7newcasesPOP/10

quietly: sum MA7newcasesPOP , d
 scalar contmax = r(max)*1.5
 scalar contmin = r(min)*0.9
 scalar contlabmin = round(r(min),10)
 scalar contlabmax = round(r(max),10)
local contup = contmax 
local contlup = contlabmax 
local contlo = contmin 
local contllo = contlabmin 
display `contup' 
display `contlo'

cap drop barmin barmax
gen barmin = 0
gen barmax = 100

replace MA7newcasesPOP = 0 if MA7newcasesPOP<0

drop if ddate > mdy(03,31,2021)
 keep if  year >= 2020
 replace MA7helplinecontacts = . if  ddate >mdy(03,31,2021)
 /*
# delimit ;
twoway rbar barmin barmax ddate if wave1==1 | wave2==1 , bcolor(ebg) fintensity(100) yaxis(2) 
	|| line MA7newcasesPOP ddate , lcolor(cranberry) lpattern(solid) yaxis(2)
 || line stringencyindex ddate , lcolor(ebblue) lpattern(solid) yaxis(2)
	|| scatter helplinecontacts ddate , msymbol(o) mcolor(gs0)	msize(tiny) yaxis(1)
 	|| line MA7helplinecontacts  ddate, lcolor(gs0) lpattern(solid) yaxis(1) 
	|| rcap  barmin barmax ddate if year >3000, msymbol(d) lcolor(sky) yaxis(1)
	|| rcap barmin barmax ddate if year >3000, msymbol(d) lcolor(dknavy) yaxis(1)
		scheme(s2color) 
		legend(label(5 "Daily helpline calls") label(2  "Infections/population")  label(3 "Stringency index") label(6 "Change in first wave")  label(7 "Change in subsequent wave") order(5 2 3  6 7) cols(2)  pos(7) ring(1) colfirst size(small) rowgap(0) colgap(30) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Infections rate/index score", xoffset(0) axis(2) size(small)) 
		ytitle("Daily calls", xoffset(0) axis(1) size(small) color(gs0) )	
		title("`titletext'", size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(2) nogrid) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale( axis(2) titlegap(0)) 	
		yscale(axis(1) titlegap(0))
		xtitle(" ", ) 
 		xlabel( , labsize(small) labcolor(gs0) format(%tdMon_CCYY)) 
		xsize(6) ysize(3)
		name(x`C', replace);
# delimit cr
*/
# delimit ;
twoway rbar barmin barmax ddate if wave1==1 | wave2==1 , bcolor(ebg) fintensity(100) yaxis(2) 
	|| line MA7newcasesPOP ddate , lcolor(cranberry) lpattern(solid) yaxis(2)
 || line stringencyindex ddate , lcolor(ebblue) lpattern(solid) yaxis(2)
	|| scatter helplinecontacts ddate , msymbol(o) mcolor(gs0)	msize(tiny) yaxis(1)
 	|| line MA7helplinecontacts  ddate, lcolor(gs0) lpattern(solid) yaxis(1) 
		scheme(s2color) 
		legend(label(5 "Daily helpline calls") label(2  "Infections rate")  label(3 "Stringency index") order(5 2 3) cols(3)  pos(6) ring(1) colfirst size(small)  region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Infections rate/index score", xoffset(0) axis(2) size(small)) 
		ytitle("Daily calls", xoffset(0) axis(1) size(small) color(gs0) )	
		title("`titletext'", size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(2) nogrid) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid) 
		yscale( axis(2) titlegap(0)) 	
		yscale(axis(1) titlegap(0))
		xtitle(" ", ) 
 		xlabel( , labsize(small) labcolor(gs0) format(%tdMon_CCYY)) 
		xsize(6) ysize(3)
		name(x`C', replace);
# delimit cr

keep ddate helplinecontacts helplinename MA7helplinecontacts MA7newcasesPOP stringencyindex
order helplinename ddate helplinecontacts  MA7helplinecontacts MA7newcasesPOP stringencyindex
save "$rawdata\F3_`C'.dta", replace
}
use "$rawdata\F3_GER1.dta", clear
gen panel = "a"
append using "$rawdata\F3_FRA.dta"
replace panel = "b" if panel == ""
 export excel using ".\Revisions_Nature\Final figures\Fig3_SourceData.xlsx", firstrow(varlabels) replace

foreach C in GER1 FRA  {
erase "$rawdata\F3_`C'.dta"
}

foreach C in GER1 FRA  {

use "$rawdata\merged_contacts.dta",  clear


keep if HCcode == "`C'"

gen confirmedcasesPOP = confirmedcases/population

bysort country: egen dateofoutbreak = min(ddate) if confirmedcasesPOP > 10 & confirmedcases != .
bysort country (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
format dateofoutbreak %td
gen outbreakdate = (ddate==dateofoutbreak)


gen wave1 = 0
replace wave1 = 1 if ddate > mdy(3,11,2020) & ddate < mdy(7,1,2020)
egen w1date1 = min(ddate) if wave1 == 1
egen w1date2 = max(ddate) if wave1 == 1

gen wave2 = 0
replace wave2 = 1 if ddate > mdy(9,30,2020)
egen w2date1 = min(ddate) if wave2 == 1
egen w2date2 = max(ddate) if wave2 == 1

format w1date1 w1date2 w2date1 w2date2  %td
foreach V of varlist w1date1 w1date2 w2date1 w2date2 {
sort `V'
replace `V' = `V'[1]
}
bysort HCcode: sum w1date1 w1date2 w2date1 w2date2 
sort ddate

gen inbetweenwaves = 0
replace inbetweenwaves = 1 if ddate > w1date2 & w2date1 > ddate

global topicdummies "lonely suicide violence addiction physhealth  T_econ  T_social othertopic"
global topicdummiesGER3 "lonely suicide violence addiction physhealth  T_econ  T_social othertopic"

global XFE1 "year weekofyear weekday"
global XSE1 "cluster nweek"


gen wavecode = 1 if ddate < w1date1
replace wavecode = 0 if year < 2020
replace wavecode = 2 if wave1
replace wavecode = 3 if inbetweenwaves
replace wavecode = 4  if wave2

bysort wavecode: sum fears
bysort wavecode: sum lonely
global controls ""

reghdfe fears $controls wave1  wave2  , absorb($XFE1) vce($XSE1) nocons
sum fears  if e(sample) == 1
estadd scalar Tmean = r(mean), replace
local Tpremean = r(mean)
local titletext: variable label fears
display "`titletext'"
est store e_`C'_fears
frame eresults: regsave using "$rawdata\cplot`C'.dta", ci level(95) addlabel(depvartitel, fears, titletext, "`titletext'", pre_mean, `Tpremean') detail(all) replace

foreach T in $topicdummies {
reghdfe `T' $controls wave1  wave2 , absorb($XFE1) vce($XSE1) nocons
sum `T'  if e(sample) == 1 
estadd scalar Tmean = r(mean), replace
local Tpremean = r(mean)
local titletext: variable label `T'
display "`titletext'"
est store e_`C'_`T'
frame eresults: regsave using "$rawdata\cplot`C'.dta", ci level(95) addlabel(depvartitel, `T', titletext, "`titletext'", pre_mean, `Tpremean') detail(all) append
}

}


# delimit ;
estout e_GER1_fears e_GER1_lonely  e_GER1_suicide e_GER1_addiction e_GER1_violence  e_GER1_physhealth  e_GER1_T_econ e_GER1_T_social
 using ".\02_Project\tables\RESULTS_F2GER.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(N, fmt( %9.0fc)   labels("\midrule \# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
         "\midrule \# Helplines&           7          &          10          &          12          &          10          &          10          &           9          &           9          &           9          \\" "\midrule \# Helplines&           \multicolumn{1}{c}{7}          &          "
		 "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(_cons "\textit{Constant}"
						  living_alone "\textit{Living alone}"
						  age "\textit{Age}"
						  wave1 "\textit{First wave}"
						  wave2 "\textit{Subseq. wave}"
						  age1 "\textit{Age <30}"
						  age2 "\textit{Age 30-60}"
						  age3 "\textit{Age >60}"
						  suicide "\textit{Suicide}"
						  lonely "\textit{Loneliness}"
						  violence "\textit{Violence}"
						  addiction "\textit{Addiction}"
						  lstringency "log(1+\textit{Stringency index})"
						  postoutbreak "\textit{Post outbreak}"
						  female_age1  "\textit{Female*Age 0-30}"
						  female_age2  "\textit{Female*Age 30-60}"
						  female_age3  "\textit{Female*Age 60+}"
						  male_age1  "\textit{Male*Age 0-30}"
						  male_age2  "\textit{Male*Age 30-60}"
						  male_age3  "\textit{Male*Age 60+}"
						  post_male  "\textit{Post outbreak*Male}"
						  post_female  "\textit{Post outbreak*Female}"
						  post_age1  "\textit{Post outbreak*Age 0-30}"
						  post_age2  "\textit{Post outbreak*Age 30-60}"
						  post_age3  "\textit{Post outbreak*Age 60+}"
						  post_female_age1 "\textit{Post outbreak*Female*Age 0-30}"
						  post_female_age2 "\textit{Post outbreak*Female*Age 30-60}"
						  post_female_age3 "\textit{Post outbreak*Female*Age 60+}"
						  post_male_age1   "\textit{Post outbreak*Male*Age 0-30}"
						  post_male_age2   "\textit{Post outbreak*Male*Age 30-60}"
						  post_male_age3   "\textit{Post outbreak*Male*Age 60+}"
						  female "\textit{Female}")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8}  \setlength{\tabcolsep}{0.2cm}
	\begin{sidewaystable}[ht!]"
		"\caption{ Helpline calls in Germany and France during the first and subsequent waves \label{RESULTS_F2GERFRA}}\footnotesize"
		"\begin{tabular}{p{4.3cm} cccccccc}\toprule"
		 "\textbf{a) Germany}& \multicolumn{1}{c}{(1) Fear}& \multicolumn{1}{c}{(2) Loneliness}& \multicolumn{1}{c}{(3) Suicide} & \multicolumn{1}{c}{(4) Addiction} & \multicolumn{1}{c}{(5) Violence} & \multicolumn{1}{c}{(6) Phys. Health}  & \multicolumn{1}{c}{(7) Livelihood}  & \multicolumn{1}{c}{(8) Relationships}  \\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){2-2}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}")
		 postfoot("\midrule");
# delimit cr


# delimit ;
estout e_FRA_fears e_FRA_lonely  e_FRA_suicide e_FRA_addiction e_FRA_violence  e_FRA_physhealth  e_FRA_T_econ e_FRA_T_social
 using ".\02_Project\tables\RESULTS_F2FRA.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(N, fmt( %9.0fc)   labels("\midrule \# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
		 "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(_cons "\textit{Constant}"
						  living_alone "\textit{Living alone}"
						  wave1 "\textit{First wave}"
						  wave2 "\textit{Subseq. wave}"
						  age "\textit{Age}"
						  age1 "\textit{Age <30}"
						  age2 "\textit{Age 30-60}"
						  age3 "\textit{Age >60}"
						  suicide "\textit{Suicide}"
						  lonely "\textit{Loneliness}"
						  violence "\textit{Violence}"
						  addiction "\textit{Addiction}"
						  lstringency "log(1+\textit{Stringency index})"
						  postoutbreak "\textit{Post outbreak}"
						  female_age1  "\textit{Female*Age 0-30}"
						  female_age2  "\textit{Female*Age 30-60}"
						  female_age3  "\textit{Female*Age 60+}"
						  male_age1  "\textit{Male*Age 0-30}"
						  male_age2  "\textit{Male*Age 30-60}"
						  male_age3  "\textit{Male*Age 60+}"
						  post_male  "\textit{Post outbreak*Male}"
						  post_female  "\textit{Post outbreak*Female}"
						  post_age1  "\textit{Post outbreak*Age 0-30}"
						  post_age2  "\textit{Post outbreak*Age 30-60}"
						  post_age3  "\textit{Post outbreak*Age 60+}"
						  post_female_age1 "\textit{Post outbreak*Female*Age 0-30}"
						  post_female_age2 "\textit{Post outbreak*Female*Age 30-60}"
						  post_female_age3 "\textit{Post outbreak*Female*Age 60+}"
						  post_male_age1   "\textit{Post outbreak*Male*Age 0-30}"
						  post_male_age2   "\textit{Post outbreak*Male*Age 30-60}"
						  post_male_age3   "\textit{Post outbreak*Male*Age 60+}"
						  female "\textit{Female}")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\textbf{b) France}& \multicolumn{1}{c}{(1) Fear}& \multicolumn{1}{c}{(2) Loneliness}& \multicolumn{1}{c}{(3) Suicide} & \multicolumn{1}{c}{(4) Addiction} & \multicolumn{1}{c}{(5) Violence} & \multicolumn{1}{c}{(6) Phys. Health}  & \multicolumn{1}{c}{(7) Livelihood}  & \multicolumn{1}{c}{(8) Relationships}  \\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){2-2}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}")
		 postfoot("\bottomrule\\
		\end{tabular}\\"			
			"\footnotesize \textbf{Note:} Separate linear probability models, dependent variable is equal to one for calls related to the respective category. Estimated coefficients with 95\% confidence intervals in brackets. The sample includes all calls during the time from 1 January 2019 to 30 June 2020. Models include year, week-of-year and day-of-week fixed effects, standard errors are clustered at the helpline-week level. See Materials and methods, equation \ref{eq:wave2}.\\
	\end{sidewaystable}")
	;
# delimit cr



use "$rawdata\cplotGER1.dta", clear

drop if var == "age1"
drop if var == "age3"
drop if var == "_cons"
gen zero = 0

cap drop vxnum
gen vxnum =     1 if  depvartitel ==  "T_social" &  var == "wave2"
replace vxnum = 2 if  depvartitel ==  "T_social" &  var == "wave1"

replace vxnum = 4 if  depvartitel ==  "T_econ" & var == "wave2"
replace vxnum = 5 if  depvartitel ==  "T_econ" & var == "wave1"

replace vxnum = 7 if  depvartitel ==  "physhealth" & var == "wave2"
replace vxnum = 8 if  depvartitel ==  "physhealth" & var == "wave1"

replace vxnum = 10 if  depvartitel ==  "violence" & var == "wave2"
replace vxnum = 11 if  depvartitel ==  "violence" & var == "wave1"

replace vxnum = 13 if  depvartitel ==  "addiction" & var == "wave2"
replace vxnum = 14 if  depvartitel ==  "addiction" & var == "wave1"

replace vxnum = 16 if  depvartitel ==  "suicide" & var == "wave2"
replace vxnum = 17 if  depvartitel ==  "suicide" & var == "wave1"

replace vxnum = 19 if  depvartitel ==  "lonely" &  var == "wave2"
replace vxnum = 20 if  depvartitel ==  "lonely" &  var == "wave1"

replace vxnum = 22 if  depvartitel == "fears"  &  var == "wave2"
replace vxnum = 23 if  depvartitel == "fears"  &  var == "wave1"


replace coef = coef*100
replace ci_upper = ci_upper*100
replace ci_lower = ci_lower*100

tostring N , gen(N_string) format(%12.0fc) force
local N= N_string[18]
display "`N'"

# delimit ;
graph twoway  rbar  zero coef vxnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.8)
		  ||   rcap ci_upper ci_lower vxnum if  var == "wave1", horizontal  color(sky)
		  || scatter  vxnum coef if  var == "wave1" , mc(sky)  m(d)
		  || rcap ci_upper ci_lower vxnum if  var == "wave2" , horizontal  color(dknavy)
		  || scatter  vxnum coef if  var == "wave2", mc(dknavy)  m(d)
				scheme(s2color )  legend(label(2 "First wave")  label(4 "Subsequent waves") order(2 4)  cols(2)  pos(6) ring(1)  colfirst size(small) region(lcolor(white))) 
		graphregion(color(white) ) plotregion(color(white)   margin(small)) bgcolor(white) 
		xtitle("Percentage-points", axis(1) size(small)) 
		ytitle("")  xline(0, lcolor(ebg) lwidth(thin) lpattern(solid))
		title("{bf:b }", size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 
		ylabel( 22.5  "Fears (infection)"  19.5 "Loneliness" 16.5 "Suicidality"  13.5 "Addiction"   10.5 "Violence"  7.5 "Physical health" 4.5 "Livelihood"  1.5 "Relationships" , nogrid labsize(small) angle(horizontal) labcolor(gs0) )
		note("N=`N' calls", pos(5) ring(0) size(small))
		xlabel(-4(1)3, labsize(small) labcolor(gs0) ) fxsize(80)
		name(plotGER1, replace) ;
# delimit cr

replace N = N[1]
 gsort- vxnum
 drop if vxnum == .
 rename titletext topic
 gen helpline = "Telefonseelsorge, Germany"
keep helpline  topic var coef stderr ci_lower ci_upper N 
order helpline   topic var coef stderr ci_lower ci_upper N
 export excel using ".\Revisions_Nature\Final figures\Fig3_SourceData.xlsx", firstrow(varlabels) sheet("Results GER") sheetreplace
 

use "$rawdata\cplotFRA.dta", clear

drop if var == "age1"
drop if var == "age3"
drop if var == "_cons"
gen zero = 0

cap drop vxnum
gen vxnum =     1 if  depvartitel ==  "T_social" &  var == "wave2"
replace vxnum = 2 if  depvartitel ==  "T_social" &  var == "wave1"

replace vxnum = 4 if  depvartitel ==  "T_econ" & var == "wave2"
replace vxnum = 5 if  depvartitel ==  "T_econ" & var == "wave1"

replace vxnum = 7 if  depvartitel ==  "physhealth" & var == "wave2"
replace vxnum = 8 if  depvartitel ==  "physhealth" & var == "wave1"

replace vxnum = 10 if  depvartitel ==  "violence" & var == "wave2"
replace vxnum = 11 if  depvartitel ==  "violence" & var == "wave1"

replace vxnum = 13 if  depvartitel ==  "addiction" & var == "wave2"
replace vxnum = 14 if  depvartitel ==  "addiction" & var == "wave1"

replace vxnum = 16 if  depvartitel ==  "suicide" & var == "wave2"
replace vxnum = 17 if  depvartitel ==  "suicide" & var == "wave1"

replace vxnum = 19 if  depvartitel ==  "lonely" &  var == "wave2"
replace vxnum = 20 if  depvartitel ==  "lonely" &  var == "wave1"

replace vxnum = 22 if  depvartitel == "fears"  &  var == "wave2"
replace vxnum = 23 if  depvartitel == "fears"  &  var == "wave1"

replace coef = coef*100
replace ci_upper = ci_upper*100
replace ci_lower = ci_lower*100


tostring N , gen(N_string) format(%12.0fc) force
local N= N_string[1]
display "`N'"
# delimit ;
graph twoway rbar  zero coef vxnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.8)
		  ||   rcap ci_upper ci_lower vxnum if  var == "wave1", horizontal  color(sky)
		  || scatter  vxnum coef if  var == "wave1" , mc(sky)  m(d)
		  || rcap ci_upper ci_lower vxnum if  var == "wave2" , horizontal  color(dknavy)
		  || scatter  vxnum coef if  var == "wave2", mc(dknavy)  m(d)
				scheme(s2color )  legend(label(2 "First wave")  label(4 "Subsequent waves") order(2 4) cols(2)  pos(6) ring(1) colfirst size(small) region(lcolor(white))) 
		graphregion(color(white) ) plotregion(color(white)   margin(small)) bgcolor(white) 
		xtitle("Percentage-points", axis(1) size(small)) 
		ytitle("") 	
		title("{bf: d}", size(medsmall) color(gs0) pos(11) ring(1) span justification(left) )
		xline(0, lcolor(ebg) lwidth(thin) lpattern(solid))
			ylabel( 22.5  "Fears (infection)"  19.5 "Loneliness" 16.5 "Suicidality"  13.5 "Addiction"   10.5 "Violence"  7.5 "Physical health" 4.5 "Livelihood"  1.5 "Relationships" , nogrid labsize(small) angle(horizontal) labcolor(gs0) )
		note("N=`N' calls", pos(5) ring(0) size(small))
		xlabel(-4(1)3, labsize(small) angle(horizontal)  labcolor(gs0) ) fxsize(80)
		name(plotFRA, replace) ;
# delimit cr

 gsort- vxnum
 drop if vxnum == .
 rename titletext topic
 gen helpline = "Telefonseelsorge, Germany"
keep helpline  topic var coef stderr ci_lower ci_upper N 
order helpline   topic var coef stderr ci_lower ci_upper N
 export excel using ".\Revisions_Nature\Final figures\Fig3_SourceData.xlsx", firstrow(varlabels) sheet("Results FRA") sheetreplace

*grc1leg  xGER1 plotGER1 xFRA plotFRA , cols(2) imargin(medsmall)  	xsize(18.3cm) ysize(7cm)  graphregion(color(white) margin(small) ) 
graph combine xGER1 plotGER1 xFRA plotFRA , cols(2) imargin(medsmall) 	xsize(18.3cm) ysize(9cm)  graphregion(color(white) margin(small) ) 
graph export ".\02_Project\Figures\exhibit2.pdf", replace
graph export ".\02_Project\Figures\exhibit2.png", replace


		graph export ".\Revisions_Nature\Final figures\Fig3.pdf", replace
















