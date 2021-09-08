
use "$rawdata\merged_series.dta", clear


gen knownrepshare = contacts_repcall/helplinecontacts

xtline MA7knownrepshare if HCcode != "GER1" 
mvsumm knownrepshare, gen(MA7knownrepshare) stat(mean) window(7) force
keep if ddate<mdy(1,28,2021)

# delimit ;
twoway  line MA7knownrepshare ddate if HCcode == "GER2", lcolor(plb1) lpattern(solid) yaxis(1) lwidth(medthick) 
		|| line MA7knownrepshare ddate if HCcode == "GER3", lcolor(plg1) lpattern(solid) yaxis(1) lwidth(medthick)
		|| line MA7knownrepshare ddate if HCcode == "BEL", lcolor(ply1) lpattern(solid) yaxis(1) lwidth(medthick)
		|| line MA7knownrepshare ddate if HCcode == "ISR", lcolor(pll1) lpattern(solid) yaxis(1) lwidth(medthick)
		|| line MA7knownrepshare ddate if HCcode == "LBN", lcolor(plb2) lpattern(solid) yaxis(1) lwidth(medthick)
		|| line MA7knownrepshare ddate if HCcode == "CHN", lcolor(plg2) lpattern(solid) yaxis(1) lwidth(medthick)
		scheme(s2color) 
		legend(label(1 "GER2" )  order(4 2 1) cols(1)  pos(7) ring(1) colfirst size(medsmall)  colgap(30) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Known repeat callers (share)", xoffset(0) axis(1) size(medsmall) color(gs0) )	
		ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		yscale( axis(1) titlegap(0))
		xtitle("", yoffset(-2)) 
 		xlabel( , labsize(medsmall) labcolor(gs0) format(%tdMon_CCYY)) 
		xsize(6) ysize(3);
# delimit cr
graph export ".\02_Project\Figures\recallshares.pdf", replace


use "$rawdata\merged_contacts_postestimation.dta",  clear


keep if mainsample1 == 1

egen maintopicsum = rowtotal(fears lonely suicide addiction violence  physhealth T_econ T_social )
 
sum  maintopicsum 
gen nobs = r(N) 
tostring nobs , gen(nobs_string) format(%12.0fc) force


tab HCcode if maintopicsum !=.
gen nhl = r(r) 
tostring nhl , gen(nhl_string) format(%12.0fc) force

local N_calls= nobs_string[1]
local N_hl= nhl_string[1]
display "`N_calls'"
display "`N_hl'"

# delimit ;
hist maintopicsum if maintopicsum>0, d bcolor(edkbg) lcolor(edkbg) lwidth(medthick)
 title("{bf: b} ", justification(left)  size(vlarge) 	margin(small) color(gs0) pos(11) ring(1) span )  
 xtitle("Non-exclusive topics/call", size(vlarge)) 
 ytitle("Share of calls", size(vlarge)) note("N=`N_calls' calls" "(`N_hl' helplines)", pos(5) justification(left) ring(1)  size(large))
 scheme(s1mono) graphregion(color(white) lwidth(thick)) plotregion(color(white) ) 
 ylabel(0(0.2).6, nogrid angle(horizontal) labsize(vlarge) 	 format(%9.1f)) 
 xlabel(1(1)8, labsize(vlarge)  nogrid) fxsize(90)
 name(grc1, replace) ;
# delimit cr

 
 
 foreach V of varlist fears lonely suicide addiction violence  physhealth T_econ T_social  {
tabstat fears lonely suicide addiction violence  physhealth T_econ T_social, statistics(mean) by(`V') save
matrix C`V' = (r(Stat2))
matrix list  C`V'
}


matrix C = (Cfears \ Clonely \ Csuicide \ Caddiction \ Cviolence \ Cphyshealth \ CT_econ \ CT_social)
matrix rownames C =  "Fears==1"  "Loneliness==1"  "Suicidality==1"  "Addiction==1" "Violence==1"  "Physical health==1"  "Livelihood==1"  "Relationships==1"
matrix colnames C =  "Fears"  "Loneliness"  "Suicidality"  "Addiction" "Violence"  "Physical health"  "Livelihood"  "Relationships" 


 foreach V in fears lonely suicide addiction violence  physhealth T_econ T_social  {
sum `V' if `V' == 1
gen N`V' = r(N)
tostring N`V' , gen(N_`V'_string) format(%12.0fc) force
}


foreach V in fears lonely suicide addiction violence  physhealth T_econ T_social  {
local N_`V'= N_`V'_string[1]
display "`N_`V''"
}
# delimit ;
heatplot C, values(format(%9.2fc)) legend(off) aspectratio(1) scheme(s1mono) nodiag
		graphregion(color(white) margin(vsmall) lwidth(medium)) plotregion(color(white)   margin(small))
		xtitle("", size(medsmall))	ytitle("", size(medsmall)) 
		 title("{bf: a} ", justification(left) size(medsmall) 	
		 margin(small) color(gs0) pos(11) ring(1) span )
		 xlabel(, angle(45) labsize(medsmall) nogrid	)
		 text(1 10 "`N_fears'", placement(west) size(small))
		 text(2 10 "`N_lonely'", placement(west) size(small))
		 text(3 10 "`N_suicide'", placement(west) size(small))
		 text(4 10 "`N_addiction'", placement(west) size(small))
		 text(5 10 "`N_violence'", placement(west) size(small))
		 text(6 10 "`N_physhealth'", placement(west) size(small))
		 text(7 10 "`N_T_econ'", placement(west) size(small))
		 text(8 10 "`N_T_social'", placement(west) size(small))
		 text(0.2 9.5 "N", placement(west) size(small))
		 ylabel(,  labsize(medsmall) nogrid	) name(grc2, replace) 
		colors(plasma)   cuts(-0.15(0.05)0.4)  ;
# delimit cr		

				graph export ".\02_Project\Figures\heatplot_corrtopics.pdf", replace
				
graph combine    grc1 coefpMrEXCLcomp, scheme(s1mono) imargin(small)  cols(2) xsize(10) ysize(4)  graphregion(color(white) lwidth(medium) ) plotregion(color(white) margin(zero) ) name(grc3, replace)  
				graph export ".\02_Project\Figures\corrtopics.pdf", replace

	
	
	
	




use "$rawdata\merged_contacts.dta",  clear


bysort HCcode: egen mrcall =  mean(repcall)
gen knownrepcall = 0 if mrcall != .
replace knownrepcall = 1 if repcall == 1
replace knownrepcall = . if year == 2020 & HCcode == "GER1"
replace knownrepcall = . if HCcode == "GER1"

foreach V of varlist female age1 age2 age3 phone knownrepcall  {
bysort HCcode: egen share_`V' = mean(`V')
bysort HCcode: egen prepanshare_`V' = mean(`V') if ddate<mdy(3,1,2020)
bysort HCcode: egen postpanshare_`V' = mean(`V') if ddate>mdy(3,1,2020)
}

gen helplinecontacts = 1
fcollapse (firstnm) country helplinename  share_* postpanshare_* prepanshare* (count) helplinecontacts , by(HCcode)




tostring helplinecontacts , gen(helplinecontacts_string) format(%12.0fc) force

gen hphlcode = .
replace hphlcode = 1 if HCcode == "GER1"
replace hphlcode = 2 if HCcode == "FRA"
replace hphlcode = 3 if HCcode == "NLD"
replace hphlcode = 4 if HCcode == "GER2"
replace hphlcode = 5 if HCcode == "BEL"
replace hphlcode = 6 if HCcode == "ITA"
replace hphlcode = 7 if HCcode == "AUT"
replace hphlcode = 8 if HCcode == "SVN"
replace hphlcode = 9 if HCcode == "GER3"
replace hphlcode = 10 if HCcode == "CHN"
replace hphlcode = 11 if HCcode == "ISR"
replace hphlcode = 12 if HCcode == "LBN"
					

gsort -helplinecontacts					
keep if hphlcode !=.					
					
foreach V of varlist prepanshare_female postpanshare_female prepanshare_age1	postpanshare_age1 prepanshare_age2 postpanshare_age2 prepanshare_age3 postpanshare_age3 prepanshare_phone postpanshare_phone prepanshare_knownrepcall postpanshare_knownrepcall   {
	gen `V'_r = round(`V',0.01)
tostring `V'_r, gen(`V'_string) 	format(%9.2fc) force
}					
					
order	country helplinename	 prepanshare_female_string postpanshare_female_string prepanshare_age1_string	postpanshare_age1_string prepanshare_age2_string postpanshare_age2_string prepanshare_age3_string postpanshare_age3_string prepanshare_phone_string postpanshare_phone_string prepanshare_knownrepcall_string postpanshare_knownrepcall_string     
					
					
					
					
					
					
foreach V in female age1 age2 age3 phone knownrepcall  {
gen pandiffshare_`V' = postpanshare_`V'-prepanshare_`V' 
}
					
					
					
					
					
					
					
					
					
					
					
					
					


use "$rawdata\merged_contacts.dta",  clear

sum chat phone mail

tab firstcall

bysort HCcode: egen mrcall =  mean(repcall)

gen knownrepcall = 0 if mrcall != .
replace knownrepcall = 1 if repcall == 1
replace knownrepcall = . if year == 2020 & HCcode == "GER1"
replace knownrepcall = . if HCcode == "GER1"

	bysort HCcode: sum firstcall habitcall repcall knownrepcall 

gen hphlcode = .
replace hphlcode = 1 if HCcode == "GER1"
replace hphlcode = 2 if HCcode == "FRA"
replace hphlcode = 3 if HCcode == "NLD"
replace hphlcode = 4 if HCcode == "GER2"
replace hphlcode = 5 if HCcode == "BEL"
replace hphlcode = 6 if HCcode == "ITA"
replace hphlcode = 7 if HCcode == "AUT"
replace hphlcode = 8 if HCcode == "SVN"
replace hphlcode = 9 if HCcode == "GER3"
replace hphlcode = 10 if HCcode == "CHN"
replace hphlcode = 11 if HCcode == "ISR"
replace hphlcode = 12 if HCcode == "LBN"

foreach j of numlist 1/12  {
sum hphlcode if hphlcode == `j'
gen N`j' = r(N)
tostring N`j' , gen(N_`j'_string) format(%12.0fc) force
}

					
					
	tabstat fears lonely suicide addiction violence  physhealth T_econ T_social , statistics(mean) by(hphlcode) save
matrix C = (r(Stat1) \ r(Stat2) \ r(Stat3)  \ r(Stat4)  \ r(Stat5)  \ r(Stat6)  \ r(Stat7)  \ r(Stat8) \ r(Stat9) \ r(Stat10) \ r(Stat11)  \ r(Stat12) \ r(StatTotal))
matrix rownames C = `r(name1)' `r(name2)' `r(name3)'  `r(name4)'  `r(name5)'  `r(name6)'  `r(name7)'  `r(name8)'  `r(name9)'  `r(name10)'   `r(name11)'  `r(name12)'   Average
matrix colnames C =  "Fears"  "Loneliness"  "Suicidality"  "Addiction" "Violence"  "Physical health"  "Livelihood"  "Relationships"
matrix rownames C = "Germany (Telefonseelsorge)" "France (SOS Amitié)"  "Netherlands (De Luisterlijn)" "Germany (NgK children line)" "Belgium (Tele-Onthaal)" "Italy (Telefono Amico)" "Austria (Telefonseelsorge)" "Slovenia (Zaupni Samarijan)" "Germany (NgK parents line)" "China (Hope 24)" "Israel (SAHAR)" "Lebanon (Embrace Lifeline)" "Average"

foreach j of numlist 1/12  {
local N_`j'= N_`j'_string[1]
display "`N_`j''"
}
local N_tot=Ntot_string[1]
display "`N_tot'"

# delimit ;
heatplot C, values(format(%9.2f)) legend(off) aspectratio(1.2) scheme(s1mono)
		graphregion(color(white) margin(medsmall) lwidth(medium)) plotregion(color(white)  margin(small))
		 text(0.2 10 "N", placement(west) size(small))
		 text(1 10.5 "`N_1'", placement(west) size(small))
		 text(2 10.5 "`N_2'", placement(west) size(small))
		 text(3  10.5 "`N_3 '", placement(west) size(small))
		 text(4  10.5 "`N_4 '", placement(west) size(small))
		 text(5  10.5 "`N_5 '", placement(west) size(small))
		 text(6  10.5 "`N_6 '", placement(west) size(small))
		 text(7  10.5 "`N_7 '", placement(west) size(small))
		 text(8  10.5 "`N_8 '", placement(west) size(small))
		 text(9  10.5 "`N_9 '", placement(west) size(small))
		 text(10 10.5 "`N_10'", placement(west) size(small))
		 text(11 10.5 "`N_11'", placement(west) size(small))
		 text(12 10.5 "`N_12'", placement(west) size(small))
		 text(13 10.5 "`N_tot'", placement(west) size(small))
		 xlabel(, angle(45) labsize(small) nogrid	) 
		 ylabel(,  labsize(small) nogrid	) name(grc1, replace) 
		colors(plasma)    cuts(-0.15(0.05)0.4) ;
# delimit cr		

					graph export ".\02_Project\Figures\heatplot_HCtopics.pdf", replace
					
					
	tabstat female age1 age2 age3 phone  knownrepcall , statistics(mean) by(hphlcode) save
matrix C = (r(Stat1) \ r(Stat2) \ r(Stat3)  \ r(Stat4)  \ r(Stat5)  \ r(Stat6)  \ r(Stat7)  \ r(Stat8) \ r(Stat9) \ r(Stat10) \ r(Stat11)  \ r(Stat12) \ r(StatTotal))
matrix rownames C = `r(name1)' `r(name2)' `r(name3)'  `r(name4)'  `r(name5)'  `r(name6)'  `r(name7)'  `r(name8)'  `r(name9)'  `r(name10)'   `r(name11)'  `r(name12)'   Average
matrix colnames C =  "Female"  "Age 0-30"  "Age 30-60"  "Age 60+" "Voice call"  "Known repeat caller" 
matrix rownames C = "Germany (Telefonseelsorge)" "France (SOS Amitié)"  "Netherlands (De Luisterlijn)" "Germany (NgK children line)" "Belgium (Tele-Onthaal)" "Italy (Telefono Amico)" "Austria (Telefonseelsorge)" "Slovenia (Zaupni Samarijan)" "Germany (NgK parents line)" "China (Hope 24)" "Israel (SAHAR)" "Lebanon (Embrace Lifeline)" "Average"


sum hphlcode
gen Ntot = r(N)
tostring Ntot , gen(Ntot_string) format(%12.0fc) force

foreach j of numlist 1/12  {
local N_`j'= N_`j'_string[1]
display "`N_`j''"
}
local N_tot=Ntot_string[1]
display "`N_tot'"

# delimit ;
heatplot C, values(format(%9.2f)) legend(off) aspectratio(1.2) scheme(s1mono)
		graphregion(color(white) margin(medsmall) lwidth(medium)) plotregion(color(white)  margin(small))
		 text(0.2 7.5 "N", placement(west) size(small))
		 text(1 8 "`N_1'", placement(west) size(small))
		 text(2 8 "`N_2'", placement(west) size(small))
		 text(3  8 "`N_3 '", placement(west) size(small))
		 text(4  8 "`N_4 '", placement(west) size(small))
		 text(5  8 "`N_5 '", placement(west) size(small))
		 text(6  8 "`N_6 '", placement(west) size(small))
		 text(7  8 "`N_7 '", placement(west) size(small))
		 text(8  8 "`N_8 '", placement(west) size(small))
		 text(9  8 "`N_9 '", placement(west) size(small))
		 text(10 8 "`N_10'", placement(west) size(small))
		 text(11 8 "`N_11'", placement(west) size(small))
		 text(12 8 "`N_12'", placement(west) size(small))
		 text(13 8 "`N_tot'", placement(west) size(small))
		 xlabel(, angle(45) labsize(small) nogrid	) 
		 ylabel(,  labsize(small) nogrid	) name(grc1, replace) 
		colors(plasma)   cuts(-0.3(0.1)1) ;
# delimit cr		
					graph export ".\02_Project\Figures\heatplot_HCchars.pdf", replace


					
	reghdfe firstcall postoutbreak if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1) nocons vce($SE1) 

		reghdfe duration postoutbreak if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1) nocons vce($SE1) 
	reghdfe age postoutbreak if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1) nocons vce($SE1) 

		reghdfe female postoutbreak if female !=. & age1 !=. & age2 !=. & age3 !=. , absorb($FE1) nocons vce($SE1) 


		gen helplinecontacts = 1
		drop if hphlcode == .
		
		
		fcollapse (sum) helplinecontacts firstcall repcall habitcall  (mean) knownrepcall, by(hphlcode ddate)
					
					
