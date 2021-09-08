
use "$rawdata\merged_contacts_estimation.dta",  clear

lab var fears "Fears (incl. of infection)"
lab var lonely "Loneliness"
lab var suicide "Suicidality"
lab var addiction "Addiction"
lab var violence "Violence"
lab var physhealth "Physical health"
lab var T_econ "Livelihood"
lab var T_social "Relationships"

global topicdummies "lonely suicide addiction violence physhealth  T_econ  T_social "

global FE1 "helplinecode#year helplinecode#weekofyear helplinecode#weekday"
 global SE1 "cluster helplinecode#nweek"

replace postlockdown = (ddate > mdy(3,10,2020))

gen confirmedcasesPOP = confirmedcases/population

bysort country: egen dateofoutbreak = min(ddate) if confirmedcasesPOP > 10 & confirmedcases != .
bysort country (dateofoutbreak): replace dateofoutbreak = dateofoutbreak[1]
format dateofoutbreak %td
gen outbreakdate = (ddate==dateofoutbreak)
gen postoutbreak = (ddate>=dateofoutbreak)

replace female = . if female == 0 & male == 0	
replace male = 1-female


gen female_age1 = age1*female
gen female_age2 = age2*female
gen female_age3 = age3*female
gen male_age1 = age1*male
gen male_age2 = age2*male
gen male_age3 = age3*male

gen post_male = postoutbreak*male
gen post_female = postoutbreak*female
gen post_age1 = postoutbreak*age1
gen post_age2 = postoutbreak*age2
gen post_age3 = postoutbreak*age3
gen post_female_age1 = post_age1*female
gen post_female_age2 = post_age2*female
gen post_female_age3 = post_age3*female
gen post_male_age1 = post_age1*male
gen post_male_age2 = post_age2*male
gen post_male_age3 = post_age3*male

gen agencat = 1 if age1 == 	 1
replace agencat = 2 if age2 == 1
replace agencat = 3 if age3 == 1


///////////////////////////////////////////


reghdfe fears postoutbreak if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1) nocons vce($SE1) 
foreach G of varlist female_age1 female_age2 female_age3 male_age1 male_age2 male_age3 {
gen subsample_fears_`G' = (fears == 1 &  `G' == 1) 
sum subsample_fears_`G'  if e(sample) == 1 & postoutbreak == 0
estadd scalar Tpremean_`G' = r(mean), replace
}
gen insample_fears = (e(sample) == 1)
sum fears  if e(sample) == 1 & postoutbreak == 0
estadd scalar Tpremean = r(mean), replace
estadd scalar Tpresd = r(sd), replace
sum fears  if e(sample) == 1 & postoutbreak == 1
estadd scalar Tpostmean = r(mean), replace
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
est store pl_fears
local titletext: variable label fears
display "`titletext'"
frame eresults: regsave using "$rawdata\cplotM.dta", ci level(95) addlabel(depvartitel, fears, titletext, "`titletext'") detail(all) replace

