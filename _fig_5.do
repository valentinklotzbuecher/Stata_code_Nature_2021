frame reset
frame create eresults

use "$rawdata\merged_series.dta",  clear

keep if HCcode == "GER1" | HCcode == "FRA"

drop if  ddate > mdy(3,31,2021)

global XFE "helplinecode#year helplinecode#weekofyear helplinecode#weekday"
global XSE "cluster helplinecode#nweek"

global topicdummies "lonely suicide violence addiction physhealth T_econ  T_social "

foreach V of varlist  contacts_suicide contacts_violence contacts_addiction contacts_lonely contacts_fears contacts_physhealth contacts_T_econ contacts_T_social {
replace `V' = log(`V'+1)
}
replace li_e1_incomesupport = 0 if year == 2019

reghdfe contacts_fears lnewcasesPOP lstringencyindex li_e1_incomesupport  , absorb($XFE) vce($XSE) nocons

tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
sum contacts_fears  if e(sample) == 1 & ddate<mdy(3,11,2020)
estadd scalar Tmean = r(mean), replace
estadd local hfe "\textsc{yes}"
local titletext: variable label contacts_fears
display "`titletext'"
est store fullm_fears
frame eresults: regsave using "$rawdata\cplot3P_vol.dta", ci level(95) addlabel(depvartitel, fears, titletext, "`titletext'") detail(all) replace

foreach T in $topicdummies {
reghdfe contacts_`T' lnewcasesPOP lstringencyindex li_e1_incomesupport , absorb($XFE) vce($XSE) nocons
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
sum contacts_`T'  if e(sample) == 1 & ddate<mdy(3,11,2020)
estadd scalar Tmean = r(mean), replace
estadd local hfe "\textsc{yes}"
local titletext: variable label contacts_`T'
display "`titletext'"
est store fullm_`T'
frame eresults: regsave using "$rawdata\cplot3P_vol.dta", ci level(95) addlabel(depvartitel, `T', titletext, "`titletext'") detail(all) append
}


