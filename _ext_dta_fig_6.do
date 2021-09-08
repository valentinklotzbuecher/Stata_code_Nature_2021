

use "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\USstatepanel.dta", clear



keep if countryname == "United States"

reghdfe lddhcalls lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nweek)  vce(cluster statenum#nmonth) nocons

keep if e(sample) 
egen mobility = rowmean(GMretailrec GMgrocpharm GMtransit GMworkpl)

reghdfe lddhcalls, absorb( statenum)  vce($SE) nocons resid

gen resid = _reghdfe_resid*100
bysort nweek : egen meanres = mean(resid)


gen ddhcallsPOP = ddhcalls/population*100000

bysort nweek : egen meanmobility = mean(mobility)
bysort nweek : egen meanstringeny = mean(stringencyindex)
bysort nweek : egen meancovid = mean(newcasesPOP)
bysort nweek : egen meansupport = mean(ie1_incomesupport)
bysort nweek : egen meanllcalls = mean(lcalls)
bysort nweek : egen meancalls = mean(ddhcalls)
bysort nweek : egen totalcalls = sum(ddhcalls)
bysort nweek : egen meanddhcalls = mean(ddhcallsPOP)
bysort nweek : egen p25llcalls = pctile(lifelinecallsPOP), p(25)
bysort nweek : egen p50llcalls = pctile(lifelinecallsPOP), p(50)
bysort nweek : egen p75llcalls = pctile(lifelinecallsPOP), p(75) 

bysort statenum :  egen overallcalls = sum(ddhcalls)
tab state if overallcalls < 100
tab countryname if overallcalls > 100
drop if overallcalls < 100


xtset statenum nweek
tsfill
mvsumm totalcalls, gen(MA7totalcalls) stat(mean) window(3) force
gen wdate = yw(year(ddate),week(ddate))



replace nweek = nweek-52 if nweek>52
replace nweek = nweek-52 if nweek>52
replace totalcalls = totalcalls/1000
replace MA7totalcalls = MA7totalcalls/1000

# delimit ;
twoway scatter totalcalls nweek if year == 2019 , msymbol(d) mcolor(edkbg)	msize(small) yaxis(1)
 	|| line MA7totalcalls  nweek if year == 2019 & statecode == "TX", lcolor(edkbg) lpattern(solid)  yaxis(1) connect(ascending)
	|| scatter totalcalls nweek if year == 2020, msymbol(d) mcolor(gs0)	msize(vsmall) yaxis(1)
 	|| line MA7totalcalls  nweek if year == 2020& statecode == "TX", lcolor(gs0) lpattern(solid) yaxis(1)  connect(ascending)
	|| scatter totalcalls nweek if year == 2021, msymbol(d) mcolor(eltblue)	msize(vsmall) yaxis(1)
 	|| line MA7totalcalls  nweek if year == 2021& statecode == "TX" & nweek <12, lcolor(eltblue) lpattern(solig) yaxis(1)  connect(ascending)
	  scheme(s2color) legend(label(2 "2019") label(4 "2020") label(6 "2021") order(6 4 2)  cols(1) rowgap(zero) region(lcolor(white)) pos(1) ring(0) size(medsmall)) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Weekly calls ('000)", xoffset(-1) axis(1) size(medsmall)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		yscale(range(0 4) axis(1) titlegap(0)) 	
		title("{bf:a}  ",  size(medlarge) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		xtitle("", yoffset(-2)) 
xlabel(2.5 `""J" " ""' 7 "F" 11.5 "M" 16 "A" 20 "M" 24.5 "J" 29 "J" 33 "A" 37.5 "S" 42 "O" 46 "N" 50 "D", labsize(medsmall) labcolor(gs0) notick)
		xtick(1 5 9 14 18 22 27 31 35 40 44 48 52) fxsize(105)
		name(xlflnllcddh, replace);
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
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig6_SourceData.xlsx", firstrow(varlabels) sheet("Panel a") replace


restore



replace nweek = nweek+52 if year == 2021 
# delimit ;
twoway  line resid wdate if year !=2019 , lcolor(edkbg) lpattern(solid) yaxis(1) connect(ascending) lwidth(thin)
	|| line meanres wdate   if year !=2019 & statecode == "TX" , lcolor(gs0) lpattern(solid) yaxis(1)  connect(ascending)  lwidth(medthin)  
	  scheme(s2color) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Deviation from mean (%)", xoffset(-1) axis(1) size(medsmall)) 
		ylabel(-200(100)300, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		yscale( axis(1) titlegap(0)) 	
		title("{bf:b}  ",  size(medlarge) color(gs0) pos(11) ring(1) span justification(left)) 	 	
		xtitle("", yoffset(-2)) 
xlabel(3120(26)3170, labsize(medsmall) labcolor(gs0) format(%twMon_CCYY))	
		name(xlflnddh, replace);
# delimit cr



keep if year > 2019
keep state wdate resid meanres  newcasesPOP meancovid ie1_incomesupport meansupport stringencyindex meanstringeny
format wdate %tw
sort wdate
order state wdate resid meanres  newcasesPOP meancovid ie1_incomesupport meansupport stringencyindex meanstringeny
sort state wdate
drop if state == ""
lab var resid "Residual (log deviation)"
lab var meanres "Residual (log deviation), US average"
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig6_SourceData.xlsx", firstrow(varlabels) sheet("Panel b") sheetreplace



use "C:\Users\VK\Desktop\Files\covid19-international-impact\Vibrant-data-and-artifacts\USstatepanel.dta", clear

keep if countryname == "United States"

global DEPVAR "lddhcalls"
global SE "cluster statenum#nmonth"
global FE "statenum nweek"
global F2E "statenum nmonth week"

global Xcovid "lnewcasesPOP"
global Xstrngncy "lstringencyindex"
global Xecnspprt "leconomicsupportindex"

xtset statenum nweek




reghdfe $DEPVAR lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb($FE)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
egen callsumsample = sum(ddhcalls) if e(sample)
sum callsumsample, meanonly
estadd scalar N_calls = r(mean)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store e_baseline
regsave using "$rawdata\cplotUSmainDDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "baseline") detail(all) replace

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb($FE)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
cap drop callsumsample
egen callsumsample = sum(ddhcalls) if e(sample)
sum callsumsample, meanonly
estadd scalar N_calls = r(mean)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store e_interacted
regsave using "$rawdata\cplotUSmainDDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "interacted") detail(all) append


reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport  , absorb($F2E)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
est store e_interacted2
regsave using "$rawdata\cplotUSmainDDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "baseline2") detail(all) append


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb($F2E)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
est store e_interacted3
regsave using "$rawdata\cplotUSmainDDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "interacted2") detail(all) append

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell1
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe1") detail(all) replace

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum month year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local mfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell2
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe2") detail(all) append

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum week year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell3
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe3") detail(all) append

reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nmonth)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
est store ell4
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe4") detail(all) append


reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nweek)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store ell5
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe5") detail(all) append


reghdfe $DEPVAR  lnewcasesPOP  lstringencyindex li_e1_incomesupport, absorb(statenum nmonth week)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
est store ell6
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe6") detail(all) append


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell1x
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe1") detail(all) replace

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum month year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local mfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell2x
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe2") detail(all) append

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum week year)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
estadd local yfe "\textsc{yes}"
est store ell3x
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe3") detail(all) append

reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum nmonth)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
est store ell4x
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe4") detail(all) append


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum nweek)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nwfe "\textsc{yes}"
est store ell5x
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe5") detail(all) append


reghdfe $DEPVAR  fhlnewcasesPOP  fhlstringencyindex fhli_e1_incomesupport shlnewcasesPOP  shlstringencyindex shli_e1_incomesupport, absorb(statenum nmonth week)  vce($SE) nocons
quietly: tab statenum if e(sample) == 1
estadd scalar N_g = r(r)
estadd local sfe "\textsc{yes}"
estadd local nmfe "\textsc{yes}"
estadd local wfe "\textsc{yes}"
est store ell6x
regsave using "$rawdata\cplotUSfeLONGcomp_DDH.dta", ci level(95) addlabel(depvartitel, lcalls, titletext, "fe6") detail(all) append

# delimit ;
estout ell1 ell4 ell6 ell5
 using ".\02_Project\tables\RESULTS_US_DDH_R1.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(sfe yfe nmfe wfe  nwfe N_g N, fmt( %9.0fc %9.0fc %9.0fc  %9.0fc %9.0fc %9.0fc %9.0fc) 
  labels("\midrule State/province FE" "Year FE" "Month FE" "Week-of-year FE" "Week FE" "\# States/provinces" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
   "]          \\" "]          \\[0.17cm]"
   "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(stringencyindex "\textit{Stringency index}"
						  economicsupportindex "\textit{Economic supportindex}"
						  newcasesPOP "\textit{COVID-19 case rate}"
						  newdeathsPOP "\textit{COVID-19 deaths rate}"
						  lstringencyindex "log(\textit{Stringency index}+1)"
						  leconomicsupportindex "log(\textit{Economic support index}+1)"
						  lnewcasesPOP "log(\textit{COVID-19 case rate}+1)"
						  fhlstringencyindex "\textit{Jan-Aug}*log(\textit{Stringency index}+1)"
						  fhleconomicsupportindex "\textit{Jan-Aug}*log(\textit{Economic support index}+1)"
						  fhlnewcasesPOP "\textit{Jan-Aug}*log(\textit{COVID-19 case rate}+1)"
						  shlstringencyindex "\textit{Sep-Mar}*log(\textit{Stringency index}+1)"
						  li_e1_incomesupport "log(\textit{Income support index}+1)"
						  li_e2_debtcontractrelief "log(\textit{Debt relief index}+1)"
						  shleconomicsupportindex "\textit{Sep-Mar}*log(\textit{Economic support index}+1)"
						  fhli_e1_incomesupport "\textit{Jan-Aug}*log(\textit{Income support index}+1)"
						  shli_e1_incomesupport "\textit{Sep-Mar}*log(\textit{Income support index}+1)"
						  shlnewcasesPOP "\textit{Sep-Mar}*log(\textit{COVID-19 case rate}+1)"
						  lnewdeathsPOP "log(\textit{COVID-19 deaths rate})")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8} \setlength{\tabcolsep}{0.3cm} \begin{table}[ht!]"
		"\caption{Disaster Distress Helpline calls across US states \label{RESULTS_US_R1_DDH}}\footnotesize"
		"\begin{tabular}{p{6.5cm}  cccc}\toprule"
		 "& \multicolumn{1}{c}{(1)}& \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\\midrule")
		 postfoot("\bottomrule
			\end{tabular}\\[0.2cm]
			\footnotesize \textbf{Note:} Sub-national panel model including state and week fixed effects, dependent variable is \$\log(\textit{Disaster Distress calls}+1)\$ and independent variables are measured in logs as well. Estimated coefficients with 95\% confidence intervals, standard errors are clustered at the state-month level. See Methods and materials, equation \ref{eq:CSEp}. 
			\end{table}");
# delimit cr

# delimit ;
estout ell1x ell4x ell6x ell5x
 using ".\02_Project\tables\RESULTS_US_R2_DDH.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(sfe yfe nmfe wfe  nwfe N_g N, fmt( %9.0fc %9.0fc %9.0fc  %9.0fc %9.0fc %9.0fc %9.0fc) 
  labels("\midrule State/province FE" "Year FE" "Month FE" "Week-of-year FE" "Week FE" "\# States/provinces" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
   "]          \\" "]          \\[0.17cm]"
   "]\\" "]\\[0.17cm]")
  mlabels(none) varlabels(stringencyindex "\textit{Stringency index}"
						  economicsupportindex "\textit{Economic supportindex}"
						  newcasesPOP "\textit{COVID-19 case rate}"
						  newdeathsPOP "\textit{COVID-19 deaths rate}"
						  lstringencyindex "log(\textit{Stringency index}+1)"
						  leconomicsupportindex "log(\textit{Economic support index}+1)"
						  lnewcasesPOP "log(\textit{COVID-19 case rate}+1)"
						  fhlstringencyindex "\textit{Jan-Aug}*log(\textit{Stringency index}+1)"
						  fhleconomicsupportindex "\textit{Jan-Aug}*log(\textit{Economic support index}+1)"
						  fhlnewcasesPOP "\textit{Jan-Aug}*log(\textit{COVID-19 case rate}+1)"
						  shlstringencyindex "\textit{Sep-Mar}*log(\textit{Stringency index}+1)"
						  li_e1_incomesupport "log(\textit{Income support index}+1)"
						  li_e2_debtcontractrelief "log(\textit{Debt relief index}+1)"
						  shleconomicsupportindex "\textit{Sep-Mar}*log(\textit{Economic support index}+1)"
						  fhli_e1_incomesupport "\textit{Jan-Aug}*log(\textit{Income support index}+1)"
						  shli_e1_incomesupport "\textit{Sep-Mar}*log(\textit{Income support index}+1)"
						  shlnewcasesPOP "\textit{Sep-Mar}*log(\textit{COVID-19 case rate}+1)"
						  lnewdeathsPOP "log(\textit{COVID-19 deaths rate})")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8}  \setlength{\tabcolsep}{0.3cm}\begin{table}[ht!]"
		"\caption{Disaster Distress Helpline calls across US states: Interacted model  \label{RESULTS_US_R2_DDH}}\footnotesize"
		"\begin{tabular}{p{6.5cm}  cccc}\toprule"
		 "& \multicolumn{1}{c}{(1)}& \multicolumn{1}{c}{(2)} & \multicolumn{1}{c}{(3)} & \multicolumn{1}{c}{(4)} \\\midrule")
		 postfoot("\bottomrule
			\end{tabular}\\[0.2cm]
			\footnotesize \textbf{Note:} Sub-national panel model including state and week fixed effects, dependent variable is \$\log(\textit{Disaster Distress calls}+1)\$ and independent variables are measured in logs as well. Estimated coefficients with 95\% confidence intervals, standard errors are clustered at the state-month level. See Methods and materials, equation \ref{eq:CSEp}. 
			\end{table}");
# delimit cr




use "$rawdata\cplotUSmainDDH.dta", clear


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
		title("{bf:c} ",  size(medlarge) color(gs0) pos(11) ring(1) span justification(left)) 	
		ylabel(10 "Income supp. index"  11 "Stringency index" 12 "Infections rate" ,angle(horizontal)   labsize(medsmall) labcolor(gs0) nogrid) 		note("  N = `N' weekly call vols" " (`N_g' states, `N_calls' calls)", pos(5) ring(0) span justification(right) size(medsmall))
		xlabel(, labsize(medsmall) labcolor(gs0) format(%9.2f) )
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		name(cplot3Pddh, replace) ;
# delimit cr
		



use "$rawdata\cplotUSmainDDH.dta", clear

gen zero = 0

keep if titletext == "interacted" 


gen vxnum =    .


replace vxnum = 8 if var == "fhlnewcasesPOP" & titletext == "interacted"
replace vxnum = 7 if var == "shlnewcasesPOP" & titletext == "interacted"

replace vxnum = 5.5 if var == "fhlstringencyindex" & titletext == "interacted"
replace vxnum = 4.5 if var == "shlstringencyindex" & titletext == "interacted"

replace vxnum = 3  if var == "fhli_e1_incomesupport"  & titletext == "interacted"
replace vxnum = 2  if var == "shli_e1_incomesupport"  & titletext == "interacted"


tostring N , gen(N_string) format(%12.0fc) force
local N= N_string[1]
display "`N'"

tostring N_g , gen(N_g_string) format(%12.0fc) force
local N_g= N_g_string[1]
display "`N_g'"				


tostring N_calls , gen(N_calls_string) format(%12.0fc) force
local N_calls= N_calls_string[1]
display "`N_calls'"

 

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
		xtitle("Coefficient (elasticity)", size(medsmall))	ytitle("") note("  N = `N' weekly call vols" " (`N_g' states)", pos(1) ring(0) span justification(right) size(medsmall))
		title("{bf:d} ",  size(medlarge) color(gs0) pos(11) ring(1) span justification(left)) 	
		ylabel(3 "Income supp. index: Jan-Aug " 5.5 "Stringency index: Jan-Aug " 8 "Infections rate: Jan-Aug " 2 "Sep-Mar "  4.5 "Sep-Mar " 7 "Sep-Mar " ,  labcolor(gs0) angle(horizontal) labsize(medsmall) notick nogrid) 	ytick(2 3 4.5 5.5 7 8)	 xlabel(, labsize(medsmall) labcolor(gs0) format(%9.2f) )
				note("  N = `N' weekly call vols" " (`N_g' states, `N_calls' calls)", pos(5) ring(0) span justification(right) size(medsmall))
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		name(cplot3Pxddh, replace) ;
		# delimit cr











graph combine xlflnllcddh xlflnddh	, cols(2)	name(grc0, replace) 

graph combine cplot3Pddh cplot3Pxddh	, cols(2)  imargin(small) 		name(grc2, replace) 

graph combine grc0 grc2	, imargin(vsmall) cols(1)   ysize(10cm) xsize(18.3cm) //  
	graph export ".\02_Project\Figures\exhibit4ddh.pdf", replace
	graph export ".\02_Project\Figures\exhibit4ddh.png", replace
	
	
			graph export ".\Revisions_Nature\Final figures\ExtDataFig6.pdf", replace


	
	
use "$rawdata\cplotUSmainDDH.dta", clear

gen panel = "c" if titletext == "baseline" 	
replace panel = "d" if titletext == "interacted" 
drop if panel == ""	
	gen topic = titletext
	label variable N_g "Number of helplines"
	
gen varname = "Stringency index" if var == "lstringencyindex" |  var == "fhlstringencyindex"|  var == "shlstringencyindex"
replace varname = "Income support index" if var  == "li_e1_incomesupport"|  var == "fhli_e1_incomesupport"|  var == "shli_e1_incomesupport"
replace varname = "Infections rate" if var== "lnewcasesPOP"|  var == "fhlnewcasesPOP"|  var == "shlnewcasesPOP"
gen period = "January 2020 - August 2020" if substr(var,1,2) == "fh"
replace period = "September 2020 - March 2021" if substr(var,1,2) == "sh"
keep coef varname period coef stderr ci_lower ci_upper N N_calls N_g panel
order  panel varname period coef  stderr ci_lower ci_upper N N_g 
keep coef varname period coef stderr ci_lower ci_upper N N_calls N_g panel
order  panel varname period coef  stderr ci_lower ci_upper N N_g 
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig6_SourceData.xlsx", firstrow(varlabels) sheet("Panels c-d") sheetreplace

 



	
	
	
	