foreach T in $topicdummies {
reghdfe `T'  postoutbreak  if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1)  nocons vce($SE1) 
gen insample_`T'  = (e(sample) == 1)
foreach G of varlist female_age1 female_age2 female_age3 male_age1 male_age2 male_age3 {
gen subsample_`T'_`G' = (`T' == 1 &  `G' == 1) 
sum subsample_`T'_`G'  if e(sample) == 1 & postoutbreak == 0
estadd scalar Tpremean_`G' = r(mean), replace
}
sum `T'  if e(sample) == 1 & postoutbreak == 0
estadd scalar Tpremean = r(mean), replace
sum `T'  if e(sample) == 1 & postoutbreak == 1
estadd scalar Tpostmean = r(mean), replace
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
est store pl_`T'
local titletext: variable label `T'
display "`titletext'"
frame eresults: regsave using "$rawdata\cplotM.dta", ci level(95) addlabel(depvartitel, `T', titletext, "`titletext'") detail(all) append
}


///////////////////////////////////////////



reghdfe fears female_age1 female_age2 female_age3 male_age1  male_age3  post_female_age1 post_female_age2 post_female_age3 post_male_age1 post_male_age2 post_male_age3, absorb($FE1) nocons vce($SE1) 
sum fears  if e(sample) == 1 & postoutbreak == 0
local Tpremean = r(mean)
estadd scalar Tpremean = r(mean), replace
estadd scalar Tpresd = r(sd), replace
sum fears  if e(sample) == 1 & postoutbreak == 1
estadd scalar Tpostmean = r(mean), replace
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
est store pl_I_fears
local titletext: variable label fears
display "`titletext'"
frame eresults: regsave using "$rawdata\cplotI.dta", ci level(95) addlabel(depvartitel, fears, titletext, "`titletext'", pre_mean, `Tpremean', model, "fullyinteracted") detail(all) replace

foreach T in $topicdummies {
reghdfe `T'  female_age1 female_age2 female_age3 male_age1  male_age3  post_female_age1 post_female_age2 post_female_age3 post_male_age1 post_male_age2 post_male_age3 , absorb($FE1) nocons vce($SE1) 
sum `T'  if e(sample) == 1 & postoutbreak == 0
local Tpremean = r(mean)
estadd scalar Tpremean = r(mean), replace
sum `T'  if e(sample) == 1 & postoutbreak == 1
estadd scalar Tpostmean = r(mean), replace
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
est store pl_I_`T'
local titletext: variable label `T'
display "`titletext'"
frame eresults: regsave using "$rawdata\cplotI.dta", ci level(95) addlabel(depvartitel, `T', titletext, "`titletext'", pre_mean, `Tpremean', model, "fullyinteracted") detail(all) append
}



gen inanysample = 0
replace inanysample = 1 if insample_fears == 1 | insample_lonely == 1 | insample_suicide == 1 | insample_violence == 1 | insample_addiction == 1 | insample_physhealth == 1 | insample_T_econ == 1 | insample_T_social
keep if inanysample == 1



save "$rawdata\merged_contacts_postestimation.dta",  replace
use "$rawdata\merged_contacts_postestimation.dta",  clear




# delimit ;
estout pl_fears pl_lonely  pl_suicide pl_addiction pl_violence  pl_physhealth  pl_T_econ pl_T_social
 using ".\02_Project\tables\RESULTS_F2aCI.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(Tpremean N_g N, fmt(%9.2fc %9.0fc %9.0fc)   labels("\midrule Pre-outbreak share" "\# Helplines" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
         "\midrule \# Helplines&           7          &          10          &          12          &          10          &          10          &           9          &           9          &           9          \\" "\midrule \# Helplines&           \multicolumn{1}{c}{7}          &          \multicolumn{1}{c}{10}          &          \multicolumn{1}{c}{12}          &          \multicolumn{1}{c}{10}          &          \multicolumn{1}{c}{10}          &           \multicolumn{1}{c}{9}          &           \multicolumn{1}{c}{9}          &           \multicolumn{1}{c}{9}          \\"
   "&   2,123,773          &   2,066,884          &   2,244,199          &   2,215,734          &   2,215,751          &   2,222,612          &   2,007,643          &   2,094,275          \\" 
   "&   \multicolumn{1}{c}{2,123,773}          &   \multicolumn{1}{c}{2,066,884}          &   \multicolumn{1}{c}{2,244,199}          &   \multicolumn{1}{c}{2,215,734}          &   \multicolumn{1}{c}{2,215,751}          &   \multicolumn{1}{c}{2,222,612}          &   \multicolumn{1}{c}{2,007,643}          &   \multicolumn{1}{c}{2,094,275}          \\")
  mlabels(none) varlabels(_cons "\textit{Constant}"
						  living_alone "\textit{Living alone}"
						  age "\textit{Age}"
						  age1 "\textit{Age <30}"
						  age2 "\textit{Age 30-60}"
						  age3 "\textit{Age >60}"
						  suicide "\textit{Suicide}"
						  lonely "\textit{Loneliness}"
						  violence "\textit{Violence}"
						  addiction "\textit{Addiction}"
						  lstringency "log(1+\textit{Stringency index})"
						  postoutbreak "\textit{Post outbreak}""
						  female "\textit{Female}")
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8}     \setlength{\tabcolsep}{0.13cm}	\begin{sidewaystable}[ht!]"
		"\caption{Changing conversation topics following the pandemic outbreak \label{RESULTS_F2}}\footnotesize"
		"\begin{tabular}{p{3.5cm} cccccccc}\toprule"
		 "\textbf{a)}& \multicolumn{1}{c}{(1) Fear}& \multicolumn{1}{c}{(2) Loneliness}& \multicolumn{1}{c}{(3) Suicidality} & \multicolumn{1}{c}{(4) Addiction} & \multicolumn{1}{c}{(5) Violence} & \multicolumn{1}{c}{(6) Phys. Health}  & \multicolumn{1}{c}{(7) Livelihood}  & \multicolumn{1}{c}{(8) Relationships}  \\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){2-2}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}")
		 postfoot("\midrule\\" "\toprule");
		# delimit cr

		
		
# delimit ;
estout pl_I_fears pl_I_lonely  pl_I_suicide pl_I_addiction pl_I_violence  pl_I_physhealth  pl_I_T_econ pl_I_T_social
 using ".\02_Project\tables\RESULTS_F2bCI.txt", replace style(tex) type
 cells(b(nostar fmt(%9.3f)) 
       ci(par fmt(%9.3f)))
     stats(Tpremean N_g N, fmt(%9.2fc %9.0fc %9.0fc)   labels("\midrule Pre-outbreak share" "\# Helplines" "\# Observations"))
  substitute("&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95&      b/ci95\\" ""
   "]\\" "]\\[0.17cm]"
      "\midrule \# Helplines&           7          &          10          &          12          &          10          &          10          &           9          &           9          &           9          \\" "\midrule \# Helplines&           \multicolumn{1}{c}{7}          &          \multicolumn{1}{c}{10}          &          \multicolumn{1}{c}{12}          &          \multicolumn{1}{c}{10}          &          \multicolumn{1}{c}{10}          &           \multicolumn{1}{c}{9}          &           \multicolumn{1}{c}{9}          &           \multicolumn{1}{c}{9}          \\"
   "&   2,123,773          &   2,066,884          &   2,244,199          &   2,215,734          &   2,215,751          &   2,222,612          &   2,007,643          &   2,094,275          \\" 
   "&   \multicolumn{1}{c}{2,123,773}          &   \multicolumn{1}{c}{2,066,884}          &   \multicolumn{1}{c}{2,244,199}          &   \multicolumn{1}{c}{2,215,734}          &   \multicolumn{1}{c}{2,215,751}          &   \multicolumn{1}{c}{2,222,612}          &   \multicolumn{1}{c}{2,007,643}          &   \multicolumn{1}{c}{2,094,275}          \\")
  mlabels(none) varlabels(_cons "\textit{Constant}"
						  living_alone "\textit{Living alone}"
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
						  post_male  "\textit{Post*Male}"
						  post_female  "\textit{Post*Female}"
						  post_age1  "\textit{Post*Age 0-30}"
						  post_age2  "\textit{Post*Age 30-60}"
						  post_age3  "\textit{Post*Age 60+}"
						  post_female_age1 "\textit{Post*Female*Age 0-30}"
						  post_female_age2 "\textit{Post*Female*Age 30-60}"
						  post_female_age3 "\textit{Post*Female*Age 60+}"
						  post_male_age1   "\textit{Post*Male*Age 0-30}"
						  post_male_age2   "\textit{Post*Male*Age 30-60}"
						  post_male_age3   "\textit{Post*Male*Age 60+}"
						  female "\textit{Female}")
		order(post_female_* post_male_* female_* male_*)
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\textbf{b)}& \multicolumn{1}{c}{(9) Fear}& \multicolumn{1}{c}{(10) Loneliness}& \multicolumn{1}{c}{(11) Suicidality} & \multicolumn{1}{c}{(12) Addiction} & \multicolumn{1}{c}{(13) Violence} & \multicolumn{1}{c}{(14) Phys. Health}  & \multicolumn{1}{c}{(15) Livelihood}  & \multicolumn{1}{c}{(16) Relationships}  \\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){2-2}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}")
  postfoot("\bottomrule\\
		\end{tabular}"			
			"\\\footnotesize \textbf{Note:} Separate linear probability models, dependent variable is equal to one for calls related to the respective category. Estimated coefficients with 95\% confidence intervals in brackets. The sample includes all calls during the time from 1 January 2019 to 30 June 2020. \textbf{a)} Average change post-outbreak, \textbf{b)} fully interacted model.                   Models include helpline fixed effects, interacted with year, week-of-year and day-of-week indicators, standard errors are clustered at the helpline-week level. See Methods, equations  \ref{eq:did} and \ref{eq:intac}.\\         \end{sidewaystable}");