# delimit ;
estout fullm_fears fullm_lonely  fullm_suicide fullm_addiction fullm_violence  fullm_physhealth  fullm_T_econ fullm_T_social
 using ".\02_Project\tables\R_vol_GER_FRA.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(N, fmt( %9.0fc)   labels("\midrule \# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
		 "]\\" "]\\[0.17cm]")
  mlabels(none)  varlabels(stringencyindex "\textit{Stringency index}"
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
 prehead("\renewcommand{\arraystretch}{0.8}  \setlength{\tabcolsep}{0.2cm}
	\begin{sidewaystable}[ht!]"
		"\caption{ Helpline calls in Germany and France \label{R_vol_GER_FRA}}\footnotesize"
		"\begin{tabular}{p{4.3cm} cccccccc}\toprule"
		 "& \multicolumn{1}{c}{(1) Fear}& \multicolumn{1}{c}{(2) Loneliness}& \multicolumn{1}{c}{(3) Suicide} & \multicolumn{1}{c}{(4) Addiction} & \multicolumn{1}{c}{(5) Violence} & \multicolumn{1}{c}{(6) Phys. Health}  & \multicolumn{1}{c}{(7) Livelihood}  & \multicolumn{1}{c}{(8) Relationships}  \\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){2-2}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}")
		 postfoot("\bottomrule\\
		\end{tabular}\\"			
			"\footnotesize \textbf{Note:} Separate linear probability models, dependent variable is equal to one for calls related to the respective category. Estimated coefficients with 95\% confidence intervals in brackets. The sample includes all calls during the time from 1 January 2019 to 30 June 2020. Models include year, week-of-year and day-of-week fixed effects, standard errors are clustered at the helpline-week level. See Materials and methods, equation \ref{eq:wave2}.\\
	\end{sidewaystable}")
	;
# delimit cr




use "$rawdata\cplot3P_vol.dta", clear

drop if var == "age1"
drop if var == "age3"
drop if var == "female"
drop if var == "_cons"
gen zero = 0

cap drop vxnum
gen vxnum =  .   
replace vxnum = 1 if  depvartitel ==  "T_social" &  var == "li_e1_incomesupport"
replace vxnum = 2 if  depvartitel ==  "T_social" &  var == "lstringencyindex"
replace vxnum = 3 if  depvartitel ==  "T_social" &  var == "lnewcasesPOP"

replace vxnum = 6 if  depvartitel ==  "T_econ" &  var == "li_e1_incomesupport"
replace vxnum = 7 if  depvartitel ==  "T_econ" &  var == "lstringencyindex"
replace vxnum = 8 if  depvartitel ==  "T_econ" &  var == "lnewcasesPOP"

replace vxnum = 11 if  depvartitel ==  "physhealth" &  var == "li_e1_incomesupport"
replace vxnum = 12 if  depvartitel ==  "physhealth" &  var == "lstringencyindex"
replace vxnum = 13 if  depvartitel ==  "physhealth" &  var == "lnewcasesPOP"

replace vxnum = 16 if  depvartitel ==  "violence" &  var == "li_e1_incomesupport"
replace vxnum = 17 if  depvartitel ==  "violence" &  var == "lstringencyindex"
replace vxnum = 18 if  depvartitel ==  "violence" &  var == "lnewcasesPOP"

replace vxnum = 21 if  depvartitel ==  "addiction" &  var == "li_e1_incomesupport"
replace vxnum = 22 if  depvartitel ==  "addiction" &  var == "lstringencyindex"
replace vxnum = 23 if  depvartitel ==  "addiction" &  var == "lnewcasesPOP"

replace vxnum = 26 if  depvartitel ==  "suicide" &  var == "li_e1_incomesupport"
replace vxnum = 27 if  depvartitel ==  "suicide" &  var == "lstringencyindex"
replace vxnum = 28  if  depvartitel ==  "suicide" &  var == "lnewcasesPOP"

replace vxnum = 31 if  depvartitel ==  "lonely" &  var == "li_e1_incomesupport"
replace vxnum = 32 if  depvartitel ==  "lonely" &  var == "lstringencyindex"
replace vxnum = 33 if  depvartitel ==  "lonely" &  var == "lnewcasesPOP"

replace vxnum = 36 if  depvartitel == "fears"  &  var == "li_e1_incomesupport"
replace vxnum = 37 if  depvartitel == "fears"  &  var == "lstringencyindex"
replace vxnum = 38 if  depvartitel == "fears"  &  var == "lnewcasesPOP"


foreach T in fears lonely suicide violence addiction physhealth  T_econ  T_social othertopic {
gen N_`T' =  N if depvartitel == "`T'"
sort N_`T'
replace N_`T' = N_`T'[1]
tostring N_`T' , gen(N_`T'_string) format(%12.0fc) force
local N_`T'= N_`T'_string[1]
display "`N_`T''"
gen N_g_`T' =  N_g if depvartitel == "`T'"
sort N_g_`T'
replace N_g_`T' = N_g_`T'[1]
tostring N_g_`T' , gen(N_g_`T'_string) format(%12.0fc) force
local N_g_`T'= N_g_`T'_string[1]
display "`N_g_`T''"
}


# delimit ;
graph twoway   rcap ci_upper ci_lower vxnum if  var == "li_e1_incomesupport", horizontal  color(gold*1.1)
		  || scatter  vxnum coef if  var == "li_e1_incomesupport" , mc(gold*1.1)  m(d)
		  ||  rcap ci_upper ci_lower vxnum if  var == "lstringencyindex" , horizontal  color(ebblue)
		  || scatter  vxnum coef if  var == "lstringencyindex", mc(ebblue)  m(d)
		  || rcap ci_upper ci_lower vxnum if  var == "lnewcasesPOP" , horizontal  color(cranberry)
		  || scatter  vxnum coef if  var == "lnewcasesPOP", mc(cranberry)  m(d)
				scheme(s2color )  legend(label(1 "Income support index") label(3 "Stringency index") label(5 "Infections rate") order(5 3 1) pos(5) ring(0)  cols(1) size(medsmall) region(lcolor(white))) 
		graphregion(color(white) ) plotregion(color(white)   margin(medium)) bgcolor(white) 
		ytitle("") 		ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) ) 
			note("N = `N_fears' daily call volumes" "       (2 helplines)", justification(left) size(medsmall) pos(5) ring(0) yoffset(18) )
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		title("",  size(medlarge) color(gs0)) 	
		ylabel( 37  "Fear (incl. infection)"  32 "Loneliness" 27 "Suicidality"  22 "Addiction"   17 "Violence"   12 "Physical health"   7 "Livelihood"   2 "Relationships" , nogrid labsize(medsmall) labcolor(gs0) )
		xlabel(-0.05 "-0.05" 0 "0" 0.05 "0.05"  0.1 "0.1"  0.15 "0.15"    , notick labsize(medsmall) labcolor(gs0) format(%9.2fc) ) xsize(8.9cm) ysize(7cm) xtitle("Coefficient (elasticity)") 	xscale(range(-0.07 0.25))
		name(cplot3P, replace) saving(".\02_Project\Figures\cplot3Pnobars_vol_GER_FRA.gph", replace);
# delimit cr
graph export ".\02_Project\Figures\cplot3Pnobars_vol_GER_FRA.pdf", replace

graph export ".\Revisions_Nature\Final figures\Fig5.pdf", replace



	gen topic = titletext
	label variable N_g "Number of helplines"
gen varname = "Stringency index" if var == "lstringencyindex"
replace varname = "Income support index" if var  == "li_e1_incomesupport"
replace varname = "Infections rate" if var== "lnewcasesPOP"
gsort -vxnum
keep coef topic varname coef stderr ci_lower ci_upper N N_g 
order  topic varname  coef  stderr ci_lower ci_upper N N_g 
 export excel using ".\Revisions_Nature\Final figures\Fig5_SourceData.xlsx", firstrow(varlabels) replace

 






