


use "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\USstatepanel.dta", clear

keep if countryname == "United States"


reghdfe lcalls lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nweek)  vce(cluster statenum#nmonth) nocons

keep if e(sample) 

egen overallcalls= sum(lifelinecalls)
egen overallddhcalls= sum(ddhcalls)
sum overallcalls overallddhcalls

reghdfe lcalls, absorb( statenum)  vce($SE) nocons resid

gen resid = _reghdfe_resid*100
bysort nweek : egen meanres = mean(resid)


gen ddhcallsPOP = ddhcalls/population*100000

bysort nweek : egen meanstringeny = mean(stringencyindex)
bysort nweek : egen meancovid = mean(newcasesPOP)
bysort nweek : egen meansupport = mean(ie1_incomesupport)
bysort nweek : egen meanllcalls = mean(lcalls)
bysort nweek : egen meancalls = mean(lifelinecalls)
bysort nweek : egen totalcalls = sum(lifelinecalls)
bysort nweek : egen meanddhcalls = mean(ddhcallsPOP)
bysort nweek : egen p25llcalls = pctile(lifelinecallsPOP), p(25)
bysort nweek : egen p50llcalls = pctile(lifelinecallsPOP), p(50)
bysort nweek : egen p75llcalls = pctile(lifelinecallsPOP), p(75) 

gen wdate = yw(year(ddate),week(ddate))

xtset statenum nweek
tsfill
mvsumm totalcalls, gen(MA7totalcalls) stat(mean) window(3) force




replace nweek = nweek-52 if nweek>52
replace nweek = nweek-52 if nweek>52
replace totalcalls = totalcalls/1000
replace MA7totalcalls = MA7totalcalls/1000

# delimit ;
twoway scatter totalcalls nweek if year == 2019 , msymbol(d) mcolor(edkbg)	msize(small) yaxis(1)
 	|| line MA7totalcalls  nweek if year == 2019 & statecode == "TX", lcolor(edkbg) lpattern(solid)  yaxis(1) connect(ascending)
	|| scatter totalcalls nweek if year == 2020, msymbol(d) mcolor(gs0)	msize(small) yaxis(1)
 	|| line MA7totalcalls  nweek if year == 2020& statecode == "TX", lcolor(gs0) lpattern(solid) yaxis(1)  connect(ascending)
	|| scatter totalcalls nweek if year == 2021, msymbol(d) mcolor(eltblue)	msize(small) yaxis(1)
 	|| line MA7totalcalls  nweek if year == 2021& statecode == "TX" & nweek <12, lcolor(eltblue) lpattern(solid) yaxis(1)  connect(ascending)
	  scheme(s2color) legend(label(2 "2019") label(4 "2020") label(6 "2021") order(6 4 2)  cols(1)  region(lcolor(white)) pos(5) ring(0) size(medsmall)) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Weekly calls ('000)", xoffset(-1) axis(1) size(medsmall)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		yscale(range(25 40) axis(1) titlegap(0)) 	
		title("{bf:a}   ",  size(medium) color(gs0) pos(11) ring(1) span justification(left)) 	
		xtitle("", yoffset(-2)) 
xlabel(2.5 `""J" " ""' 7 "F" 11.5 "M" 16 "A" 20 "M" 24.5 "J" 29 "J" 33 "A" 37.5 "S" 42 "O" 46 "N" 50 "D", labsize(medsmall) labcolor(gs0) notick)
		xtick(1 5 9 14 18 22 27 31 35 40 44 48 52) fxsize(75)
		name(xlflnllc, replace);
# delimit cr


preserve
keep if wdate !=.
bysort wdate: keep if _n ==1
keep wdate totalcalls MA7totalcalls
format wdate %tw
sort wdate
rename MA7totalcalls MA3totalcalls
order wdate totalcalls MA3totalcalls
lab var totalcalls "US Lifeline calls, weekly total"
lab var MA3totalcalls "US Lifeline call volume, 3-Week moving average"
 export excel using ".\Revisions_Nature\Final figures\Fig4_SourceData.xlsx", firstrow(varlabels) sheet("Panel a") replace


restore


replace nweek = nweek+52 if year == 2021 
// graph export ".\02_Project\Figures\lcallsresid.pdf", replace 


# delimit ;
twoway  line resid wdate if year !=2019 , lcolor(edkbg) lpattern(solid) yaxis(1) connect(ascending) lwidth(vthin)
	|| line meanres wdate   if year !=2019 & statecode == "TX" , lcolor(gs0) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(thin)  
	  scheme(s2color) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Call deviation (%)", xoffset(-1) axis(1) size(medlarge)) 
		ylabel(-50 -25 0 25 50, labcolor(gs0) angle(horizontal) labsize(medlarge) axis(1) nogrid) 
		yscale(range(-50 50) axis(1) titlegap(0)) 	
		title("{bf:b}  ",  size(large) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		xtitle("", yoffset(-2)) 
xlabel(3120(26)3170, labsize(medlarge) labcolor(gs0) format(%twMon_CCYY))	
		name(xlfln, replace);
# delimit cr

# delimit ;
twoway line stringencyindex wdate if year > 2019 , lcolor(edkbg) lpattern(solid) yaxis(1)  connect(ascending) lwidth(vthin)
		|| line meanstringeny wdate if year > 2019 & statecode == "TX", lcolor(ebblue) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(thin)  
		scheme(s2color) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1) size(medlarge)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(medlarge) axis(1) nogrid) 
		yscale( axis(1) titlegap(0)) xtitle("")	
		ytitle("Stringency index", size(medlarge)) 
		xsize(6) ysize(3.5) 		title("{bf:d}  ",  size(large) color(gs0) pos(11) ring(1) span justification(left)) 	 	
xlabel(3120(26)3170, labsize(medlarge) labcolor(gs0) format(%twMon_CCYY))	
		name(xlflns, replace);
# delimit cr


# delimit ;
twoway line ie1_incomesupport wdate if year > 2019, lcolor(edkbg) lpattern(solid) yaxis(1)  connect(ascending) lwidth(vthin)
		|| line meansupport wdate if year > 2019 & statecode == "TX", lcolor(gold*1.2) lpattern(solid) yaxis(1) lwidth(thin) connect(ascending)  	
		scheme(s2color) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1) size(medlarge)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(medlarge) axis(1) nogrid) 
		yscale( axis(1) titlegap(0)) 	xtitle("")
		ytitle("Income supp. index", size(medlarge)) 		title("{bf:e}  ",  size(large) color(gs0) pos(11) ring(1) span justification(left)) 	 	
xlabel(3120(26)3170, labsize(medlarge) labcolor(gs0) format(%twMon_CCYY))	
		name(xlflne, replace);
# delimit cr


# delimit ;
twoway line newcasesPOP wdate if year > 2019 , lcolor(edkbg) lpattern(solid) yaxis(1)  connect(ascending) lwidth(vthin)
		|| line meancovid wdate  if year > 2019 & statecode == "TX" , lcolor(cranberry) lpattern(solid) yaxis(1) lwidth(thin) connect(ascending)  	
		scheme(s2color) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("", xoffset(-1) axis(1) size(medlarge)) 
		ylabel(0(300)1200, labcolor(gs0) angle(horizontal) labsize(medlarge) axis(1) nogrid) 
		yscale( axis(1) titlegap(0)) 	xtitle("")
		ytitle("Infections rate", size(medlarge)) title("{bf:c}  ",  size(large) color(gs0) pos(11) ring(1) span justification(left)) 	 	
xlabel(3120(26)3170, labsize(medlarge) labcolor(gs0) format(%twMon_CCYY))	
		name(xlflnc, replace);
# delimit cr


preserve
keep if year > 2019
keep state wdate resid meanres  newcasesPOP meancovid ie1_incomesupport meansupport stringencyindex meanstringeny
format wdate %tw
sort wdate
order state wdate resid meanres  newcasesPOP meancovid ie1_incomesupport meansupport stringencyindex meanstringeny
sort state wdate
drop if state == ""
lab var resid "Residual (log deviation)"
lab var meanres "Residual (log deviation), US average"
 export excel using ".\Revisions_Nature\Final figures\Fig4_SourceData.xlsx", firstrow(varlabels) sheet("Panels b-e") sheetreplace


restore



use "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\USstatepanel.dta", clear


global DEPVAR "lcalls"
global SE "cluster statenum#nmonth"

global FE "statenum nweek"
global F2E "statenum nmonth week"

global Xcovid "lnewcasesPOP"
global Xstrngncy "lstringencyindex"
global Xecnspprt "leconomicsupportindex"


keep if countryname == "United States"

xtset statenum nweek

reghdfe $DEPVAR lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb($FE)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
egen callsumsample = sum(lifelinecalls) if e(sample)
sum callsumsample, meanonly
estadd scalar N_calls = r(mean)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store e_baseline

regsave using "$rawdata\cplotnoCA.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "baseline") detail(all) replace

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb($FE)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
cap drop callsumsample
egen callsumsample = sum(lifelinecalls) if e(sample)
sum callsumsample, meanonly
estadd scalar N_calls = r(mean)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store e_interacted
regsave using "$rawdata\cplotnoCA.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "interacted") detail(all) append


reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell1
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe1") detail(all) replace

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum month year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local mfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell2
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe2") detail(all) append

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum week year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell3
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe3") detail(all) append

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nmonth)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
est store ell4
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe4") detail(all) append


reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nweek)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store ell5
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe5") detail(all) append


reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nmonth week)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
est store ell6
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe6") detail(all) append

// ell2  
# delimit ;
estout ell1 ell4 ell6 ell5
 using ".\02_Project\tables\RESULTS_USxCA_R1.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(sfe yfe nmfe wfe  nwfe N_g N, fmt( %9.0fc %9.0fc %9.0fc  %9.0fc %9.0fc %9.0fc %9.0fc) 
  labels("\midrule State/province FE" "Year FE" "Month FE" "Week-of-year FE" "Week FE" "\# States/provinces" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
   "]          \\" "]          \\[0.17cm]"
   "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(stringencyindex "\textit{Stringency index}"
						  economicsupportindex "\textit{Economic supportindex}"
						  newcasesPOP "\textit{Infections/population}"
						  newdeathsPOP "\textit{COVID-19 deaths rate}"
						  lstringencyindex "log(\textit{Stringency index}+1)"
						  leconomicsupportindex "log(\textit{Economic support index}+1)"
						  lnewcasesPOP "log(\textit{Infections/population}+1)"
						  fhlstringencyindex "\textit{Jan-Aug}*log(\textit{Stringency index}+1)"
						  fhleconomicsupportindex "\textit{Jan-Aug}*log(\textit{Economic support index}+1)"
						  fhlnewcasesPOP "\textit{Jan-Aug}*log(\textit{Infections/population}+1)"
						  shlstringencyindex "\textit{Sep-Mar}*log(\textit{Stringency index}+1)"
						  li_e1_incomesupport "log(\textit{Income support index}+1)"
						  li_e2_debtcontractrelief "log(\textit{Debt relief index}+1)"
						  shleconomicsupportindex "\textit{Sep-Mar}*log(\textit{Economic support index}+1)"
						  fhli_e1_incomesupport "\textit{Jan-Aug}*log(\textit{Income support index}+1)"
						  shli_e1_incomesupport "\textit{Sep-Mar}*log(\textit{Income support index}+1)"
						  shlnewcasesPOP "\textit{Sep-Mar}*log(\textit{Infections/population}+1)"
						  lnewdeathsPOP "log(\textit{COVID-19 deaths rate})")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8} \setlength{\tabcolsep}{0.3cm} \begin{table}[ht!]"
		"\caption{Lifeline calls across US states \label{RESULTS_US_R1}}\footnotesize"
		"\begin{tabular}{p{6.5cm}  cccc}\toprule"
		 "& \multicolumn{1}{c}{(1)}& \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\\midrule")
		 postfoot("\bottomrule
			\end{tabular}\\[0.2cm]
			\footnotesize \textbf{Note:} Sub-national panel model including state and week fixed effects, dependent variable is \$\log(\textit{Lifeline calls}+1)\$ and independent variables are measured in logs as well. Estimated coefficients with 95\% confidence intervals, standard errors are clustered at the state-month level. See Methods and materials, equation \ref{eq:CSEp}. 
			\end{table}");
# delimit cr


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
cap drop callsumsample
egen callsumsample = sum(lifelinecalls) if e(sample)
sum callsumsample, meanonly
estadd scalar N_calls = r(mean)
estadd local sfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell1
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe1") detail(all) replace

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum month year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local mfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell2
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe2") detail(all) append

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum week year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell3
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe3") detail(all) append

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum nmonth)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
est store ell4
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe4") detail(all) append


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum nweek)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store ell5
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe5") detail(all) append


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum nmonth week)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
est store ell6
regsave using "$rawdata\cplotUSfeLONGcomp.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe6") detail(all) append

// ell2  
# delimit ;
estout ell1 ell4 ell6 ell5
 using ".\02_Project\tables\RESULTS_USxCA_R2.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(sfe yfe nmfe wfe  nwfe N_g N, fmt( %9.0fc %9.0fc %9.0fc  %9.0fc %9.0fc %9.0fc %9.0fc) 
  labels("\midrule State/province FE" "Year FE" "Month FE" "Week-of-year FE" "Week FE" "\# States/provinces" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
   "]          \\" "]          \\[0.17cm]"
   "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(stringencyindex "\textit{Stringency index}"
						  economicsupportindex "\textit{Economic supportindex}"
						  newcasesPOP "\textit{Infections/population}"
						  newdeathsPOP "\textit{COVID-19 deaths rate}"
						  lstringencyindex "log(\textit{Stringency index}+1)"
						  leconomicsupportindex "log(\textit{Economic support index}+1)"
						  lnewcasesPOP "log(\textit{Infections/population}+1)"
						  fhlstringencyindex "\textit{Jan-Aug}*log(\textit{Stringency index}+1)"
						  fhleconomicsupportindex "\textit{Jan-Aug}*log(\textit{Economic support index}+1)"
						  fhlnewcasesPOP "\textit{Jan-Aug}*log(\textit{Infections/population}+1)"
						  shlstringencyindex "\textit{Sep-Mar}*log(\textit{Stringency index}+1)"
						  li_e1_incomesupport "log(\textit{Income support index}+1)"
						  li_e2_debtcontractrelief "log(\textit{Debt relief index}+1)"
						  shleconomicsupportindex "\textit{Sep-Mar}*log(\textit{Economic support index}+1)"
						  fhli_e1_incomesupport "\textit{Jan-Aug}*log(\textit{Income support index}+1)"
						  shli_e1_incomesupport "\textit{Sep-Mar}*log(\textit{Income support index}+1)"
						  shlnewcasesPOP "\textit{Sep-Mar}*log(\textit{Infections/population}+1)"
						  lnewdeathsPOP "log(\textit{COVID-19 deaths rate})")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8}  \setlength{\tabcolsep}{0.3cm}\begin{table}[ht!]"
		"\caption{Lifeline calls across US states: Interacted model  \label{RESULTS_US_R2}}\footnotesize"
		"\begin{tabular}{p{6.5cm}  cccc}\toprule"
		 "& \multicolumn{1}{c}{(1)}& \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\\midrule")
		 postfoot("\bottomrule
			\end{tabular}\\[0.2cm]
			\footnotesize \textbf{Note:} Sub-national panel model including state and week fixed effects, dependent variable is \$\log(\textit{Lifeline calls}+1)\$ and independent variables are measured in logs as well. Estimated coefficients with 95\% confidence intervals, standard errors are clustered at the state-month level. See Methods and materials, equation \ref{eq:CSEp}. 
			\end{table}");
# delimit cr




use "$rawdata\cplotnoCA.dta", clear


gen zero = 0
gen vxnum =     10 if var == "li_e1_incomesupport"  & titletext == "baseline"
replace vxnum = 11 if var == "lstringencyindex" & titletext == "baseline"
replace vxnum = 12 if var == "lnewcasesPOP" & titletext == "baseline"

keep if titletext == "baseline"


tostring N_calls , gen(N_calls_string) format(%12.0fc) force
local N_calls= N_calls_string[1]
display "`N_calls'"

tostring N , gen(N_string) format(%12.0fc) force
local N= N_string[1]
display "`N'"

tostring N_g , gen(N_g_string) format(%12.0fc) force
local N_g= N_g_string[1]
display "`N_g'"

# delimit ;
graph twoway rbar  zero coef vxnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.65)
		  ||   rcap ci_upper ci_lower vxnum if  var == "li_e1_incomesupport" , horizontal  color(gold*1.2)
		  || scatter  vxnum coef if  var == "li_e1_incomesupport" , mc(gold*1.2)  m(d)
		  ||  rcap ci_upper ci_lower vxnum if  var == "lstringencyindex", horizontal  color(ebblue)
		  || scatter  vxnum coef if  var == "lstringencyindex" , mc(ebblue)  m(d)
		  ||  rcap ci_upper ci_lower vxnum if  var == "lnewcasesPOP" , horizontal  color(cranberry)
		  ||  scatter  vxnum coef if  var == "lnewcasesPOP", mc(cranberry)  m(d)
				scheme(s2color )   legend(off) 
		graphregion(color(white) ) plotregion(color(white)   margin(small)) bgcolor(white) 
		xtitle("Coefficient (elasticity)", size(medsmall))	ytitle("") 
		title("{bf:f}",  size(medium) color(gs0) pos(11) ring(1) span justification(left)) 	
		ylabel(10 "Income supp. index"  11 "Stringency index" 12 "Infections rate" ,angle(horizontal)   labsize(medsmall) labcolor(gs0) nogrid)
		xlabel(-0.04 "-0.04" -0.02 "-0.02" 0 "0" 0.04 "0.04" 0.02 "0.02"0.06 "0.06", labsize(medsmall) labcolor(gs0) format(%9.2f) )
				note("  N = `N' weekly call volumes" " (`N_g' states, `N_calls' calls)", pos(5) ring(0) span justification(right) size(medsmall))
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		name(cplot3P, replace) ;
# delimit cr
		

		




		


use "$rawdata\cplotnoCA.dta", clear

gen zero = 0

keep if titletext == "interacted" 


gen vxnum =    .


replace vxnum = 8 if var == "fhlnewcasesPOP" & titletext == "interacted"
replace vxnum = 7 if var == "shlnewcasesPOP" & titletext == "interacted"

replace vxnum = 5.5 if var == "fhlstringencyindex" & titletext == "interacted"
replace vxnum = 4.5 if var == "shlstringencyindex" & titletext == "interacted"

replace vxnum = 3  if var == "fhli_e1_incomesupport"  & titletext == "interacted"
replace vxnum = 2  if var == "shli_e1_incomesupport"  & titletext == "interacted"


tostring N_calls , gen(N_calls_string) format(%12.0fc) force
local N_calls= N_calls_string[1]
display "`N_calls'"

tostring N , gen(N_string) format(%12.0fc) force
local N= N_string[1]
display "`N'"

tostring N_g , gen(N_g_string) format(%12.0fc) force
local N_g= N_g_string[1]
display "`N_g'"


 
# delimit ;
graph twoway  rbar  zero coef vxnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(1)
		  ||  rcap ci_upper ci_lower vxnum if  var == "li_e1_incomesupport" | var == "shli_e1_incomesupport"| var == "fhli_e1_incomesupport", horizontal  color(gold*1.1)
		  || scatter  vxnum coef if  var == "li_e1_incomesupport" | var == "shli_e1_incomesupport" | var == "fhli_e1_incomesupport", mc(gold*1.1)  m(d)
		  ||  rcap ci_upper ci_lower vxnum if  var == "lstringencyindex" | var == "shlstringencyindex" | var == "fhlstringencyindex", horizontal  color(ebblue)
		  || scatter  vxnum coef if  var == "lstringencyindex" | var == "shlstringencyindex" | var == "fhlstringencyindex", mc(ebblue)  m(d)
		  ||  rcap ci_upper ci_lower vxnum if  var == "lnewcasesPOP" | var == "shlnewcasesPOP" | var == "fhlnewcasesPOP", horizontal  color(cranberry)
		  ||  scatter  vxnum coef if  var == "lnewcasesPOP" | var == "shlnewcasesPOP" | var == "fhlnewcasesPOP", mc(cranberry)  m(d)
				scheme(s2color )   legend(off) 
		graphregion(color(white) ) plotregion(color(white)   margin(small)) bgcolor(white) 
		xtitle("Coefficient (elasticity)", size(medsmall))	ytitle("") 
		title("{bf:g} ",  size(medsmall) color(gs0) pos(11) ring(1) span justification(left)) 	
		ylabel(3 "Income supp. index: Jan-Aug " 5.5 "Stringency index: Jan-Aug " 8 "Infections rate: Jan-Aug " 2 "Sep-Mar "  4.5 "Sep-Mar " 7 "Sep-Mar " ,  labcolor(gs0) angle(horizontal) labsize(medsmall) notick nogrid) 	ytick(2 3 4.5 5.5 7 8)	
		note("  N = `N' weekly call volumes" " (`N_g' states, `N_calls' calls)", pos(5) ring(0) span justification(right) size(medsmall))
		xlabel(-0.05 "-0.05" 0 "0"  0.05 "0.05" 0.1 "0.10", labsize(medsmall) labcolor(gs0) format(%9.2f) )
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		name(cplot3Px, replace) ;
		# delimit cr
		
/*
graph combine xlflnllc xlfln	, cols(2)			name(grc0, replace) 

graph combine  xlflnc  xlflns xlflne, name(grc1, replace) cols(3)  imargin(vsmall)

		

graph combine cplot3P cplot3Px 	, cols(2)  imargin(medsmall) 	name(grc2, replace) 

graph combine grc0 grc1 grc2	, imargin(tiny)  cols(1) ysize(10cm) xsize(18.3cm) plotregion(color(white)   margin(zero))  graphregion(color(white)  margin(vsmall)) //  
*/

graph combine cplot3P cplot3Px 	, cols(2)  imargin(medsmall) 	name(grc2, replace)  fysize(40) 
	
graph combine xlfln xlflnc  xlflns xlflne 	, cols(2)  imargin(medsmall) 	name(grcX2, replace)  
graph combine xlflnllc grcX2	, cols(2)			name(grc0, replace) 
graph combine grc0 grc2	, imargin(tiny)  cols(1) ysize(10cm) xsize(18.3cm) plotregion(color(white)   margin(zero))  graphregion(color(white)  margin(vsmall))  
	
	graph export ".\02_Project\Figures\exhibit4noCA.pdf", replace
	
		graph export ".\Revisions_Nature\Final figures\Fig4.pdf", replace
	*	graph export ".\Revisions_Nature\Final figures\Fig4.png", replace
	
	


use "$rawdata\cplotnoCA.dta", clear
	
gen panel = "f" if titletext == "baseline" 	
replace panel = "g" if titletext == "interacted" 
	
	gen topic = titletext
	label variable N_g "Number of helplines"
	
gen varname = "Stringency index" if var == "lstringencyindex" |  var == "fhlstringencyindex"|  var == "shlstringencyindex"
replace varname = "Income support index" if var  == "li_e1_incomesupport"|  var == "fhli_e1_incomesupport"|  var == "shli_e1_incomesupport"
replace varname = "Infections rate" if var== "lnewcasesPOP"|  var == "fhlnewcasesPOP"|  var == "shlnewcasesPOP"
gen period = "January 2020 - August 2020" if substr(var,1,2) == "fh"
replace period = "September 2020 - March 2021" if substr(var,1,2) == "sh"
keep coef varname period coef stderr ci_lower ci_upper N N_calls N_g panel
order  panel varname period coef  stderr ci_lower ci_upper N N_g 

 export excel using ".\Revisions_Nature\Final figures\Fig4_SourceData.xlsx", firstrow(varlabels) sheet("Panels f-g") sheetreplace

 



	