# delimit cr


estpost tabstat   female  age1 age2 age3 phone chat firstcall living_alone  fears lonely suicide addiction violence physhealth  T_econ  T_social if postoutbreak == 0, statistics(mean sum count) columns(statistics)


# delimit ;
esttab using ".\02_Project\Tables\descriptives_contactlevel_sample.tex", replace style(tex) type noabbrev label nomtitle nonumber noisily
	cells("Mean(fmt(%9.3f) label(\multicolumn{1}{c}{Share})) 
			Sum(fmt(%9.0fc) label(\multicolumn{1}{c}{Total})) 
			count(fmt(%9.0fc) label(\multicolumn{1}{c}{N}))" )  
	substitute("\_" "\"
				"\hline" ""
				"{N}\\" "{N}\\\midrule")
				stats(N , fmt(%9.0fc) labels("\midrule Total calls"))  
				varlabels(living_alone "\textit{Living alone}"
						  living_family  "\textit{Living with family}"
						  living_partner   "\textit{Living with partner}"
						  female "\textit{Female}"
						  age "\textit{Age}"
						  age1 "\textit{Age < 30}"
						  age2 "\textit{Age 30-60}"
						  age2a  "\textit{Age 30-44}"
						  age2b "\textit{Age 45-60}"
						  age3 "\textit{Age > 60}"
						  retired "\textit{Retired}"
						  education "\textit{Studying}"
						  unemployed "\textit{Unemployed}"
						  employed "\textit{Employed}"
						  phone "\textit{Phone contacts}"
						  firstcall "\textit{First-time caller}"
						  repcall "\textit{Repeat caller}"
						  hour "\textit{Hour of day}"
						  coronacall "\textit{Covid related}"
						  chat "\textit{Chat}"
						  duration "\textit{Duration}"
						  suicide "\textit{Suicidality}"
						  T_social "\textit{Relationships}"
						  T_econ "\textit{Livelihood}"
						  physhealth "\textit{Physical health}"
						  fears "\textit{Fears}"
						  lonely "\textit{Loneliness}"
						  violence "\textit{Violence}"
						  addiction "\textit{Addiction}")
				prehead("{\small"
							"\renewcommand{\arraystretch}{1.2}  \setlength{\tabcolsep}{0.5cm}"	
							"\begin{table}[ht!]"
		"\caption{Caller characteristics and conversation topics\label{descriptives_contactlevel_sample}}\footnotesize"
		"\begin{tabular}{p{5cm} rrr}\toprule")	
		 postfoot("\bottomrule
			\end{tabular}\\
			\parbox{\columnwidth}{\footnotesize \textbf{Note:}  descriptive statistics for calls included in the main estimation sample for the respective topic.}
			\end{table}");
# delimit cr





use "$rawdata\cplotM.dta", clear

keep if var == "postoutbreak" 	
gen vnum = 6 if depvartitel ==  "suicide"
replace vnum = 8 if depvartitel ==  "fears"
replace vnum = 7 if depvartitel ==  "lonely"
replace vnum = 5 if depvartitel ==  "addiction"
replace vnum = 4 if depvartitel ==  "violence"
replace vnum = 3 if depvartitel ==  "physhealth"
replace vnum = 2 if depvartitel ==  "T_econ"
replace vnum = 1 if depvartitel ==  "T_social"
replace vnum = 0 if depvartitel ==  "othertopic"
gen zero = 0

di invnormal(0.975)
di invnormal(0.95)
di invnormal(0.995)
gen ci90_lower = coef-invnormal(0.95)*(stderr)
gen ci95_lower = coef-invnormal(0.975)*(stderr)
gen ci99_lower = coef-invnormal(0.995)*(stderr)

gen ci90_upper = coef+invnormal(0.95)*(stderr)
gen ci95_upper = coef+invnormal(0.975)*(stderr)
gen ci99_upper = coef+invnormal(0.995)*(stderr)

foreach V of varlist coef ci_lower ci_upper {
gen `V'_stdzd =  (`V'/Tpremean)*100
}

gen double varcoef = stderr^2
gen double varcoef_stdzd = varcoef*(1000/Tpremean)^2 
gen double stderr_stdzd = sqrt(varcoef_stdzd)

gen ci90_lower_stdzd = coef_stdzd-invnormal(0.95)*(stderr_stdzd)
gen ci95_lower_stdzd = coef_stdzd-invnormal(0.975)*(stderr_stdzd)
gen ci99_lower_stdzd = coef_stdzd-invnormal(0.995)*(stderr_stdzd)
			  
gen ci90_upper_stdzd = coef_stdzd+invnormal(0.95)*(stderr_stdzd)
gen ci95_upper_stdzd = coef_stdzd+invnormal(0.975)*(stderr_stdzd)
gen ci99_upper_stdzd = coef_stdzd+invnormal(0.995)*(stderr_stdzd)

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
gen ppm_`T' =  Tpremean if depvartitel == "`T'"
sort ppm_`T'
replace ppm_`T' = ppm_`T'[1]
tostring ppm_`T' , gen(ppm_`T'_string) format(%9.2f) force
local ppm_`T'= ppm_`T'_string[1]
display "`ppm_`T''"
}

 
gen equivtlevel =.
gen equivtlevelneg =.
 foreach V in  fears lonely suicide addiction violence physhealth  T_econ  T_social {
sum Tpremean if  depvartitel ==  "`V'"
local eql_`V' = r(mean)*0.05
display `eql_`V''
local eql2_`V' = r(mean)*0.1
display `eql2_`V''
local eql3_`V' = r(mean)*0.01
display `eql3_`V''

replace equivtlevel = 100* `eql_`V'' if  depvartitel ==  "`V'"
replace equivtlevelneg = -100* `eql_`V'' if  depvartitel ==  "`V'"

local Nnum_`V' = N_`V'[1]

gen SE_`V' =  stderr*sqrt(N_`V') if depvartitel == "`V'"
sort SE_`V'
replace SE_`V' = SE_`V'[1]
local SE_`V' = SE_`V'[1]

gen coef_`V' =  coef if depvartitel == "`V'"
sort coef_`V'
replace coef_`V' =coef_`V'[1]
local B_`V' = coef_`V'[1]
di "`V'"
di `Num_`V'' 
di `SE_`V''
di `B_`V'' 

tostti `Nnum_`V''   `B_`V''   `SE_`V'' 0 , eqvtype(delta) eqvlevel(`eql_`V'') relevance

gen eqtest_t1_`V' = r(t1)
gen eqtest_t2_`V' = r(t2)
gen eqtest_p1_`V' = r(p1)
gen eqtest_p2_`V' = r(p2)
gen eqtest_result_`V' = r(relevance)

}

gen double eqtest_t1 = .
gen double eqtest_t2 = .
gen double eqtest_p1 = .
gen double eqtest_p2 = .
gen  eqtest_result = ""
 foreach V in  fears lonely suicide addiction violence physhealth  T_econ  T_social {
replace eqtest_t1 = eqtest_t1_`V' if depvartitel == "`V'"
replace eqtest_t2 = eqtest_t2_`V' if depvartitel == "`V'"
replace eqtest_p1 = eqtest_p1_`V' if depvartitel == "`V'"
replace eqtest_p2 = eqtest_p2_`V' if depvartitel == "`V'"
replace eqtest_result = eqtest_result_`V' if depvartitel == "`V'"
 }


	
gen equivtlevel_stdzd = 100*0.05
gen equivtlevelneg_stdzd = -100*0.05

  

replace vnum = . if depvartitel ==  "othertopic"


gen Tpremean1 = Tpremean_female_age1  
gen Tpremean2 = Tpremean_female_age2 + Tpremean1 
gen Tpremean3 = Tpremean_female_age3 + Tpremean2 
gen Tpremean4 = Tpremean_male_age1 + Tpremean3
gen Tpremean5 = Tpremean_male_age2 + Tpremean4
gen Tpremean6 = Tpremean_male_age3 + Tpremean5

foreach V of varlist coef ci_upper ci_lower Tpremean* {
replace `V' = `V' * 100
}

gen vnuml =vnum-0.5
gen vnumu =vnum+0.5
 

 
 
 

# delimit ;
graph twoway  rbar  zero coef vnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.75)
		  ||  rcap ci_upper ci_lower vnum, horizontal  color(gs0) lwidth(medthick) msize(large)
		  || scatter  vnum coef,  mc(gs0)  m(d) msize(medium)
				scheme(s2color ) legend(off) 
				text(8.8 3.4 "N (calls)", size(large) placement(east))
				text(8 3.3 "`N_fears'",  size(large) placement(east))
				text(7 3.3 "`N_lonely'", size(large)  placement(east))
				text(6 3.3  "`N_suicide'", size(large)  placement(east))
				text(5 3.3  "`N_addiction'", size(large)  placement(east))
				text(4 3.3  "`N_violence'", size(large)  placement(east))
				text(3 3.3  "`N_physhealth'", size(large)  placement(east))
				text(2 3.3  "`N_T_econ'",  size(large) placement(east))
				text(1 3.3  "`N_T_social'", size(large)  placement(east))
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		xtitle("Post-outbreak change (percentage-points)", size(large)) ytitle("")  
		title("  {bf:b}  ", size(huge) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		xline(0, lcolor(edkbg) lwidth(medium) lpattern(solid))
	ylabel(6 "Suicidality" 8 "Fears (incl. infection)" 7 "Loneliness" 5 "Addiction" 4 "Violence" 3 "Physical health" 2 "Livelihood" 1 "Relationships", labsize(large) labcolor(gs0) nogrid   angle(horizontal))
 xscale(range(-3 4.5)) 
		xlabel(-3(1)3, labsize(large) labcolor(gs0) )  fxsize(137)
		name(coefpMrXXX, replace)   ;
# delimit cr
		

# delimit ;
graph twoway  rbar  zero Tpremean1 vnum, horizontal bcolor(dkorange*0.6) lcolor(dkorange*0.6) barwidth(0.75)
		|| 	rbar  Tpremean1 Tpremean2 vnum, horizontal bcolor(dkorange) lcolor(dkorange) barwidth(0.75)
		|| 	rbar  Tpremean2 Tpremean3 vnum, horizontal bcolor(dkorange*1.3) lcolor(dkorange*1.3) barwidth(0.75)
		|| 	rbar  Tpremean3 Tpremean4 vnum, horizontal bcolor(blue*0.6) lcolor(blue*0.6) barwidth(0.75)
		|| 	rbar  Tpremean4 Tpremean5 vnum, horizontal bcolor(blue) lcolor(blue) barwidth(0.75)
		|| 	rbar  Tpremean5 Tpremean6 vnum, horizontal bcolor(blue*1.3) lcolor(blue*1.5) barwidth(0.75)
				scheme(s2color ) legend(label(1 "0-30   Female") label(2 "30-60") label(3 "60+") label(4 "0-30   Male") label(5 "30-60") label(6 "60+") cols(1)  size(large)  pos(2) ring(0) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		xtitle("Pre-outbreak share (%)", size(large) color(gs0)) ytitle("") 
		title("{bf:a} ", size(huge) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		ylabel(6 "Suicidality" 8 "Fears (incl. infection)" 7 "Loneliness" 5 "Addiction" 4 "Violence" 3 "Physical health" 2 "Livelihood" 1 "Relationships", labsize(large) labcolor(gs0) nogrid   angle(horizontal))
		xlabel(0(5)35, labsize(large) labcolor(gs0) ) 
		name(coefGplotMppmXXX, replace)   ;
# delimit cr
 
 
graph combine coefGplotMppmXXX  coefpMrXXX, imargin(small) cols(2) graphregion(color(white)  margin(small)) xsize(18.3cm) ysize(6.5cm)  
				graph export ".\02_Project\Figures\coefGplotIfully.pdf", replace


		graph export ".\Revisions_Nature\Final figures\Fig2.pdf", replace
		graph export ".\Revisions_Nature\Final figures\Fig2.eps", replace
 
/*
# delimit ;
graph twoway  rbar  zero coef vnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.75)
		  ||  rcap ci_upper ci_lower vnum, horizontal  color(gs0) lwidth(medium) msize(medium)
		  || scatter  vnum coef,  mc(gs0)  m(d) msize(medium)
				scheme(s2color ) legend(off) 
				text(9 3.8 "N", size(small) placement(east))
				text(8 3.3 "`N_fears'",  size(small) placement(east))
				text(7 3.3 "`N_lonely'", size(small)  placement(east))
				text(6 3.3  "`N_suicide'", size(small)  placement(east))
				text(5 3.3  "`N_addiction'", size(small)  placement(east))
				text(4 3.3  "`N_violence'", size(small)  placement(east))
				text(3 3.3  "`N_physhealth'", size(small)  placement(east))
				text(2 3.3  "`N_T_econ'",  size(small) placement(east))
				text(1 3.3  "`N_T_social'", size(small)  placement(east))
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		xtitle("Post-outbreak change (percentage-points)", size(small)) ytitle("")  
		title("  {bf:b}  ", size(medium) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		xline(0, lcolor(edkbg) lwidth(medium) lpattern(solid))
	ylabel(6 "Suicidality" 8 "Fears (incl. infection)" 7 "Loneliness" 5 "Addiction" 4 "Violence" 3 "Physical health" 2 "Livelihood" 1 "Relationships", labsize(small) labcolor(gs0) nogrid   angle(horizontal))
 xscale(range(-3 4.5))
		xlabel(-3(1)3, labsize(medsmall) labcolor(gs0) )   fxsize(50)
		name(coefpMr, replace)   ;
# delimit cr
		

# delimit ;
graph twoway  rbar  zero Tpremean1 vnum, horizontal bcolor(dkorange*0.6) lcolor(dkorange*0.6) barwidth(0.75)
		|| 	rbar  Tpremean1 Tpremean2 vnum, horizontal bcolor(dkorange) lcolor(dkorange) barwidth(0.75)
		|| 	rbar  Tpremean2 Tpremean3 vnum, horizontal bcolor(dkorange*1.3) lcolor(dkorange*1.3) barwidth(0.75)
		|| 	rbar  Tpremean3 Tpremean4 vnum, horizontal bcolor(blue*0.6) lcolor(blue*0.6) barwidth(0.75)
		|| 	rbar  Tpremean4 Tpremean5 vnum, horizontal bcolor(blue) lcolor(blue) barwidth(0.75)
		|| 	rbar  Tpremean5 Tpremean6 vnum, horizontal bcolor(blue*1.3) lcolor(blue*1.5) barwidth(0.75)
				scheme(s2color ) legend(label(1 "0-30   Female") label(2 "30-60") label(3 "60+") label(4 "0-30   Male") label(5 "30-60") label(6 "60+") cols(1)  size(small) rowgap(0) pos(2) ring(0) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(medsmall)) bgcolor(white) 
		xtitle("Pre-outbreak share (%)", size(small) color(gs0)) ytitle("") 
		title("{bf:a} ", size(medium) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		ylabel(6 "Suicidality" 8 "Fears (incl. infection)" 7 "Loneliness" 5 "Addiction" 4 "Violence" 3 "Physical health" 2 "Livelihood" 1 "Relationships", labsize(small) labcolor(gs0) nogrid   angle(horizontal))
		xlabel(0(5)35, labsize(small) labcolor(gs0) ) 
		name(coefGplotMppm, replace)   ;
# delimit cr
 
 
 */
 # delimit ;
graph twoway  rbar  zero coef vnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.75)
		  ||  rcap ci_upper ci_lower vnum, horizontal  color(gs0) lwidth(thick) msize(vlarge)
		  ||  rcap vnuml vnumu equivtlevelneg , vertical  color(eltblue)  lwidth(medthick) msize(zero) lpattern(solid  )
		  ||  rcap vnuml vnumu equivtlevel , vertical  color(eltblue)  lwidth(medthick) msize(zero) lpattern(solid  )
		  || scatter  vnum coef,  mc(gs0)  m(d) msize(vlarge)
				scheme(s2color ) legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(medsmall)) bgcolor(white) 
		xtitle("Percentage-points", size(vlarge)) ytitle("")  
		title("  {bf:a}  ", size(vlarge) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		xline(0, lcolor(edkbg) lwidth(medthick) lpattern(solid))
		ylabel(6 "Suicidality" 8 "Fears (incl. infection)" 7 "Loneliness" 5 "Addiction" 4 "Violence" 3 "Physical health" 2 "Livelihood" 1 "Relationships", labsize(vlarge) labcolor(gs0) nogrid   angle(horizontal))
		xlabel(-3(1)3, labsize(vlarge) labcolor(gs0) )   fxsize(130)
		name(grc1, replace)   ;
# delimit cr

# delimit ;
graph twoway  rbar  zero coef_stdzd vnum, horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.75)
		  ||  rcap ci_upper_stdzd ci_lower_stdzd vnum, horizontal  color(gs0) lwidth(thick) msize(vlarge)
		  ||  rcap vnuml vnumu equivtlevelneg_stdzd  , vertical  color(eltblue)  lwidth(medthick) msize(zero) lpattern(solid  )
		  ||  rcap vnuml vnumu equivtlevel_stdzd  , vertical  color(eltblue)  lwidth(medthick) msize(zero) lpattern(solid  )
		  || scatter  vnum coef_stdzd,  mc(gs0)  m(d) msize(vlarge)
				scheme(s2color ) legend(off) 
				text(9 28 "N",size(vlarge) placement(east))
				text(8 25 "`N_fears'", size(vlarge) placement(east))
				text(7 25 "`N_lonely'",size(vlarge) placement(east))
				text(6 25  "`N_suicide'", size(vlarge) placement(east))
				text(5 25  "`N_addiction'",  size(vlarge) placement(east))
				text(4 25  "`N_violence'",  size(vlarge) placement(east))
				text(3 25  "`N_physhealth'", size(vlarge)  placement(east))
				text(2 25  "`N_T_econ'",  size(vlarge) placement(east))
				text(1 25  "`N_T_social'",  size(vlarge) placement(east))
		graphregion(color(white) margin(small)) plotregion(color(white)  margin(medsmall)) bgcolor(white) 
		xtitle("% of pre-pandemic share", size(vlarge)) ytitle("")  
		title("  {bf:b}  ", size(vlarge) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		xline(0, lcolor(edkbg) lwidth(medthick) lpattern(solid))
	ylabel(6 " " 8 " " 7 " " 5 " " 4 " " 3 " " 2 " " 1 " ", labsize(vlarge) labcolor(gs0) nogrid angle(horizontal))	xscale(range(-10 35))
		xlabel(-10(5)20, labsize(vlarge) labcolor(gs0) )  
		name(grc2, replace)   ;
# delimit cr


# delimit ;
graph combine grc1 grc2 ,
	imargin(small) cols(2)   
	graphregion(color(white)  margin(vsmall)) xsize(8) ysize(3.3)
;
# delimit cr
		graph export ".\02_Project\Figures\EQVtesting.pdf", replace
		
		graph export ".\Revisions_Nature\Final figures\ExtDataFig2.pdf", replace
	*	graph export ".\Revisions_Nature\Final figures\ExtDataFig2.eps", replace
	*	graph export ".\Revisions_Nature\Final figures\ExtDataFig2.png", replace




order titletext
 gsort- vnum
 
 rename titletext topic
 	label variable N_g "Number of helplines"

 
 preserve
keep  N topic Tpremean1 Tpremean2 Tpremean3 Tpremean4 Tpremean5 Tpremean6 Tpremean_male_age3 Tpremean_male_age2 Tpremean_male_age1 Tpremean_female_age3 Tpremean_female_age2 Tpremean_female_age1 N_g
order topic  Tpremean1 Tpremean2 Tpremean3 Tpremean4 Tpremean5 Tpremean6 N N_g Tpremean_male_age3 Tpremean_male_age2 Tpremean_male_age1 Tpremean_female_age3 Tpremean_female_age2 Tpremean_female_age1
 export excel using ".\Revisions_Nature\Final figures\Fig2_SourceData.xlsx", firstrow(varlabels) sheet("Panel a") replace

restore
 
 preserve
keep topic coef stderr ci_lower ci_upper N N_g equivtlevel equivtlevelneg N
order  topic coef stderr ci_lower ci_upper N N_g equivtlevel equivtlevelneg N
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig2_SourceData.xlsx", firstrow(varlabels) sheet("Panel a") replace
 
restore
 
preserve
 keep topic coef_stdzd stderr_stdzd ci_lower_stdzd ci_upper_stdzd equivtlevel_stdzd equivtlevelneg_stdzd N N_g
order topic coef_stdzd stderr_stdzd ci_lower_stdzd ci_upper_stdzd equivtlevel_stdzd equivtlevelneg_stdzd N N_g
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig2_SourceData.xlsx", firstrow(varlabels) sheet("Panel b") sheetreplace
restore 


replace stderr = stderr *100
keep topic coef ci_lower ci_upper N N_g stderr equivtlevel eqtest_t1 eqtest_t2 eqtest_p1 eqtest_p2 eqtest_result
order topic  coef ci_lower ci_upper stderr equivtlevel eqtest_t1 eqtest_t2 eqtest_p1 eqtest_p2 eqtest_result N N_g

 export excel using ".\Revisions_Nature\Final figures\ExtDataFig2_SourceData.xlsx", firstrow(varlabels) sheet("Equivalence test results") sheetreplace




 
use "$rawdata\cplotI.dta", clear
keep if model == "fullyinteracted"

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
gen ppm_`T' =  Tpremean if depvartitel == "`T'"
sort ppm_`T'
replace ppm_`T' = ppm_`T'[1]
tostring ppm_`T' , gen(ppm_`T'_string) format(%9.2f) force
local ppm_`T'= ppm_`T'_string[1]
display "`ppm_`T''"
}



di invnormal(0.975)
di invnormal(0.95)
di invnormal(0.995)
gen ci90_lower = coef-invnormal(0.95)*(stderr)
gen ci95_lower = coef-invnormal(0.975)*(stderr)
gen ci99_lower = coef-invnormal(0.995)*(stderr)

gen ci90_upper = coef+invnormal(0.95)*(stderr)
gen ci95_upper = coef+invnormal(0.975)*(stderr)
gen ci99_upper = coef+invnormal(0.995)*(stderr)

gen vnum = .

replace vnum = 13 if  var == "female_age1" 
replace vnum = 11 if var == "female_age2" 	
replace vnum = 9 if var == "female_age3" 		
replace vnum = 7  if var == "male_age1"	
replace vnum = 5  if var == "male_age2"  
replace vnum = 3 if  var == "male_age3" 	
	
replace vnum = 25 if  var == "post_female_age1" 
replace vnum = 23 if var == "post_female_age2" 	
replace vnum = 21 if var == "post_female_age3" 
replace vnum = 19  if var == "post_male_age1" 	
replace vnum = 17  if var == "post_male_age2" 	
replace vnum = 15 if  var == "post_male_age3" 	

keep if vnum > 14 & vnum != .
gen zero = 0


foreach V of varlist coef ci_upper ci_lower {
replace `V' = `V' * 100
}



replace titletext =  "{bf:c}         Fears (incl. of infection)"  if depvartitel ==  "fears"
replace titletext =  "{bf:d}          Loneliness"                if depvartitel ==  "lonely"
replace titletext =  "{bf:e}         Suicidality"      if depvartitel == "suicide"
replace titletext =  "{bf:f}           Addiction"         if depvartitel ==  "addiction"
replace titletext =  "{bf:g}         Violence"         if depvartitel ==  "violence"
replace titletext =  "{bf:h}          Physical health"    if depvartitel ==  "physhealth"
replace titletext =  "{bf:i}           Livelihood"      if depvartitel ==  "T_econ"
replace titletext =  "{bf:j}           Relationships"      if depvartitel ==  "T_social"


replace titletext =  "{bf:c}"  if depvartitel ==  "fears"
replace titletext =  "{bf:d}"           if depvartitel ==  "lonely"
replace titletext =  "{bf:e}" if depvartitel == "suicide"
replace titletext =  "{bf:f}"    if depvartitel ==  "addiction"
replace titletext =  "{bf:g}" if depvartitel ==  "violence"
replace titletext =  "{bf:h}"    if depvartitel ==  "physhealth"
replace titletext =  "{bf:i}"  if depvartitel ==  "T_econ"
replace titletext =  "{bf:j}"     if depvartitel ==  "T_social"

gen topictext = ""
replace topictext =  "Fears (incl. of infection)"  if depvartitel ==  "fears"
replace topictext =  "Loneliness"                if depvartitel ==  "lonely"
replace topictext =  "Suicidality"      if depvartitel == "suicide"
replace topictext =  "Addiction"         if depvartitel ==  "addiction"
replace topictext =  "Violence"         if depvartitel ==  "violence"
replace topictext =  "Physical health"    if depvartitel ==  "physhealth"
replace topictext =  "Livelihood"      if depvartitel ==  "T_econ"
replace topictext =  "Relationships"      if depvartitel ==  "T_social"



foreach T in fears suicide addiction T_econ lonely violence physhealth T_social {
cap drop titletemp_`T'
gen titletemp_`T' = titletext if depvartitel == "`T'"
gsort -titletemp_`T'
local titletext = titletemp_`T'[1] 
display "`titletext'"
cap drop topictemp_`T'
gen topictemp_`T' = topictext if depvartitel == "`T'"
gsort -topictemp_`T'
local topictext = topictemp_`T'[1] 
display "`topictext'"
# delimit ;
graph twoway  rbar  zero coef vnum if depvartitel == "`T'", horizontal bcolor(edkbg) lcolor(ebg) barwidth(1.5)
		  || rcap  ci_lower ci_upper vnum if depvartitel == "`T'"  &  var  == "post_female_age1" ,horizontal lcolor(dkorange*0.7)	 lwidth(medium) 
		  || rcap  ci_lower ci_upper vnum if depvartitel == "`T'"  &  var  == "post_female_age2" ,horizontal lcolor(dkorange)	 lwidth(medium) 
		  || rcap  ci_lower ci_upper vnum if depvartitel == "`T'"  &  var  == "post_female_age3" ,horizontal lcolor(dkorange*1.3)	 lwidth(medium) 
		  || rcap  ci_lower ci_upper vnum if depvartitel == "`T'"  &  var  == "post_male_age1" ,horizontal lcolor(blue*0.7) lwidth(medium) 
		  || rcap  ci_lower ci_upper vnum if depvartitel == "`T'"  &  var  == "post_male_age2" ,horizontal lcolor(blue)	 lwidth(medium)
		  || rcap  ci_lower ci_upper vnum if depvartitel == "`T'"  &  var  == "post_male_age3" ,horizontal lcolor(blue*1.5) lwidth(medium)
		  || scatter  vnum coef if depvartitel == "`T'"  &  var  == "post_female_age1" , mc(dkorange*0.7)	 m(d) msize(medium)
		  || scatter  vnum coef if depvartitel == "`T'"  &  var  == "post_female_age2" , mc(dkorange)	 m(d) msize(medium)
		  || scatter  vnum coef if depvartitel == "`T'"  &  var  == "post_female_age3" , mc(dkorange*1.3)	 m(d) msize(medium)
		  || scatter  vnum coef if depvartitel == "`T'"  &  var  == "post_male_age1" , mc(blue*0.7)	 m(d) msize(medium)
		  || scatter  vnum coef if depvartitel == "`T'"  &  var  == "post_male_age2" , mc(blue)	 m(d) msize(medium)
		  || scatter  vnum coef if depvartitel == "`T'"  &  var  == "post_male_age3" , mc(blue*1.5)	 m(d) msize(medium)
				scheme(s2color) legend(off)   
		graphregion(color(white)) plotregion(color(white)  margin(medsmall)) bgcolor(white) 
				xtitle("Percentage-points", size(small)) ytitle("")  
		subtitle("  `topictext'", size(medsmall) color(gs0) pos(12) ring(1) span justification(center))  
		note("N = `N_`T'' calls" "(`N_g_`T'' helplines)", pos(5) ring(1) span justification(right) size(small))
		ylabel(19 "M:   0-30" 17 "30-60" 15 "60+" 25 "F:   0-30" 23 "30-60" 21 "60+"  , labcolor(gs0) angle(horizontal) labsize(small) axis(1) nogrid ) 
		yscale(range(15 25))
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		xlabel(-6(2)4, labsize(small) labcolor(gs0) )	
		name(grci_`T' , replace) ;
# delimit cr
}
	*	fysize(30)		title("  `titletext'", size(medium) color(gs0) pos(11) ring(1) span justification(left))  



# delimit ;
graph combine grci_fears grci_lonely grci_suicide grci_addiction grci_violence grci_physhealth grci_T_econ grci_T_social ,  name(gryx,replace)
	imargin(small) cols(4)   	graphregion(color(white)  margin(vsmall))  	;
# delimit cr

		graph export ".\02_Project\Figures\ExtDataFig_sexage.pdf", replace
		graph export ".\Revisions_Nature\Final figures\ExtDataFig_sexage.pdf", replace
 
/*
graph combine coefGplotMppm  coefpMr, imargin(small)  graphregion(color(white)  margin(vsmall))  name(gryee,replace) fysize(40)

		
# delimit ;
graph combine grci_fears grci_lonely grci_suicide grci_addiction grci_violence grci_physhealth grci_T_econ grci_T_social ,  name(gryx,replace)
	imargin(small) cols(4)   	graphregion(color(white)  margin(vsmall))  	;
# delimit cr
# delimit ;

graph combine gryee gryx , 	imargin(small) cols(1) graphregion(color(white)  margin(vsmall))  	 xsize(18.3cm) ysize(14.5cm) ;

# delimit cr
*/

		
 
	gen topic = substr(titletext,-17,.)
	replace topic = trim(topic)
	replace topic = "Fear (in" + topic if topic == "cl. of infection)"
	label variable N_g "Number of helplines"
	gen panel = substr(titletext,5,1)
gen sex = "female" if substr(var,1,11) ==  "post_female"
replace sex = "male" if substr(var,1,9) ==  "post_male"
gen age = "0-30" if substr(var,-4,4)  == "age1"
replace age = "30-60" if substr(var,-4,4)  == "age2"
replace age = "60+" if substr(var,-4,4)  == "age3"
sort panel
keep coef topic sex age  stderr ci_lower ci_upper N N_g panel
order panel topic sex age  coef  stderr ci_lower ci_upper N N_g 
 export excel using ".\Revisions_Nature\Final figures\Fig2_SourceData.xlsx", firstrow(varlabels) sheet("Panels c-j") sheetreplace

 
 




