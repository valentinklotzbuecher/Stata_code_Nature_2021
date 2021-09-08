
 frame reset

use "$rawdata\merged_contacts_estimation.dta",  clear

 egen maintopicsum = rowtotal(fears lonely suicide addiction violence  physhealth T_econ T_social )
 sum maintopicsum
 tab maintopicsum, m

keep if maintopicsum < 2

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
gen insample_fearsx = (e(sample) == 1)
sum fears  if e(sample) == 1 & postoutbreak == 0
estadd scalar Tpremean = r(mean), replace
estadd scalar Tpresd = r(sd), replace
sum fears  if e(sample) == 1 & postoutbreak == 1
estadd scalar Tpostmean = r(mean), replace
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
est store plx_fears
local titletext: variable label fears
display "`titletext'"
frame create eresults
 regsave using "$rawdata\cplotM_excl.dta", ci level(95) addlabel(depvartitel, fears, titletext, "`titletext'") detail(all) replace
frame change default

foreach T in $topicdummies {
reghdfe `T'  postoutbreak  if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1)  nocons vce($SE1) 
gen insample_`T'x  = (e(sample) == 1)
sum `T'  if e(sample) == 1 & postoutbreak == 0
estadd scalar Tpremean = r(mean), replace
sum `T'  if e(sample) == 1 & postoutbreak == 1
estadd scalar Tpostmean = r(mean), replace
tab helplinename if e(sample) == 1
estadd scalar N_g = r(r), replace
est store plx_`T'
local titletext: variable label `T'
display "`titletext'"
frame eresults: regsave using "$rawdata\cplotM_excl.dta", ci level(95) addlabel(depvartitel, `T', titletext, "`titletext'") detail(all) append
}




# delimit ;
estout plx_fears plx_lonely  plx_suicide plx_addiction plx_violence  plx_physhealth  plx_T_econ plx_T_social
 using ".\02_Project\tables\RESULTS_F2aCI_excl.txt", replace style(tex) type
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
  starlevels(\mbox{*} 0.10 \mbox{**} 0.050 \mbox{***} 0.010)  
  label lz dmarker(".")
  prehead("\renewcommand{\arraystretch}{0.8}  \setlength{\tabcolsep}{0.2cm}
	\begin{sidewaystable}[ht!]"
		"\caption{Changing conversation topics following the pandemic outbreak \label{RESULTS_F2_excl}}\footnotesize"
		"\begin{tabular}{p{5cm} cccccccc}\toprule"
		 "\textbf{a)}& \multicolumn{1}{c}{(1) Fear}& \multicolumn{1}{c}{(2) Loneliness}& \multicolumn{1}{c}{(3) Suicidality} & \multicolumn{1}{c}{(4) Addiction} & \multicolumn{1}{c}{(5) Violence} & \multicolumn{1}{c}{(6) Phys. Health}  & \multicolumn{1}{c}{(7) Livelihood}  & \multicolumn{1}{c}{(8) Relationships}  \\\cmidrule(lr){2-2}\cmidrule(lr){3-3}\cmidrule(lr){4-4}\cmidrule(lr){5-5}\cmidrule(lr){6-6}\cmidrule(lr){2-2}\cmidrule(lr){7-7}\cmidrule(lr){8-8}\cmidrule(lr){9-9}")
		  postfoot("\bottomrule\\
		\end{tabular}"			
			"\\\footnotesize \textbf{Note:} Separate linear probability models, dependent variable is equal to one for calls related to the respective category. Estimated coefficients with 95\% confidence intervals in brackets. The sample includes all calls during the time from 1 January 2019 to 30 June 2020. \textbf{a)} Average change post-outbreak, \textbf{b)} fully interacted model.                   Models include helpline fixed effects, interacted with year, week-of-year and day-of-week indicators, standard errors are clustered at the helpline-week level. See Methods, equations  \ref{eq:did} and \ref{eq:intac}.\\         \end{sidewaystable}");
# delimit cr
		 




use "$rawdata\cplotM_excl.dta", clear

gen exclusive = 1 

append using "$rawdata\cplotM.dta"

replace exclusive = 0 if exclusive == .



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

foreach V of varlist coef {
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
gen N_`T' =  N if depvartitel == "`T'" & exclusive == 0
sort N_`T'
replace N_`T' = N_`T'[1]
tostring N_`T' , gen(N_`T'_string) format(%12.0fc) force
local N_`T'= N_`T'_string[1]
display "`N_`T''"
gen N_g_`T' =  N_g if depvartitel == "`T'" & exclusive == 0
sort N_g_`T'
replace N_g_`T' = N_g_`T'[1]
tostring N_g_`T' , gen(N_g_`T'_string) format(%12.0fc) force
local N_g_`T'= N_g_`T'_string[1]
display "`N_g_`T''"
gen Nx_`T' =  N if depvartitel == "`T'" & exclusive == 1
sort Nx_`T'
replace Nx_`T' = Nx_`T'[1]
tostring Nx_`T' , gen(Nx_`T'_string) format(%12.0fc) force
local Nx_`T'= Nx_`T'_string[1]
display "`Nx_`T''"
gen Nx_g_`T' =  N_g if depvartitel == "`T'" & exclusive == 1
sort Nx_g_`T'
replace Nx_g_`T' = Nx_g_`T'[1]
tostring Nx_g_`T' , gen(Nx_g_`T'_string) format(%12.0fc) force
local Nx_g_`T'= Nx_g_`T'_string[1]
display "`Nx_g_`T''"
}


replace vnum = . if depvartitel ==  "othertopic"
replace vnum = vnum +0.2 if  exclusive == 0
replace vnum = vnum -0.2 if  exclusive



gen Tpremean1 = Tpremean_female_age1  
gen Tpremean2 = Tpremean_female_age2 + Tpremean1 
gen Tpremean3 = Tpremean_female_age3 + Tpremean2 
gen Tpremean4 = Tpremean_male_age1 + Tpremean3
gen Tpremean5 = Tpremean_male_age2 + Tpremean4
gen Tpremean6 = Tpremean_male_age3 + Tpremean5

foreach V of varlist coef ci_upper ci_lower Tpremean* {
replace `V' = `V' * 100
}

# delimit ;
graph twoway  rbar  zero coef vnum if  exclusive == 0 , horizontal bcolor(edkbg) lcolor(edkbg) barwidth(0.4)
		  ||  rbar  zero coef vnum if  exclusive == 1, horizontal bcolor(ebg) lcolor(ebg) barwidth(0.4)
		  ||  rcap ci_upper ci_lower vnum if  exclusive == 0 , horizontal  color(gs0) lwidth(medthin) msize(small)
		  ||  rcap ci_upper ci_lower vnum if  exclusive == 1, horizontal  color(gold) lwidth(medthin) msize(small)
		  || scatter  vnum coef if  exclusive == 0 ,  mc(gs0)  m(d) msize(small)
		  || scatter  vnum coef if  exclusive == 1,  mc(gold)  m(d) msize(small)
				scheme(s1color ) legend(label(3 "Full sample") label(4 "Single-topic calls")  order(3 4) region(lcolor(white)) size(small) pos(6) ring(1) cols(2)) 
				text(9 4 "N",  size(vsmall) placement(east))
				text(8.2 3.5 "`N_fears'",  size(vsmall) placement(east))
				text(7.8 3.5 "`Nx_fears'", size(vsmall) placement(east))
				text(7.2 3.5 "`N_lonely'", size(vsmall) placement(east))
				text(6.8 3.5 "`Nx_lonely'", size(vsmall) placement(east))
				text(6.2 3.5  "`N_suicide'", size(vsmall) placement(east))
				text(5.8 3.5 "`Nx_suicide'", size(vsmall) placement(east))
				text(5.2 3.5  "`N_addiction'", size(vsmall) placement(east))
				text(4.8 3.5 "`Nx_addiction'", size(vsmall) placement(east))
				text(4.2 3.5  "`N_violence'", size(vsmall) placement(east))
				text(3.8 3.5 "`Nx_violence'", size(vsmall) placement(east))
				text(3.2 3.5  "`N_physhealth'", size(vsmall) placement(east))
				text(2.8 3.5 "`Nx_physhealth'", size(vsmall) placement(east))
				text(2.2 3.5  "`N_T_econ'", size(vsmall) placement(east))
				text(1.8 3.5 "`Nx_T_econ'", size(vsmall) placement(east))
				text(1.2 3.5  "`N_T_social'", size(vsmall) placement(east))
				text(0.8 3.5 "`Nx_T_social'", size(vsmall) placement(east))
		graphregion(color(white) margin(large)) plotregion(color(white)  margin(small)) bgcolor(white) 
		xtitle("Post-outbreak change (percentage-points)", size(small)) ytitle("")  
		title("{bf: c}", size(small) color(gs0) pos(11)  span justification(left) margin(bottom) ) 
		xline(0, lcolor(edkbg) lwidth(thin) lpattern(solid))
		ylabel(6 "Suicidality" 8 "Fears (incl. infection)" 7 "Loneliness" 5 "Addiction" 4 "Violence" 3 "Physical health" 2 "Livelihood" 1 "Relationships", labsize(small) labcolor(gs0) nogrid  angle(horizontal))
		xlabel(-3(1)3, labsize(small) labcolor(gs0) ) 	xscale(range(-3 5)) fxsize(90)  fysize(45)
		name(coefpMrEXCLcomp, replace)   ;
# delimit cr

	gen topic = titletext
	label variable N_g "Number of helplines"
gsort -vnum
keep coef topic exclusive  stderr ci_lower ci_upper N N_g 
order  topic exclusive  coef  stderr ci_lower ci_upper N N_g 
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig5_SourceData.xlsx", firstrow(varlabels) sheet("Panel c") replace


		
			

use "$rawdata\merged_contacts_postestimation.dta",  clear


egen maintopicsum = rowtotal(fears lonely suicide addiction violence  physhealth T_econ T_social )
sum  maintopicsum if maintopicsum>0
gen nobs = r(N) 
tostring nobs , gen(nobs_string) format(%12.0fc) force

tab HCcode if maintopicsum>0
gen nhl = r(r) 
tostring nhl , gen(nhl_string) format(%12.0fc) force

local N_calls= nobs_string[1]
local N_hl= nhl_string[1]
display "`N_calls'"
display "`N_hl'"

tab maintopicsum if maintopicsum>0

# delimit ;
hist maintopicsum if maintopicsum>0, d bcolor(edkbg) lcolor(edkbg) lwidth(medthick)
 title("{bf: a} ", justification(left)  size(medium) 	margin(small) color(gs0) pos(11) ring(1) span )  
 xtitle("Conversation topics/call", size(small)) 
 ytitle("Share of calls", size(small)) note("N=`N_calls' calls" "(`N_hl' helplines)", pos(5) justification(left) ring(1)  size(small))
 scheme(s1mono) graphregion(color(white) lwidth(thick) margin(bottom)) plotregion(color(white) margin(vsmall)) 
 ylabel(0(0.2).6, nogrid angle(horizontal) labsize(small) 	 format(%9.1f)) 
 xlabel(1(1)8, labsize(small)  nogrid) name(grc1, replace)  fxsize(90)  saving(".\02_Project\Figures\corrtopics.gph", replace);
# delimit cr


replace maintopicsum = . if maintopicsum==0
twoway__histogram_gen maintopicsum, gen(x y, replace) width(1) start(0) 

replace x = 18/1645422 if _n == 8
replace y = _n in 1/8

 foreach V of varlist fears lonely suicide addiction violence  physhealth T_econ T_social  {
tabstat fears lonely suicide addiction violence  physhealth T_econ T_social, statistics(mean) by(`V') save
matrix C`V' = (r(Stat2))
matrix list  C`V'
}


matrix C = (Cfears \ Clonely \ Csuicide \ Caddiction \ Cviolence \ Cphyshealth \ CT_econ \ CT_social)
matrix rownames C =  "Fears=1"  "Loneliness=1"  "Suicidality=1"  "Addiction=1" "Violence=1"  "Physical health=1"  "Livelihood=1"  "Relationships=1"
matrix colnames C =  "Fears"  "Loneliness"  "Suicidality"  "Addiction" "Violence"  "Phys_health"  "Livelihood"  "Relations" 


 foreach V in fears lonely suicide addiction violence  physhealth T_econ T_social  {
sum `V' if `V' == 1
gen N`V' = r(N)
tostring N`V' , gen(N_`V'_string) format(%12.0fc) force
}


foreach V in fears lonely suicide addiction violence  physhealth T_econ T_social  {
local N_`V'= N_`V'_string[1]
display "`N_`V''"
}


tab HCcode 
gen N_cx = r(N) 
tostring N_cx , gen(N_c_stringx) format(%12.0fc) force


local N_calls= N_c_stringx[1]


# delimit ;
heatplot C, values(format(%9.2fc)) legend(off) aspectratio(0.77) scheme(s1mono) nodiag
		graphregion(color(white) margin(vsmall) lwidth(medium)) plotregion(color(white)   margin(small))
		xtitle("", size(small))	ytitle("", size(small)) 
		 title("{bf: b} ", justification(left) size(medium) 	
		 margin(small) color(gs0) pos(11) ring(1) span ) note("N=`N_calls' calls (12 helplines)", pos(5) justification(left) ring(1)  size(small))
		 xlabel(, angle(45) labsize(small) nogrid	)
		 ylabel(,  labsize(small) nogrid	) name(grc2, replace) 
		colors(plasma)   cuts(-0.15(0.05)0.4) fxsize(150) ;
# delimit cr		


graph combine    grc1 grc2  , scheme(s1mono) imargin(small)  cols(2) xsize(8) ysize(4)  graphregion(color(white) lwidth(medium) ) plotregion(color(white) margin(zero) ) name(grc3, replace)  
	
				
graph combine    grc3 coefpMrEXCLcomp, scheme(s1mono) imargin(small)  cols(1)  xsize(6) ysize(5.2) graphregion(color(white) lwidth(medium) ) plotregion(color(white) margin(zero) ) saving(".\02_Project\Figures\corrtopics.gph", replace)

graph export ".\02_Project\Figures\corrtopics.pdf", replace

graph export ".\Revisions_Nature\Final figures\ExtDataFig5.pdf", replace


preserve

keep y x  nobs nhl
keep in 1/8
rename y n_topics
rename x density
rename nobs N
rename nhl N_g
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig5_SourceData.xlsx", firstrow(varlabels) sheet("Panel a") sheetreplace

restore

matrix colnames C =  "Fears"  "Loneliness"  "Suicidality"  "Addiction" "Violence"  "Phys_health"  "Livelihood"  "Relations" 

svmat C, names(col) 
keep Fears Loneliness Suicidality Addiction Violence Phys_health Livelihood Relations N_cx nhl
keep in 1/8
rename N_cx N
rename nhl N_g
gen topic1 = "Fears == 1" if _n == 1
replace topic1 = "Loneliness == 1" if _n == 2
replace topic1 = "Suicidality == 1" if _n ==3 
replace topic1 = "Addiction == 1" if _n ==4 
replace topic1 = "Violence == 1" if _n ==5 
replace topic1 = "Physical health == 1" if _n ==6 
replace topic1 = "Livelihood == 1" if _n ==7 
replace topic1 = "Relationships == 1" if _n ==8 
      
order topic1 Fears Loneliness Suicidality Addiction Violence Phys_health Livelihood N N_g
 export excel using ".\Revisions_Nature\Final figures\ExtDataFig5_SourceData.xlsx", firstrow(varlabels) sheet("Panel b") sheetreplace


 
	